import '../entities/ticket.dart';

/// Contrat du dépôt de billets — couvre les UC de l'Epic 3 (porteur).
///
/// UC7  : import d'un billet (via code unique / QR) depuis un statut non
///        attribué (`unused`) vers un billet possédé par un utilisateur.
/// UC8  : consultation d'un billet donné.
/// UC9  : historique des billets possédés par un utilisateur.
abstract class TicketRepository {
  Future<Ticket> importTicket(String uniqueCode, {required String userId});

  Future<Ticket> getTicket(String ticketId);

  Future<List<Ticket>> getMyTickets(String userId);

  //   UC4 - Ajout de la methode, generateTickets

  Future<List<Ticket>> generateTickets(String eventId, int quantity);

  // UC4 -  Afficher les tickets génèrés d'un organisateur

  Future<List<Ticket>> getTicketsForEvent(String eventId);
}
