import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/ticket/data/repositories/fake_ticket_repository.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket_status.dart';

void main() {
  const demoUser = 'demo-user-id';

  group('FakeTicketRepository (UC8/UC9)', () {
    test('UC9 getMyTickets ne retourne que les billets de l’utilisateur',
        () async {
      final repository = FakeTicketRepository.demo(
        demoUserId: demoUser,
        latency: Duration.zero,
      );

      final tickets = await repository.getMyTickets(demoUser);

      expect(tickets.length, 4);
      expect(tickets.every((t) => t.userId == demoUser), isTrue);
    });

    test('UC9 un utilisateur sans billet obtient une liste vide', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);

      final tickets = await repository.getMyTickets('autre-user');

      expect(tickets, isEmpty);
    });

    test('UC8 getTicket retourne le bon billet', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);

      final ticket = await repository.getTicket('ticket-0003');

      expect(ticket.id, 'ticket-0003');
      expect(ticket.status, TicketStatus.valid);
    });

    test('UC8 getTicket inconnu lève une exception', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);

      expect(
        () => repository.getTicket('inconnu'),
        throwsA(isA<Exception>()),
      );
    });
  });
}