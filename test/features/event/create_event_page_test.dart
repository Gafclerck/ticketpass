import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/routing/app_router.dart';
import 'package:ticketpass/core/routing/app_routes.dart';
import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';

void main() {
  Future<void> pumpCreate(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
  }

  Color? headerColor(WidgetTester tester) {
    final animated = find.ancestor(
      of: find.text('Créer un événement'),
      matching: find.byType(AnimatedContainer),
    );
    final container = tester.widget<AnimatedContainer>(animated.first);
    final decoration = container.decoration;
    return decoration is BoxDecoration ? decoration.color : null;
  }

  testWidgets(
      'CreateEventPage — le header est transparent au repos et opaque au '
      'scroll', (tester) async {
    router.go(AppRoutes.eventCreate);
    await pumpCreate(tester);

    // hauteur réduite pour garantir un contenu scrollable
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 1.0;
    await tester.pump();

    expect(find.text('Créer un événement'), findsOneWidget);

    // au repos : en-tête dans le flux, transparent
    expect(headerColor(tester), Colors.transparent);

    await tester.fling(find.byType(ListView), const Offset(0, -600), 1000);
    await tester.pumpAndSettle();

    // au scroll : en-tête épinglé + fond plein qui masque le contenu
    expect(find.text('Créer un événement'), findsOneWidget);
    expect(headerColor(tester), AppColors.background);
  });

  testWidgets(
      'CreateEventPage — l’encoche du bas est incluse dans le dégagement',
      (tester) async {
    tester.view.padding = const FakeViewPadding(bottom: 34);
    router.go(AppRoutes.eventCreate);
    await pumpCreate(tester);

    final listView = tester.widget<ListView>(find.byType(ListView));
    expect(
      (listView.padding as EdgeInsets).bottom,
      AppSpacing.bottomClearanceNoNav + 34,
    );
  });
}