import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ticketpass/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:ticketpass/features/auth/presentation/providers/auth_providers.dart';
import 'package:ticketpass/main.dart';

void main() {
  testWidgets('App boots logged out and shows the login screen', (
    tester,
  ) async {
    // UC14 : la garde de route redirige vers /login tant que personne n'est
    // connecté. On surcharge authRepositoryProvider avec le fake pour ne
    // jamais toucher le vrai Firebase dans ce test.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Se connecter'), findsOneWidget);
  });
}