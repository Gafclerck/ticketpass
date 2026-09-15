import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ticketpass/features/home/presentation/screens/home_page.dart';
import 'package:ticketpass/main.dart';
import 'helpers/test_auth.dart';

void main() {
  setUp(() => resetAuthRouting());

  testWidgets('App boots and shows the home screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authUserRepositoryOverride()],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });
}