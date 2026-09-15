import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// UC14 — Inscription d'un nouvel utilisateur.
class SignUp {
  final AuthRepository repository;

  const SignUp(this.repository);

  Future<User> call(String email, String password, String fullName) {
    if (password.length < 6) {
      throw ArgumentError('Le mot de passe doit contenir au moins 6 caractères.');
    }
    return repository.signUp(email, password, fullName);
  }
}
