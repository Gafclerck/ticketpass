import 'package:drift/drift.dart' show InsertMode, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:ticketpass/core/database/app_database.dart';
import 'package:ticketpass/core/database/database_provider.dart';
import 'package:ticketpass/features/event/domain/entities/event_status.dart';
import 'package:ticketpass/features/event/domain/entities/event_type.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket_status.dart';

/// Désactive l'avertissement drift « AppDatabase created multiple times »
/// (une base en mémoire par test — exécuteurs distincts, pas de course réelle).
void silenceDriftWarnings() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
}

/// Surcharge `appDatabaseProvider` par une base SQLite en mémoire.
///
/// Chaque appel crée une base vierge : aucun test ne dépend de l'état d'un
/// autre. À combiner avec un seed (plugins/événements) quand le scénario
/// nécessite des données.
Override appDatabaseInMemoryOverride() {
  silenceDriftWarnings();
  return appDatabaseProvider.overrideWithValue(
    AppDatabase(NativeDatabase.memory()),
  );
}

/// Insère un événement minimal (prérequis FK des billets). Renvoie sa version
/// persistée (aucun humain n'a besoin de lire la valeur de retour).
Future<void> insertEvent(
  AppDatabase database,
  String id, {
  String? title,
}) {
  return database.into(database.events).insert(
        EventsCompanion.insert(
          id: id,
          title: title ?? 'Event $id',
          description: '',
          eventDate: DateTime(2026),
          startTime: DateTime(2026),
          type: EventType.concert,
          brandName: '',
          eventPlace: '',
          maxPlaces: 100,
          status: EventStatus.upcoming,
        ),
        mode: InsertMode.insertOrIgnore,
      );
}

/// Insère un billet minimal (requiert un événement existant — FK `eventId`).
/// `userId` vide = billet non attribué (identifiant Firebase, pas de FK).
Future<void> insertTicket(
  AppDatabase database, {
  required String id,
  required TicketStatus status,
  required String userId,
  required String eventId,
}) {
  return database.into(database.tickets).insert(
        TicketsCompanion.insert(
          id: id,
          status: status,
          uniqueCode: 'uc-$id',
          qrSignature: 'sig-$id',
          userId: userId,
          eventId: eventId,
        ),
        mode: InsertMode.insertOrIgnore,
      );
}