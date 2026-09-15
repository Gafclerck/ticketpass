import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/database/app_database.dart' show AppDatabase;
import 'package:ticketpass/features/event/data/repositories/drift_event_repository.dart';
import 'package:ticketpass/features/event/domain/entities/event.dart';
import 'package:ticketpass/features/event/domain/entities/event_status.dart';
import 'package:ticketpass/features/event/domain/entities/event_type.dart';

Event _sampleEvent({String id = ''}) {
  final now = DateTime(2027, 6, 1, 18);
  return Event(
    id: id,
    title: 'Flutter Summer Camp',
    description: 'Conférence Flutter.',
    eventDate: now,
    startTime: now,
    type: EventType.conference,
    brandName: 'Flutter Fire Camp',
    eventPlace: 'Paris',
    maxPlaces: 100,
    status: EventStatus.upcoming,
  );
}

void main() {
  late AppDatabase database;
  late DriftEventRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftEventRepository(database);
  });

  tearDown(() => database.close());

  group('DriftEventRepository (UC15)', () {
    test('createEvent persiste l’événement et le rôle organiser', () async {
      final created = await repository.createEvent(
        _sampleEvent(),
        userId: 'user-1',
      );

      expect(created.id, isNotEmpty);

      final found = await repository.getEventById(created.id);
      expect(found.title, 'Flutter Summer Camp');

      final mine = await repository.getMyEvents('user-1');
      expect(mine.map((e) => e.id), contains(created.id));
    });

    test('getMyEvents ne retourne que les événements dont on est organiser', () async {
      await repository.createEvent(_sampleEvent(), userId: 'user-1');
      await repository.createEvent(_sampleEvent(), userId: 'user-2');

      final mine = await repository.getMyEvents('user-1');
      final autre = await repository.getMyEvents('user-2');

      expect(mine, hasLength(1));
      expect(autre, hasLength(1));
    });

    test('getDiscoverEvents retourne tous les événements', () async {
      await repository.createEvent(_sampleEvent(), userId: 'user-1');
      await repository.createEvent(_sampleEvent(), userId: 'user-2');

      final all = await repository.getDiscoverEvents();
      expect(all, hasLength(2));
    });

    test('getEventById inconnu lève une exception', () async {
      expect(
        () => repository.getEventById('inconnu'),
        throwsA(isA<Exception>()),
      );
    });

    test('updateEvent modifie l’événement existant', () async {
      final created = await repository.createEvent(
        _sampleEvent(),
        userId: 'user-1',
      );

      final updated = await repository.updateEvent(
        created.copyWith(title: 'Nouveau titre'),
      );

      expect(updated.title, 'Nouveau titre');
      final reread = await repository.getEventById(created.id);
      expect(reread.title, 'Nouveau titre');
    });

    test('deleteEvent retire l’événement et son rôle organiser', () async {
      final created = await repository.createEvent(
        _sampleEvent(),
        userId: 'user-1',
      );

      await repository.deleteEvent(created.id);

      expect(
        () => repository.getEventById(created.id),
        throwsA(isA<Exception>()),
      );
      final mine = await repository.getMyEvents('user-1');
      expect(mine, isEmpty);
    });
  });
}
