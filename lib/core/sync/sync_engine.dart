import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../features/ticket/data/datasources/ticket_remote_datasource.dart';
import 'sync_handlers.dart';
import 'sync_store.dart';

/// Moteur de convergence : draine la file `SyncOutbox` vers Firestore.
///
/// Un cycle [runOnce] :
/// 1. vérifie la connectivité (fonction injectée — remplaçable en test) ;
/// 2. réclame ([SyncStore.claimDue]) les opérations dues (ordre d'ancienneté,
///    bascule `syncing` anti-course), les applique via [SyncHandlers] ;
/// 3. succès → `done` ; conflit CAS ([TicketStateConflictException]) →
///    `cancelled` + pull de réconciliation demandé via [onConflictPulled] ;
///    autre échec (réseau) → `failed` avec backoff ([SyncStore.markFailed]) ;
/// 4. purge les lignes réglées alors que les retries restent dus.
///
/// Aucun timer ici, aucune souscription : c'est le [SyncLifecycle] (lancé dans
/// `main()`) qui pilote les cycles. Des providers de test n'instancient jamais
/// ce moteur — les contrats de garde (pas de timer en arrière-plan) restent
/// intacts pour `flutter test`.
class SyncEngine {
  final SyncStore store;
  final SyncHandlers handlers;
  final Future<bool> Function() isOnline;

  /// Demandé quand un conflit CAS a annulé une opération : l'état distant a
  /// divergé, il faut tirer pour réconcilier (branché dans `main()`).
  final void Function() onConflictPulled;

  bool _running = false;

  SyncEngine({
    required this.store,
    required this.handlers,
    Future<bool> Function()? isOnline,
    this.onConflictPulled = _noop,
  }) : isOnline = isOnline ?? _defaultOnlineCheck;

  static void _noop() {}

  static Future<bool> _defaultOnlineCheck() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  bool get isRunning => _running;

  /// Draîne la file tant qu'il y a des opérations dues. Renvoie le nombre
  /// d'opérations traitées (0 si hors-ligne ou déjà en cours).
  Future<int> runOnce() async {
    if (_running) return 0;
    _running = true;
    var processed = 0;
    try {
      if (!await isOnline()) return 0;

      while (true) {
        final claimed = await store.claimDue();
        if (claimed.isEmpty) break;

        for (final row in claimed) {
          processed++;
          try {
            await handlers.apply(row);
            await store.markDone(row.id);
          } on TicketStateConflictException catch (error) {
            // Conflit multi-appareils : l'état distant prime. La ligne est
            // réglée en cancelled ; le pull qui suit dans le même cycle
            // réconciliera l'état local.
            dev.log(
              'sync: conflit CAS, op ${row.entityType}/${row.op} '
              '(${row.entityId}) annulée — $error',
              name: 'TicketPass',
            );
            await store.markCancelled(row.id);
            onConflictPulled();
          } catch (error) {
            // Réseau / indisponible : backoff via la politique du store. Au
            // bout de `maxAttempts`, la ligne part en cancelled (permanente).
            final result = await store.markFailed(row.id);
            if (result == MarkFailedResult.cancelled) {
              dev.log(
                'sync: op ${row.entityType}/${row.op} (${row.entityId}) '
                'abandonnée après ${SyncStore.maxAttempts} tentatives',
                name: 'TicketPass',
              );
            }
          }
        }
      }

      await store.clearFinished();
      return processed;
    } finally {
      // Un cycle interrompu ne doit laisser aucune ligne bloquée en syncing.
      await store.resetStuckSyncing();
      _running = false;
    }
  }
}