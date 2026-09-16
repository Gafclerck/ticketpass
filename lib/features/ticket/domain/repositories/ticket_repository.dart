import '../entities/ticket.dart';

/// Contrat du dépôt de billets — couvre les UC de l'Epic 3 (porteur).
///
/// L'import de billet (UC7) est supprimé : un billet s'obtient uniquement via
/// la distribution automatique [acquireTicket] (UC19) depuis le détail d'un
/// événement.
///
/// UC8  : consultation d'un billet donné.
/// UC9  : historique des billets possédés par un utilisateur.
/// UC19 : distribution automatique d'un billet à un utilisateur (achat).
abstract class TicketRepository {
  Future<Ticket> getTicket(String ticketId);

  Future<List<Ticket>> getMyTickets(String userId);

  //   UC4 - Ajout de la methode, generateTickets

  Future<List<Ticket>> generateTickets(String eventId, int quantity);

  // UC4 -  Afficher les tickets génèrés d'un organisateur

  Future<List<Ticket>> getTicketsForEvent(String eventId);

  // UC19 - Distribution automatique d'un billet disponible à [userId].

  Future<Ticket> acquireTicket(String eventId, {required String userId});

  // Participants d'un événement : ids des détenteurs de billets attribués.

  Future<List<String>> getParticipants(String eventId);

  // UC11 - Valider un billet (transition VALID -> USED) par l'organisateur ou
  // le contrôleur.

  Future<Ticket> validateTicket(String ticketId);
}
