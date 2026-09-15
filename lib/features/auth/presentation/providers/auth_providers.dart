import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketpass/core/routing/auth_refresh_listenable.dart';
import 'package:ticketpass/features/auth/data/datasources/profile_image_remote_datasource.dart';
import 'package:ticketpass/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:ticketpass/features/auth/domain/entities/user.dart';
import 'package:ticketpass/features/auth/domain/repositories/auth_user_repository.dart';
import 'package:ticketpass/features/auth/domain/usecases/sign_in.dart';
import 'package:ticketpass/features/auth/domain/usecases/sign_out.dart';
import 'package:ticketpass/features/auth/domain/usecases/sign_up.dart';
import 'package:ticketpass/features/auth/domain/usecases/update_profile.dart';
import 'package:ticketpass/features/auth/domain/usecases/watch_auth_state.dart';

/// Implémentation RÉELLE (Firebase Auth + Firestore + Storage). Plus aucun
/// point de bascule fake : les tests remplacent ce provider par un mock
/// (mocktail) au niveau du contrat.
final authUserRepositoryProvider = Provider<AuthUserRepository>((ref) {
  return FirebaseAuthRepository();
});

/// Source d'upload de l'avatar (Storage) — utilisée par l'écran Profil.
final profileImageDatasourceProvider =
    Provider<ProfileImageRemoteDatasource>((ref) {
  return FirebaseProfileImageRemoteDatasource();
});

final signInProvider = Provider<SignIn>((ref) {
  return SignIn(ref.watch(authUserRepositoryProvider));
});

final signUpProvider = Provider<SignUp>((ref) {
  return SignUp(ref.watch(authUserRepositoryProvider));
});

final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authUserRepositoryProvider));
});

final watchAuthStateProvider = Provider<WatchAuthState>((ref) {
  return WatchAuthState(ref.watch(authUserRepositoryProvider));
});

final updateProfileProvider = Provider<UpdateProfile>((ref) {
  return UpdateProfile(ref.watch(authUserRepositoryProvider));
});

/// État d'authentification courant (null = déconnecté).
///
/// `build()` s'abonne à `authStateChanges()` du repository ; les mutations
/// (`signIn/signUp/signOut/updateProfile`) passent par les use cases puis
/// rafraîchissent `state` et le listenable de routage.
final authControllerProvider =
    NotifierProvider<AuthController, User?>(AuthController.new);

class AuthController extends Notifier<User?> {
  StreamSubscription<User?>? _authSubscription;

  @override
  User? build() {
    final repository = ref.watch(authUserRepositoryProvider);
    // Session restaurable de façon synchrone (Firebase `currentUser`) : l'état
    // est cohérent dès le premier frame, avant le redirect du routeur.
    final initial = repository.currentUser;

    _authSubscription?.cancel();
    _authSubscription = repository.authStateChanges().listen((user) {
      if (!ref.mounted) return;
      state = user;
      authRefreshListenable.notify(isAuthenticated: user != null);
    });
    ref.onDispose(() => _authSubscription?.cancel());

    if (initial != null) {
      // Notifié au microtask suivant : évite un notify pendant le build.
      scheduleMicrotask(() {
        if (ref.mounted) {
          authRefreshListenable.notify(isAuthenticated: true);
        }
      });
    }
    return initial;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final user = await ref
        .read(signInProvider)
        .call(email: email, password: password);
    if (!ref.mounted) return;
    state = user;
    authRefreshListenable.notify(isAuthenticated: true);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final user = await ref
        .read(signUpProvider)
        .call(email: email, password: password, fullName: fullName);
    if (!ref.mounted) return;
    state = user;
    authRefreshListenable.notify(isAuthenticated: true);
  }

  Future<void> signOut() async {
    await ref.read(signOutProvider).call();
    if (!ref.mounted) return;
    state = null;
    authRefreshListenable.notify(isAuthenticated: false);
  }

  Future<void> updateProfile({String? fullName, String? profileUrl}) async {
    await ref
        .read(updateProfileProvider)
        .call(fullName: fullName, profileUrl: profileUrl);
    if (!ref.mounted) return;
    final current = state;
    if (current != null) {
      state = current.copyWith(
        fullName: fullName ?? current.fullName,
        profileUrl: profileUrl ?? current.profileUrl,
      );
    }
  }
}