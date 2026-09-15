import '../entities/user.dart';
import '../repositories/auth_user_repository.dart';

/// UC — écoute de l'identité courante (null = déconnecté).
class WatchAuthState {
  final AuthUserRepository repository;

  WatchAuthState(this.repository);

  Stream<User?> call() => repository.authStateChanges();
}