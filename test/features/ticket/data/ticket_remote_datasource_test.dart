import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/ticket/data/datasources/ticket_remote_datasource.dart';
import 'package:ticketpass/features/ticket/data/models/ticket_model.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket_status.dart';

TicketModel ticket({
  String id = 't1',
  String eventId = 'ev1',
  TicketStatus status = TicketStatus.unused,
  String userId = '',
}) {
  return TicketModel(
    id: id,
    status: status,
    uniqueCode: 'uc-$id',
    qrSignature: 'sig-$id',
    userId: userId,
    eventId: eventId,
    updatedAtMs: 100,
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreTicketRemoteDataSource datasource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = FirestoreTicketRemoteDataSource(firestore: firestore);
  });

  group('saveGeneratedTickets / fetch', () {
    test('persiste puis relit les billets d’un événement', () async {
      await datasource.saveGeneratedTickets([
        ticket(id: 't1'),
        ticket(id: 't2'),
      ]);

      final fetched = await datasource.fetchEventTickets('ev1');
      expect(fetched.map((t) => t.id).toSet(), {'t1', 't2'});
      expect(fetched.every((t) => t.status == TicketStatus.unused), isTrue);
    });

    test('fetchTicket retourne null si inconnu et relit sinon', () async {
      expect(await datasource.fetchTicket('ev1', 'inconnu'), isNull);

      await datasource.saveGeneratedTickets([ticket(id: 't1')]);
      final fetched = await datasource.fetchTicket('ev1', 't1');
      expect(fetched!.uniqueCode, 'uc-t1');
    });

    test('fetchMyTickets (collectionGroup) ne filtre que le userId visé', () async {
      await datasource.saveGeneratedTickets([
        ticket(id: 'a', userId: 'u1', status: TicketStatus.valid),
        ticket(id: 'b', userId: 'u2', status: TicketStatus.valid),
        ticket(id: 'c', userId: 'u1', status: TicketStatus.valid),
      ]);

      final mine = await datasource.fetchMyTickets('u1');
      expect(mine.map((t) => t.id).toSet(), {'a', 'c'});
    });
  });

  group('claimTicket (CAS)', () {
    test('acquiert un billet libre pour un utilisateur', () async {
      await datasource.saveGeneratedTickets([ticket(id: 't1')]);

      final claimed = await datasource.claimTicket(
        eventId: 'ev1',
        ticketId: 't1',
        userId: 'buyer',
      );
      expect(claimed.status, TicketStatus.valid);
      expect(claimed.userId, 'buyer');

      final after = await datasource.fetchTicket('ev1', 't1');
      expect(after!.status, TicketStatus.valid);
      expect(after.userId, 'buyer');
    });

    test('rejeu du même acheteur = succès (idempotent)', () async {
      await datasource.saveGeneratedTickets([ticket(id: 't1')]);
      await datasource.claimTicket(
        eventId: 'ev1',
        ticketId: 't1',
        userId: 'buyer',
      );

      final again = await datasource.claimTicket(
        eventId: 'ev1',
        ticketId: 't1',
        userId: 'buyer',
      );
      expect(again.status, TicketStatus.valid);
      expect(again.userId, 'buyer');
    });

    test('conflit : déjà attribué à un autre', () async {
      await datasource.saveGeneratedTickets([ticket(id: 't1')]);
      await datasource.claimTicket(
        eventId: 'ev1',
        ticketId: 't1',
        userId: 'u1',
      );

      await expectLater(
        datasource.claimTicket(eventId: 'ev1', ticketId: 't1', userId: 'u2'),
        throwsA(isA<TicketStateConflictException>()),
      );
    });

    test('conflit : billet déjà validé', () async {
      await datasource.saveGeneratedTickets([ticket(id: 't1')]);
      await datasource.claimTicket(
        eventId: 'ev1',
        ticketId: 't1',
        userId: 'u1',
      );
      await datasource.validateTicketEntry(eventId: 'ev1', ticketId: 't1');

      await expectLater(
        datasource.claimTicket(eventId: 'ev1', ticketId: 't1', userId: 'u2'),
        throwsA(isA<TicketStateConflictException>()),
      );
    });

    test('conflit : billet inexistant', () async {
      await expectLater(
        datasource.claimTicket(eventId: 'ev1', ticketId: 'x', userId: 'u1'),
        throwsA(isA<TicketStateConflictException>()),
      );
    });
  });

  group('validateTicketEntry (CAS)', () {
    test('fait passer VALID -> USED', () async {
      await datasource.saveGeneratedTickets([ticket(id: 't1')]);
      await datasource.claimTicket(
        eventId: 'ev1',
        ticketId: 't1',
        userId: 'u1',
      );

      final used = await datasource.validateTicketEntry(
        eventId: 'ev1',
        ticketId: 't1',
      );
      expect(used.status, TicketStatus.used);
      expect(used.userId, 'u1');
    });

    test('rejeu d’un billet déjà used = succès (idempotent)', () async {
      await datasource.saveGeneratedTickets([ticket(id: 't1')]);
      await datasource.claimTicket(
        eventId: 'ev1',
        ticketId: 't1',
        userId: 'u1',
      );
      await datasource.validateTicketEntry(eventId: 'ev1', ticketId: 't1');

      final again = await datasource.validateTicketEntry(
        eventId: 'ev1',
        ticketId: 't1',
      );
      expect(again.status, TicketStatus.used);
    });

    test('conflit : rejette un billet unused', () async {
      await datasource.saveGeneratedTickets([ticket(id: 't1')]);

      await expectLater(
        datasource.validateTicketEntry(eventId: 'ev1', ticketId: 't1'),
        throwsA(isA<TicketStateConflictException>()),
      );
    });
  });
}