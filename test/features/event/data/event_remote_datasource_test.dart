import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/auth/domain/entities/role.dart';
import 'package:ticketpass/features/event/data/datasources/event_remote_datasource.dart';
import 'package:ticketpass/features/event/data/models/event_model.dart';
import 'package:ticketpass/features/event/domain/entities/event_status.dart';
import 'package:ticketpass/features/event/domain/entities/event_type.dart';

EventModel eventModel({
  String id = 'ev1',
  String title = 'Concert',
  EventStatus status = EventStatus.upcoming,
  EventType type = EventType.concert,
  int updatedAtMs = 0,
}) {
  return EventModel(
    id: id,
    title: title,
    description: 'Description',
    eventDate: DateTime(2026, 10, 1),
    startTime: DateTime(2026, 10, 1, 20),
    brandingUrl: '',
    type: type,
    brandName: 'Artiste',
    eventPlace: 'Paris',
    maxPlaces: 100,
    status: status,
    updatedAtMs: updatedAtMs,
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreEventRemoteDataSource datasource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = FirestoreEventRemoteDataSource(firestore: firestore);
  });

  group('createEvent / fetch', () {
    test('crée puis relit l’événement', () async {
      await datasource.createEvent(eventModel());

      final fetched = await datasource.fetchEventById('ev1');
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Concert');
      expect(fetched.updatedAtMs, 0);
    });

    test('createEvent idempotent (rejeu) : pas de doublon', () async {
      await datasource.createEvent(eventModel());
      await datasource.createEvent(eventModel());
      expect((await datasource.fetchAllEvents()).length, 1);
    });

    test('fetchEventById null pour un inconnu', () async {
      expect(await datasource.fetchEventById('nope'), isNull);
    });

    test('fetchAllEvents trié par event_date_ms', () async {
      await datasource.createEvent(
        eventModel(id: 'a', title: 'Tard', updatedAtMs: 2),
      );
      await firestore.collection('events').doc('b').set({
        'id': 'b',
        'title': 'truc',
        'event_date_ms': 0,
        'start_time_ms': 0,
        'event_type': 'concert',
        'max_places': 1,
        'event_status': 'upcoming',
      });

      final all = await datasource.fetchAllEvents();
      expect(all.map((e) => e.id).toList(), ['b', 'a']);
    });
  });

  test('updateEvent (merge) : le client conserve ses champs, seule la colonne horodatage évolue', () async {
    await datasource.createEvent(eventModel());
    final refetched = await datasource.fetchEventById('ev1');
    expect(refetched!.title, 'Concert');

    await datasource.updateEvent(
      eventModel(title: 'Concert renommé', updatedAtMs: 99),
    );
    final updated = await datasource.fetchEventById('ev1');
    expect(updated!.title, 'Concert renommé');
    expect(updated.eventPlace, 'Paris');
    expect(updated.updatedAtMs, 99);
  });

  group('assignRole (arrayUnion idempotent) / fetchRoles', () {
    test('empile les rôles sans écraser et sans doublon', () async {
      await datasource.createEvent(eventModel());
      await datasource.assignRole('ev1', 'user-a', Role.organiser);
      await datasource.assignRole('ev1', 'user-a', Role.organiser);
      await datasource.assignRole('ev1', 'user-a', Role.controller);
      await datasource.assignRole('ev1', 'user-b', Role.controller);

      final roles = await datasource.fetchRoles('ev1');
      expect(roles.length, 2);
      final a = roles.firstWhere((r) => r.userId == 'user-a');
      expect(a.roles.toSet(), {Role.organiser, Role.controller});
      final b = roles.firstWhere((r) => r.userId == 'user-b');
      expect(b.roles, [Role.controller]);
    });
  });

  group('deleteEvent (cascade + idempotent)', () {
    test('supprime billets, rôles puis le document', () async {
      await datasource.createEvent(eventModel());
      await datasource.assignRole('ev1', 'u1', Role.organiser);
      await firestore
          .collection('events')
          .doc('ev1')
          .collection('tickets')
          .doc('t1')
          .set({'id': 't1', 'user_id': ''});

      await datasource.deleteEvent('ev1');

      expect(await datasource.fetchEventById('ev1'), isNull);
      expect(
        (await firestore
                .collection('events')
                .doc('ev1')
                .collection('tickets')
                .get())
            .docs,
        isEmpty,
      );
      expect(
        (await firestore
                .collection('events')
                .doc('ev1')
                .collection('roles')
                .get())
            .docs,
        isEmpty,
      );
    });

    test('rejeu sur doc absent = succès (idempotent)', () async {
      await datasource.deleteEvent('ev1');
      await datasource.deleteEvent('ev1');
    });
  });
}