import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// UC14 — Connexion d'un utilisateur existant.
class SignIn {
  final AuthRepository repository;

  const SignIn(this.repository);

  Future<User> call(String email, String password) {
    return repository.signIn(email, password);
  }
}
