import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/ticket/data/repositories/fake_ticket_repository.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket_status.dart';

void main() {
  group('ValidateTicket (UC11)', () {
    test('passe un billet VALID à USED', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);
      await repository.generateTickets('ev', 1);
      final acquired = await repository.acquireTicket('ev', userId: 'u1');
      expect(acquired.status, TicketStatus.valid);

      final used = await repository.validateTicket(acquired.id);

      expect(used.status, TicketStatus.used);
      expect(used.eventId, 'ev');
    });

    test('refuse un billet déjà utilisé', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);
      await repository.generateTickets('ev', 1);
      final acquired = await repository.acquireTicket('ev', userId: 'u1');

      await repository.validateTicket(acquired.id);

      expect(
        () => repository.validateTicket(acquired.id),
        throwsA(isA<Exception>()),
      );
    });

    test('refuse un billet non attribué (unused)', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);
      await repository.generateTickets('ev', 1);
      final unused = (await repository.getTicketsForEvent('ev')).first;

      expect(
        () => repository.validateTicket(unused.id),
        throwsA(isA<Exception>()),
      );
    });

    test('refuse un billet inconnu', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);

      expect(
        () => repository.validateTicket('inconnu'),
        throwsA(isA<Exception>()),
      );
    });
  });
}