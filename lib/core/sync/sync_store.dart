import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart' as db;

/// Valeurs de `sync_outbox.status`.
abstract final class SyncStatus {
  static const pending = 'pending';
  static const syncing = 'syncing';
  static const done = 'done';
  static const cancelled = 'cancelled';
}

/// Valeurs de `sync_outbox.entity_type`.
abstract final class SyncEntityType {
  static const event = 'event';
  static const ticket = 'ticket';
  static const role = 'role';
}

/// Valeurs de `sync_outbox.op` (décomposées par [SyncEntityType]).
abstract final class SyncOp {
  static const create = 'create';
  static const update = 'update';
  static const delete = 'delete';
  static const assign = 'assign';
  static const generate = 'generate';
  static const acquire = 'acquire';
  static const validate = 'validate';
}

/// Résultat de [SyncStore.markFailed].
enum MarkFailedResult { retry, cancelled }

/// File de sortie de convergence — façade sur la table `SyncOutbox`.
///
/// Responsabilités :
/// - accueillir les écritures locales des repos (même transaction drift) en
///   `pending` ;
/// - laisser un moteur (slice C-c) réclamer (`claimDue`) les opérations dues
///   et les rejouer idempotemment chez Firestore ;
/// - comptabiliser les échecs avec backoff exponentiel plafonné ; après
///   [maxAttempts] tentatives, la ligne est `cancelled` (permanente, loggée
///   par le moteur).
class SyncStore {
  final db.AppDatabase database;

  const SyncStore(this.database);

  /// Nombre maximal de tentatives avant de déclarer une opération `cancelled`.
  static const maxAttempts = 8;

  /// Backoff exponentiel (base 2 s, facteur 2, plafond 5 min).
  static int backoffDelayMs(int attempt) {
    const baseMs = 2000;
    const capMs = 5 * 60 * 1000;
    final shifted = baseMs << (attempt - 1);
    return shifted > capMs ? capMs : shifted;
  }

  /// Insère une opération `pending`. Renvoie la ligne persistée.
  Future<db.SyncOutboxData> enqueue({
    required String entityType,
    required String entityId,
    required String op,
    Map<String, dynamic>? payload,
    String? precondition,
    int? nowMs,
  }) async {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final id = const Uuid().v4();
    final encoded = jsonEncode(payload ?? const <String, dynamic>{});

    await database.into(database.syncOutbox).insert(
      db.SyncOutboxCompanion.insert(
        id: id,
        entityType: entityType,
        entityId: entityId,
        op: op,
        precondition: precondition == null
            ? const Value.absent()
            : Value(precondition),
        payload: encoded,
        status: SyncStatus.pending,
        createdAtMs: now,
      ),
    );

    return db.SyncOutboxData(
      id: id,
      entityType: entityType,
      entityId: entityId,
      op: op,
      precondition: precondition,
      payload: encoded,
      status: SyncStatus.pending,
      createdAtMs: now,
      attempts: 0,
    );
  }

  /// Réclame les opérations dues (`pending`, retry échu) dans l'ordre
  /// d'ancienneté et les bascule `syncing`. Anti-course : la clause de mise à
  /// jour ne retouche que les lignes encore `pending` — deux moteurs lancés en
  /// parallèle ne rejouent jamais deux fois la même ligne.
  Future<List<db.SyncOutboxData>> claimDue({int? nowMs}) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    return database.transaction(() async {
      final due = await (database.select(database.syncOutbox)
            ..where(
              (row) =>
                  row.status.equals(SyncStatus.pending) &
                  (row.nextRetryAtMs.isNull() |
                      row.nextRetryAtMs.isSmallerThanValue(now)),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.createdAtMs)])
            ..limit(64))
          .get();

      if (due.isEmpty) return const <db.SyncOutboxData>[];

      await (database.update(database.syncOutbox)
            ..where(
              (row) =>
                  row.status.equals(SyncStatus.pending) &
                  (row.nextRetryAtMs.isNull() |
                      row.nextRetryAtMs.isSmallerThanValue(now)),
            ))
          .write(db.SyncOutboxCompanion(status: Value(SyncStatus.syncing)));

      // Relit les lignes dans leur état persisté (le select initial portait
      // encore `pending`).
      return <db.SyncOutboxData>[
        for (final row in due)
          await (database.select(database.syncOutbox)
                ..where((r) => r.id.equals(row.id)))
              .getSingle(),
      ];
    });
  }

  /// Marque l'opération comme synchronisée.
  Future<void> markDone(String id) async {
    await (database.update(database.syncOutbox)
          ..where((row) => row.id.equals(id)))
        .write(db.SyncOutboxCompanion(status: Value(SyncStatus.done)));
  }

  /// Marque l'opération comme en conflit permanent (ex. état distant divergent
  /// : billet déjà attribué à un autre). Le pull Firestore (slice C-c) est
  /// chargé de réconcilier l'état local.
  Future<void> markCancelled(String id) async {
    await (database.update(database.syncOutbox)
          ..where((row) => row.id.equals(id)))
        .write(db.SyncOutboxCompanion(status: Value(SyncStatus.cancelled)));
  }

  /// Comptabilise un échec : `pending` + backoff, ou `cancelled` au-delà de
  /// [maxAttempts].
  Future<MarkFailedResult> markFailed(String id, {int? nowMs}) async {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final row = await (database.select(database.syncOutbox)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return MarkFailedResult.cancelled;

    final attempts = row.attempts + 1;
    if (attempts >= maxAttempts) {
      await (database.update(database.syncOutbox)
            ..where((row) => row.id.equals(id)))
          .write(
        db.SyncOutboxCompanion(
          status: const Value(SyncStatus.cancelled),
          nextRetryAtMs: const Value(null),
        ),
      );
      return MarkFailedResult.cancelled;
    }

    final nextRetryAtMs = now + backoffDelayMs(attempts);
    await (database.update(database.syncOutbox)
          ..where((row) => row.id.equals(id)))
        .write(
      db.SyncOutboxCompanion(
        status: const Value(SyncStatus.pending),
        attempts: Value(attempts),
        nextRetryAtMs: Value(nextRetryAtMs),
      ),
    );
    return MarkFailedResult.retry;
  }

  /// Purge des lignes réglées (terminées, annulées) — appelé par le moteur
  /// après un cycle, pour borner la table. Renvoie le nombre de lignes purgées.
  Future<int> clearFinished() async {
    final deleted = await (database.delete(database.syncOutbox)
          ..where(
            (row) =>
                row.status.equals(SyncStatus.done) |
                row.status.equals(SyncStatus.cancelled),
          ))
        .go();
    return deleted;
  }

  Future<int> pendingCount() async {
    final count = await (database.select(database.syncOutbox)
          ..where((row) => row.status.equals(SyncStatus.pending)))
        .get();
    return count.length;
  }
}