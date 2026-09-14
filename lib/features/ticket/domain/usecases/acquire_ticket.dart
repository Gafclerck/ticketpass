import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

/// UC19 — distribution automatique d'un billet à un utilisateur.
class AcquireTicket {
  final TicketRepository repository;

  const AcquireTicket(this.repository);

  Future<Ticket> call(String eventId, {required String userId}) {
    return repository.acquireTicket(eventId, userId: userId);
  }
}