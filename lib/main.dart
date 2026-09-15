import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketpass/core/database/database_provider.dart';
import 'package:ticketpass/core/database/local_user_sync.dart';
import 'package:ticketpass/core/routing/app_router.dart';
import 'package:ticketpass/core/theme/app_theme.dart';
import 'package:ticketpass/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // UC15 : base locale ouverte une seule fois ici (fichier SQLite dans le
  // répertoire documents), puis injectée via override — ouvrir un fichier
  // est asynchrone, donc ça ne peut pas se faire dans le corps d'un Provider.
  final database = await openAppDatabase();

  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // UC15 : active la synchro Firebase -> table locale Users pour toute la
    // durée de vie de l'app (voir userSyncEffectProvider).
    ref.watch(userSyncEffectProvider);

    return MaterialApp.router(
      title: 'TicketPass',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
