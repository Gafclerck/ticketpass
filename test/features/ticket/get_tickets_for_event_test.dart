import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/ticket/data/repositories/fake_ticket_repository.dart';
import 'package:ticketpass/features/ticket/domain/usecases/get_tickets_for_event.dart';

void main() {
  group('GetTicketsForEvent (UC6)', () {
    test('retourne uniquement les billets de l’événement demandé', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);
      final usecase = GetTicketsForEvent(repository);

      // Le jeu de démo contient 6 billets, tous sur 'demo-event-id'.
      await repository.generateTickets('autre-event-id', 2);

      final tickets = await usecase.call('demo-event-id');

      expect(tickets.length, 6);
      expect(tickets.every((t) => t.eventId == 'demo-event-id'), isTrue);
    });

    test('retourne une liste vide pour un événement sans billet', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);
      final usecase = GetTicketsForEvent(repository);

      final tickets = await usecase.call('event-inconnu');

      expect(tickets, isEmpty);
    });
  });
}
