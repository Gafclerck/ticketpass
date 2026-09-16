import 'dart:convert';

import '../database/app_database.dart' as db;
import '../../features/auth/domain/entities/role.dart';
import '../../features/event/data/datasources/event_remote_datasource.dart';
import '../../features/event/data/models/event_model.dart';
import '../../features/ticket/data/datasources/ticket_remote_datasource.dart';
import '../../features/ticket/data/models/ticket_model.dart';
import 'sync_store.dart';

/// Applique une opération de l'outbox à la source de vérité (Firestore).
///
/// Mapping pur `SyncOutboxData → datasource` : chaque opération est idempotente
/// (voir C-a) donc un rejeu est sûr. Un état distant divergent se signale par
/// [TicketStateConflictException] — le moteur (slice C-c) bascule la ligne en
/// `cancelled` puis déclenche un pull pour réconcilier.
class SyncHandlers {
  final EventRemoteDataSource events;
  final TicketRemoteDataSource tickets;

  const SyncHandlers({required this.events, required this.tickets});

  Map<String, dynamic> _decodePayload(String payload) =>
      jsonDecode(payload) as Map<String, dynamic>;

  Future<void> apply(db.SyncOutboxData row) async {
    switch (row.entityType) {
      case SyncEntityType.event:
        await _applyEvent(row);
      case SyncEntityType.role:
        await _applyRole(row);
      case SyncEntityType.ticket:
        await _applyTicket(row);
      default:
        throw StateError(
          'SyncHandlers: entité inconnue "${row.entityType}" (op ${row.op}).',
        );
    }
  }

  Future<void> _applyEvent(db.SyncOutboxData row) async {
    switch (row.op) {
      case SyncOp.create:
        await events.createEvent(
          EventModel.fromJson(_decodePayload(row.payload)),
        );
      case SyncOp.update:
        await events.updateEvent(
          EventModel.fromJson(_decodePayload(row.payload)),
        );
      case SyncOp.delete:
        await events.deleteEvent(row.entityId);
      default:
        throw StateError('SyncHandlers: op événement inconnue "${row.op}".');
    }
  }

  Future<void> _applyRole(db.SyncOutboxData row) async {
    switch (row.op) {
      case SyncOp.assign:
        final payload = _decodePayload(row.payload);
        await events.assignRole(
          payload['event_id'] as String,
          payload['user_id'] as String,
          Role.values.byName(payload['role'] as String),
        );
      default:
        throw StateError('SyncHandlers: op rôle inconnue "${row.op}".');
    }
  }

  Future<void> _applyTicket(db.SyncOutboxData row) async {
    switch (row.op) {
      case SyncOp.generate:
        await tickets.saveGeneratedTickets([
          TicketModel.fromJson(_decodePayload(row.payload)),
        ]);
      case SyncOp.acquire:
        final payload = _decodePayload(row.payload);
        await tickets.claimTicket(
          eventId: payload['event_id'] as String,
          ticketId: payload['ticket_id'] as String,
          userId: payload['user_id'] as String,
        );
      case SyncOp.validate:
        final payload = _decodePayload(row.payload);
        await tickets.validateTicketEntry(
          eventId: payload['event_id'] as String,
          ticketId: payload['ticket_id'] as String,
        );
      default:
        throw StateError('SyncHandlers: op billet inconnue "${row.op}".');
    }
  }
}