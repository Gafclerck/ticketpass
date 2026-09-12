import '../models/ticket_model.dart';

/// Contrat de la source distante (Firestore) — **abstrait, non branché**.
///
/// Défini maintenant pour figer le contrat, implémenté au sprint d'infra
/// (`TicketRemoteDataSourceImpl`). Aucune API Firebase exposée ici : le
/// contrat parle billets, pas documents.
abstract class TicketRemoteDataSource {
  Future<TicketModel?> fetchById(String ticketId);

  Future<List<TicketModel>> fetchByUserId(String userId);

  Future<TicketModel> save(TicketModel ticket);
}