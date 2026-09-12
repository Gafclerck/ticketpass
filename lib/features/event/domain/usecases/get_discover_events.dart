import '../entities/event.dart';
import '../repositories/event_repository.dart';

/// Catalogue public — découverte d'événements (Home / EventsScreen).
class GetDiscoverEvents {
  final EventRepository repository;

  const GetDiscoverEvents(this.repository);

  Future<List<Event>> call() => repository.getDiscoverEvents();
}