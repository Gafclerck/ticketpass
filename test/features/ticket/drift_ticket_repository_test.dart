import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/database/app_database.dart' as db;
import 'package:ticketpass/features/ticket/data/repositories/drift_ticket_repository.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket_status.dart';
import 'package:ticketpass/features/ticket/domain/usecases/generate_tickets.dart';
import '../../helpers/test_database.dart';

/// Spécification des règles métier des billets sur la base locale (drive).
void main() {
  late db.AppDatabase database;
  late DriftTicketRepository repository;

  setUp(() async {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = DriftTicketRepository(database);
    // Événements de test (FK `eventId`). Les `userId` sont des identifiants
    // Firebase en texte simple : aucune ligne `Users` n'est nécessaire.
    await insertEvent(database, 'ev');
    await insertEvent(database, 'ev2');
  });

  tearDown(() => database.close());

  group('UC8/UC9 — consultation & historique', () {
    test('getMyTickets ne retourne que les billets de l’utilisateur', () async {
      await insertTicket(database,
          id: 't1', status: TicketStatus.valid, userId: 'demo-user-id', eventId: 'ev');
      await insertTicket(database,
          id: 't2', status: TicketStatus.used, userId: 'demo-user-id', eventId: 'ev');
      await insertTicket(database,
          id: 't3', status: TicketStatus.used, userId: 'autre', eventId: 'ev');

      final tickets = await repository.getMyTickets('demo-user-id');

      expect(tickets.map((t) => t.id).toSet(), {'t1', 't2'});
    });

    test('getTicket retourne le billet, inconnu → exception', () async {
      await insertTicket(database,
          id: 't1', status: TicketStatus.valid, userId: 'demo-user-id', eventId: 'ev');

      final ticket = await repository.getTicket('t1');

      expect(ticket.id, 't1');
      expect(ticket.status, TicketStatus.valid);
      await expectLater(repository.getTicket('inconnu'), throwsException);
    });
  });

  group('UC4 — generateTickets', () {
    test('génère N billets unused et met le compteur de l’événement à jour',
        () async {
      final tickets = await repository.generateTickets('ev', 3);

      expect(tickets.length, 3);
      expect(tickets.every((t) => t.status == TicketStatus.unused), isTrue);
      expect(tickets.every((t) => t.eventId == 'ev'), isTrue);

      final event = await (database.select(database.events)
            ..where((e) => e.id.equals('ev')))
          .getSingle();
      expect(event.ticketsNumber, 3);
    });

    test('l’UC rejette une quantité nulle ou négative', () {
      final usecase = GenerateTickets(repository);

      expect(() => usecase.call('ev', 0), throwsArgumentError);
      expect(() => usecase.call('ev', -1), throwsArgumentError);
    });

    test('refuse la génération pour un événement inconnu (rollback)', () async {
      await expectLater(
        repository.generateTickets('inconnu', 2),
        throwsException,
      );
      // Le batch d'insertion a été annulé : aucun billet orphelin.
      expect(await repository.getTicketsForEvent('inconnu'), isEmpty);
    });
  });

  group('UC19 — acquireTicket', () {
    test('attribue un billet unused et le passe VALID', () async {
      await repository.generateTickets('ev', 2);

      final acquired = await repository.acquireTicket('ev', userId: 'buyer-1');

      expect(acquired.userId, 'buyer-1');
      expect(acquired.status, TicketStatus.valid);
    });

    test('refuse le double billet du même utilisateur', () async {
      await repository.generateTickets('ev', 2);

      await repository.acquireTicket('ev', userId: 'buyer-1');

      await expectLater(
        repository.acquireTicket('ev', userId: 'buyer-1'),
        throwsException,
      );
    });

    test('refuse quand le stock est épuisé ou indisponible', () async {
      await repository.generateTickets('ev', 1);

      await repository.acquireTicket('ev', userId: 'buyer-1');

      await expectLater(
        repository.acquireTicket('ev', userId: 'buyer-2'),
        throwsException,
      );
    });

    test('refuse un acheteur non identifié', () async {
      await repository.generateTickets('ev', 2);

      await expectLater(
        repository.acquireTicket('ev', userId: '  '),
        throwsException,
      );
    });
  });

  group('UC11 — validateTicket', () {
    test('passe un billet VALID à USED', () async {
      await repository.generateTickets('ev', 1);
      final acquired = await repository.acquireTicket('ev', userId: 'u1');

      final used = await repository.validateTicket(acquired.id);

      expect(used.status, TicketStatus.used);
      expect(used.eventId, 'ev');
    });

    test('refuse un billet déjà utilisé, non attribué ou inconnu', () async {
      await repository.generateTickets('ev', 2);
      final acquired = await repository.acquireTicket('ev', userId: 'u1');
      await repository.validateTicket(acquired.id);
      final unused = (await repository.getTicketsForEvent('ev'))
          .firstWhere((t) => t.userId.isEmpty);

      await expectLater(repository.validateTicket(acquired.id), throwsException);
      await expectLater(repository.validateTicket(unused.id), throwsException);
      await expectLater(repository.validateTicket('inconnu'), throwsException);
    });
  });

  group('participants & UC6', () {
    test('getParticipants retourne les détenteurs distincts, sans les unused',
        () async {
      await repository.generateTickets('ev', 3);
      await repository.acquireTicket('ev', userId: 'user-a');
      await repository.acquireTicket('ev', userId: 'user-b');

      final participants = await repository.getParticipants('ev');

      expect(participants.toSet(), {'user-a', 'user-b'});
      expect(await repository.getParticipants('ev2'), isEmpty);
    });

    test('getTicketsForEvent filtre par événement', () async {
      await repository.generateTickets('ev', 2);
      await repository.generateTickets('ev2', 1);

      final tickets = await repository.getTicketsForEvent('ev');

      expect(tickets.length, 2);
      expect(tickets.every((t) => t.eventId == 'ev'), isTrue);
    });
  });
}