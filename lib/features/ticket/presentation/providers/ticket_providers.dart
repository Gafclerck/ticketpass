import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/fake_ticket_repository.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../../domain/usecases/get_my_tickets.dart';
import '../../domain/usecases/get_ticket.dart';
import '../../domain/usecases/import_ticket.dart';

/// Point de bascule : demain, [TicketRepository] sera une implémentation
/// drift/Firestore. Seul CE provider changera.
final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return FakeTicketRepository.demo();
});

final importTicketProvider = Provider<ImportTicket>((ref) {
  return ImportTicket(ref.watch(ticketRepositoryProvider));
});

final getTicketProvider = Provider<GetTicket>((ref) {
  return GetTicket(ref.watch(ticketRepositoryProvider));
});

final getMyTicketsProvider = Provider<GetMyTickets>((ref) {
  return GetMyTickets(ref.watch(ticketRepositoryProvider));
});

/// UC9 — historique des billets d'un utilisateur.
final myTicketsProvider = FutureProvider.family<List<Ticket>, String>((
  ref,
  userId,
) {
  return ref.watch(getMyTicketsProvider).call(userId);
});

/// UC8 — consultation d'un billet.
final ticketProvider = FutureProvider.family<Ticket, String>((
  ref,
  ticketId,
) {
  return ref.watch(getTicketProvider).call(ticketId);
});