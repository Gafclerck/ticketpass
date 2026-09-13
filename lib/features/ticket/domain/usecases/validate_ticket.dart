import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

/// UC11 — Validation d'un billet (transition `VALID` → `USED`).
///
/// Appelé par l'organisateur ou le contrôleur après vérification du QR (UC10).
class ValidateTicket {
  final TicketRepository repository;

  const ValidateTicket(this.repository);

  Future<Ticket> call(String ticketId) {
    return repository.validateTicket(ticketId);
  }
}