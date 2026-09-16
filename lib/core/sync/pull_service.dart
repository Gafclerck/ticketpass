import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../database/app_database.dart' as db;
import '../../features/auth/domain/entities/role.dart';
import '../../features/event/data/datasources/event_remote_datasource.dart';
import '../../features/event/data/models/event_model.dart';
import '../../features/ticket/data/datasources/ticket_remote_datasource.dart';
import '../../features/ticket/data/models/ticket_model.dart';
import 'sync_store.dart';

/// Réconcilie le cache local depuis la source de vérité (Firestore).
///
/// Sources d'autorité :
/// - événements + rôles + compteurs (`ticketsNumber = max(local, count)` —
///   compteur monotone, jamais écrit dans Firestore) ;
/// - billets possédés par l'utilisateur (collectionGroup) et billets des
///   événements dont il est staff (organisateur/contrôleur) — écrans « Billets »
///   et « Scan » à jour.
///
/// Garde-fous alimentés par [SyncStore.snapshot] : ne jamais écraser/supprimer
/// ce qu'une op locale en attente de push porte (local en avance), et ne jamais
/// recréer un événement couvert par un `delete` local (tombstone) — le `delete`
/// distant est propagé par la ligne outbox, le pull n'interfère pas.
class PullService {
  final db.AppDatabase database;
  final EventRemoteDataSource events;
  final TicketRemoteDataSource tickets;
  final SyncStore store;

  PullService({
    required this.database,
    required this.events,
    required this.tickets,
    required this.store,
  });

  Future<void> pullAll({required String userId}) async {
    final snap = await store.snapshot();
    final remoteEvents = await events.fetchAllEvents();
    final remoteById = {for (final e in remoteEvents) e.id: e};

    // 1 — Événements distants (sauf tombstone, sauf local en avance).
    for (final remote in remoteEvents) {
      if (snap.tombstoneEventIds.contains(remote.id)) continue;
      if (snap.pendingEventIds.contains(remote.id)) continue;

      final local = await _localEvent(remote.id);
      final remoteTickets = await tickets.fetchEventTickets(remote.id);
      final ticketsNumber = math.max(
        local?.ticketsNumber ?? 0,
        remoteTickets.length,
      );
      final updatedAtMs = math.max(local?.updatedAtMs ?? 0, remote.updatedAtMs);
      await database.into(database.events).insertOnConflictUpdate(
        _eventCompanion(remote, ticketsNumber: ticketsNumber, updatedAtMs: updatedAtMs),
      );
    }

    // 2 — Rôles par événement distant (union remote + assigns locaux pendants).
    for (final remote in remoteEvents) {
      if (snap.tombstoneEventIds.contains(remote.id)) continue;
      await _syncRoles(remote.id, snap);
    }

    // 3 — Suppression locale des événements absents côté distant (sauf pending).
    final localEvents = await (database.select(database.events)).get();
    for (final local in localEvents) {
      if (remoteById.containsKey(local.id)) continue;
      if (snap.pendingEventIds.contains(local.id)) continue;
      await database.transaction(() async {
        await (database.delete(database.tickets)
              ..where((r) => r.eventId.equals(local.id)))
            .go();
        await (database.delete(database.eventUserRoles)
              ..where((r) => r.eventId.equals(local.id)))
            .go();
        await (database.delete(database.events)
              ..where((r) => r.id.equals(local.id)))
            .go();
      });
    }

    // 4 — Mes billets (collectionGroup) + suppression des disparus.
    await _syncOwnedTickets(userId, snap);
    // 4bis — billets des événements dont je suis staff (organiser/controller).
    await _syncStaffTickets(userId, snap);
  }

