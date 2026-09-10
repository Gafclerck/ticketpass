import '../repositories/event_repository.dart';

class DeleteEvent {
  final EventRepository repository;

  const DeleteEvent(this.repository);

  Future<void> call(String eventId) {
    return repository.deleteEvent(eventId);
  }
}
