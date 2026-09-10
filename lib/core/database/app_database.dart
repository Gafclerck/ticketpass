import 'package:drift/drift.dart';

import '../../features/auth/domain/entities/role.dart';
import '../../features/event/domain/entities/event_status.dart';
import '../../features/event/domain/entities/event_type.dart';
import '../../features/ticket/domain/entities/ticket_status.dart';

part 'app_database.g.dart';

/// Schéma local (drift) de l'application — **contrat de persistance**.
///
/// Reflète exactement `docs/classe.md` : mêmes tables, mêmes clés primaires,
/// mêmes contraintes uniques. L'implémentation concrète (`AppDatabase`)
/// et les datasources locales associées seront branchées au sprint d'infra ;
/// ce fichier fige déjà le contrat SQL.
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();
  TextColumn get fullName => text()();
  TextColumn get profileUrl => text().nullable()();
  TextColumn get authId => text().unique()();

  @override
  Set<Column> get primaryKey => {id};
}

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

  @override
  Set<Column> get primaryKey => {id};
}

class Tickets extends Table {
  TextColumn get id => text()();
  TextColumn get status => textEnum<TicketStatus>()();
  TextColumn get uniqueCode => text().unique()();
  TextColumn get qrSignature => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get eventId => text().references(Events, #id)();

  @override
  Set<Column> get primaryKey => {id};
}

class EventUserRoles extends Table {
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get eventId => text().references(Events, #id)();
  TextColumn get role => textEnum<Role>()();

  @override
  Set<Column> get primaryKey => {userId, eventId, role};
}

@DriftDatabase(tables: [Users, Events, Tickets, EventUserRoles])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}