  Future<db.Event?> _localEvent(String id) async {
    return (database.select(database.events)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
  }

  db.EventsCompanion _eventCompanion(
    EventModel model, {
    required int ticketsNumber,
    required int updatedAtMs,
  }) {
    return db.EventsCompanion(
      id: Value(model.id),
      title: Value(model.title),
      description: Value(model.description),
      eventDate: Value(model.eventDate),
      startTime: Value(model.startTime),
      brandingUrl: Value(model.brandingUrl),
      ticketsNumber: Value(ticketsNumber),
      type: Value(model.type),
      brandName: Value(model.brandName),
      eventPlace: Value(model.eventPlace),
      maxPlaces: Value(model.maxPlaces),
      status: Value(model.status),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  db.TicketsCompanion _ticketCompanion(TicketModel model, int updatedAtMs) {
    return db.TicketsCompanion(
      id: Value(model.id),
      status: Value(model.status),
      uniqueCode: Value(model.uniqueCode),
      qrSignature: Value(model.qrSignature),
      userId: Value(model.userId),
      eventId: Value(model.eventId),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  Future<void> _syncRoles(String eventId, OutboxSnapshot snap) async {
    final remoteRoles = await events.fetchRoles(eventId);
    final keepKeys = snap.pendingRoleKeys.where((k) => k.startsWith('$eventId|'));
    final remoteKeys = <String>{
      for (final role in remoteRoles)
        for (final r in role.roles) '$eventId|${role.userId}|${r.name}',
    };
    final finalKeys = {...remoteKeys, ...keepKeys};

    await database.transaction(() async {
      await (database.delete(database.eventUserRoles)
            ..where((r) => r.eventId.equals(eventId)))
          .go();
      for (final key in finalKeys) {
        final parts = key.split('|');
        await database.into(database.eventUserRoles).insert(
          db.EventUserRolesCompanion.insert(
            userId: parts[1],
            eventId: eventId,
            role: Role.values.byName(parts[2]),
          ),
        );
      }
    });
  }

  Future<void> _syncOwnedTickets(String userId, OutboxSnapshot snap) async {
    final remoteTickets = await tickets.fetchMyTickets(userId);
    final remoteIds = {for (final t in remoteTickets) t.id};

    final localTickets = await (database.select(database.tickets)
          ..where((r) => r.userId.equals(userId))).get();
    final localById = {for (final t in localTickets) t.id: t};

    await database.transaction(() async {
      for (final remote in remoteTickets) {
        if (snap.pendingTicketIds.contains(remote.id)) continue;
        final local = localById[remote.id];
        final updatedAtMs = math.max(local?.updatedAtMs ?? 0, remote.updatedAtMs);
        await database.into(database.tickets).insertOnConflictUpdate(
          _ticketCompanion(remote, updatedAtMs),
        );
      }
      for (final local in localTickets) {
        if (remoteIds.contains(local.id)) continue;
        if (snap.pendingTicketIds.contains(local.id)) continue;
        await (database.delete(database.tickets)
              ..where((r) => r.id.equals(local.id)))
            .go();
      }
    });
  }

  Future<void> _syncStaffTickets(String userId, OutboxSnapshot snap) async {
    final staffRoles = await (database.select(database.eventUserRoles)
          ..where(
            (r) =>
                r.userId.equals(userId) &
                (r.role.equals(Role.organiser.name) |
                    r.role.equals(Role.controller.name)),
          ))
        .get();
    final staffEventIds = staffRoles.map((r) => r.eventId).toSet();

    for (final eventId in staffEventIds) {
      if (snap.tombstoneEventIds.contains(eventId)) continue;

      final remoteTickets = await tickets.fetchEventTickets(eventId);
      final remoteIds = {for (final t in remoteTickets) t.id};

      final localTickets = await (database.select(database.tickets)
            ..where((r) => r.eventId.equals(eventId))).get();
      final localById = {for (final t in localTickets) t.id: t};

      await database.transaction(() async {
        for (final remote in remoteTickets) {
          if (snap.pendingTicketIds.contains(remote.id)) continue;
          final local = localById[remote.id];
          final updatedAtMs = math.max(
            local?.updatedAtMs ?? 0,
            remote.updatedAtMs,
          );
          await database.into(database.tickets).insertOnConflictUpdate(
            _ticketCompanion(remote, updatedAtMs),
          );
        }
        for (final local in localTickets) {
          if (remoteIds.contains(local.id)) continue;
          if (snap.pendingTicketIds.contains(local.id)) continue;
          await (database.delete(database.tickets)
                ..where((r) => r.id.equals(local.id)))
              .go();
        }
      });
    }
  }
}