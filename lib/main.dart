import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketpass/core/routing/app_router.dart';
import 'package:ticketpass/core/theme/app_theme.dart';
import 'package:ticketpass/features/auth/presentation/providers/auth_providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fond sombre + icônes claires (SystemUiOverlayStyle.dark = light icons)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  try {
    // Généré par `flutterfire configure` — tant qu'il n'a pas tourné, le
    // scaffold lève UnsupportedError et l'app affiche l'écran de setup.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    runApp(const ProviderScope(child: FirebaseSetupRequiredApp()));
    return;
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Garde l'état d'authentification vivant dès le boot : sans cette ligne,
    // rien ne souscrit à authStateChanges et un utilisateur déjà connecté
    // (session persistée) resterait bloqué sur l'écran de connexion.
    ref.watch(authControllerProvider);

    return MaterialApp.router(
      title: 'TicketPass',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}

/// Écran de garde affiché quand la configuration Firebase est absente
/// (`lib/firebase_options.dart` non généré par `flutterfire configure`).
class FirebaseSetupRequiredApp extends StatelessWidget {
  const FirebaseSetupRequiredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const Scaffold(
        backgroundColor: Color(0xFF080808),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Firebase n’est pas encore configuré. Lancez « flutterfire '
              'configure » depuis la racine du projet, puis relancez l’app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFF5F7FA), fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}