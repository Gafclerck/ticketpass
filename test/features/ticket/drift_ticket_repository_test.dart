import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/database/app_database.dart';
import 'package:ticketpass/features/ticket/data/repositories/drift_ticket_repository.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket_status.dart';

void main() {
  late AppDatabase database;
  late DriftTicketRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftTicketRepository(database);
  });

  tearDown(() => database.close());

  group('DriftTicketRepository (UC15)', () {
    test('UC4 generateTickets persiste des billets unused en base', () async {
      final generated = await repository.generateTickets('event-1', 3);

      expect(generated, hasLength(3));
      expect(generated.every((t) => t.status == TicketStatus.unused), isTrue);

      final forEvent = await repository.getTicketsForEvent('event-1');
      expect(forEvent, hasLength(3));
    });

    test('UC7 importTicket attache un billet unused et le passe VALID', () async {
      final generated = await repository.generateTickets('event-1', 1);
      final ticket = generated.single;

      final imported = await repository.importTicket(
        ticket.uniqueCode,
        userId: 'user-1',
      );

      expect(imported.userId, 'user-1');
      expect(imported.status, TicketStatus.valid);

      final reread = await repository.getTicket(ticket.id);
      expect(reread.userId, 'user-1');
      expect(reread.status, TicketStatus.valid);
    });

    test('UC7 code inconnu lève une exception', () async {
      expect(
        () => repository.importTicket('code-inconnu', userId: 'user-1'),
        throwsA(isA<Exception>()),
      );
    });

    test('UC7 un billet déjà attribué ne peut pas être réimporté', () async {
      final generated = await repository.generateTickets('event-1', 1);
      final ticket = generated.single;
      await repository.importTicket(ticket.uniqueCode, userId: 'user-1');

      expect(
        () => repository.importTicket(ticket.uniqueCode, userId: 'user-2'),
        throwsA(isA<Exception>()),
      );
    });

    test('UC9 getMyTickets ne retourne que les billets de l’utilisateur', () async {
      final generated = await repository.generateTickets('event-1', 2);
      await repository.importTicket(generated[0].uniqueCode, userId: 'user-1');

      final mine = await repository.getMyTickets('user-1');
      final autre = await repository.getMyTickets('user-2');

      expect(mine, hasLength(1));
      expect(autre, isEmpty);
    });
  });
}
