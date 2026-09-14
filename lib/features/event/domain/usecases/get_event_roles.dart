import '../entities/event_user_role.dart';
import '../repositories/event_repository.dart';

/// Rôles des utilisateurs sur un événement.
class GetEventRoles {
  final EventRepository repository;

  const GetEventRoles(this.repository);

  Future<List<EventUserRole>> call(String eventId) {
    return repository.getRoles(eventId);
  }
}