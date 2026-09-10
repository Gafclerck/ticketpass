import 'role.dart';

/// Utilisateur — spec `docs/classe.md`.
class User {
  final String id;
  final String email;
  final String password;
  final String fullName;
  final String? profileUrl;
  final String authId;

  const User({
    required this.id,
    required this.email,
    required this.password,
    required this.fullName,
    this.profileUrl,
    required this.authId,
  });

  /// Rôle "[PAR DÉFAUT] participant" — un utilisateur participe à un
  /// événement à moins qu'un [EventUserRole] ne lui donne un autre rôle.
  Role get defaultRole => Role.participant;

  User copyWith({
    String? id,
    String? email,
    String? password,
    String? fullName,
    String? profileUrl,
    String? authId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      profileUrl: profileUrl ?? this.profileUrl,
      authId: authId ?? this.authId,
    );
  }
}