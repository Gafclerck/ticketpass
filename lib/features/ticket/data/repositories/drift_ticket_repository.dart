import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../../../core/security/ticket_signature_service.dart';
import '../../../../core/sync/sync_store.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_status.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../models/ticket_model.dart';

/// Implémentation [TicketRepository] sur la base locale (drift), **cache
/// hors-ligne** pour la vérification de billet (scan offline) : les écritures
/// sont acceptées immédiatement puis convergent vers Firestore (source de
/// vérité) au slice infra/sync.
///
/// Reproduit les règles métier de `docs/classe.md` : attribution uniquement
/// depuis des billets `unused` (`userId` vide), refus du double billet et de
/// l'épuisement du stock, validation `VALID → USED` exclusive, participants
/// distincts. L'import (UC7) reste supprimé : seuls `generateTickets` (UC4) et
/// `acquireTicket` (UC19) créent/attribuent des billets.
class DriftTicketRepository implements TicketRepository {
  final db.AppDatabase database;
  final SyncStore syncStore;

  DriftTicketRepository(this.database, {SyncStore? syncStore})
      : syncStore = syncStore ?? SyncStore(database);

  static int _nowMs() => DateTime.now().millisecondsSinceEpoch;

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
  Future<Ticket> getTicket(String ticketId) async {
    final row = await (database.select(database.tickets)
          ..where((row) => row.id.equals(ticketId)))
        .getSingleOrNull();

    if (row == null) {
      throw Exception('Billet introuvable.');
    }

    return _toDomain(row);
  }

  @override
  Future<List<Ticket>> getMyTickets(String userId) async {
    final rows = await (database.select(database.tickets)
          ..where((row) => row.userId.equals(userId))
          ..orderBy([(row) => OrderingTerm.asc(row.updatedAtMs)]))
        .get();

    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<List<Ticket>> getTicketsForEvent(String eventId) async {
    final rows = await (database.select(database.tickets)
          ..where((row) => row.eventId.equals(eventId))
          ..orderBy([(row) => OrderingTerm.asc(row.updatedAtMs)]))
        .get();

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
    final nowMs = _nowMs();

    await database.transaction(() async {
      await database
          .batch((batch) => batch.insertAll(
                database.tickets,
                generated
                    .map(
                      (t) => _toCompanion(t).copyWith(
                        updatedAtMs: Value(nowMs),
                      ),
                    )
                    .toList(growable: false),
              ));

      final current = await (database.select(database.events)
            ..where((row) => row.id.equals(eventId)))
          .getSingleOrNull();
      if (current == null) {
        // Lève dans la transaction : le batch d'insertion est annulé (rollback),
        // aucun billet orphelin ne survit à un événement introuvable.
        throw Exception('Événement introuvable.');
      }
      await (database.update(database.events)
            ..where((row) => row.id.equals(eventId)))
          .write(
        db.EventsCompanion(ticketsNumber: Value(current.ticketsNumber + quantity)),
      );

      // Un billet généré = une ligne outbox (idempotente côté distant).
      for (final ticket in generated) {
        await syncStore.enqueue(
          entityType: SyncEntityType.ticket,
          entityId: eventId,
          op: SyncOp.generate,
          payload: TicketModel.fromEntity(
            ticket,
            updatedAtMs: nowMs,
          ).toJson(),
          nowMs: nowMs,
        );
      }
    });

    return generated;
  }

  @override
  Future<Ticket> acquireTicket(
    String eventId, {
    required String userId,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('Le billet doit être attribué à un utilisateur identifié.');
    }

    // Refus de double billet pour le même utilisateur et le même événement.
    final alreadyOwned = await (database.select(database.tickets)
          ..where(
            (row) => row.eventId.equals(eventId) & row.userId.equals(userId),
          ))
        .get();
    if (alreadyOwned.isNotEmpty) {
      throw Exception('Vous possédez déjà un billet pour cet événement.');
    }

    final available = await (database.select(database.tickets)
          ..where(
            (row) =>
                row.eventId.equals(eventId) &
                row.status.equals(TicketStatus.unused.name) &
                row.userId.equals(''),
          )
          ..limit(1))
        .get();

    if (available.isEmpty) {
      throw Exception('Plus de billet disponible pour cet événement.');
    }

    // Attribution atomique : ne met à jour QUE si le billet est encore libre.
    // Idem pour l'enqueue (même transaction : pas d'opération outbox si le
    // billet n'a pas été attribué).
    final target = available.first;
    await database.transaction(() async {
      final updated = await (database.update(database.tickets)
            ..where(
              (row) =>
                  row.id.equals(target.id) &
                  row.status.equals(TicketStatus.unused.name) &
                  row.userId.equals(''),
            ))
          .write(
        db.TicketsCompanion(
          userId: Value(userId),
          status: Value(TicketStatus.valid),
          updatedAtMs: Value(_nowMs()),
        ),
      );

      if (updated != 1) {
        throw Exception('Plus de billet disponible pour cet événement.');
      }

      await syncStore.enqueue(
        entityType: SyncEntityType.ticket,
        entityId: target.id,
        op: SyncOp.acquire,
        precondition: jsonEncode({'status': TicketStatus.unused.name}),
        payload: {
          'event_id': eventId,
          'ticket_id': target.id,
          'user_id': userId,
        },
      );
    });

    return _toDomain(target).copyWith(
      userId: userId,
      status: TicketStatus.valid,
    );
  }

  @override
  Future<List<String>> getParticipants(String eventId) async {
    final rows = await (database.select(database.tickets)
          ..where((row) => row.eventId.equals(eventId)))
        .get();

    return rows
        .where((row) => row.userId.isNotEmpty)
        .map((row) => row.userId)
        .toSet()
        .toList(growable: false);
  }

  @override
  Future<Ticket> validateTicket(String ticketId) async {
    final row = await (database.select(database.tickets)
          ..where((row) => row.id.equals(ticketId)))
        .getSingleOrNull();

    if (row == null) {
      throw Exception('Billet introuvable.');
    }

    if (row.status != TicketStatus.valid) {
      throw Exception(
        'Seul un billet valide peut être utilisé '
        '(statut : ${row.status.label}).',
      );
    }

    await database.transaction(() async {
      await (database.update(database.tickets)
            ..where((row) => row.id.equals(ticketId)))
          .write(
        db.TicketsCompanion(
          status: Value(TicketStatus.used),
          updatedAtMs: Value(_nowMs()),
        ),
      );

      await syncStore.enqueue(
        entityType: SyncEntityType.ticket,
        entityId: ticketId,
        op: SyncOp.validate,
        precondition: jsonEncode({'status': TicketStatus.valid.name}),
        payload: {'event_id': row.eventId, 'ticket_id': ticketId},
      );
    });

    return _toDomain(row).copyWith(status: TicketStatus.used);
  }
}