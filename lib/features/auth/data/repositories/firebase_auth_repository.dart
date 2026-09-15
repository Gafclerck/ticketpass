import 'package:firebase_auth/firebase_auth.dart' as firebase;

import '../../domain/entities/user.dart';
import '../../domain/errors/auth_exception.dart';
import '../../domain/repositories/auth_user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';
import 'auth_error_mapper.dart';

/// Implémentation réelle du dépôt d'authentification.
///
/// Orchestre `FirebaseAuth` (identité, connexions) et la source Firestore
/// `users/{uid}` (profil : nom complet + URL d'avatar). `[User.id]` = uid
/// Firebase. Toute erreur Firebase remonte en [AuthException] (message FR).
class FirebaseAuthRepository implements AuthUserRepository {
  final firebase.FirebaseAuth _auth;
  final UserRemoteDatasource _userDatasource;

  FirebaseAuthRepository({
    firebase.FirebaseAuth? auth,
    UserRemoteDatasource? userDatasource,
  }) : _auth = auth ?? firebase.FirebaseAuth.instance,
       _userDatasource = userDatasource ?? FirebaseUserRemoteDatasource();

  @override
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _toDomainUser(firebaseUser);
    });
  }

  @override
  User? get currentUser {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    // Lecture synchrone : repli sur les données Auth. Le flux hydrate ensuite
    // le profil Firestore complet (fullName/profileUrl renseignés).
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      fullName: firebaseUser.displayName ?? '',
      profileUrl: firebaseUser.photoURL,
    );
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _mapErrors(() async {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('La connexion a échoué. Réessayez.');
      }
      return _toDomainUser(firebaseUser);
    });
  }

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return _mapErrors(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('La création du compte a échoué.');
      }
      await firebaseUser.updateProfile(displayName: fullName.trim());
      await _userDatasource.upsert(
        UserModel(
          id: firebaseUser.uid,
          email: email.trim(),
          fullName: fullName.trim(),
        ),
      );
      return User(
        id: firebaseUser.uid,
        email: email.trim(),
        fullName: fullName.trim(),
      );
    });
  }

  @override
  Future<void> signOut() {
    return _mapErrors(() => _auth.signOut());
  }

  @override
  Future<void> updateProfile({String? fullName, String? profileUrl}) async {
    await _mapErrors(() async {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        throw const AuthException('Aucun utilisateur connecté.');
      }
      if (fullName != null) {
        await firebaseUser.updateProfile(displayName: fullName.trim());
      }
      final existing = await _toDomainUser(firebaseUser);
      await _userDatasource.upsert(
        UserModel(
          id: firebaseUser.uid,
          email: existing.email,
          fullName: fullName?.trim() ?? existing.fullName,
          profileUrl: profileUrl ?? existing.profileUrl,
        ),
      );
    });
  }

  Future<User> _toDomainUser(firebase.User firebaseUser) async {
    final doc = await _userDatasource.fetchById(firebaseUser.uid);
    if (doc != null) {
      return doc.toEntity();
    }
    // Compte Auth sans profil Firestore (legacy) : repli sur les données Auth.
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      fullName: firebaseUser.displayName ?? '',
      profileUrl: firebaseUser.photoURL,
    );
  }

  Future<T> _mapErrors<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException {
      rethrow;
    } on firebase.FirebaseAuthException catch (error) {
      throw mapAuthError(error);
    } catch (_) {
      throw const AuthException('Une erreur est survenue. Réessayez.');
    }
  }
}