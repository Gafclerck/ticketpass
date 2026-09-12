import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

class GenerateTickets {
  final TicketRepository repository;
  const GenerateTickets(this.repository);

  Future<List<Ticket>> call (String eventId, int quantity){
    if(quantity <= 0){
      throw ArgumentError('La quantité doit etre superieur à 0');
    }
    return repository.generateTickets(eventId, quantity);
  }
}