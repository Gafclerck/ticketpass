# TickerPass (Flutter)

## Commandes
- `flutter analyze` — vérification statique (doit rester à 0 issue).
- `flutter test` — tests (fake repo UC billets + boot widget).

## Structuration
- Entités conformes à `docs/classe.md` ; use cases côté domaine ; repos / fakes côté data ; présentation = Riverpod + widgets DS dans `lib/core/theme` et `lib/core/widgets`.
- Identité utilisateur : passe par `features/auth/presentation/providers/current_user_provider.dart` (source unique, remplace le sprint Firebase Auth).

## Règles de routage (importantes)
- Les 4 onglets du shell : `StatefulShellRoute.indexedStack` dans `lib/core/routing/app_router.dart` (nav bar flottante).
- **Toute page qui doit cacher la barre de navigation = une `GoRoute` RACINE (hors `StatefulShellRoute`) enveloppée dans `AppShell`**, comme `/ticket/:id` et `/event/create|edit`. Ne pas utiliser `Navigator.push` depuis une branche : le push atterrit sur le navigateur de la branche et la nav flottante reste au-dessus du contenu.
- Aller vers un onglet : `context.go(AppRoutes.<name>)`. Aller vers une page plein-écran : `context.push(...)` ; rendre le résultat via `context.pop(true)` quand le caller doit invalider ses providers.
- Après une création / modification / suppression, invalider `myEventsProvider` ET `discoverEventsProvider` si l'écran d'origine affiche l'un d'eux.