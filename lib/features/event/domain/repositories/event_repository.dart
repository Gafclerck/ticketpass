import '../entities/event.dart';
import '../entities/event_user_role.dart';

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

  /// Rôles d'un utilisateur sur un événement.
  Future<List<EventUserRole>> getRoles(String eventId);

  /// Ajoute (ou remplace) un rôle pour un utilisateur sur un événement
  /// (UC24 — désignation de contrôleur, etc.). L'organisateur est attribué
  /// automatiquement à la création.
  Future<void> assignRole(EventUserRole role);
}