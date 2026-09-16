import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../../auth/domain/entities/role.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_user_role.dart';
import '../../domain/repositories/event_repository.dart';

/// Implémentation [EventRepository] sur la base locale (drift), **cache
/// hors-ligne** : les écritures sont acceptées immédiatement puis ramenées à
/// la convergence vers Firestore (source de vérité) au slice infra/sync.
///
/// Règles métier de `docs/classe.md` : possession portée par le rôle
/// `organiser` posé à la création (jamais d'événement sans créateur), rôles
/// idempotents (PK composite `(userId, eventId, role)`), suppression qui nettoie
/// rôles + billets (FK `eventId → Events`, propagation manuelle dans la bonne
/// ordre).
class DriftEventRepository implements EventRepository {
  final db.AppDatabase database;

  const DriftEventRepository(this.database);

  static int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  Event _toDomain(db.Event row) {
    return Event(
      id: row.id,
      title: row.title,
      description: row.description,
      eventDate: row.eventDate,
      startTime: row.startTime,
      brandingUrl: row.brandingUrl,
      ticketsNumber: row.ticketsNumber,
      type: row.type,
      brandName: row.brandName,
      eventPlace: row.eventPlace,
      maxPlaces: row.maxPlaces,
      status: row.status,
    );
  }

  db.EventsCompanion _toCompanion(Event event) {
    return db.EventsCompanion.insert(
      id: event.id,
      title: event.title,
      description: event.description,
      eventDate: event.eventDate,
      startTime: event.startTime,
      brandingUrl: Value(event.brandingUrl),
      ticketsNumber: Value(event.ticketsNumber),
      type: event.type,
      brandName: event.brandName,
      eventPlace: event.eventPlace,
      maxPlaces: event.maxPlaces,
      status: event.status,
    );
  }

  @override
  Future<Event> createEvent(Event event, {required String userId}) async {
    if (userId.trim().isEmpty) {
      throw Exception('L’événement doit avoir un créateur identifié.');
    }

    final created = event.id.isEmpty
        ? event.copyWith(id: const Uuid().v4())
        : event;

    await database.transaction(() async {
      await database.into(database.events).insert(
            _toCompanion(created).copyWith(updatedAtMs: Value(_nowMs())),
          );
      await database.into(database.eventUserRoles).insert(
            db.EventUserRolesCompanion.insert(
              userId: userId,
              eventId: created.id,
              role: Role.organiser,
            ).copyWith(updatedAtMs: Value(_nowMs())),
          );
    });

    return created;
  }

  @override
  Future<Event> updateEvent(Event event) async {
    // `ticketsNumber` est exclu de l'écriture : il est détenu par la génération
    // (`generateTickets`) et non par le formulaire d'édition.
    final updated = await (database.update(database.events)
          ..where((row) => row.id.equals(event.id)))
        .write(
      _toCompanion(event).copyWith(
        ticketsNumber: const Value.absent(),
        updatedAtMs: Value(_nowMs()),
      ),
    );

    if (updated != 1) {
      throw Exception('Événement introuvable.');
    }

    return event;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await database.transaction(() async {
      await (database.delete(database.tickets)
            ..where((row) => row.eventId.equals(eventId)))
          .go();
      await (database.delete(database.eventUserRoles)
            ..where((row) => row.eventId.equals(eventId)))
          .go();
      await (database.delete(database.events)
            ..where((row) => row.id.equals(eventId)))
          .go();
    });
  }

  @override
  Future<List<Event>> getMyEvents(String userId) async {
    final roles = await (database.select(database.eventUserRoles)
          ..where(
            (row) =>
                row.userId.equals(userId) &
                row.role.equals(Role.organiser.name),
          ))
        .get();

    final eventIds = roles.map((row) => row.eventId).toSet();
    if (eventIds.isEmpty) return const [];

    final rows = await (database.select(database.events)
          ..where((row) => row.id.isIn(eventIds))
          ..orderBy([(row) => OrderingTerm.desc(row.eventDate)]))
        .get();

    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<List<Event>> getDiscoverEvents() async {
    final rows = await (database.select(database.events)
          ..orderBy([(row) => OrderingTerm.asc(row.eventDate)]))
        .get();
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<Event> getEventById(String eventId) async {
    final row = await (database.select(database.events)
          ..where((row) => row.id.equals(eventId)))
        .getSingleOrNull();

    if (row == null) {
      throw Exception('Événement introuvable.');
    }

    return _toDomain(row);
  }

  @override
  Future<List<EventUserRole>> getRoles(String eventId) async {
    final rows = await (database.select(database.eventUserRoles)
          ..where((row) => row.eventId.equals(eventId)))
        .get();

    return rows
        .map(
          (row) => EventUserRole(
            userId: row.userId,
            eventId: row.eventId,
            role: row.role,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> assignRole(EventUserRole role) async {
    if (role.userId.trim().isEmpty) {
      throw Exception('Impossible d’attribuer un rôle à un utilisateur inconnu.');
    }

    // Idempotent : la clé primaire composite (userId, eventId, role) fait que
    // la re-désignation du même rôle est un no-op.
    await database.into(database.eventUserRoles).insert(
      db.EventUserRolesCompanion.insert(
        userId: role.userId,
        eventId: role.eventId,
        role: role.role,
      ).copyWith(updatedAtMs: Value(_nowMs())),
      mode: InsertMode.insertOrIgnore,
    );
  }
}