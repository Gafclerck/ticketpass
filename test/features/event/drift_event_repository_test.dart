import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/database/app_database.dart' as db;
import 'package:ticketpass/features/auth/domain/entities/role.dart';
import 'package:ticketpass/features/event/data/repositories/drift_event_repository.dart';
import 'package:ticketpass/features/event/domain/entities/event.dart';
import 'package:ticketpass/features/event/domain/entities/event_status.dart';
import 'package:ticketpass/features/event/domain/entities/event_type.dart';
import 'package:ticketpass/features/event/domain/entities/event_user_role.dart';

/// Spécification du repo événements sur la base locale (drift).
void main() {
  late db.AppDatabase database;
  late DriftEventRepository repository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = DriftEventRepository(database);
  });

  tearDown(() => database.close());

  group('DriftEventRepository — rôles (UC24)', () {
    test('la création attribue le rôle organiser au créateur', () async {
      final event = await repository.createEvent(_event(), userId: 'org-1');

      final roles = await repository.getRoles(event.id);

      expect(
        roles.any((r) => r.userId == 'org-1' && r.role == Role.organiser),
        isTrue,
      );
    });

    test('assignRole ajoute un contrôleur valide', () async {
      final event = await repository.createEvent(_event(), userId: 'org-1');

      await repository.assignRole(
        EventUserRole(
          userId: 'ctrl-1',
          eventId: event.id,
          role: Role.controller,
        ),
      );

      final roles = await repository.getRoles(event.id);

      expect(
        roles.any((r) => r.userId == 'ctrl-1' && r.role == Role.controller),
        isTrue,
      );
    });

    test('assignRole est idempotent', () async {
      final event = await repository.createEvent(_event(), userId: 'org-1');
      final role = EventUserRole(
        userId: 'ctrl-1',
        eventId: event.id,
        role: Role.controller,
      );

      await repository.assignRole(role);
      await repository.assignRole(role);

      expect(
        (await repository.getRoles(event.id)).length,
        2, // organiser + controller
      );
    });

    test('getRoles retourne une liste vide sans rôle', () async {
      expect(await repository.getRoles('e-inconnue'), isEmpty);
    });
  });

  group('DriftEventRepository — CRUD événements', () {
    test('createEvent persiste et est retrouvée par getEventById', () async {
      final event = await repository.createEvent(_event(), userId: 'org-1');

      final found = await repository.getEventById(event.id);

      expect(found.title, 'Concert de test');
      expect(found.maxPlaces, 100);
    });

    test('getMyEvents ne renvoie que les événements de l’organisateur',
        () async {
      final event = await repository.createEvent(
        _event(),
        userId: 'org-1',
      );
      await repository.createEvent(_event(), userId: 'org-2');

      final mine = await repository.getMyEvents('org-1');
      final other = await repository.getMyEvents('org-2');

      expect(mine.map((e) => e.id), [event.id]);
      expect(other, isNotEmpty);
    });

    test('updateEvent met à jour et refuse un id inconnu', () async {
      final event = await repository.createEvent(_event(), userId: 'org-1');

      final updated = await repository.updateEvent(
        event.copyWith(title: 'Nouveau titre'),
      );

      expect((await repository.getEventById(event.id)).title, updated.title);
      expect(
        () => repository.updateEvent(event.copyWith(id: 'inconnu')),
        throwsA(isA<Exception>()),
      );
    });

    test('updateEvent ne réécrit pas ticketsNumber (détenu par generate)',
        () async {
      final event = await repository.createEvent(_event(), userId: 'org-1');
      // Simule un stock déjà généré en base.
      await (database.update(database.events)
            ..where((row) => row.id.equals(event.id)))
          .write(db.EventsCompanion(ticketsNumber: Value(10)));

      await repository.updateEvent(event.copyWith(title: 'Titre modifié'));

      final row = await (database.select(database.events)
            ..where((row) => row.id.equals(event.id)))
          .getSingle();
      expect(row.ticketsNumber, 10);
      expect(row.title, 'Titre modifié');
    });

    test('getDiscoverEvents retourne les événements triés par date croissante',
        () async {
      await repository.createEvent(
        _event(eventDate: DateTime(2026, 1, 10)),
        userId: 'org-1',
      );
      await repository.createEvent(
        _event(eventDate: DateTime(2025, 12, 1)),
        userId: 'org-2',
      );
      await repository.createEvent(
        _event(eventDate: DateTime(2026, 3, 15)),
        userId: 'org-1',
      );

      final discover = await repository.getDiscoverEvents();

      expect(discover.length, 3);
      for (var i = 1; i < discover.length; i++) {
        expect(
          discover[i - 1].eventDate.isBefore(discover[i].eventDate) ||
              discover[i - 1].eventDate.isAtSameMomentAs(discover[i].eventDate),
          isTrue,
        );
      }
    });

    test('deleteEvent supprime l’événement, ses rôles et ses billets',
        () async {
      final event = await repository.createEvent(_event(), userId: 'org-1');
      await repository.assignRole(
        EventUserRole(
          userId: 'org-1',
          eventId: event.id,
          role: Role.controller,
        ),
      );

      await repository.deleteEvent(event.id);

      expect(await repository.getDiscoverEvents(), isEmpty);
      expect(await repository.getRoles(event.id), isEmpty);
      expect(
        () => repository.getEventById(event.id),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('intégrité — créateur obligatoire', () {
    test('createEvent refuse un créateur vide', () async {
      await expectLater(
        repository.createEvent(_event(), userId: '  '),
        throwsException,
      );
    });

    test('assignRole refuse un utilisateur inconnu', () async {
      final event = await repository.createEvent(_event(), userId: 'org-1');

      await expectLater(
        repository.assignRole(
          EventUserRole(
            userId: '',
            eventId: event.id,
            role: Role.controller,
          ),
        ),
        throwsException,
      );
    });
  });
}

Event _event({DateTime? eventDate}) => Event(
      id: '',
      title: 'Concert de test',
      description: 'Description',
      eventDate: eventDate ?? DateTime.now(),
      startTime: eventDate ?? DateTime.now(),
      type: EventType.concert,
      brandName: 'Artiste',
      eventPlace: 'Paris',
      maxPlaces: 100,
      status: EventStatus.upcoming,
    );