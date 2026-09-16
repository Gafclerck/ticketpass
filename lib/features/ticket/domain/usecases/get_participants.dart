import '../repositories/ticket_repository.dart';

/// Participants d'un événement — ids des détenteurs de billets attribués.
class GetParticipants {
  final TicketRepository repository;

  const GetParticipants(this.repository);

  Future<List<String>> call(String eventId) {
    return repository.getParticipants(eventId);
  }
}