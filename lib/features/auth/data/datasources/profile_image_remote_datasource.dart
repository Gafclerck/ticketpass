import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Contrat du stockage de l'image de profil.
abstract class ProfileImageRemoteDatasource {
  /// Dépose l'avatar dans `profile_images/{userId}.jpg` et retourne son URL
  /// de téléchargement (à persister dans le doc Firestore `users/{uid}`).
  Future<String> uploadProfileImage({
    required String userId,
    required Uint8List bytes,
  });
}

/// Implémentation Firebase Storage.
class FirebaseProfileImageRemoteDatasource
    implements ProfileImageRemoteDatasource {
  final FirebaseStorage _storage;

  FirebaseProfileImageRemoteDatasource({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadProfileImage({
    required String userId,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref().child('profile_images/$userId.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}