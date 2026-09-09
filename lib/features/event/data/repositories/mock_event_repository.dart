import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';

/// Implémentation fake (en mémoire) du dépôt d'événements.
///
/// Point de bascule : sera remplacée par `EventRepositoryImpl` (drift +
/// Firestore) au sprint d'infrastructure, SANS toucher au domaine ni à la
/// présentation.
class MockEventRepository implements EventRepository {
  final Map<String, List<Event>> _eventsByUserId = {};

  @override
  Future<Event> createEvent(Event event, {required String userId}) async {
    final now = DateTime.now();

    final createdEvent = event.copyWith(
      id: event.id.isEmpty ? now.microsecondsSinceEpoch.toString() : event.id,
    );

    (_eventsByUserId[userId] ??= <Event>[]).add(createdEvent);
    return createdEvent;
  }

  @override
  Future<Event> updateEvent(Event event) async {
    for (final events in _eventsByUserId.values) {
      final index = events.indexWhere((item) => item.id == event.id);

      if (index != -1) {
        events[index] = event;
        return event;
      }
    }

    throw Exception('Événement introuvable.');
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    for (final events in _eventsByUserId.values) {
      events.removeWhere((event) => event.id == eventId);
    }
  }

  @override
  Future<List<Event>> getMyEvents(String userId) async {
    return List.unmodifiable(_eventsByUserId[userId] ?? const <Event>[]);
  }
}