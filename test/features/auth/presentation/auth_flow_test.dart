import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/routing/app_router.dart';
import 'package:ticketpass/core/routing/app_routes.dart';
import 'package:ticketpass/features/auth/domain/errors/auth_exception.dart';
import 'package:ticketpass/features/auth/presentation/pages/login_page.dart';
import 'package:ticketpass/features/auth/presentation/pages/register_page.dart';
import 'package:ticketpass/features/home/presentation/screens/home_page.dart';
import 'package:ticketpass/features/profile/presentation/screens/profile_page.dart';
import 'package:ticketpass/main.dart';
import '../../../helpers/test_auth.dart';
import '../../../helpers/test_database.dart';

/// Tests du flux d'authentification : guard du routeur (redirect + pending
/// location) et formulaires Login / Register.
void main() {
  setUp(() => resetAuthRouting());

  Future<void> pumpApp(
    WidgetTester tester, {
    required ProviderScope scope,
    List<String>? goTo,
  }) async {
    // Surface haute : la ListView des pages auth construit tout le contenu
    // (le bouton d'envoi est sous la ligne de flottaison sinon).
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    if (goTo != null) {
      for (final location in goTo) {
        router.go(location);
      }
    }
    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();
  }

  Future<void> flushTimers(WidgetTester tester) async {
    // Le profil/accueil chargent les repos démo (latence 200 ms) : attendre
    // la fin de leurs timers pour ne pas laisser de timer pendant au teardown.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  group('guard du routeur', () {
    testWidgets('boot déconnecté → /login', (tester) async {
      await pumpApp(
        tester,
        scope: ProviderScope(
          overrides: [
            authUserRepositoryOverride(unauthenticated: true),
            appDatabaseInMemoryOverride(),
          ],
          child: const MyApp(),
        ),
      );

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('page d’auth visitée connecté → /home', (tester) async {
      await pumpApp(
        tester,
        scope: ProviderScope(
          overrides: [
          authUserRepositoryOverride(),
          appDatabaseInMemoryOverride(),
        ],
        child: const MyApp(),
      ),
      goTo: [AppRoutes.login],
      );

expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(RegisterPage), findsNothing);
      await flushTimers(tester);
    });

    testWidgets(
        'écran protégé visé déconnecté → login puis retour sur la '
        'destination initiale après connexion', (tester) async {
      await pumpApp(
        tester,
        scope: ProviderScope(
          overrides: [
          authUserRepositoryOverride(unauthenticated: true),
          appDatabaseInMemoryOverride(),
        ],
        child: const MyApp(),
      ),
      goTo: [AppRoutes.profile],
      );

      // la destination protégée a été mémorisée, on est sur login
      expect(find.byType(LoginPage), findsOneWidget);

      // connexion simulée avec les identifiants du stub
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'alice@exemple.fr',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Mot de passe'),
        'password',
      );
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      // retour sur la destination initiale → Profil
      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);

      await flushTimers(tester);
    });
  });

  group('Login', () {
    testWidgets('identifiants invalides → message d’erreur (AuthException)',
        (tester) async {
      await pumpApp(
        tester,
        scope: ProviderScope(
          overrides: [
            authUserRepositoryOverride(
              unauthenticated: true,
              signInError: AuthException('Identifiants incorrects.'),
            ),
            appDatabaseInMemoryOverride(),
          ],
          child: const MyApp(),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'alice@exemple.fr',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Mot de passe'),
        'mauvais',
      );
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Identifiants incorrects.'), findsOneWidget);
    });
  });

  group('Register', () {
    testWidgets('validations du formulaire', (tester) async {
      await pumpApp(
        tester,
        scope: ProviderScope(
          overrides: [
          authUserRepositoryOverride(unauthenticated: true),
          appDatabaseInMemoryOverride(),
        ],
        child: const MyApp(),
      ),
      goTo: [AppRoutes.register],
      );

      expect(find.text('Créer un compte'), findsOneWidget);

      await tester.tap(find.text('Créer mon compte'));
      await tester.pumpAndSettle();

      expect(find.text('Le nom complet est obligatoire.'), findsOneWidget);
      expect(find.text('L’email est obligatoire.'), findsOneWidget);
      expect(
        find.text('Le mot de passe fait 6 caractères minimum.'),
        findsWidgets,
      );
    });

    testWidgets('inscription valide → création de compte puis /home',
        (tester) async {
      await pumpApp(
        tester,
        scope: ProviderScope(
          overrides: [
          authUserRepositoryOverride(unauthenticated: true),
          appDatabaseInMemoryOverride(),
        ],
        child: const MyApp(),
      ),
      goTo: [AppRoutes.register],
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Nom complet'),
        'Alice Martin',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'alice@exemple.fr',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Mot de passe'),
        'password',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirmer le mot de passe'),
        'password',
      );
      await tester.tap(find.text('Créer mon compte'));
      await tester.pumpAndSettle();

expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      await flushTimers(tester);
    });

    testWidgets('nav « Déjà un compte ? Se connecter » → /login',
        (tester) async {
      await pumpApp(
        tester,
        scope: ProviderScope(
          overrides: [
          authUserRepositoryOverride(unauthenticated: true),
          appDatabaseInMemoryOverride(),
        ],
        child: const MyApp(),
      ),
      goTo: [AppRoutes.register],
      );

      await tester.tap(find.text('Déjà un compte ? Se connecter'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}