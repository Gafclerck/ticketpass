import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/database/app_database.dart';
import 'package:ticketpass/core/sync/pull_service.dart';
import 'package:ticketpass/core/sync/sync_store.dart';
import 'package:ticketpass/features/auth/domain/entities/role.dart';
import 'package:ticketpass/features/event/data/datasources/event_remote_datasource.dart';
import 'package:ticketpass/features/event/data/models/event_model.dart';
import 'package:ticketpass/features/event/domain/entities/event_status.dart';
import 'package:ticketpass/features/event/domain/entities/event_type.dart';
import 'package:ticketpass/features/ticket/data/datasources/ticket_remote_datasource.dart';
import 'package:ticketpass/features/ticket/data/models/ticket_model.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket_status.dart';

import '../../helpers/test_database.dart';

EventModel remoteEvent({String id = 'ev1'}) => EventModel(
      id: id,
      title: 'Event $id',
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

TicketModel remoteTicket({String id = 't1', String eventId = 'ev1'}) =>
    TicketModel(
      id: id,
      status: TicketStatus.unused,
      uniqueCode: 'remote-uc-$id',
      qrSignature: 'sig-$id',
      userId: '',
      eventId: eventId,
      updatedAtMs: 0,
    );

void main() {
  late FakeFirebaseFirestore firestore;
  late AppDatabase database;
  late SyncStore store;
  late PullService pull;
  late FirestoreEventRemoteDataSource remoteEvents;
  late FirestoreTicketRemoteDataSource remoteTickets;

  setUp(() {
    silenceDriftWarnings();
    firestore = FakeFirebaseFirestore();
    database = AppDatabase(NativeDatabase.memory());
    store = SyncStore(database);
    remoteEvents = FirestoreEventRemoteDataSource(firestore: firestore);
    remoteTickets = FirestoreTicketRemoteDataSource(firestore: firestore);
    pull = PullService(
      database: database,
      events: remoteEvents,
      tickets: remoteTickets,
      store: store,
    );
  });

  tearDown(() => database.close());

  Future<List<Event>> localEvents() => database.select(database.events).get();
  Future<List<Ticket>> localTickets() =>
      database.select(database.tickets).get();
  Future<List<EventUserRole>> localRoles() =>
      database.select(database.eventUserRoles).get();

  test('importe événements, compteur max(local, count) et rôles distants', () async {
    await remoteEvents.createEvent(remoteEvent(id: 'ev1'));
    await remoteTickets.saveGeneratedTickets([
      remoteTicket(id: 't1', eventId: 'ev1'),
      remoteTicket(id: 't2', eventId: 'ev1'),
    ]);
    await remoteEvents.assignRole('ev1', 'u-org', Role.organiser);

    await pull.pullAll(userId: 'u-user');

    final events = await localEvents();
    expect(events.map((e) => e.id), contains('ev1'));
    expect(events.single.ticketsNumber, 2);
    final roles = await localRoles();
    expect(
      roles.any((r) => r.eventId == 'ev1' && r.userId == 'u-org'),
      isTrue,
    );
  });

  test('ne supprime pas un événement à l’enqueue local (pending)', () async {
    await insertEvent(database, 'mine');
    await store.enqueue(
      entityType: SyncEntityType.event,
      entityId: 'mine',
      op: SyncOp.create,
      payload: const {},
    );

    await pull.pullAll(userId: 'u-user');

    expect((await localEvents()).map((e) => e.id), contains('mine'));
  });

  test('ne recrée pas un événement tombstoné (delete pendants)', () async {
    await remoteEvents.createEvent(remoteEvent(id: 'ghost'));
    await store.enqueue(
      entityType: SyncEntityType.event,
      entityId: 'ghost',
      op: SyncOp.delete,
    );

    await pull.pullAll(userId: 'u-user');

    expect((await localEvents()).map((e) => e.id), isNot(contains('ghost')));
  });

  test('supprime les événements locaux absents côté distant', () async {
    await insertEvent(database, 'gone');

    await pull.pullAll(userId: 'u-user');

    expect(await localEvents(), isEmpty);
  });

  test('mes billets distants importés ; les disparus locaux retirés', () async {
    await remoteEvents.createEvent(remoteEvent(id: 'ev1'));
    await remoteTickets.saveGeneratedTickets([
      remoteTicket(id: 'tOwned', eventId: 'ev1'),
      remoteTicket(id: 'tOther', eventId: 'ev1'),
    ]);
    await remoteTickets.claimTicket(
      eventId: 'ev1',
      ticketId: 'tOwned',
      userId: 'u-user',
    );
    await insertEvent(database, 'ev1');
    await insertTicket(
      database,
      id: 'ghostTicket',
      status: TicketStatus.valid,
      userId: 'u-user',
      eventId: 'ev1',
    );

    await pull.pullAll(userId: 'u-user');

    final tickets = await localTickets();
    final byId = {for (final t in tickets) t.id: t};
    expect(byId.containsKey('tOwned'), isTrue);
    expect(byId.containsKey('tOther'), isFalse); // pas staff : seuls mes billets.
    expect(byId.containsKey('ghostTicket'), isFalse);
  });

  test('tire les billets des événements dont je suis staff (organisateur)', () async {
    await remoteEvents.createEvent(remoteEvent(id: 'evStaff'));
    await remoteEvents.assignRole('evStaff', 'u-user', Role.organiser);
    await remoteTickets.saveGeneratedTickets([
      remoteTicket(id: 's1', eventId: 'evStaff'),
      remoteTicket(id: 's2', eventId: 'evStaff'),
    ]);

    await pull.pullAll(userId: 'u-user');

    final staffTickets = (await localTickets())
        .where((t) => t.eventId == 'evStaff')
        .toList();
    expect(staffTickets, hasLength(2));
  });

  test('un billet avec acquire pendante n’est pas écrasé par le pull', () async {
    // État local : achat local fait (statut valid, userId me).
    await insertEvent(database, 'ev1');
    await insertTicket(
      database,
      id: 'tA',
      status: TicketStatus.valid,
      userId: 'u-user',
      eventId: 'ev1',
    );
    await store.enqueue(
      entityType: SyncEntityType.ticket,
      entityId: 'tA',
      op: SyncOp.acquire,
      precondition: '{"status": "unused"}',
      payload: const {'event_id': 'ev1', 'ticket_id': 'tA', 'user_id': 'u-user'},
    );
    // Côté distant, le même billet a été attribué (uniqueCode évolué).
    await remoteEvents.createEvent(remoteEvent(id: 'ev1'));
    await remoteTickets.saveGeneratedTickets([
      remoteTicket(id: 'tA', eventId: 'ev1'),
    ]);
    await remoteTickets.claimTicket(
      eventId: 'ev1',
      ticketId: 'tA',
      userId: 'u-user',
    );

    await pull.pullAll(userId: 'u-user');

    final local = (await localTickets()).singleWhere((t) => t.id == 'tA');
    expect(local.userId, 'u-user');
    expect(local.uniqueCode, 'uc-tA'); // valeur locale, pas la distante.
  });

  test('un rôle assign pendants est conservé au réassemblage des rôles', () async {
    await remoteEvents.createEvent(remoteEvent(id: 'ev1'));
    await insertEvent(database, 'ev1');
    await database.into(database.eventUserRoles).insert(
      EventUserRolesCompanion.insert(
        userId: 'uX',
        eventId: 'ev1',
        role: Role.controller,
      ),
    );
    await store.enqueue(
      entityType: SyncEntityType.role,
      entityId: 'ev1',
      op: SyncOp.assign,
      payload: const {'event_id': 'ev1', 'user_id': 'uX', 'role': 'controller'},
    );

    await pull.pullAll(userId: 'u-user');

    final roles = await localRoles();
    expect(
      roles.any((r) => r.userId == 'uX' && r.role == Role.controller),
      isTrue,
    );
  });
}