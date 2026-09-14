import '../entities/event_user_role.dart';
import '../repositories/event_repository.dart';

/// UC24 — attribue un rôle à un utilisateur sur un événement.
class AssignRole {
  final EventRepository repository;

  const AssignRole(this.repository);

  Future<void> call(EventUserRole role) {
    return repository.assignRole(role);
  }
}