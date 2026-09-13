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

  testWidgets(
      'EventDetailScreen — un visiteur obtient un billet (UC19) puis voit '
      '« Voir mon billet »', (tester) async {
    router.go('/event/event-demo-1');
    await pumpDetail(
      tester,
      eventRepository: MockEventRepository.demo(),
      ticketRepository: FakeTicketRepository.demo(latency: Duration.zero),
    );

    // design spec : header flottant, hero, chips, « À propos »
    expect(find.text('Kendrick Lamar — The Big Steppers'), findsWidgets);
    expect(find.text('Obtenir un billet'), findsOneWidget);
    expect(find.text('À propos'), findsOneWidget);

    await tester.tap(find.text('Obtenir un billet'));
    await tester.pumpAndSettle();

    // redirection vers le billet obtenu (ROADMAP)
    expect(find.text('Mon billet'), findsOneWidget);

    // retour sur le détail : l'utilisateur est désormais porteur
    router.go('/event/event-demo-1');
    await tester.pumpAndSettle();

    expect(find.text('Voir mon billet'), findsOneWidget);
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

    // pile flottante droite (spéc §8 organisateur) + bloc jauge
    expect(find.text('Générer'), findsOneWidget);
    expect(find.text('Voir les billets'), findsOneWidget);
    expect(find.text('Participants'), findsOneWidget);
    expect(find.text('Modifier'), findsOneWidget);
    expect(find.text('Scanner'), findsOneWidget);
    expect(find.text('À propos'), findsOneWidget);
    expect(find.text('Jauge'), findsOneWidget);
  });
}