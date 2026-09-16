import 'dart:convert';

import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/database/app_database.dart';
import 'package:ticketpass/core/sync/sync_engine.dart';
import 'package:ticketpass/core/sync/sync_handlers.dart';
import 'package:ticketpass/core/sync/sync_store.dart';
import 'package:ticketpass/features/event/data/datasources/event_remote_datasource.dart';
import 'package:ticketpass/features/event/data/models/event_model.dart';
import 'package:ticketpass/features/event/domain/entities/event_status.dart';
import 'package:ticketpass/features/event/domain/entities/event_type.dart';
import 'package:ticketpass/features/ticket/data/datasources/ticket_remote_datasource.dart';
import 'package:ticketpass/features/ticket/data/models/ticket_model.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket_status.dart';

import '../../helpers/test_database.dart' show silenceDriftWarnings;

class _FailingHandlers extends SyncHandlers {
  const _FailingHandlers({required super.events, required super.tickets});

  @override
  Future<void> apply(SyncOutboxData row) async {
    throw Exception('réseau KO');
  }
}

EventModel remoteEvent({String id = 'ev1'}) {
  return EventModel(
    id: id,
    title: 'Concert $id',
    description: '',
    eventDate: DateTime(2026, 10, 1),
    startTime: DateTime(2026, 10, 1, 20),
    brandingUrl: '',
    type: EventType.concert,
    brandName: '',
    eventPlace: '',
    maxPlaces: 10,
    status: EventStatus.upcoming,
    updatedAtMs: 0,
  );
}

TicketModel unusedTicket({String id = 't1', String eventId = 'ev1'}) {
  return TicketModel(
    id: id,
    status: TicketStatus.unused,
    uniqueCode: 'uc-$id',
    qrSignature: 'sig-$id',
    userId: '',
    eventId: eventId,
    updatedAtMs: 0,
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late AppDatabase database;
  late SyncStore store;
  late SyncHandlers handlers;
  late SyncEngine engine;

  setUp(() {
    silenceDriftWarnings();
    firestore = FakeFirebaseFirestore();
    database = AppDatabase(NativeDatabase.memory());
    store = SyncStore(database);
    handlers = SyncHandlers(
      events: FirestoreEventRemoteDataSource(firestore: firestore),
      tickets: FirestoreTicketRemoteDataSource(firestore: firestore),
    );
    engine = SyncEngine(
      store: store,
      handlers: handlers,
      isOnline: () async => true,
    );
  });

  tearDown(() => database.close());

  Future<List<SyncOutboxData>> outboxRows() =>
      database.select(database.syncOutbox).get();

  test('draine la file : opérations poussées chez Firestore puis purgées', () async {
    final event = remoteEvent();
    await store.enqueue(
      entityType: SyncEntityType.event,
      entityId: event.id,
      op: SyncOp.create,
      payload: event.toJson(),
      nowMs: 1,
    );
    await store.enqueue(
      entityType: SyncEntityType.ticket,
      entityId: event.id,
      op: SyncOp.generate,
      payload: unusedTicket(eventId: event.id).toJson(),
      nowMs: 2,
    );

    final processed = await engine.runOnce();

    expect(processed, 2);
    final remote = FirestoreEventRemoteDataSource(firestore: firestore);
    final remoteTickets =
        FirestoreTicketRemoteDataSource(firestore: firestore);
    expect((await remote.fetchEventById(event.id))!.title, event.title);
    expect(
      (await remoteTickets.fetchEventTickets(event.id)).single.id,
      't1',
    );
    // done → purgées par clearFinished.
    expect(await outboxRows(), isEmpty);
  });

  test('hors-ligne : rien n’est traité', () async {
    await store.enqueue(
      entityType: SyncEntityType.event,
      entityId: 'ev1',
      op: SyncOp.create,
      payload: remoteEvent().toJson(),
    );
    final offlineEngine = SyncEngine(
      store: store,
      handlers: handlers,
      isOnline: () async => false,
    );

    expect(await offlineEngine.runOnce(), 0);
    expect(await store.pendingCount(), 1);
  });

  test('conflit CAS → ligne cancelled + \'onConflictPulled\' déclenché', () async {
    // Le billet est déjà attribué à u1 chez Firestore.
    final remoteTickets =
        FirestoreTicketRemoteDataSource(firestore: firestore);
    await remoteTickets.saveGeneratedTickets([unusedTicket()]);
    await remoteTickets.claimTicket(eventId: 'ev1', ticketId: 't1', userId: 'u1');

    await store.enqueue(
      entityType: SyncEntityType.ticket,
      entityId: 't1',
      op: SyncOp.acquire,
      precondition: jsonEncode({'status': 'unused'}),
      payload: {'event_id': 'ev1', 'ticket_id': 't1', 'user_id': 'u2'},
    );

    var pullRequested = false;
    final conflictEngine = SyncEngine(
      store: store,
      handlers: handlers,
      isOnline: () async => true,
      onConflictPulled: () => pullRequested = true,
    );

    await conflictEngine.runOnce();

    expect(pullRequested, isTrue);
    // Réglée en cancelled puis purgée par clearFinished : plus rien en file.
    expect(await outboxRows(), isEmpty);
    // Et le distant n'a pas été écrasé par l'acquire divergé.
    final remoteTicket = await remoteTickets.fetchTicket('ev1', 't1');
    expect(remoteTicket!.userId, 'u1');
  });

  test('échec réseau → retry : attempts incrémenté, backoff programmé', () async {
    final failingEngine = SyncEngine(
      store: store,
      handlers: _FailingHandlers(
        events: FirestoreEventRemoteDataSource(firestore: firestore),
        tickets: FirestoreTicketRemoteDataSource(firestore: firestore),
      ),
      isOnline: () async => true,
    );
    await store.enqueue(
      entityType: SyncEntityType.event,
      entityId: 'ev1',
      op: SyncOp.create,
      payload: remoteEvent().toJson(),
      nowMs: 1,
    );

    final before = DateTime.now().millisecondsSinceEpoch;
    final processed = await failingEngine.runOnce();

    expect(processed, 1);
    final row = (await outboxRows()).single;
    expect(row.status, SyncStatus.pending);
    expect(row.attempts, 1);
    expect(
      row.nextRetryAtMs,
      greaterThanOrEqualTo(before + SyncStore.backoffDelayMs(1)),
    );
  });

  test('lignes laissées en syncing par un cycle interrompu redeviennent pending', () async {
    await store.enqueue(
      entityType: SyncEntityType.event,
      entityId: 'ev1',
      op: SyncOp.create,
      payload: remoteEvent().toJson(),
      nowMs: 1,
    );
    await store.claimDue(nowMs: 100);
    expect((await outboxRows()).single.status, SyncStatus.syncing);

    await store.resetStuckSyncing();
    expect((await outboxRows()).single.status, SyncStatus.pending);
    expect(await store.pendingCount(), 1);
  });
}