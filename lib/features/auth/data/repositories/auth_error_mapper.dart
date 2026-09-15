import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/errors/auth_exception.dart';

/// Traduit une erreur d'authentification Firebase en [AuthException] dont le
/// message est affichable (français).
AuthException mapAuthError(Object error) {
  if (error is! FirebaseAuthException) {
    return const AuthException('Une erreur est survenue. Réessayez.');
  }

  switch (error.code) {
    case 'user-not-found':
      return const AuthException('Aucun compte associé à cet email.');
    case 'wrong-password':
    case 'invalid-credential':
      return const AuthException('Identifiants incorrects.');
    case 'invalid-email':
      return const AuthException('Adresse email invalide.');
    case 'email-already-in-use':
      return const AuthException('Un compte existe déjà avec cet email.');
    case 'weak-password':
      return const AuthException(
        'Mot de passe trop faible (6 caractères minimum).',
      );
    case 'too-many-requests':
      return const AuthException('Trop de tentatives. Réessayez plus tard.');
    case 'network-request-failed':
      return const AuthException(
        'Problème de connexion. Vérifiez votre réseau.',
      );
    case 'operation-not-allowed':
      return const AuthException(
        'La connexion par email/mot de passe est désactivée.',
      );
    default:
      return AuthException(error.message ?? 'Connexion impossible.');
  }
}