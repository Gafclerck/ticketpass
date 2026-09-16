# TickerPass (Flutter)

## Méthodologie de travail (screen par screen)

Les modifications se font **écran après écran**, jamais plusieurs en même temps. Chaque étape est **validée par l'utilisateur avant de passer à la suivante** (il n'y a jamais deux étapes exécutées d'affilée sans validation intermédiaire).

1. **Analyse & diagnostic** de l'écran → on identifie ce qui ne va pas.
2. **Plan de correction** (validé par l'utilisateur).
3. **Évaluation de l'étendue** : quel est l'impact ? Est-ce que ça touche d'autres écrans ?
4. **Plan définitif puis exécution** (validé par l'utilisateur).
5. **Tests** (règles RG, `flutter analyze` 0 issue, `flutter test` verts) pour s'assurer que rien ne casse.
6. **Commit**.

Ensuite on recommence le même cycle sur l'écran suivant.

## Commandes
- `flutter analyze` — vérification statique (doit rester à 0 issue).
- `flutter test` — suite complète (141 tests : UC domaine/data + sync C-a→C-d + widget tests).

## Structuration
- Entités conformes à `docs/classe.md` ; use cases côté domaine ; data = repos **drift** (`DriftEventRepository`, `DriftTicketRepository`, cache) + datasources **Firestore** (`FirestoreEventRemoteDataSource`, `FirestoreTicketRemoteDataSource`) ; présentation = Riverpod + widgets DS dans `lib/core/theme` et `lib/core/widgets`.
- Identité utilisateur : passe par `features/auth/presentation/providers/current_user_provider.dart` (source unique, remplace le sprint Firebase Auth).

## Sync (slice C — local-first, Firestore source de vérité)
- **Toute écriture = enqueue outbox DANS la même transaction drift** que la mutation (parcours : `drift_*_repository.dart` + `sync_store.dart`). Un conflit **CAS** (billet) → op `cancelled` + pull de réconciliation ; échec réseau → backoff 2 s → 5 min, max 8 tentatives.
- **PullService** : upsert events (`ticketsNumber = max(local, count)`, jamais écrit distants), rôles réassemblés (union remote + assigns pendants), suppression des absents **sauf pending**, **tombstone** = `event/delete` pending (le pull ne recrée jamais) ; tire mes billets + billets des events staff.
- **Refetch auto** : `syncRevisionProvider` (bump par `SyncLifecycle`, lancé UNIQUEMENT dans `main()`, jamais en test) — les FutureProviders du catalogue le `watch`. Ne pas enchaîner un refetch manuel par-dessus.
- `deploy/firestore.rules` = règles d'accès de référence (create auth, reste organiser/owner). Slope datasources/tests : `fake_cloud_firestore` (jamais de règles en test, jamais de timer en arrière-plan).

## Règles de routage (importantes)
- Les 4 onglets du shell : `StatefulShellRoute.indexedStack` dans `lib/core/routing/app_router.dart` (nav bar flottante).
- **Toute page qui doit cacher la barre de navigation = une `GoRoute` RACINE (hors `StatefulShellRoute`) enveloppée dans `AppShell`**, comme `/ticket/:id` et `/event/create|edit`. Ne pas utiliser `Navigator.push` depuis une branche : le push atterrit sur le navigateur de la branche et la nav flottante reste au-dessus du contenu.
- Aller vers un onglet : `context.go(AppRoutes.<name>)`. Aller vers une page plein-écran : `context.push(...)` ; rendre le résultat via `context.pop(true)` quand le caller doit invalider ses providers.
- Après une création / modification / suppression, invalider `myEventsProvider` ET `discoverEventsProvider` si l'écran d'origine affiche l'un d'eux.