import '../entities/user.dart';
import '../repositories/auth_user_repository.dart';

/// UC — création de compte (email + mot de passe + nom complet).
class SignUp {
  final AuthUserRepository repository;

  SignUp(this.repository);

  Future<User> call({
    required String email,
    required String password,
    required String fullName,
  }) =>
      repository.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
}