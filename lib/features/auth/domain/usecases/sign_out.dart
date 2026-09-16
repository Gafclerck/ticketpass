import '../repositories/auth_user_repository.dart';

/// UC — déconnexion.
class SignOut {
  final AuthUserRepository repository;

  SignOut(this.repository);

  Future<void> call() => repository.signOut();
}