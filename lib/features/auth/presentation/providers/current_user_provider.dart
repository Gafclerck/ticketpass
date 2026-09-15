import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketpass/features/auth/domain/entities/user.dart';

import 'auth_providers.dart';

/// Utilisateur courant, dérivé de l'authentification Firebase réelle (UC14).
///
/// Sûr d'appeler sans null-check : la garde de route (`app_router.dart`,
/// `redirect`) empêche d'atteindre un écran qui lit ce provider tant que
/// personne n'est connecté — si ce n'était pas le cas, ce serait un bug de
/// la garde de route, d'où l'échec explicite plutôt qu'un retour silencieux.
final currentUserProvider = Provider<User>((ref) {
  final user = ref.watch(authStateChangesProvider).value;

  if (user == null) {
    throw StateError(
      'currentUserProvider lu sans utilisateur connecté — la garde de '
      'route (app_router redirect) aurait dû empêcher cet écran.',
    );
  }

  return user;
});