import 'dart:convert';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/database/app_database.dart';
import 'package:ticketpass/core/sync/sync_handlers.dart';
import 'package:ticketpass/core/sync/sync_store.dart';
import 'package:ticketpass/features/auth/domain/entities/role.dart';
import 'package:ticketpass/features/event/data/datasources/event_remote_datasource.dart';
import 'package:ticketpass/features/event/data/models/event_model.dart';
import 'package:ticketpass/features/event/domain/entities/event_status.dart';
import 'package:ticketpass/features/event/domain/entities/event_type.dart';
import 'package:ticketpass/features/ticket/data/datasources/ticket_remote_datasource.dart';
import 'package:ticketpass/features/ticket/data/models/ticket_model.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket_status.dart';

EventModel event({String id = 'ev1', String title = 'Concert', int updatedAtMs = 0}) {
  return EventModel(
    id: id,
    title: title,
    description: 'Description',
    eventDate: DateTime(2026, 10, 1),
    startTime: DateTime(2026, 10, 1, 20),
    brandingUrl: '',
    type: EventType.concert,
    brandName: 'Artiste',
    eventPlace: 'Paris',
    maxPlaces: 100,
    status: EventStatus.upcoming,
    updatedAtMs: updatedAtMs,
  );
}

TicketModel ticket({
  String id = 't1',
  String eventId = 'ev1',
  TicketStatus status = TicketStatus.unused,
  String userId = '',
  int updatedAtMs = 100,
}) {
  return TicketModel(
    id: id,
    status: status,
    uniqueCode: 'uc-$id',
    qrSignature: 'sig-$id',
    userId: userId,
    eventId: eventId,
    updatedAtMs: updatedAtMs,
  );
}

