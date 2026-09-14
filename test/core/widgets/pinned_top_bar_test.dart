import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/widgets/pinned_top_bar.dart';

Widget _buildApp() {
  return MaterialApp(
    home: Scaffold(
      body: PinnedTopBar(
        header: const Text('Ma tête de page'),
        body: ListView.builder(
          itemCount: 50,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Ligne $i'),
          ),
        ),
      ),
    ),
  );
}

Color? _backgroundOf(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byType(PinnedTopBar),
      matching: find.byType(AnimatedContainer),
    ),
  );
  final decoration = container.decoration;
  return decoration is BoxDecoration ? decoration.color : null;
}

void main() {
  testWidgets('PinnedTopBar — header transparent au repos', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_buildApp());

    expect(find.text('Ma tête de page'), findsOneWidget);
    expect(_backgroundOf(tester), Colors.transparent);
  });

  testWidgets('PinnedTopBar — reste collé et fond plein après scroll',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_buildApp());

    await tester.fling(
      find.byType(ListView),
      const Offset(0, -1200),
      2000,
    );
    await tester.pumpAndSettle();

    // le header est toujours visible (épinglé) et devient opaque
    expect(find.text('Ma tête de page'), findsOneWidget);
    expect(_backgroundOf(tester), AppColors.background);
  });
}