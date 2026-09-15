import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> signIn(String email, String password);

  Future<User> signUp(String email, String password, String fullName);

  Future<void> signOut();

  // connaitre si l'utilisateur est toujours connecté
  Stream<User?> get authStateChanges;
}
