import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

/// UC9 — Historique des billets d'un utilisateur.
class GetMyTickets {
  final TicketRepository repository;

  const GetMyTickets(this.repository);

  Future<List<Ticket>> call(String userId) {
    return repository.getMyTickets(userId);
  }
}