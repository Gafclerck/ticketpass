import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/database/app_database.dart' as db;
import 'package:ticketpass/core/sync/sync_store.dart';
import 'package:ticketpass/features/auth/domain/entities/role.dart';
import 'package:ticketpass/features/event/data/repositories/drift_event_repository.dart';
import 'package:ticketpass/features/event/domain/entities/event.dart';
import 'package:ticketpass/features/event/domain/entities/event_status.dart';
import 'package:ticketpass/features/event/domain/entities/event_type.dart';
import 'package:ticketpass/features/event/domain/entities/event_user_role.dart';
import 'package:ticketpass/features/ticket/data/repositories/drift_ticket_repository.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket_status.dart';

import '../../helpers/test_database.dart';

Event sampleEvent() => Event(
      id: 'ev1',
      title: 'Concert test',
      description: '',
      eventDate: DateTime(2026, 10, 1),
      startTime: DateTime(2026, 10, 1, 20),
      type: EventType.concert,
      brandName: '',
      eventPlace: '',
      maxPlaces: 10,
      status: EventStatus.upcoming,
    );

void main() {
  late db.AppDatabase database;
  late DriftEventRepository events;
  late DriftTicketRepository tickets;

  Future<List<db.SyncOutboxData>> pendingRows() async {
    final rows = await (database.select(database.syncOutbox)
          ..where(
            (row) => row.status.equals(SyncStatus.pending),
          )
          ..orderBy(
            [(row) => OrderingTerm.asc(row.createdAtMs)],
          ))
        .get();
    return rows;
  }

  setUp(() {
    silenceDriftWarnings();
    database = db.AppDatabase(NativeDatabase.memory());
    events = DriftEventRepository(database);
    tickets = DriftTicketRepository(database);
  });

  tearDown(() => database.close());

  test('createEvent enqueue event/create + role/assign organiser', () async {
    await events.createEvent(sampleEvent(), userId: 'u1');

    final rows = await pendingRows();
    expect(rows, hasLength(2));

    final eventRow = rows[0];
    expect(eventRow.entityType, SyncEntityType.event);
    expect(eventRow.op, SyncOp.create);
    expect(eventRow.entityId, 'ev1');
    expect(
      jsonDecode(eventRow.payload)['title'] as String,
      'Concert test',
    );

    final roleRow = rows[1];
    expect(roleRow.entityType, SyncEntityType.role);
    expect(roleRow.op, SyncOp.assign);
    expect(roleRow.entityId, 'ev1');
    final rolePayload = jsonDecode(roleRow.payload) as Map<String, dynamic>;
    expect(rolePayload['user_id'], 'u1');
    expect(rolePayload['role'], Role.organiser.name);
  });

  test('updateEvent enqueue event/update', () async {
    await insertEvent(database, 'ev1');
    await events.updateEvent(sampleEvent());

    final rows = await pendingRows();
    expect(rows.single.entityType, SyncEntityType.event);
    expect(rows.single.op, SyncOp.update);
    expect(rows.single.entityId, 'ev1');
  });

  test('deleteEvent enqueue event/delete (tombstone)', () async {
    await insertEvent(database, 'ev1');
    await events.deleteEvent('ev1');

    final rows = await pendingRows();
    expect(rows.single.entityType, SyncEntityType.event);
    expect(rows.single.op, SyncOp.delete);
    expect(rows.single.entityId, 'ev1');
  });

  test('assignRole enqueue role/assign', () async {
    await insertEvent(database, 'ev1');
    await events.createEvent(
      sampleEvent().copyWith(id: 'ev0', title: 'base'),
      userId: 'u1',
    );
    await events.assignRole(
      EventUserRole(
        eventId: 'ev0',
        userId: 'u2',
        role: Role.controller,
      ),
    );

    final rows = await pendingRows();
    final assign = rows.lastWhere((r) =>
        r.entityType == SyncEntityType.role && r.op == SyncOp.assign);
    final payload = jsonDecode(assign.payload) as Map<String, dynamic>;
    expect(payload['event_id'], 'ev0');
    expect(payload['user_id'], 'u2');
    expect(payload['role'], Role.controller.name);
  });

  test('generateTickets enqueue un ticket/generate par billet', () async {
    await insertEvent(database, 'ev1');
    final generated = await tickets.generateTickets('ev1', 3);

    final rows = await pendingRows();
    expect(rows, hasLength(3));
    for (var i = 0; i < rows.length; i++) {
      expect(rows[i].entityType, SyncEntityType.ticket);
      expect(rows[i].op, SyncOp.generate);
      expect(rows[i].entityId, 'ev1');
      expect(
        jsonDecode(rows[i].payload)['id'] as String,
        generated[i].id,
      );
    }
  });

  test('acquireTicket enqueue ticket/acquire avec précondition unused', () async {
    await insertEvent(database, 'ev1');
    await insertTicket(
      database,
      id: 't1',
      status: TicketStatus.unused,
      userId: '',
      eventId: 'ev1',
    );

    final acquired = await tickets.acquireTicket('ev1', userId: 'u2');

    final rows = await pendingRows();
    expect(rows.single.entityType, SyncEntityType.ticket);
    expect(rows.single.op, SyncOp.acquire);
    expect(rows.single.entityId, acquired.id);
    expect(rows.single.precondition, jsonEncode({'status': 'unused'}));
    final payload = jsonDecode(rows.single.payload) as Map<String, dynamic>;
    expect(payload['user_id'], 'u2');
    expect(payload['event_id'], 'ev1');
    expect(payload['ticket_id'], acquired.id);
  });

  test('validateTicket enqueue ticket/validate avec précondition valid', () async {
    await insertEvent(database, 'ev1');
    await insertTicket(
      database,
      id: 't1',
      status: TicketStatus.valid,
      userId: 'u2',
      eventId: 'ev1',
    );

    await tickets.validateTicket('t1');

    final rows = await pendingRows();
    expect(rows.single.entityType, SyncEntityType.ticket);
    expect(rows.single.op, SyncOp.validate);
    expect(rows.single.entityId, 't1');
    expect(rows.single.precondition, jsonEncode({'status': 'valid'}));
    expect(
      (jsonDecode(rows.single.payload) as Map<String, dynamic>)['event_id'],
      'ev1',
    );
  });
}