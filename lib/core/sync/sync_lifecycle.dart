import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import 'pull_service.dart';
import 'sync_engine.dart';

/// Orchestrateur de la synchronisation, lancé uniquement dans `main()`.
///
/// Réagit aux événements (jamais de timer) : l'authentification émet 1 event au
/// boot (→ pull initial si en ligne) et une souscription `connectivity_plus`
/// relance le cycle à chaque reconnexion. Chaque cycle : drain outbox puis pull
/// de réconciliation, puis [onCycleDone] (incrément de `syncRevisionProvider`).
///
/// Hors `main()` ce composant n'est jamais construit : les tests `flutter test`
/// ne voient ni `FirebaseAuth` ni de timers en arrière-plan. Les flux auth et
/// connectivité sont injectables pour couvrir le cycle en test d'intégration.
class SyncLifecycle {
  final SyncEngine engine;
  final PullService pull;
  final Future<bool> Function() isOnline;
  final void Function() onCycleDone;

  StreamSubscription<String?>? _authSub;
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  String? _userId;
  bool _running = false;
  bool _cycleRequested = false;

  SyncLifecycle({
    required this.engine,
    required this.pull,
    required this.onCycleDone,
    Future<bool> Function()? isOnline,
    Stream<String?>? authEvents,
    Stream<List<ConnectivityResult>>? connectivityEvents,
  }) : isOnline = isOnline ?? _defaultOnlineCheck {
    _authSub = (authEvents ??
            firebase.FirebaseAuth.instance.authStateChanges().map((u) => u?.uid))
        .listen((uid) {
      _userId = uid;
      _requestCycle();
    });
    _connSub =
        (connectivityEvents ?? Connectivity().onConnectivityChanged).listen((
          results,
        ) {
          if (!results.contains(ConnectivityResult.none)) {
            _requestCycle();
          }
        });
  }

  static Future<bool> _defaultOnlineCheck() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  void _requestCycle() {
    if (_running) {
      _cycleRequested = true;
      return;
    }
    _runCycle();
  }

  Future<void> _runCycle() async {
    _running = true;
    try {
      if (!await isOnline()) return;

      await engine.runOnce();
      if (_userId != null) {
        await pull.pullAll(userId: _userId!);
      }
      onCycleDone();
    } catch (error) {
      // Cycle dégradé (réseau, docs manquants…) : on ne change rien, le prochain
      // événement auth/connectivité relancera la tentative.
    } finally {
      _running = false;
      if (_cycleRequested) {
        _cycleRequested = false;
        _runCycle();
      }
    }
  }

  void dispose() {
    _authSub?.cancel();
    _connSub?.cancel();
  }
}