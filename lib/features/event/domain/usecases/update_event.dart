import '../entities/event.dart';
import '../repositories/event_repository.dart';

class UpdateEvent {
  final EventRepository repository;

  const UpdateEvent(this.repository);

  Future<Event> call(Event event) {
    return repository.updateEvent(event);
  }
}
