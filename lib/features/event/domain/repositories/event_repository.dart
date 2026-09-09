import '../entities/event.dart';

abstract class EventRepository {
  Future<Event> createEvent(Event event);

  Future<Event> updateEvent(Event event);

  Future<void> deleteEvent(String eventId);

  Future<List<Event>> getMyEvents(String organizerId);
}
