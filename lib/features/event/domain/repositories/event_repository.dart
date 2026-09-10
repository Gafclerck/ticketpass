import '../entities/event.dart';

/// Contrat du dépôt d'événements.
///
/// La possession d'un événement est portée par `EventUserRole(role: organiser)`
/// (cf. `docs/classe.md`). Tant que l'auth et les rôles ne sont pas implémentés,
/// les appels passent explicitement l'`userId`.
abstract class EventRepository {
  Future<Event> createEvent(Event event, {required String userId});

  Future<Event> updateEvent(Event event);

  Future<void> deleteEvent(String eventId);

  Future<List<Event>> getMyEvents(String userId);

  /// Catalogue public (découverte) — événements visibles de tous.
  Future<List<Event>> getDiscoverEvents();

  /// Détail d'un événement (nécessaire à la page d'édition et à
  /// l'EventDetailScreen à venir).
  Future<Event> getEventById(String eventId);
}