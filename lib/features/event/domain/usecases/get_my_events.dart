import '../entities/event.dart';
import '../repositories/event_repository.dart';

class GetMyEvents {
  final EventRepository repository;

  const GetMyEvents(this.repository);

  Future<List<Event>> call(String organizerId) {
    return repository.getMyEvents(organizerId);
  }
}
