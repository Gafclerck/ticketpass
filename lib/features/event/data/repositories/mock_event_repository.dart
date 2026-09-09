import '../../domain/entities/event.dart';
import '../../domain/entities/event_status.dart';
import '../../domain/entities/event_type.dart';
import '../../domain/repositories/event_repository.dart';

/// Implémentation fake (en mémoire) du dépôt d'événements.
///
/// Point de bascule : sera remplacée par `EventRepositoryImpl` (drift +
/// Firestore) au sprint d'infrastructure, SANS toucher au domaine ni à la
/// présentation.
class MockEventRepository implements EventRepository {
  final Map<String, List<Event>> _eventsByUserId = {};
  final List<Event> _catalogue = [];

  MockEventRepository();

  /// Jeu de démonstration du catalogue public (découverte).
  factory MockEventRepository.demo() {
    final repository = MockEventRepository();
    repository._catalogue.addAll(_sampleEvents());
    return repository;
  }

  static List<Event> _sampleEvents() {
    final now = DateTime.now();
    return [
      Event(
        id: 'event-demo-1',
        title: 'Kendrick Lamar — The Big Steppers',
        description: 'Concert exceptionnel en plein air.',
        eventDate: now.add(const Duration(days: 14)),
        startTime: now.add(const Duration(days: 14, hours: 4)),
        brandingUrl: '',
        ticketsNumber: 1000,
        type: EventType.concert,
        brandName: 'Kendrick Lamar',
        eventPlace: 'Stade de France, Paris',
        maxPlaces: 2000,
        status: EventStatus.upcoming,
      ),
      Event(
        id: 'event-demo-2',
        title: 'Paris Design Week',
        description: 'Conférences et ateliers design.',
        eventDate: now.add(const Duration(days: 30)),
        startTime: now.add(const Duration(days: 30, hours: 3)),
        brandingUrl: '',
        ticketsNumber: 0,
        type: EventType.conference,
        brandName: 'PDW',
        eventPlace: 'Cité des sciences, Paris',
        maxPlaces: 500,
        status: EventStatus.upcoming,
      ),
      Event(
        id: 'event-demo-3',
        title: 'Stand-up Festival',
        description: 'Trois soirs de humoristes.',
        eventDate: now.subtract(const Duration(days: 3)),
        startTime: now.subtract(const Duration(days: 3, hours: 2)),
        brandingUrl: '',
        ticketsNumber: 300,
        type: EventType.theatre,
        brandName: 'SUF',
        eventPlace: 'Bataclan, Paris',
        maxPlaces: 800,
        status: EventStatus.passed,
      ),
    ];
  }

  @override
  Future<Event> createEvent(Event event, {required String userId}) async {
    final now = DateTime.now();

    final createdEvent = event.copyWith(
      id: event.id.isEmpty ? now.microsecondsSinceEpoch.toString() : event.id,
    );

    (_eventsByUserId[userId] ??= <Event>[]).add(createdEvent);
    _catalogue.add(createdEvent);
    return createdEvent;
  }

  @override
  Future<Event> updateEvent(Event event) async {
    for (final events in _eventsByUserId.values) {
      final index = events.indexWhere((item) => item.id == event.id);

      if (index != -1) {
        events[index] = event;
        _replaceInCatalogue(event);
        return event;
      }
    }

    throw Exception('Événement introuvable.');
  }

  void _replaceInCatalogue(Event event) {
    final index = _catalogue.indexWhere((item) => item.id == event.id);
    if (index != -1) {
      _catalogue[index] = event;
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    for (final events in _eventsByUserId.values) {
      events.removeWhere((event) => event.id == eventId);
    }
    _catalogue.removeWhere((event) => event.id == eventId);
  }

  @override
  Future<List<Event>> getMyEvents(String userId) async {
    return List.unmodifiable(_eventsByUserId[userId] ?? const <Event>[]);
  }

  @override
  Future<List<Event>> getDiscoverEvents() async {
    return List.unmodifiable(_catalogue);
  }
}