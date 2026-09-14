import 'package:ticketpass/core/security/ticket_signature_service.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_status.dart';
import '../../domain/repositories/ticket_repository.dart';

/// Implémentation fake (en mémoire) du dépôt de billets.
///
/// **Fake réaliste et non un stub** : il applique les règles métier de
/// `docs/classe.md` (attribution uniquement depuis `unused`, refus des codes
/// inconnus/déjà utilisés) et simule une latence réseau contrôlable.
/// L'import de billet (UC7) a été retiré : seuls `generateTickets` (UC4) et
/// `acquireTicket` (UC19) créent/attribuent des billets.
class FakeTicketRepository implements TicketRepository {
  final List<Ticket> _tickets;

  /// Latence simulée (ms) pour tester les états de chargement.
  final Duration latency;

  FakeTicketRepository({
    List<Ticket>? seed,
    this.latency = const Duration(milliseconds: 200),
  }) : _tickets = List.of(seed ?? const []);

  /// Jeu de données de démonstration pour l'utilisateur [demoUserId].
  factory FakeTicketRepository.demo({
    String demoUserId = 'demo-user-id',
    Duration latency = const Duration(milliseconds: 200),
  }) {
    final tickets = <Ticket>[
      // Billets déjà possédés par l'utilisateur de démo.
      _make(
        id: 'ticket-0003',
        status: TicketStatus.valid,
        userId: demoUserId,
        eventId: 'demo-event-id',
      ),
      _make(
        id: 'ticket-0004',
        status: TicketStatus.used,
        userId: demoUserId,
        eventId: 'demo-event-id',
      ),
      _make(
        id: 'ticket-0005',
        status: TicketStatus.revoked,
        userId: demoUserId,
        eventId: 'demo-event-id',
      ),
      _make(
        id: 'ticket-0006',
        status: TicketStatus.invalid,
        userId: demoUserId,
        eventId: 'demo-event-id',
      ),
      // Billets disponibles du catalogue de démonstration (event-demo-1),
      // pour que l'achat (UC19) fonctionne depuis la Home découverte.
      ...List.generate(20, (i) {
        return _make(
          id: 'ticket-demo-1-${i + 1}',
          status: TicketStatus.unused,
          userId: '',
          eventId: 'event-demo-1',
        );
      }),
    ];
    return FakeTicketRepository(seed: tickets, latency: latency);
  }

  static Ticket _make({
    required String id,
    required TicketStatus status,
    required String userId,
    required String eventId,
  }) {
    final uniqueCode = const Uuid().v4();
    final signature = TicketSignatureService.sign(id, eventId);
    return Ticket(
      id: id,
      status: status,
      uniqueCode: uniqueCode,
      qrSignature: signature,
      userId: userId,
      eventId: eventId,
    );
  }

  Future<void> _simulateLatency() async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
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

  @override
  Future<List<Ticket>> getTicketsForEvent(String eventId) async {
    await _simulateLatency();

    return _tickets
        .where((ticket) => ticket.eventId == eventId)
        .toList(growable: false);
  }

  @override
  Future<List<Ticket>> generateTickets(String eventId, int quantity) async {
    await _simulateLatency();

    final generated = List.generate(
      quantity,
      (_) => _make(
        id: const Uuid().v4(),
        status: TicketStatus.unused,
        userId: '',
        eventId: eventId,
      ),
    );

    _tickets.addAll(generated);

    return generated;
  }

  @override
  Future<Ticket> acquireTicket(
    String eventId, {
    required String userId,
  }) async {
    await _simulateLatency();

    final alreadyOwned = _tickets.any(
      (ticket) => ticket.eventId == eventId && ticket.userId == userId,
    );

    if (alreadyOwned) {
      throw Exception('Vous possédez déjà un billet pour cet événement.');
    }

    final index = _tickets.indexWhere(
      (ticket) =>
          ticket.eventId == eventId &&
          ticket.status == TicketStatus.unused &&
          ticket.userId.isEmpty,
    );

    if (index == -1) {
      throw Exception('Plus de billet disponible pour cet événement.');
    }

    final acquired = _tickets[index].copyWith(
      userId: userId,
      status: TicketStatus.valid,
    );
    _tickets[index] = acquired;

    return acquired;
  }

  @override
  Future<List<String>> getParticipants(String eventId) async {
    await _simulateLatency();

    return _tickets
        .where(
          (ticket) => ticket.eventId == eventId && ticket.userId.isNotEmpty,
        )
        .map((ticket) => ticket.userId)
        .toSet()
        .toList(growable: false);
  }

  @override
  Future<Ticket> validateTicket(String ticketId) async {
    await _simulateLatency();

    final index = _tickets.indexWhere((ticket) => ticket.id == ticketId);

    if (index == -1) {
      throw Exception('Billet introuvable.');
    }

    final ticket = _tickets[index];

    if (ticket.status != TicketStatus.valid) {
      throw Exception(
        'Seul un billet valide peut être utilisé '
        '(statut : ${ticket.status.label}).',
      );
    }

    final used = ticket.copyWith(status: TicketStatus.used);
    _tickets[index] = used;

    return used;
  }
}
