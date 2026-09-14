import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/auth/domain/entities/role.dart';
import 'package:ticketpass/features/event/data/repositories/mock_event_repository.dart';
import 'package:ticketpass/features/event/domain/entities/event.dart';
import 'package:ticketpass/features/event/domain/entities/event_status.dart';
import 'package:ticketpass/features/event/domain/entities/event_type.dart';
import 'package:ticketpass/features/event/domain/entities/event_user_role.dart';

void main() {
  group('MockEventRepository — rôles (UC24)', () {
    test('la création attribue le rôle organiser au créateur', () async {
      final repository = MockEventRepository();
      final event = await repository.createEvent(
        _event(),
        userId: 'org-1',
      );

      final roles = await repository.getRoles(event.id);

      expect(
        roles.any((r) => r.userId == 'org-1' && r.role == Role.organiser),
        isTrue,
      );
    });

    test('assignRole ajoute un contrôleur', () async {
      final repository = MockEventRepository();
      await repository.assignRole(
        EventUserRole(
          userId: 'ctrl-1',
          eventId: 'e1',
          role: Role.controller,
        ),
      );

      final roles = await repository.getRoles('e1');

      expect(roles.single.role, Role.controller);
    });

    test('assignRole est idempotent', () async {
      final repository = MockEventRepository();
      final role = EventUserRole(
        userId: 'ctrl-1',
        eventId: 'e1',
        role: Role.controller,
      );
      await repository.assignRole(role);
      await repository.assignRole(role);

      expect((await repository.getRoles('e1')).length, 1);
    });

    test('getRoles retourne une liste vide sans rôle', () async {
      final repository = MockEventRepository();

      expect(await repository.getRoles('e-inconnue'), isEmpty);
    });
  });
}

Event _event() => Event(
      id: '',
      title: 'Concert de test',
      description: 'Description',
      eventDate: DateTime.now(),
      startTime: DateTime.now(),
      type: EventType.concert,
      brandName: 'Artiste',
      eventPlace: 'Paris',
      maxPlaces: 100,
      status: EventStatus.upcoming,
    );