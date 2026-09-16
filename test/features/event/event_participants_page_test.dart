import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/routing/app_router.dart';
import '../../helpers/mock_event_repository.dart';
import 'package:ticketpass/features/event/domain/entities/event.dart';
import 'package:ticketpass/features/event/domain/entities/event_status.dart';
import 'package:ticketpass/features/event/domain/entities/event_type.dart';
import 'package:ticketpass/features/event/presentation/providers/event_providers.dart';
import '../../helpers/fake_ticket_repository.dart';
import 'package:ticketpass/features/ticket/presentation/providers/ticket_providers.dart';
import '../../helpers/test_auth.dart';

Event _event(String id) => Event(
      id: id,
      title: 'Concert participants',
      description: 'Description.',
      eventDate: DateTime.now().add(const Duration(days: 7)),
      startTime: DateTime.now().add(const Duration(days: 7, hours: 2)),
      type: EventType.concert,
      brandName: 'Artiste',
      eventPlace: 'Lyon',
      maxPlaces: 100,
      status: EventStatus.upcoming,
    );

void main() {
  setUp(() => resetAuthRouting());
  Future<void> pumpPage(
    WidgetTester tester, {
    required MockEventRepository eventRepository,
    required FakeTicketRepository ticketRepository,
    required String location,
  }) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    router.go(location);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authUserRepositoryOverride(),
          eventRepositoryProvider.overrideWithValue(eventRepository),
          ticketRepositoryProvider.overrideWithValue(ticketRepository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('participants — l’organisateur liste et désigne un contrôleur',
      (tester) async {
    final eventRepository = MockEventRepository();
    await eventRepository.createEvent(
      _event('par-event'),
      userId: 'demo-user-id',
    );

    final ticketRepository = FakeTicketRepository.demo(latency: Duration.zero);
    await ticketRepository.generateTickets('par-event', 2);
    await ticketRepository.acquireTicket('par-event', userId: 'visitor-1');
    await ticketRepository.acquireTicket('par-event', userId: 'visitor-2');

    await pumpPage(
      tester,
      eventRepository: eventRepository,
      ticketRepository: ticketRepository,
      location: '/event/participants/par-event',
    );

    expect(find.text('visitor-1'), findsOneWidget);
    expect(find.text('visitor-2'), findsOneWidget);
    expect(find.text('Désigner contrôleur'), findsNWidgets(2));

    await tester.tap(find.text('Désigner contrôleur').first);
    await tester.pumpAndSettle();

    expect(find.text('Contrôleur'), findsOneWidget);
    expect(find.text('Désigner contrôleur'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('participants — accès refusé sans rôle', (tester) async {
    await pumpPage(
      tester,
      eventRepository: MockEventRepository.demo(),
      ticketRepository: FakeTicketRepository.demo(latency: Duration.zero),
      location: '/event/participants/event-demo-1',
    );

    expect(find.textContaining('Accès réservé'), findsOneWidget);
  });
}