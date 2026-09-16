import '../../domain/entities/user.dart';

/// Sérialisation du profil utilisateur — document Firestore `users/{uid}`.
///
/// Clés snake_case (`full_name`, `profile_url`). `id` = uid Firebase, la clé
/// du document. Seul point de (dé)sérialisation Firestore du profil.
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? profileUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.profileUrl,
  });

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      profileUrl: user.profileUrl,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      fullName: fullName,
      profileUrl: profileUrl,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['uid'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      profileUrl: json['profile_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'email': email,
      'full_name': fullName,
      'profile_url': profileUrl,
    };
  }
}