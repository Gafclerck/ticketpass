import 'dart:developer' as dev;

import 'package:drift/drift.dart';

import '../../features/auth/domain/entities/role.dart';
import '../../features/event/domain/entities/event_status.dart';
import '../../features/event/domain/entities/event_type.dart';
import '../../features/ticket/domain/entities/ticket_status.dart';

part 'app_database.g.dart';

/// Schéma local (drift) de l'application — **cache hors-ligne**.
///
/// Drift n'est pas la source de persistance principale : c'est le cache de
/// disponibilité (écritures acceptées hors-ligne) ramené à la convergence par
/// la file `SyncOutbox` vers Firestore (source de vérité). Le schéma reflète
/// donc les mêmes tables que `docs/classe.md`, sans table `Users` : l'identité
/// est exclusivement gérée par Firebase Auth (`authStateChanges`, uid stocké
/// en texte simple dans `userId`).
class Events extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get eventDate => dateTime()();
  DateTimeColumn get startTime => dateTime()();
  TextColumn get brandingUrl => text().clientDefault(() => '')();
  IntColumn get ticketsNumber => integer().clientDefault(() => 0)();
  TextColumn get type => textEnum<EventType>()();
  TextColumn get brandName => text()();
  TextColumn get eventPlace => text()();
  IntColumn get maxPlaces => integer()();
  TextColumn get status => textEnum<EventStatus>()();
  IntColumn get updatedAtMs => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Tickets extends Table {
  // `ticketsNumber` est détenu par `Events` (génération) — jamais écrit en
  // direct par une mise à jour d'événement.
  TextColumn get id => text()();
  TextColumn get status => textEnum<TicketStatus>()();
  TextColumn get uniqueCode => text().unique()();
  TextColumn get qrSignature => text()();
  // Identifiant Firebase (uid), jamais une FK : la table `Users` n'existe pas
  // en local. Vide = billet non attribué.
  TextColumn get userId => text()();
  TextColumn get eventId => text().references(Events, #id)();
  IntColumn get updatedAtMs => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class EventUserRoles extends Table {
  // Identifiant Firebase (uid) — même logique que `Tickets.userId`.
  TextColumn get userId => text()();
  TextColumn get eventId => text().references(Events, #id)();
  TextColumn get role => textEnum<Role>()();
  IntColumn get updatedAtMs => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {userId, eventId, role};
}

/// File de sortie de convergence vers Firestore (slice infra/sync).
///
/// Une ligne = une opération à rejouer idempotemment chez la source de vérité.
/// `precondition` porte l'état attendu AVANT l'opération (Compare-And-Set, ex.
/// une validation `VALID → USED`) pour que les conflits multi-appareils soient
/// résolus correctement. Non encore consommé : peuplé par les repos à la
/// convergence (slice C), le schéma est figé dès maintenant.
class SyncOutbox extends Table {
  TextColumn get id => text()(); // uuid de l'opération
  TextColumn get entityType => text()(); // event | ticket | role | generate
  TextColumn get entityId => text()(); // id ciblé (eventId pour generate)
  TextColumn get op => text()(); // create | update | delete | acquire | validate | assign | generate
  TextColumn get precondition => text().nullable()(); // JSON CAS (ex. {status: valid})
  TextColumn get payload => text()(); // JSON de l'écriture/opération
  TextColumn get status => text()(); // pending | syncing | done | cancelled
  IntColumn get createdAtMs => integer()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get nextRetryAtMs => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Events, Tickets, EventUserRoles, SyncOutbox])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  // 2 → 3 : suppression de la table `Users` (identité = Firebase uniquement),
  // `userId` en texte simple sans FK, ajout `updatedAtMs` + table `SyncOutbox`.
  // Destructif : pré-release, aucune donnée à conserver.
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 3) {
            // Réinitialisation complète : le schéma v3 n'a pas de continuité
            // avec v2 (table Users supprimée, FKs retirées). Aucune donnée de
            // prod à préserver en pré-release.
            dev.log(
              'app_database: migration destructrice $from → $to '
              '(réinitialisation du schéma local)',
              name: 'TicketPass',
            );
            for (final table in allTables) {
              await m.drop(table);
            }
            await m.createAll();
          }
        },
        beforeOpen: (details) async {
          // SQLite désactive les FK par défaut. On garde l'intégrité locale :
          // `Tickets.eventId` / `EventUserRoles.eventId` référencent `Events.id`
          // (pas de billet ni de rôle sans événement). Les `userId` sont des
          // uids Firebase en texte simple, sans contrainte locale.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}