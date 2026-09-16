import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

/// Fournit l'instance [AppDatabase] de l'application.
///
/// Doit être surchargée dans `main()` avec la base ouverte par
/// [openAppDatabase] (et par une base en mémoire dans les tests). Ne jamais
/// lire ce provider sans surcharge : ouvrir un fichier SQLite est asynchrone,
/// donc ça ne peut pas se faire dans le corps synchrone d'un `Provider`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider doit être surchargé (voir main() / openAppDatabase()).',
  );
});

/// Ouvre (ou crée) le fichier SQLite de l'application dans le répertoire
/// documents — un fichier par installation, qui survit aux redémarrages.
Future<AppDatabase> openAppDatabase() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File(p.join(directory.path, 'ticketpass.sqlite'));
  return AppDatabase(NativeDatabase.createInBackground(file));
}