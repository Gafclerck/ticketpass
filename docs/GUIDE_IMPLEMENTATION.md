# Guide d'implémentation — TicketPass (Flutter)

Document de référence pour comprendre ce qui est implémenté et contribuer.
Source de vérité produit : `docs/FLUTTER_PROTOTYPE_SPEC.md` (UI) et `docs/classe.md` (domaine).
Règles complémentaires : `AGENTS.md`.

---

## 1. Architecture & organisation des couches

Chaque fonctionnalité (`features/`) suit le même découpage vertical :

```
features/<feature>/
  domain/    entités (docs/classe.md) · use cases (1 classe = 1 action) · contrats de repos
  data/      implémentations fake + modèles + datasources (non branchées)
  presentation/  providers Riverpod · écrans/pages · widgets feature
core/         tokens DS · widgets DS · routage · app shell
```

- **Dépendances** : presentation → domain (jamais l'inverse) ; data → domain seulement.
- **Entités** : classes manuelles conformes à `docs/classe.md` (`copyWith` écrit à la main, pas de freezed).
- **Fakes** : `MockEventRepository`, `FakeTicketRepository` simulent la latence et les règles métier. Les contrats datasources (`ticket_local_datasource`…) existent mais ne sont pas branchés : **le provider Riverpod est l'unique point de bascule fake → réel**.
- **Identité** : `features/auth/presentation/providers/current_user_provider.dart` expose l'utilisateur démo (`User`). C'est la **source unique** ; l'ancien `core/providers/current_user_provider.dart` a été supprimé.

### Providers existants (résumé)

| Provider | Type | Rôle |
|---|---|---|
| `currentUserProvider` | Provider\<User> | utilisateur courant démo (`demo-user-id`) |
| `eventRepositoryProvider` | Provider\<EventRepository> | `MockEventRepository.demo()` (catalogue seed de 3 événements) |
| `myEventsProvider(userId)` | FutureProvider.family | événements créés par l'user |
| `discoverEventsProvider` | FutureProvider | catalogue public (Home) |
| `eventProvider(eventId)` | FutureProvider.family | détail (édition, futur EventDetail) |
| `createEvent/updateEvent/deleteEventProvider` | Provider\<UseCase> | mutations |
| `myTicketsProvider(userId)` | FutureProvider.family | billets de l'user |
| `ticketProvider(ticketId)` | FutureProvider.family | détail billet |
| `importTicketProvider` | Provider\<UseCase> | UC7 import (code → billet VALID) |

---

## 2. Design System (logique d'implémentation)

### 2.1 Tokens (`lib/core/theme/`)

- `app_colors.dart` — palette du Dark (glask blue `#148CFA`, fond `#080808`, glass white 10/12/14%, textes primaire/secondaire/muted, variantes d'états `primaryHovered/Pressed/Border`, statuts success/error). **Pas de `ColorScheme.fromSeed`** : la spec impose une palette custom ; `AppTheme._colorScheme` est écrit manuellement.
- `app_spacing.dart` — échelle 4/8/12/16/20/24/32/40 + constraints globaux : `pageHorizontal` (20), `pageTop` (48), `bottomClearanceWithNav` (= hauteur nav 76 + offset 16 + 20 = 112), `bottomClearanceNoNav` (40).
- `app_radius.dart` — `card` 28, `large` 32, `box` 20, `button` 28, `pill` 999, etc.
- `app_typography.dart` — `ui` = Inter, `display` = Playfair.
- `app_theme.dart` — **SEUL endroit qui assemble les tokens en `ThemeData`** : `fontFamily: Inter`, textTheme Google Fonts avec Playfair sur les titres, `inputDecorationTheme` verre (h56, radius 20, focus primary/50), `cardTheme` glass. Pages : helper `AppTheme.pagePadding(bottom:)`.

### 2.2 Coquille `AppShell` + glow

`lib/core/widgets/app_shell.dart` pose le fond `#080808` + **halo radial bleu** (top-right, 28% → transparent). Toute page plein-écran est enveloppée dans `AppShell`.

### 2.3 Widgets DS (`lib/core/widgets/`) — mapping spec

| Spec | Widget | Notes |
|---|---|---|
| §5.2/5.13 | `PressableScale`, `UserAvatar` | feedback tactile scale 0.90–0.98 ; avatar image/initiales |
| §5.12 | `AppButton` | 4 variantes (`primary/secondary/ghost/danger`), 3 tailles (`sm 40/md 48/lg 56`), `fullWidth` |
| §5.14 | `GlassCard` | `defaultMode` white/10 blur24 / `elevated` white/14 blur28 |
| §5.7 | `BackButtonCircle` | cercle 44 glass, `context.pop()` par défaut |
| §5.11 | `AppSearchField` | h56 pill, loupe, focus primary |
| §5.9 | `StatusBadge` | fond rgba(couleur,20%), texte couleur, bordure 30%, 4 variantes (`blue/green/red/gray`) |
| §5.1 | `AppShell` | + `PageHeader` (titre Playfair, back optionnel, trailing) |
| §8 (+§5.4) | `EmptyState`, `EventCard`, `TicketCard` | états vides DS ; cartes discovery / porterfeuille |

**Règle cadence** : ne promouvoir un widget en `core/widgets` que s'il est utilisé ≥ 3 fois ; sinon il reste local à la feature (ex : segments/chips de la Home restent privés dans `home_page.dart`).

### 2.4 Badges

- `StatusBadge` (core) : générique, prend `label` + `variant`.
- `TicketStatusBadge` (feature ticket) : mappe `TicketStatus` → variante (valid→green, used→gray, unused→blue, invalid/revoked→red).
- Même principe pour le statut d'événement dans `EventCard`.

---

## 3. Décisions clés et raisons

| Décision | Raison |
|---|---|
| Pas de `ColorScheme.fromSeed`, palette custom | la spec impose un bleu électrique unique + verre blanc ; `fromSeed` dérive une palette tonale M3 incontrôlée |
| Inter (UI) + Playfair (titres) via `google_fonts` | spec §9 ; un seul `ThemeData` (`AppTheme.dark`) branché dans `main.dart` |
| QR placé sur **fond blanc** | sur thème sombre un QR noir devient invisible ; la carte billet utilisait avant un fond sombre |
| **CTA dans le contenu, jamais de FAB** | les pages d'onglet vivent sous la nav bar flottante (Stack) ; un `FloatingActionButton` est entièrement recouvert. Le CTA vit dans l'état vide / en tête de liste |
| **Pages plein-écran = GoRoute racine + AppShell** | `Navigator.push` depuis une branche atterrit sur le navigateur de la branche → la nav flottante reste au-dessus et masque le contenu. Toutes les pages plein-écran (`/ticket/:id`, `/event/create`, `/event/edit?id=`) sont des routes racine |
| Clearance unifiée `bottomClearanceWithNav` (112) | le dernier item d'un onglet doit rester au-dessus de la nav (92) + marge (20) |
| Nav bar dans un `SafeArea` | inset des appareils à encoche (home indicator) pas pris en compte avec un `Positioned(bottom:16)` |
| Identité unifiée (`currentUserProvider`) | éviter deux sources de vérité (l'ancien provider core `currentUserIdProvider` a été supprimé) |
| `getEventById` ajouté au repo | l'édition charge par id (deep-linkable, cache par `eventProvider`) et prépare l'EventDetail à venir |
| QR réel (`qr_flutter`) | coût marginal vs QR décoratif, utile au scan futur par l'agent |
| Invalidation `myEvents` **et** `discoverEvents` après mutation | un événement créé doit apparaître partout ; `discoverEventsProvider` seul serait stale |

---

## 4. Déplacements / mofidications notables du code existant

- **`app_theme.dart` réécrit** + tokens créés (`app_spacing/radius/typography`), `app_colors` étendu (états, glass, success/error). Ancien `app_text_styles.dart` : **non utilisé**, à supprimer.
- **`app_router.dart`** : branché sur `AppShell` ; les 4 onglets dans `StatefulShellRoute.indexedStack` ; nav bar dans un `SafeArea` ; ajout des routes racine `/event/create` et `/event/edit`.
- **`app_bottom_navigation_bar.dart`** : inchangé structurellement (`maListeIcon` = 4 onglets).
- **`status_badge.dart`** : déplacé de `features/ticket/.../widgets` vers `core/widgets` (générique) ; wrapper `TicketStatusBadge` côté ticket ; imports des écrans mis à jour.
- **`home_page.dart` / `profile_page.dart`** : placeholders → vrais écrans spec §8 (segment Buy/Sell/Create, recherche + chips, `_Header` avatar → profil ; UserCard stats dérivées des providers, menu, logout factice).
- **`my_tickets_page.dart` / `events_page.dart`** : FAB supprimés → `EmptyState` + tuiles CTA (`_ImportTile`, `_CreateTile`) + `TicketCard`/`EventCard` ; padding `bottomClearanceWithNav`.
- **`create_event_page.dart` / `edit_event_page.dart`** : AppBar → `PageHeader` custom, pickers date/heure → champs verre `readOnly`, boutons → `AppButton` ; `EditEventPage` charge par `eventId` (route racine).
- **`ticket_detail_page.dart`** : AppBar → `PageHeader` (`Mon billet`), `Card` → `GlassCard` elevated, QR sur fond blanc.
- **`MockEventRepository`** : catalogue public + `demo()` (seed 3 événements) + `getEventById`.
- **`widget_test.dart`** : l'assertion "Home" → "TicketPass" (nouveau header).

---

## 5. Routage (règles absolues)

1. **Onglet** → branche du `StatefulShellRoute` ; naviguer avec `context.go(AppRoutes.<name>)`.
2. **Page plein-écran (sans nav)** → `GoRoute` RACINE, hors shell, enveloppée `AppShell`. Ne JAMAIS `Navigator.push` depuis une branche (nav resterait au-dessus).
3. Ouvrir une plein-écran : `context.push(...)` (retourne un résultat). Fermer en rendant un résultat : `context.pop(true)`.
4. Après création/modification/suppression → invalider `myEventsProvider` ET `discoverEventsProvider` (si l'écran d'origine affiche l'un des deux).

---

## 6. Ajouter une fonctionnalité (procédure)

**Domaine (`domain/`)**
1. Entité conforme à `docs/classe.md` ; le cas échéant 1 use case = 1 méthode (`class GetX { final Repo r; Future<X> call(...) }`).
2. Ajouter la méthode au contrat `EventRepository` / `TicketRepository`.

**Data (`data/`)**
3. Implémenter la méthode dans le fake (`MockEventRepository`, `FakeTicketRepository`) avec latence simulée + règles métier (ex : un billet `used` ne se réimporte pas).
4. `data/models/` : mapping si le format fake ≠ entité.

**Présentation (`presentation/`)**
5. Exposer le use case par un `Provider` (lire le repo via `eventRepositoryProvider`/`ticketRepositoryProvider`).
6. Capture d'état : `FutureProvider(.family)` si besoin de paramètre (`userId`, `eventId`).
7. Écran :
   - Utiliser les tokens (`AppSpacing`, `AppRadius`, `AppColors`) et les widgets DS (jamais de `Card`/`AppBar`/`FilledButton` bruts).
   - Choix du routage : plein-écran → route racine (`app_router.dart` + constante dans `app_routes.dart`) + `AppShell` ; sinon branche.
   - Pagination des onglets : `AppTheme.pagePadding(bottom: AppSpacing.bottomClearanceWithNav)`.

**Validation**
8. `flutter analyze` (0 issue) puis `flutter test` (8/8).
9. Commit par étape significative, message + fichier : `feat(<feature>): <verbe> <objet>`.

---

## 7. Validation courante

- `flutter analyze` → `No issues found!`
- `flutter test` → 8 tests verts (7 UC billets sur fake + 1 boot app).
- Lint/sorties Windows : warnings CRLF/LF bénins.