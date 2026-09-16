import '../../../auth/domain/entities/role.dart';

/// Document Firestore `events/{eventId}/roles/{userId}`.
///
/// Rôles d'un utilisateur sur un événement, stockés comme un tableau de noms
/// d'enum (`['organiser', 'controller']`). L'`id` du document = `userId` ;
/// `user_id` est aussi présent dans le payload pour les lectures par requête.
class EventRoleModel {
  final String userId;
  final List<Role> roles;

  const EventRoleModel({required this.userId, this.roles = const []});

  factory EventRoleModel.fromJson(Map<String, dynamic> json) {
    final names = json['roles'] as List<dynamic>? ?? const [];
    return EventRoleModel(
      userId: json['user_id'] as String,
      roles: names
          .map((name) => Role.values.byName(name as String))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'roles': roles.map((r) => r.name).toList(growable: false),
    };
  }
}