SyncOutboxData row({
  required String entityType,
  required String entityId,
  required String op,
  Map<String, dynamic>? payload,
  String? precondition,
}) {
  return SyncOutboxData(
    id: 'op-$entityType-$op-$entityId',
    entityType: entityType,
    entityId: entityId,
    op: op,
    precondition: precondition,
    payload: jsonEncode(payload ?? const <String, dynamic>{}),
    status: SyncStatus.pending,
    createdAtMs: 0,
    attempts: 0,
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late EventRemoteDataSource events;
  late TicketRemoteDataSource tickets;
  late SyncHandlers handlers;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    events = FirestoreEventRemoteDataSource(firestore: firestore);
    tickets = FirestoreTicketRemoteDataSource(firestore: firestore);
    handlers = SyncHandlers(events: events, tickets: tickets);
  });

  group('event', () {
    test('create puis update puis delete', () async {
      await handlers.apply(row(
        entityType: SyncEntityType.event,
        entityId: 'ev1',
        op: SyncOp.create,
        payload: event().toJson(),
      ));
      await handlers.apply(row(
        entityType: SyncEntityType.event,
        entityId: 'ev1',
        op: SyncOp.update,
        payload: event(title: 'Renommé', updatedAtMs: 5).toJson(),
      ));

      var fetched = await events.fetchEventById('ev1');
      expect(fetched!.title, 'Renommé');
      expect(fetched.updatedAtMs, 5);

      await events.assignRole('ev1', 'u1', Role.organiser);
      await handlers.apply(row(
        entityType: SyncEntityType.event,
        entityId: 'ev1',
        op: SyncOp.delete,
      ));

      fetched = await events.fetchEventById('ev1');
      expect(fetched, isNull);
      expect(await events.fetchRoles('ev1'), isEmpty);
      expect(
        (await firestore
                .collection('events')
                .doc('ev1')
                .collection('tickets')
                .get())
            .docs,
        isEmpty,
      );
    });
  });

  group('role', () {
    test('assign applique arrayUnion (idempotent)', () async {
      await events.createEvent(event());
      for (var i = 0; i < 2; i++) {
        await handlers.apply(row(
          entityType: SyncEntityType.role,
          entityId: 'ev1',
          op: SyncOp.assign,
          payload: {'event_id': 'ev1', 'user_id': 'u1', 'role': 'controller'},
        ));
      }
      await handlers.apply(row(
        entityType: SyncEntityType.role,
        entityId: 'ev1',
        op: SyncOp.assign,
        payload: {'event_id': 'ev1', 'user_id': 'u1', 'role': 'organiser'},
      ));

      final roles = await events.fetchRoles('ev1');
      final mine = roles.firstWhere((r) => r.userId == 'u1');
      expect(mine.roles.toSet(), {Role.organiser, Role.controller});
    });
  });

  group('ticket', () {
    test('generate persiste le billet côté distant', () async {
      await events.createEvent(event());
      await handlers.apply(row(
        entityType: SyncEntityType.ticket,
        entityId: 'ev1',
        op: SyncOp.generate,
        payload: ticket().toJson(),
      ));

      final fetched = await tickets.fetchEventTickets('ev1');
      expect(fetched.single.id, 't1');
      expect(fetched.single.status, TicketStatus.unused);
    });

    test('acquire attribue le billet à l’acheteur', () async {
      await events.createEvent(event());
      await handlers.apply(row(
        entityType: SyncEntityType.ticket,
        entityId: 'ev1',
        op: SyncOp.generate,
        payload: ticket().toJson(),
      ));

      await handlers.apply(row(
        entityType: SyncEntityType.ticket,
        entityId: 't1',
        op: SyncOp.acquire,
        precondition: jsonEncode({'status': 'unused'}),
        payload: {'event_id': 'ev1', 'ticket_id': 't1', 'user_id': 'buyer'},
      ));

      final after = await tickets.fetchTicket('ev1', 't1');
      expect(after!.status, TicketStatus.valid);
      expect(after.userId, 'buyer');
    });

    test('acquire en conflit (déjà pris) lève TicketStateConflictException', () async {
      await events.createEvent(event());
      await handlers.apply(row(
        entityType: SyncEntityType.ticket,
        entityId: 'ev1',
        op: SyncOp.generate,
        payload: ticket().toJson(),
      ));
      await tickets.claimTicket(eventId: 'ev1', ticketId: 't1', userId: 'u1');

      await expectLater(
        handlers.apply(row(
          entityType: SyncEntityType.ticket,
          entityId: 't1',
          op: SyncOp.acquire,
          payload: {'event_id': 'ev1', 'ticket_id': 't1', 'user_id': 'u2'},
        )),
        throwsA(isA<TicketStateConflictException>()),
      );
    });

    test('validate fait passer VALID → USED', () async {
      await events.createEvent(event());
      await handlers.apply(row(
        entityType: SyncEntityType.ticket,
        entityId: 'ev1',
        op: SyncOp.generate,
        payload: ticket(status: TicketStatus.valid, userId: 'u1').toJson(),
      ));

      await handlers.apply(row(
        entityType: SyncEntityType.ticket,
        entityId: 't1',
        op: SyncOp.validate,
        precondition: jsonEncode({'status': 'valid'}),
        payload: {'event_id': 'ev1', 'ticket_id': 't1'},
      ));

      final after = await tickets.fetchTicket('ev1', 't1');
      expect(after!.status, TicketStatus.used);
    });

    test('validate en conflit (unused) lève TicketStateConflictException', () async {
      await events.createEvent(event());
      await handlers.apply(row(
        entityType: SyncEntityType.ticket,
        entityId: 'ev1',
        op: SyncOp.generate,
        payload: ticket().toJson(),
      ));

      await expectLater(
        handlers.apply(row(
          entityType: SyncEntityType.ticket,
          entityId: 't1',
          op: SyncOp.validate,
          payload: {'event_id': 'ev1', 'ticket_id': 't1'},
        )),
        throwsA(isA<TicketStateConflictException>()),
      );
    });
  });

  test('entité inconnue → erreur de programme (StateError)', () async {
    await expectLater(
      handlers.apply(SyncOutboxData(
        id: 'x',
        entityType: 'machine',
        entityId: 'e1',
        op: SyncOp.create,
        payload: '{}',
        status: SyncStatus.pending,
        createdAtMs: 0,
        attempts: 0,
      )),
      throwsA(isA<StateError>()),
    );
  });
}