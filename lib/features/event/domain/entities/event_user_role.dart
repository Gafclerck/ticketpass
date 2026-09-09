import '../../../auth/domain/entities/role.dart';

/// Table d'association entre un utilisateur et un événement — spec
/// `docs/classe.md`.
///
/// Clé primaire composite `(user_id, event_id, role)` : un même utilisateur
/// peut cumuler plusieurs rôles sur un même événement ("the organizer can be
/// the controller").
class EventUserRole {
  final String userId;
  final String eventId;
  final Role role;

  const EventUserRole({
    required this.userId,
    required this.eventId,
    required this.role,
  });
}