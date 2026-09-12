import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/ticket/data/repositories/fake_ticket_repository.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket_status.dart';
import 'package:ticketpass/features/ticket/domain/usecases/generate_tickets.dart';

void main() {
  group('GenerateTickets (UC4)', () {
    test('génère le bon nombre de billets, tous unused', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);
      final usecase = GenerateTickets(repository);

      final tickets = await usecase.call('event-42', 3);

      expect(tickets.length, 3);
      expect(tickets.every((t) => t.status == TicketStatus.unused), isTrue);
      expect(tickets.every((t) => t.eventId == 'event-42'), isTrue);
    });

    test('les billets générés sont bien ajoutés au repository', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);
      final usecase = GenerateTickets(repository);

      final generated = await usecase.call('event-42', 2);

      for (final ticket in generated) {
        final stored = await repository.getTicket(ticket.id);
        expect(stored.id, ticket.id);
      }
    });

    test('rejette une quantité nulle ou négative', () {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);
      final usecase = GenerateTickets(repository);

      expect(
            () => usecase.call('event-42', 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
            () => usecase.call('event-42', -1),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
