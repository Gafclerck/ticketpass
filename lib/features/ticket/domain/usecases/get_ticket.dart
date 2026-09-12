import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

/// UC8 — Consulter un billet.
class GetTicket {
  final TicketRepository repository;

  const GetTicket(this.repository);

  Future<Ticket> call(String ticketId) {
    return repository.getTicket(ticketId);
  }
}