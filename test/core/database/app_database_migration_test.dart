import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/database/app_database.dart';

import '../../helpers/test_database.dart';

/// Couvre le chemin `onUpgrade` (2 → 3) jamais exercé par les tests en mémoire.
/// Ouvre sur fichier, rétrograde volontairement `user_version` pour forcer la
/// migration destructrice, puis vérifie que le schéma v3 est correctement
/// recréé et réutilisable.
void main() {
  setUpAll(silenceDriftWarnings);

  test('migration 2 → 3 : reset du schéma, données purgeées, schéma réutilisable',
      () async {
    final tempDir = Directory.systemTemp.createTempSync('ticketpass_migration_');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final file = File('${tempDir.path}/app.sqlite');

    // Ouvre en v3, insère un seed, puis rétrograde en v2.
    final v3 = AppDatabase(NativeDatabase(file));
    await v3.customSelect('SELECT 1').get(); // force l'ouverture
    await insertEvent(v3, 'seed-event');
    await v3.customStatement('PRAGMA user_version = 2');
    await v3.close();

    // Réouverture : drift détecte v2 < 3 et exécute la migration destructrice.
    final migrated = AppDatabase(NativeDatabase(file));
    await migrated.customSelect('SELECT 1').get();

    final version =
        await migrated.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 3);

    // Le seed v2 a bien été purgé.
    final count =
        await migrated.customSelect('SELECT COUNT(*) FROM events').getSingle();
    expect(count.data.values.first, 0);

    // Le schéma v3 est immédiatement réutilisable.
    await insertEvent(migrated, 'ev-after');
    final after =
        await migrated.customSelect('SELECT COUNT(*) FROM events').getSingle();
    expect(after.data.values.first, 1);

    await migrated.close();
  });
}
