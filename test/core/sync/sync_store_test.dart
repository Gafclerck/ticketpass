import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/database/app_database.dart';
import 'package:ticketpass/core/sync/sync_store.dart';

import '../../helpers/test_database.dart' show silenceDriftWarnings;

void main() {
  late AppDatabase database;
  late SyncStore store;

  setUp(() {
    silenceDriftWarnings();
    database = AppDatabase(NativeDatabase.memory());
    store = SyncStore(database);
  });

  tearDown(() => database.close());

  Future<SyncOutboxData> rowById(String id) async {
    return (database.select(database.syncOutbox)
          ..where((r) => r.id.equals(id)))
        .getSingle();
  }

  test('enqueue insère une ligne pending et la renvoie', () async {
    final row = await store.enqueue(
      entityType: SyncEntityType.event,
      entityId: 'ev1',
      op: SyncOp.create,
      payload: {'title': 'Concert'},
      nowMs: 1000,
    );

    expect(row.status, SyncStatus.pending);
    expect(row.attempts, 0);
    expect(row.payload, contains('Concert'));
    expect(await store.pendingCount(), 1);
  });

  test('claimDue récupère les pending dans l’ordre puis bloque la ré-prise', () async {
    await store.enqueue(
      entityType: SyncEntityType.event,
      entityId: 'a',
      op: SyncOp.create,
      nowMs: 100,
    );
    await store.enqueue(
      entityType: SyncEntityType.event,
      entityId: 'b',
      op: SyncOp.create,
      nowMs: 200,
    );

    final claimed = await store.claimDue(nowMs: 300);
    expect(claimed.map((r) => r.entityId).toList(), ['a', 'b']);
    expect(claimed.every((r) => r.status == SyncStatus.syncing), isTrue);

    // Deuxième claim : rien à réclamer (CAS anti-course).
    expect(await store.claimDue(nowMs: 9999999), isEmpty);

    await store.markDone(claimed[0].id);
    await store.markDone(claimed[1].id);
    expect(await store.clearFinished(), 2);
  });

  test('claimDue respecte nextRetryAtMs (futur = pas dû)', () async {
    await store.enqueue(
      entityType: SyncEntityType.ticket,
      entityId: 't1',
      op: SyncOp.acquire,
      nowMs: 100,
    );
    await store.enqueue(
      entityType: SyncEntityType.ticket,
      entityId: 't2',
      op: SyncOp.acquire,
      nowMs: 100,
    );

    final first = await store.claimDue(nowMs: 100);
    // t1 : prochain retry à 150+2000=2150 ; t2 : prochain retry à 5000+2000.
    await store.markFailed(first[0].id, nowMs: 150);
    await store.markFailed(first[1].id, nowMs: 5000);

    // À t=3000, seul le retry de t1 (dû à 2150) est réclamable.
    final claimed = await store.claimDue(nowMs: 3000);
    expect(claimed.length, 1);
    expect(claimed.single.id, first[0].id);
    expect(claimed.single.attempts, 1);
  });

  test('markFailed incrémente attempts et programme le backoff exponentiel', () async {
    final row = await store.enqueue(
      entityType: SyncEntityType.event,
      entityId: 'ev1',
      op: SyncOp.create,
      nowMs: 0,
    );
    await store.markFailed(row.id, nowMs: 0);

    final after = await rowById(row.id);
    expect(after.status, SyncStatus.pending);
    expect(after.attempts, 1);
    expect(after.nextRetryAtMs, SyncStore.backoffDelayMs(1));
  });

  test('markFailed cancelled au bout de maxAttempts tentatives', () async {
    final row = await store.enqueue(
      entityType: SyncEntityType.event,
      entityId: 'ev1',
      op: SyncOp.create,
      nowMs: 0,
    );

    var result = MarkFailedResult.retry;
    for (var attempt = 1; attempt <= SyncStore.maxAttempts; attempt++) {
      result = await store.markFailed(row.id, nowMs: 0);
    }

    expect(result, MarkFailedResult.cancelled);
    final after = await rowById(row.id);
    expect(after.status, SyncStatus.cancelled);
    expect(after.nextRetryAtMs, isNull);
  });

  test('backoff exponentiel plafonné à 5 minutes', () {
    expect(SyncStore.backoffDelayMs(1), 2000);
    expect(SyncStore.backoffDelayMs(3), 8000);
    expect(SyncStore.backoffDelayMs(10), 5 * 60 * 1000);
  });

  test('markCancelled puis clearFinished purgent la table', () async {
    final done = await store.enqueue(
      entityType: SyncEntityType.event,
      entityId: 'ev1',
      op: SyncOp.update,
      nowMs: 1,
    );
    final cancelled = await store.enqueue(
      entityType: SyncEntityType.ticket,
      entityId: 't1',
      op: SyncOp.acquire,
      nowMs: 2,
    );

    await store.markDone(done.id);
    await store.markCancelled(cancelled.id);

    expect(await store.clearFinished(), 2);
    expect(await store.pendingCount(), 0);
    expect(await database.select(database.syncOutbox).get(), isEmpty);
  });
}