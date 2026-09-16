import 'role.dart';

/// Utilisateur — adapté du modèle `docs/classe.md` au contexte d'authentification.
///
/// Écarts assumés vs le diagramme : pas de `password` (jamais stocké côté app,
/// géré par Firebase Auth) ni d'`authId` (l'identifiant [`User.id`] est
/// l'uid Firebase, clé du doc Firestore `users/{uid}` et `userId` partout).
class User {
  final String id;
  final String email;
  final String fullName;
  final String? profileUrl;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.profileUrl,
  });

  /// Rôle "[PAR DÉFAUT] participant" — un utilisateur participe à un
  /// événement à moins qu'un [EventUserRole] ne lui donne un autre rôle.
  Role get defaultRole => Role.participant;

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? profileUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profileUrl: profileUrl ?? this.profileUrl,
    );
  }
}