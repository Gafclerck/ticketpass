import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/entities/user.dart' as domain;
import '../../features/auth/presentation/providers/auth_providers.dart';
import 'app_database.dart';
import 'database_provider.dart';

/// Miroir local (table `Users`) de l'utilisateur Firebase courant.
///
/// `Tickets.userId` et `EventUserRoles.userId` référencent `Users.id`
/// (contrat `app_database.dart`) : sans ce miroir, créer un événement ou
/// importer un billet en local échouerait, puisque la source de vérité de
/// l'auth (Firebase) n'est pas la même base que le stockage local.
class LocalUserSync {
  final AppDatabase db;
  const LocalUserSync(this.db);

  Future<void> upsert(domain.User user) {
    return db
        .into(db.users)
        .insertOnConflictUpdate(
          UsersCompanion.insert(
            id: user.id,
            email: user.email,
            password: user.password,
            fullName: user.fullName,
            profileUrl: Value(user.profileUrl),
            authId: user.authId,
          ),
        );
  }
}

final localUserSyncProvider = Provider<LocalUserSync>((ref) {
  return LocalUserSync(ref.watch(appDatabaseProvider));
});

/// Provider "effet de bord" : à observer une fois (voir `MyApp.build`) pour
/// que chaque connexion/déconnexion Firebase soit répercutée dans la base
/// locale. N'expose aucune valeur utile en soi — seul le fait de le watcher
/// compte, pour activer le `ref.listen` ci-dessous pendant toute la vie de
/// l'app.
final userSyncEffectProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<domain.User?>>(authStateChangesProvider, (
    previous,
    next,
  ) {
    final user = next.value;
    if (user != null) {
      ref.read(localUserSyncProvider).upsert(user);
    }
  }, fireImmediately: true);
});
