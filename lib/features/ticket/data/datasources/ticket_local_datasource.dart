import '../models/ticket_model.dart';

/// Contrat de la source locale (drift) — **abstrait, non branché**.
///
/// Défini maintenant pour figer le contrat, implémenté au sprint d'infra
/// (`TicketLocalDataSourceImpl`). Aucune API drift/Firebase exposée ici.
abstract class TicketLocalDataSource {
  Future<List<TicketModel>> fetchByUserId(String userId);

  Future<TicketModel?> fetchById(String ticketId);

  Future<void> upsert(TicketModel ticket);

  Future<void> delete(String ticketId);
}