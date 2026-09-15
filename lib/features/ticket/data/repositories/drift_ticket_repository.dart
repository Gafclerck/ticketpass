import 'package:ticketpass/core/security/ticket_signature_service.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_status.dart';
import '../../domain/repositories/ticket_repository.dart';

/// Implémentation `TicketRepository` branchée sur la base locale (UC15,
/// drift/SQLite) — remplace `FakeTicketRepository` (en mémoire).
///
/// Reproduit les mêmes règles métier que le fake : attribution uniquement
/// depuis `unused`, refus des codes inconnus/déjà utilisés (`docs/classe.md`).
class DriftTicketRepository implements TicketRepository {
  final db.AppDatabase database;

  const DriftTicketRepository(this.database);

  Ticket _toDomain(db.Ticket row) {
    return Ticket(
      id: row.id,
      status: row.status,
      uniqueCode: row.uniqueCode,
      qrSignature: row.qrSignature,
      userId: row.userId,
      eventId: row.eventId,
    );
  }

  db.TicketsCompanion _toCompanion(Ticket ticket) {
    return db.TicketsCompanion.insert(
      id: ticket.id,
      status: ticket.status,
      uniqueCode: ticket.uniqueCode,
      qrSignature: ticket.qrSignature,
      userId: ticket.userId,
      eventId: ticket.eventId,
    );
  }

  @override
  Future<Ticket> importTicket(
    String uniqueCode, {
    required String userId,
  }) async {
    final row = await (database.select(
      database.tickets,
    )..where((row) => row.uniqueCode.equals(uniqueCode))).getSingleOrNull();

    if (row == null) {
      throw Exception('Code de billet introuvable.');
    }
    if (row.status != TicketStatus.unused) {
      throw Exception(
        'Ce billet ne peut pas être importé (statut : ${row.status.label}).',
      );
    }

    final imported = _toDomain(
      row,
    ).copyWith(userId: userId, status: TicketStatus.valid);

    await database
        .update(database.tickets)
        .replace(_toCompanion(imported));

    return imported;
  }

  @override
  Future<Ticket> getTicket(String ticketId) async {
    final row = await (database.select(
      database.tickets,
    )..where((row) => row.id.equals(ticketId))).getSingleOrNull();

    if (row == null) {
      throw Exception('Billet introuvable.');
    }
    return _toDomain(row);
  }

  @override
  Future<List<Ticket>> getMyTickets(String userId) async {
    final rows = await (database.select(
      database.tickets,
    )..where((row) => row.userId.equals(userId))).get();
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<List<Ticket>> getTicketsForEvent(String eventId) async {
    final rows = await (database.select(
      database.tickets,
    )..where((row) => row.eventId.equals(eventId))).get();
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<List<Ticket>> generateTickets(String eventId, int quantity) async {
    final generated = List.generate(quantity, (_) {
      final id = const Uuid().v4();
      return Ticket(
        id: id,
        status: TicketStatus.unused,
        uniqueCode: const Uuid().v4(),
        qrSignature: TicketSignatureService.buildQrPayload(id, eventId),
        userId: '',
        eventId: eventId,
      );
    });

    await database.batch((batch) {
      batch.insertAll(
        database.tickets,
        generated.map(_toCompanion).toList(growable: false),
      );
    });

    return generated;
  }
}
