import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/routing/app_router.dart';
import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
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
  setUp(() => resetAuthRouting());
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
          authUserRepositoryOverride(),
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

  testWidgets(
      'EventDetailScreen — l’organisateur : les libellés d’actions sont '
      'masqués et ne se révèlent qu’au survol', (tester) async {
    final repository = MockEventRepository();
    final created = await repository.createEvent(
      _event('org-event-2'),
      userId: 'demo-user-id',
    );

    router.go('/event/${created.id}');
    await pumpDetail(
      tester,
      eventRepository: repository,
      ticketRepository: FakeTicketRepository.demo(latency: Duration.zero),
    );

    AnimatedOpacity pillOf(String label) {
      final animated = find.ancestor(
        of: find.text(label),
        matching: find.byType(AnimatedOpacity),
      );
      return tester.widget<AnimatedOpacity>(animated.first);
    }

    // masquées par défaut (spéc §5.6 : opacity 0, jamais fixes)
    expect(pillOf('Modifier').opacity, 0);

    // survol du cercle Scanner → la pilule apparaît (200 ms)
    final gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    addTearDown(gesture.removePointer);
    await gesture.addPointer(location: Offset.zero);
    await tester.pump();

    final scannerIcon = find.byIcon(Icons.qr_code_scanner);
    final center = tester.getCenter(scannerIcon);
    await gesture.moveTo(center);
    await tester.pump(const Duration(milliseconds: 300));

    expect(pillOf('Scanner').opacity, 1);
  });

  testWidgets(
      'EventDetailScreen — le header de tête de page devient opaque au scroll',
      (tester) async {
    router.go('/event/event-demo-1');
    await pumpDetail(
      tester,
      eventRepository: MockEventRepository.demo(),
      ticketRepository: FakeTicketRepository.demo(latency: Duration.zero),
    );

    // hauteur réduite pour garantir un contenu scrollable
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 1.0;
    await tester.pump();

    Color? headerColor() {
      final animated = find.ancestor(
        of: find.text('Kendrick Lamar — The Big Steppers'),
        matching: find.byType(AnimatedContainer),
      );
      final container = tester.widget<AnimatedContainer>(animated.first);
      final decoration = container.decoration;
      return decoration is BoxDecoration ? decoration.color : null;
    }

    // au repos : en-tête dans le flux, transparent (rien dessous)
    expect(headerColor(), Colors.transparent);

    await tester.fling(find.byType(ListView), const Offset(0, -600), 1000);
    await tester.pumpAndSettle();

    // au scroll : header épinglé + fond plein qui masque le contenu
    expect(find.text('Kendrick Lamar — The Big Steppers'), findsWidgets);
    expect(headerColor(), AppColors.background);
  });

  testWidgets(
      'EventDetailScreen — l’encoche du bas est incluse dans le dégagement',
      (tester) async {
    tester.view.padding = const FakeViewPadding(bottom: 34);
    router.go('/event/event-demo-1');
    await pumpDetail(
      tester,
      eventRepository: MockEventRepository.demo(),
      ticketRepository: FakeTicketRepository.demo(latency: Duration.zero),
    );

    final listView = tester.widget<ListView>(find.byType(ListView));
    expect(
      (listView.padding as EdgeInsets).bottom,
      AppSpacing.bottomClearanceWithNav + 34,
    );
  });
}