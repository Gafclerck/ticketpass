import '../entities/event.dart';
import '../repositories/event_repository.dart';

/// Détail d'un événement par identifiant.
class GetEventById {
  final EventRepository repository;

  const GetEventById(this.repository);

  Future<Event> call(String eventId) => repository.getEventById(eventId);
}