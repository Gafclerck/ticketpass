import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Révision de synchronisation.
///
/// Incrémenté par le [SyncLifecycle] (lancé dans `main()`) à la fin de chaque
/// cycle de convergence. Les providers du catalogue (`myEventsProvider`,
/// `discoverEventsProvider`…) le `watch` pour se refetch automatiquement quand
/// le cache local a été réconcilié. En test la valeur n'est jamais modifiée
/// (le lifecycle n'y est pas démarré) : comportement identique au reste.
class SyncRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final syncRevisionProvider =
    NotifierProvider<SyncRevision, int>(SyncRevision.new);