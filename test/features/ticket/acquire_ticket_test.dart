import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/ticket/data/repositories/fake_ticket_repository.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket_status.dart';
import 'package:ticketpass/features/ticket/domain/usecases/acquire_ticket.dart';

void main() {
  group('AcquireTicket (UC19)', () {
    const buyer = 'buyer-1';

    test('attribue un billet unused et le passe VALID', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);
      await repository.generateTickets('event-19', 3);
      final usecase = AcquireTicket(repository);

      final acquired = await usecase.call('event-19', userId: buyer);

      expect(acquired.userId, buyer);
      expect(acquired.status, TicketStatus.valid);

      final owned = await repository.getMyTickets(buyer);
      expect(owned.map((t) => t.id), contains(acquired.id));
    });

    test('refuse le double achat pour le même utilisateur', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);
      await repository.generateTickets('event-19', 2);
      final usecase = AcquireTicket(repository);

      await usecase.call('event-19', userId: buyer);

      expect(
        () => usecase.call('event-19', userId: buyer),
        throwsA(isA<Exception>()),
      );
    });

    test('refuse quand il n’y a plus de billet disponible', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);
      final usecase = AcquireTicket(repository);

      expect(
        () => usecase.call('event-sans-billet', userId: buyer),
        throwsA(isA<Exception>()),
      );
    });

    test('un billet pris n’est plus disponible pour un autre utilisateur', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);
      await repository.generateTickets('event-19', 1);
      final usecase = AcquireTicket(repository);

      await usecase.call('event-19', userId: 'buyer-a');

      expect(
        () => usecase.call('event-19', userId: 'buyer-b'),
        throwsA(isA<Exception>()),
      );
    });
  });
}