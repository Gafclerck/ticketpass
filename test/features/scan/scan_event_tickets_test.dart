import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/routing/app_router.dart';
import 'package:ticketpass/core/security/ticket_signature_service.dart';
import 'package:ticketpass/features/event/data/repositories/mock_event_repository.dart';
import 'package:ticketpass/features/event/domain/entities/event.dart';
import 'package:ticketpass/features/event/domain/entities/event_status.dart';
import 'package:ticketpass/features/event/domain/entities/event_type.dart';
import 'package:ticketpass/features/event/presentation/providers/event_providers.dart';
import 'package:ticketpass/features/scan/presentation/providers/scan_providers.dart';
import 'package:ticketpass/features/ticket/data/repositories/fake_ticket_repository.dart';
import 'package:ticketpass/features/ticket/presentation/providers/ticket_providers.dart';

Event _event(String id) => Event(
      id: id,
      title: 'Concert scan',
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
          eventRepositoryProvider.overrideWithValue(eventRepository),
          ticketRepositoryProvider.overrideWithValue(ticketRepository),
          scanUseCameraProvider.overrideWithValue(false),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('scan — vérifie puis valide un billet VALID (UC10-11)',
      (tester) async {
    final eventRepository = MockEventRepository();
    await eventRepository.createEvent(
      _event('scan-event'),
      userId: 'demo-user-id',
    );

    final ticketRepository = FakeTicketRepository.demo(latency: Duration.zero);
    await ticketRepository.generateTickets('scan-event', 3);
    final acquired = await ticketRepository.acquireTicket(
      'scan-event',
      userId: 'visitor-1',
    );
    final payload = TicketSignatureService.buildQrPayload(
      acquired.id,
      'scan-event',
    );

    await pumpPage(
      tester,
      eventRepository: eventRepository,
      ticketRepository: ticketRepository,
      location: '/scan/scan-event',
    );

    await tester.enterText(find.byType(TextField), payload);
    await tester.tap(find.text('Vérifier'));
    await tester.pumpAndSettle();

    expect(find.text('Valider l’entrée'), findsOneWidget);
    expect(find.text('Valide'), findsOneWidget);

    await tester.tap(find.text('Valider l’entrée'));
    await tester.pumpAndSettle();

    expect(find.text('Utilisé'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('scan — accès refusé sans rôle organisateur/contrôleur',
      (tester) async {
    await pumpPage(
      tester,
      eventRepository: MockEventRepository.demo(),
      ticketRepository: FakeTicketRepository.demo(latency: Duration.zero),
      location: '/scan/event-demo-1',
    );

    expect(find.textContaining('Accès réservé'), findsOneWidget);
  });

  testWidgets('scan — signature invalide signalée', (tester) async {
    final eventRepository = MockEventRepository();
    await eventRepository.createEvent(
      _event('scan-event'),
      userId: 'demo-user-id',
    );

    await pumpPage(
      tester,
      eventRepository: eventRepository,
      ticketRepository: FakeTicketRepository.demo(latency: Duration.zero),
      location: '/scan/scan-event',
    );

    await tester.enterText(find.byType(TextField), 'ticket-1|scan-event|faux');
    await tester.tap(find.text('Vérifier'));
    await tester.pumpAndSettle();

    expect(
      find.text('QR illisible ou signature invalide.'),
      findsOneWidget,
    );
    expect(find.text('Valider l’entrée'), findsNothing);
  });
}