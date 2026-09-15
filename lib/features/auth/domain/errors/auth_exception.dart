/// Erreur d'authentification portant un message affichable (français).
///
/// Sépare le domaine de l'API Firebase : le repository traduit
/// `FirebaseAuthException` en [AuthException] avant toute remontée.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}