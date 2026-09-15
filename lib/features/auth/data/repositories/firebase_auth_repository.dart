import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implémentation `AuthRepository` branchée sur Firebase Authentication.
class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository({firebase_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  User _mapUser(
    firebase_auth.User firebaseUser, {
    String fullName = '',
    String password = '',
  }) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      // Firebase ne renvoie jamais le mot de passe en clair : on ne le connaît
      // qu'au moment de l'appel signIn/signUp ; via authStateChanges, vide.
      password: password,
      fullName: fullName.isNotEmpty ? fullName : (firebaseUser.displayName ?? ''),
      profileUrl: firebaseUser.photoURL,
      // TODO UC15 : distinguer id (métier, local/Firestore) de authId une fois
      // la persistance branchée — pour l'instant les deux valent le uid Firebase.
      authId: firebaseUser.uid,
    );
  }

  @override
  Future<User> signIn(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _mapUser(credential.user!, password: password);
  }

  @override
  Future<User> signUp(String email, String password, String fullName) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(fullName);
    return _mapUser(credential.user!, fullName: fullName, password: password);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(
          (firebaseUser) => firebaseUser == null ? null : _mapUser(firebaseUser),
        );
  }
}
