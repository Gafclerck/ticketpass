import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketpass/core/database/database_provider.dart';
import 'package:ticketpass/core/routing/app_router.dart';
import 'package:ticketpass/core/sync/pull_service.dart';
import 'package:ticketpass/core/sync/sync_engine.dart';
import 'package:ticketpass/core/sync/sync_handlers.dart';
import 'package:ticketpass/core/sync/sync_lifecycle.dart';
import 'package:ticketpass/core/sync/sync_providers.dart';
import 'package:ticketpass/core/sync/sync_store.dart';
import 'package:ticketpass/core/theme/app_theme.dart';
import 'package:ticketpass/features/auth/presentation/providers/auth_providers.dart';
import 'package:ticketpass/features/event/data/datasources/event_remote_datasource.dart';
import 'package:ticketpass/features/ticket/data/datasources/ticket_remote_datasource.dart';
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

  // Base locale (events/tickets/rôles) — ouverte AVANT le premier frame.
  final database = await openAppDatabase();

  // Convergence locale ↔ Firestore (source de vérité). Le conteneur est créé
  // explicitement pour que le lifecycle puisse, en fin de cycle, incrémenter
  // `syncRevisionProvider` et déclencher le refetch des écrans.
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
  );
  final eventsRemote = FirestoreEventRemoteDataSource();
  final ticketsRemote = FirestoreTicketRemoteDataSource();
  final store = SyncStore(database);
  final engine = SyncEngine(
    store: store,
    handlers: SyncHandlers(events: eventsRemote, tickets: ticketsRemote),
  );
  final pull = PullService(
    database: database,
    events: eventsRemote,
    tickets: ticketsRemote,
    store: store,
  );
  final lifecycle = SyncLifecycle(
    engine: engine,
    pull: pull,
    onCycleDone: () {
      container.read(syncRevisionProvider.notifier).bump();
    },
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(lifecycle: lifecycle),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key, this.lifecycle});

  /// Détenu par `main()` ; null dans les tests (widget tests) où la
  /// synchronisation n'est volontairement pas démarrée.
  final SyncLifecycle? lifecycle;

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