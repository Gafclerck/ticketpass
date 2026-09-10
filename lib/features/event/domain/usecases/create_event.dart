import '../entities/event.dart';
import '../repositories/event_repository.dart';

class CreateEvent {
  final EventRepository repository;

  const CreateEvent(this.repository);

  Future<Event> call(Event event, {required String userId}) {
    return repository.createEvent(event, userId: userId);
  }
}