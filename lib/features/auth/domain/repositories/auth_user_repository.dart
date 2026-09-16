import '../entities/user.dart';

/// Contrat du dépôt d'authentification — implémentation réelle Firebase
/// (`FirebaseAuth` + Firestore `users/{uid}` + Storage pour l'avatar).
///
/// `User.id` = uid Firebase : la même valeur est utilisée comme clé du doc
/// Firestore et comme `userId` des événements/billets du reste du domaine.
abstract class AuthUserRepository {
  /// Flux de l'identité courante (null = déconnecté). Source unique pour la
  /// présentation (dérivé par `currentUserProvider`).
  Stream<User?> authStateChanges();

  /// Identité courante lue de façon SYNCHRONE (restauration de session sans
  /// attendre le premier événement du flux). Firebase expose ce état nativement
  /// via `FirebaseAuth.instance.currentUser` ; null = déconnecté.
  User? get currentUser;

  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> signOut();

  /// Met à jour le profil Firestore (nom et/ou URL d'avatar).
  Future<void> updateProfile({String? fullName, String? profileUrl});
}