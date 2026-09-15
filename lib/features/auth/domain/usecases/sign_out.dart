import '../repositories/auth_repository.dart';

/// UC14 — Déconnexion de l'utilisateur courant.
class SignOut {
  final AuthRepository repository;

  const SignOut(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}
