import 'dart:async';

import 'package:flutter_riverpod/misc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ticketpass/core/routing/auth_refresh_listenable.dart';
import 'package:ticketpass/features/auth/domain/entities/user.dart';
import 'package:ticketpass/features/auth/domain/repositories/auth_user_repository.dart';
import 'package:ticketpass/features/auth/presentation/providers/auth_providers.dart';

/// Utilisateur démo connecté — utilisé par l'ensemble des tests widget qui
/// pompent le routeur (tous les écrans sont protégés par le redirect auth).
const demoUser = User(
  id: 'demo-user-id',
  email: 'alice@exemple.fr',
  fullName: 'Alice Martin',
);

/// Stub mocktail du contrat [AuthUserRepository] pour les tests widget.
///
/// Par défaut : flux d'état connecté (`_authStateUser`) et mutations réussies
/// retournant `_signInResult`.
class AuthUserRepositoryStub extends Mock implements AuthUserRepository {
  AuthUserRepositoryStub({
    required User? authStateUser,
    required User? signInResult,
    this.signInError,
  }) {
    when(() => authStateChanges())
        .thenAnswer((_) => Stream.value(authStateUser));
    when(() => currentUser).thenAnswer((_) => authStateUser);
    if (signInError != null) {
      when(() => signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(signInError!);
    } else {
      when(() => signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) => Future.value(signInResult));
    }
    when(() => signUpWithEmail(
      email: any(named: 'email'),
      fullName: any(named: 'fullName'),
      password: any(named: 'password'),
    )).thenAnswer((_) => Future.value(signInResult));
    when(() => signOut()).thenAnswer((_) => Future.value());
    when(() => updateProfile(
      fullName: any(named: 'fullName'),
      profileUrl: any(named: 'profileUrl'),
    )).thenAnswer((_) async => signInResult);
  }

  /// Erreur levée par `signInWithEmail` (test du banner d'erreur Login).
  final Object? signInError;

  /// Fait remonter l'état connecté au listenable de routage (synchrone).
  void emitAuthenticated() {
    authRefreshListenable.notify(isAuthenticated: true);
  }

  /// Fait remonter l'état déconnecté au listenable de routage (synchrone).
  void emitUnauthenticated() {
    authRefreshListenable.notify(isAuthenticated: false);
  }
}

/// Override du provider d'auth.
///
/// - `authUserRepositoryOverride()` → utilisateur démo déjà connecté.
/// - `unauthenticated: true` → aucun utilisateur connecté au départ.
Override authUserRepositoryOverride({
  User? user,
  bool unauthenticated = false,
  Object? signInError,
}) {
  // État de routage posé de façon synchrone AVANT le premier pump : le
  // GoRouter évalue son redirect initial dès la construction du widget.
  authRefreshListenable.notify(isAuthenticated: !unauthenticated);
  return authUserRepositoryProvider.overrideWithValue(
    AuthUserRepositoryStub(
      authStateUser: unauthenticated ? null : (user ?? demoUser),
      signInResult: user ?? demoUser,
      signInError: signInError,
    ),
  );
}

/// Réinitialise l'état global de routage (listenable partagé) entre tests.
void resetAuthRouting() => authRefreshListenable.reset();