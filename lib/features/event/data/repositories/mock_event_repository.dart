import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';

class MockEventRepository implements EventRepository {
  final List<Event> _events = [];

  @override
  Future<Event> createEvent(Event event) async {
    final now = DateTime.now();

    final createdEvent = event.copyWith(
      id: event.id.isEmpty ? now.microsecondsSinceEpoch.toString() : event.id,
      createdAt: event.createdAt,
      updatedAt: now,
    );

    _events.add(createdEvent);
    return createdEvent;
  }

  @override
  Future<Event> updateEvent(Event event) async {
    final index = _events.indexWhere((item) => item.id == event.id);

    if (index == -1) {
      throw Exception('Événement introuvable.');
    }

    final updatedEvent = event.copyWith(updatedAt: DateTime.now());
    _events[index] = updatedEvent;

    return updatedEvent;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((event) => event.id == eventId);
  }

  @override
  Future<List<Event>> getMyEvents(String organizerId) async {
    return _events.where((event) => event.organizerId == organizerId).toList();
  }
}
