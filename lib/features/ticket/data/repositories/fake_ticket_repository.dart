import 'package:uuid/uuid.dart';

import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_status.dart';
import '../../domain/repositories/ticket_repository.dart';

/// Implémentation fake (en mémoire) du dépôt de billets.
///
/// **Fake réaliste et non un stub** : il applique les règles métier de
/// `docs/classe.md` (attribution uniquement depuis `unused`, refus des codes
/// inconnus/déjà utilisés) et simule une latence réseau contrôlable.
class FakeTicketRepository implements TicketRepository {
  final List<Ticket> _tickets;

  /// Latence simulée (ms) pour tester les états de chargement.
  final Duration latency;

  FakeTicketRepository({List<Ticket>? seed, this.latency = const Duration(milliseconds: 200)})
      : _tickets = List.of(seed ?? const []);

  /// Jeu de données de démonstration pour l'utilisateur [demoUserId].
  factory FakeTicketRepository.demo({
    String demoUserId = 'demo-user-id',
    Duration latency = const Duration(milliseconds: 200),
  }) {
    final tickets = <Ticket>[
      // Billets importables (status: unused, aucun propriétaire).
      _make(id: 'ticket-0001', status: TicketStatus.unused, userId: ''),
      _make(id: 'ticket-0002', status: TicketStatus.unused, userId: ''),
      // Billets déjà possédés par l'utilisateur de démo.
      _make(id: 'ticket-0003', status: TicketStatus.valid, userId: demoUserId),
      _make(id: 'ticket-0004', status: TicketStatus.used, userId: demoUserId),
      _make(id: 'ticket-0005', status: TicketStatus.revoked, userId: demoUserId),
      _make(id: 'ticket-0006', status: TicketStatus.invalid, userId: demoUserId),
    ];
    return FakeTicketRepository(seed: tickets, latency: latency);
  }

  static Ticket _make({
    required String id,
    required TicketStatus status,
    required String userId,
  }) {
    final uniqueCode = const Uuid().v4();
    return Ticket(
      id: id,
      status: status,
      uniqueCode: uniqueCode,
      qrSignature: 'TICKETPASS::$uniqueCode',
      userId: userId,
      eventId: 'demo-event-id',
    );
  }

  Future<void> _simulateLatency() async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
  }

  @override
  Future<Ticket> importTicket(String uniqueCode, {required String userId}) async {
    await _simulateLatency();

    final index = _tickets.indexWhere((t) => t.uniqueCode == uniqueCode);

    if (index == -1) {
      throw Exception('Code de billet introuvable.');
    }

    final ticket = _tickets[index];

    if (ticket.status != TicketStatus.unused) {
      throw Exception(
        'Ce billet ne peut pas être importé (statut : ${ticket.status.label}).',
      );
    }

    final imported = ticket.copyWith(
      userId: userId,
      status: TicketStatus.valid,
    );
    _tickets[index] = imported;

    return imported;
  }

  @override
  Future<Ticket> getTicket(String ticketId) async {
    await _simulateLatency();

    for (final ticket in _tickets) {
      if (ticket.id == ticketId) {
        return ticket;
      }
    }

    throw Exception('Billet introuvable.');
  }

  @override
  Future<List<Ticket>> getMyTickets(String userId) async {
    await _simulateLatency();

    return _tickets
        .where((ticket) => ticket.userId == userId)
        .toList(growable: false);
  }
}