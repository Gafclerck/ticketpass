import 'package:ticketpass/features/ticket/domain/repositories/ticket_repository.dart';

import '../entities/ticket.dart';

class GetTicketsForEvent {
  final TicketRepository repository;
  const GetTicketsForEvent(this.repository);

  Future<List<Ticket>> call(String eventId) {
    return repository.getTicketsForEvent(eventId);
  }
}
