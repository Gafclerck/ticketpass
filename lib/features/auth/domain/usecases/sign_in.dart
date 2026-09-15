import '../entities/user.dart';
import '../repositories/auth_user_repository.dart';

/// UC — connexion par email/mot de passe.
class SignIn {
  final AuthUserRepository repository;

  SignIn(this.repository);

  Future<User> call({
    required String email,
    required String password,
  }) =>
      repository.signInWithEmail(email: email, password: password);
}