import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/ticket/data/repositories/fake_ticket_repository.dart';

void main() {
  group('GetParticipants', () {
    test('retourne les détenteurs distincts d’un événement', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);
      await repository.generateTickets('event-p', 3);
      await repository.acquireTicket('event-p', userId: 'user-a');
      await repository.acquireTicket('event-p', userId: 'user-b');

      final participants = await repository.getParticipants('event-p');

      expect(participants.toSet(), {'user-a', 'user-b'});
    });

    test('ignore les billets non attribués', () async {
      final repository = FakeTicketRepository.demo(latency: Duration.zero);
      await repository.generateTickets('event-p2', 1);

      expect(await repository.getParticipants('event-p2'), isEmpty);
    });
  });
}