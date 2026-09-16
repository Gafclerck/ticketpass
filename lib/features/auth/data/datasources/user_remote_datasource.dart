import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

/// Contrat de la source Firestore du profil utilisateur.
abstract class UserRemoteDatasource {
  Future<UserModel?> fetchById(String userId);

  Future<void> upsert(UserModel user);
}

/// Implémentation Firestore — collection `users/{uid}`.
class FirebaseUserRemoteDatasource implements UserRemoteDatasource {
  final FirebaseFirestore _firestore;

  FirebaseUserRemoteDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Future<UserModel?> fetchById(String userId) async {
    final doc = await _users.doc(userId).get();
    final data = doc.data();
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  @override
  Future<void> upsert(UserModel user) => _users.doc(user.id).set(user.toJson());
}