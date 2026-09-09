import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

/// UC7 — Recevoir / importer un billet.
class ImportTicket {
  final TicketRepository repository;

  const ImportTicket(this.repository);

  Future<Ticket> call(String uniqueCode, {required String userId}) {
    return repository.importTicket(uniqueCode, userId: userId);
  }
}