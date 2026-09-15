import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../../auth/domain/entities/role.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';

/// Implémentation `EventRepository` branchée sur la base locale (UC15,
/// drift/SQLite) — remplace `MockEventRepository` (en mémoire).
///
/// `Event` n'a pas de champ `organizerId` : la relation de possession passe
/// par `EventUserRoles` (role `organiser`), donc `createEvent` écrit les
/// deux tables dans une même transaction.
class DriftEventRepository implements EventRepository {
  final db.AppDatabase database;

  const DriftEventRepository(this.database);

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
    final createdEvent = event.copyWith(
      id: event.id.isEmpty
          ? DateTime.now().microsecondsSinceEpoch.toString()
          : event.id,
    );

    await database.transaction(() async {
      await database
          .into(database.events)
          .insert(_toCompanion(createdEvent));
      await database
          .into(database.eventUserRoles)
          .insert(
            db.EventUserRolesCompanion.insert(
              userId: userId,
              eventId: createdEvent.id,
              role: Role.organiser,
            ),
          );
    });

    return createdEvent;
  }

  @override
  Future<Event> updateEvent(Event event) async {
    final updated = await database
        .update(database.events)
        .replace(_toCompanion(event));

    if (!updated) {
      throw Exception('Événement introuvable.');
    }
    return event;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await database.transaction(() async {
      await (database.delete(
        database.eventUserRoles,
      )..where((row) => row.eventId.equals(eventId))).go();
      await (database.delete(
        database.tickets,
      )..where((row) => row.eventId.equals(eventId))).go();
      await (database.delete(
        database.events,
      )..where((row) => row.id.equals(eventId))).go();
    });
  }

  @override
  Future<List<Event>> getMyEvents(String userId) async {
    final query = database.select(database.events).join([
      innerJoin(
        database.eventUserRoles,
        database.eventUserRoles.eventId.equalsExp(database.events.id),
      ),
    ])..where(
      database.eventUserRoles.userId.equals(userId) &
          database.eventUserRoles.role.equalsValue(Role.organiser),
    );

    final rows = await query.get();
    return rows
        .map((row) => _toDomain(row.readTable(database.events)))
        .toList(growable: false);
  }

  @override
  Future<List<Event>> getDiscoverEvents() async {
    final rows = await database.select(database.events).get();
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<Event> getEventById(String eventId) async {
    final row = await (database.select(
      database.events,
    )..where((row) => row.id.equals(eventId))).getSingleOrNull();

    if (row == null) {
      throw Exception('Événement introuvable.');
    }
    return _toDomain(row);
  }
}
