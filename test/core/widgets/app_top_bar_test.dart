import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/widgets/app_top_bar.dart';

void main() {
  testWidgets('AppTopBar — titre, retour et action de droite', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppTopBar(
                title: 'Mon billet',
                showBack: true,
                trailing: Icon(Icons.share_outlined),
              ),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Mon billet'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.share_outlined), findsOneWidget);
  });

  testWidgets('AppTopBar — bande pleine devant la zone safe area du haut',
      (tester) async {
    tester.view.padding = const FakeViewPadding(top: 44);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppTopBar(title: 'Billets'),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );

    // le ColoredBox #080808 remplit la zone d'encoche : hauteur = padding top
    final band = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(AppTopBar),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(band.color, AppColors.background);
    expect(tester.getSize(find.byType(AppTopBar)).height, greaterThan(44));
  });

  testWidgets('AppTopBar — reste figée quand le contenu scrolle', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const AppTopBar(title: 'Mon billet', showBack: true),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 100,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('Ligne $i'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Mon billet'), findsOneWidget);

    await tester.fling(
      find.byType(ListView),
      const Offset(0, -1200),
      2000,
    );
    await tester.pumpAndSettle();

    // la barre (hors scroll) reste visible ; le débute du scroll a disparu
    expect(find.text('Mon billet'), findsOneWidget);
    expect(find.text('Ligne 0'), findsNothing);
  });

  testWidgets('AppSafeTopBand — bande opaque à la hauteur de l’encoche',
      (tester) async {
    tester.view.padding = const FakeViewPadding(top: 47);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppSafeTopBand(),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AppSafeTopBand)).height, 47);

    final band = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(AppSafeTopBand),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(band.color, AppColors.background);
  });
}