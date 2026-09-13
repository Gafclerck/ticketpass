import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/routing/app_router.dart';
import 'package:ticketpass/features/event/data/repositories/mock_event_repository.dart';
import 'package:ticketpass/features/event/domain/entities/event.dart';
import 'package:ticketpass/features/event/domain/entities/event_status.dart';
import 'package:ticketpass/features/event/domain/entities/event_type.dart';
import 'package:ticketpass/features/event/presentation/providers/event_providers.dart';
import 'package:ticketpass/features/ticket/data/repositories/fake_ticket_repository.dart';
import 'package:ticketpass/features/ticket/presentation/providers/ticket_providers.dart';

Event _event(String id) => Event(
      id: id,
      title: 'Concert de test',
      description: 'Description courte.',
      eventDate: DateTime.now().add(const Duration(days: 7)),
      startTime: DateTime.now().add(const Duration(days: 7, hours: 2)),
      type: EventType.concert,
      brandName: 'Artiste',
      eventPlace: 'Lyon',
      maxPlaces: 100,
      status: EventStatus.upcoming,
    );

void main() {
  Future<void> pumpDetail(
    WidgetTester tester, {
    required MockEventRepository eventRepository,
    required FakeTicketRepository ticketRepository,
  }) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventRepositoryProvider.overrideWithValue(eventRepository),
          ticketRepositoryProvider.overrideWithValue(ticketRepository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('EventDetailScreen — un visiteur peut prendre un billet (UC19)',
      (tester) async {
    router.go('/event/event-demo-1');
    await pumpDetail(
      tester,
      eventRepository: MockEventRepository.demo(),
      ticketRepository: FakeTicketRepository.demo(latency: Duration.zero),
    );

    expect(find.text('Kendrick Lamar — The Big Steppers'), findsWidgets);
    expect(find.text('Prendre un billet'), findsOneWidget);

    await tester.tap(find.text('Prendre un billet'));
    await tester.pumpAndSettle();

    expect(find.text('Voir mon billet'), findsOneWidget);

    // laisser le SnackBar s'auto-masquer pour ne pas laisser de timer.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('EventDetailScreen — l’organisateur voit les actions de gestion',
      (tester) async {
    final repository = MockEventRepository();
    final created = await repository.createEvent(
      _event('org-event-1'),
      userId: 'demo-user-id',
    );

    router.go('/event/${created.id}');
    await pumpDetail(
      tester,
      eventRepository: repository,
      ticketRepository: FakeTicketRepository.demo(latency: Duration.zero),
    );

    expect(find.text('Modifier l’événement'), findsOneWidget);
    expect(find.text('Voir les billets'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}