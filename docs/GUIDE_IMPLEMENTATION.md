# Guide d'implémentation — TicketPass (Flutter)

Document de référence pour comprendre ce qui est implémenté et contribuer.
Source de vérité produit : `docs/FLUTTER_PROTOTYPE_SPEC.md` (UI) et `docs/classe.md` (domaine).
Plan de réalignement courant : `docs/ROADMAP_REALIGNEMENT.md`.
Règles complémentaires : `AGENTS.md`.

---

## 1. Architecture & organisation des couches

Chaque fonctionnalité (`features/`) suit le même découpage vertical :

```
features/<feature>/
  domain/    entités (docs/classe.md) · use cases (1 classe = 1 action) · contrats de repos
  data/      repos drift (cache) + datasources Firestore branchées · modèles · fakes gardés pour les tests widgets
  presentation/  providers Riverpod · écrans/pages · widgets feature
core/         tokens DS · widgets DS · routage · app shell · sync (outbox, engine, pull)
```

- **Dépendances** : presentation → domain (jamais l'inverse) ; data → domain seulement.
- **Entités** : classes manuelles conformes à `docs/classe.md` (`copyWith` écrit à la main, pas de freezed).
- **Cache local & sync (slice C)** : depuis le slice C, event/ticket passent par **drift** (`DriftEventRepository`, `DriftTicketRepository`, schema 3 avec table `SyncOutbox`) avec **Firestore pour source de vérité** (`FirestoreEventRemoteDataSource`, `FirestoreTicketRemoteDataSource`, règles `deploy/firestore.rules`). Toute écriture locale enqueue une opération outbox **dans la même transaction** ; `SyncEngine` la pousse (transactions **CAS** pour les billets, backoff 2 s → 5 min, max 8) ; `PullService` réconcilie le cache au boot/reconnect ; `SyncLifecycle` est lancé dans `main()` (pas en test). `MockEventRepository`/`FakeTicketRepository` ne servent **plus qu'au scaffolding des tests widgets** (scan, participants, détail, édition).
- **Sécurité QR (UC5)** : `core/security/ticket_signature_service.dart` signe `(ticketId, eventId)` en HMAC-SHA256 (clé dev en source, à externaliser en prod) et expose `buildQrPayload`/`verifyQrPayload` pour le scan hors-ligne. Dépendance `crypto`.
- **Scanner (UC10-11)** : `features/scan`, caméra `mobile_scanner` (permission `CAMERA` ajoutée sur Android + `NSCameraUsageDescription` sur iOS), repli « Saisie manuelle » ; accès réservé organisateur/contrôleur ; transition `VALID → USED` via `validateTicket`. `scanUseCameraProvider` (override `false` en test).
- **Identité & auth** : `features/auth` est un module complet (domain/data/presentation) branché sur **Firebase réel** — Auth (`FirebaseAuth`), profil Firestore `users/{uid}` (fullName + profileUrl) et avatar sur Storage. `User.id` = uid Firebase ; **plus aucun fake en prod** : `authUserRepositoryProvider` → `FirebaseAuthRepository`. `currentUserProvider` (dérivé d'`authControllerProvider`) est la **source unique** ; l'ancien provider core `currentUserIdProvider` et l'utilisateur démo ont été supprimés. Le guard du routeur (`AuthRefreshListenable` + `redirect` GoRouter) protège tous les écrans ; en test, un stub mocktail (`test/helpers/test_auth.dart`) injecte un utilisateur. L'état de session est restauré de façon **synchrone** (`FirebaseAuth.currentUser`) pour ne jamais rendre un écran protégé avec un user null.

### Providers existants (résumé)

| Provider | Type | Rôle |
|---|---|---|
| `currentUserProvider` | Provider\<User?> | utilisateur courant (Firebase Auth) ; `!` garanti par le redirect |
| `eventRepositoryProvider` | Provider\<EventRepository> | `DriftEventRepository(appDatabaseProvider)` (cache drift) |
| `myEventsProvider(userId)` | FutureProvider.family | événements créés par l'user — watch `syncRevisionProvider` (refetch auto) |
| `discoverEventsProvider` | FutureProvider | catalogue public (Home) — watch `syncRevisionProvider` |
| `eventProvider(eventId)` | FutureProvider.family | détail (édition, futur EventDetail) |
| `createEvent/updateEvent/deleteEventProvider` | Provider\<UseCase> | mutations (+ enqueue outbox dans la même transaction drift) |
| `myTicketsProvider(userId)` | FutureProvider.family | billets de l'user — watch `syncRevisionProvider` |
| `ticketProvider(ticketId)` | FutureProvider.family | détail billet |
| `generateTicketsProvider` | Provider\<GenerateTickets> | UC4 générer N billets pour un événement |
| `getTicketsForEventProvider` / `eventTicketsProvider(eventId)` | Provider / FutureProvider.family | UC6 liste des billets générés d'un événement (vue organisateur) — watch `syncRevisionProvider` |
| `acquireTicketProvider` | Provider\<AcquireTicket> | UC19 distribution automatique d'un billet (achat) |
| `eventParticipantsProvider(eventId)` | FutureProvider.family | détenteurs de billets d'un événement (page Participants) |
| `eventRolesProvider(eventId)` / `assignRoleProvider` | FutureProvider.family / Provider | UC24 rôles + désignation d'un contrôleur |
| `validateTicketProvider` | Provider\<ValidateTicket> | UC11 transition `VALID → USED` (scanner) |
| `scanUseCameraProvider` | Provider\<bool> | caméra du scanner (`true` en app ; `false` dans les tests widget) |
| `authUserRepositoryProvider` | Provider\<AuthUserRepository> | `FirebaseAuthRepository` (réel) — seul point d'injection auth |
| `authControllerProvider` | NotifierProvider\<AuthController, User?> | état auth (login/logout/updateProfile) + notifie `authRefreshListenable` |
| `syncRevisionProvider` | NotifierProvider\<SyncRevision, int> | révision incrémentée par `SyncLifecycle` (main) à chaque cycle de sync → refetch auto des catalogues |
| `avatar_providers` (`imagePickerProvider`, `pickAndUploadAvatar`) | Provider / fonction | sélection galerie + upload Storage (avatar Profil/Register) |

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
| **Top bar fixe + bande safe-area opaque** | les icônes système (heure/batterie/réseau) doivent rester sur fond plein `#080808`, jamais sur du contenu (image/texte/halo). Deux widgets : `AppTopBar` (barre fixe hors scroll pour les sous-écrans plein-écran) et `AppSafeTopBand` (bande opaque, headers éditoriaux scrollables des onglets conservés). `SystemUiOverlayStyle.dark` appliqué au niveau racine (`main.dart`) : icônes claires sur fond sombre. Le `FloatingHeader` du détail événement est posé sous une `AppSafeTopBand`. |
| Identité unifiée (`currentUserProvider`) | éviter deux sources de vérité (l'ancien provider core `currentUserIdProvider` a été supprimé) |
| `getEventById` ajouté au repo | l'édition charge par id (deep-linkable, cache par `eventProvider`) et prépare l'EventDetail à venir |
| QR réel (`qr_flutter`) | coût marginal vs QR décoratif, utile au scan futur par l'agent |
| Invalidation `myEvents` **et** `discoverEvents` après mutation | un événement créé doit apparaître partout ; `discoverEventsProvider` seul serait stale |
| **Sync local-first (slice C)** : drift en cache, Firestore source de vérité | l'app reste fonctionnelle hors-ligne ; toute écriture enqueue une op dans la même transaction drift ; `SyncEngine` pousse (CAS + backoff 2 s/5 min/8), `PullService` tire au boot/reconnect ; `syncRevisionProvider` centralise le refetch auto des catalogues |
| **Auth via Firebase, pas de fake en prod** | directive produit : remplacer les fakes durée par du réel. Les tests injectent un stub mocktail au niveau du contrat `AuthUserRepository` |
| **Session restorée de façon synchrone** | `FirebaseAuth.currentUser` (getter synchrone du repo) pose état + redirect AVANT le 1er frame ; ajouter un `authControllerProvider` sur `authStateChanges` seulement ne suffirait pas (1er frame du routeur → user null) |
| **Routage auth : redirect + `AuthRefreshListenable`** | routes `/login`/`/register` racines (hors shell) ; `pendingLocation` mémorisé → retour sur la destination après connexion ; pages auth ≠ barre de navigation |

---

## 4. Déplacements / mofidications notables du code existant

- **`app_theme.dart` réécrit** + tokens créés (`app_spacing/radius/typography`), `app_colors` étendu (états, glass, success/error). Ancien `app_text_styles.dart` **supprimé** (code mort, fix final v1).
- **`app_router.dart`** : branché sur `AppShell` ; les 4 onglets dans `StatefulShellRoute.indexedStack` ; nav bar dans un `SafeArea` ; ajout des routes racine `/event/:id` (EventDetail), `/event/participants/:id`, `/scan/:eventId`, `/event/create` et `/event/edit`.
- **`app_bottom_navigation_bar.dart`** : inchangé structurellement (`maListeIcon` = 4 onglets).
- **`status_badge.dart`** : déplacé de `features/ticket/.../widgets` vers `core/widgets` (générique) ; wrapper `TicketStatusBadge` côté ticket ; imports des écrans mis à jour.
- **`home_page.dart` / `profile_page.dart`** : placeholders → vrais écrans spec §8 (segment Buy/Sell/Create, recherche + chips, `_Header` avatar → profil ; UserCard stats dérivées des providers, menu, logout factice).
- **Top bar fixe & safe area (`app_top_bar.dart`)** : les sous-écrans plein-écran (`ticket_detail`, `event_tickets`, `event_participants`, `create/edit_event`, `scan`) = `Column[AppTopBar, Expanded(scroll)]` — la barre (retour/titre/action) est HORS scroll, fond `#080808` derrière la zone d'encoche. Les 4 onglets gardent leur header éditorial scrollable sous `AppSafeTopBand`. L'`EventDetailScreen` pose son `FloatingHeader` sous une `AppSafeTopBand`. L'ancien Σ `SafeArea + PageHeader en tête de ListView` est abandonné. `SystemUiOverlayStyle.dark` (icônes claires) posé au niveau racine dans `main.dart` et sur `appBarTheme`.
- **`my_tickets_page.dart` / `events_page.dart`** : FAB supprimés → `EmptyState` + tuiles CTA (`_CreateTile`) + `TicketCard`/`EventCard` ; padding `bottomClearanceWithNav`. L'import de billet (UC7) est retiré : un billet ne s'obtient que par la distribution automatique (UC19) depuis le détail d'un événement.
- **`create_event_page.dart` / `edit_event_page.dart`** : AppBar → `PageHeader` custom, pickers date/heure → champs verre `readOnly`, boutons → `AppButton` ; `EditEventPage` charge par `eventId` (route racine).
- **`ticket_detail_page.dart`** : AppBar → `PageHeader` (`Mon billet`), `Card` → `GlassCard` elevated, QR sur fond blanc.
- **`event_detail_screen.dart`** : redesigné selon la spec §8 — `FloatingHeader` (retour/titre/partage) flottant sur le hero 320px (radius 32), `OrganizerRow` (avatar 48 + nom + lieu + cœur), métadonnées Date/Horaire (chips 56px), section « À propos », bloc **Jauge** (organisateur seul), et CTA par rôle : barre basse fixe (visiteur « Obtenir un billet » → UC19 puis redirection `/ticket/:id`, porteur « Voir mon billet ») ou pile flottante droite (organisateur : Générer primaire 52px + Voir les billets + Participants + Modifier + Scanner ; contrôleur : Scanner).
- **`MockEventRepository`** : catalogue public + `demo()` (seed 3 événements) + `getEventById`.
- **`app_router.dart`** : ajout du guard auth — `refreshListenable: authRefreshListenable`, `redirect` vers `/login` si déconnecté / vers `pendingLocation` si connecté, routes racine `/login` et `/register` ; `AuthRefreshListenable.rememberPending/consumePending` mémorise la destination visée.
- **`main.dart`** : `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` en try/catch avec repli « Firebase non configuré » ; `MyApp` est un `ConsumerWidget` qui watch `authControllerProvider` (souscription auth dès le boot).
- **`ProfilePage`** : réel écran profil — avatar cliquable (`pickAndUploadAvatar` → `updateProfile`), signOut fonctionnel via `authController`.
- **Tests widget auth** : `test/helpers/test_auth.dart` (stub mocktail + `authUserRepositoryOverride` qui pré-notifie le listenable + `resetAuthRouting`) ; `auth_flow_test.dart` couvre guard/login/register.
- **`widget_test.dart`** : l'assertion "Home" → "TicketPass" (nouveau header) + override auth.

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
3. Implémenter la méthode dans les repos drift (`DriftEventRepository` / `DriftTicketRepository`) avec les règles métier (ex : un billet `used` ne se revalide pas), **et** enqueuner l'opération outbox correspondante **dans la même transaction** (slice C — voir `drift_event_repository.dart`, `drift_ticket_repository.dart` + `test/core/sync/repos_enqueue_test.dart`).
4. `data/models/` : mapping si le format entité ≠ row/JSON (ex. `TicketModel`, `EventModel`).

**Présentation (`presentation/`)**
5. Exposer le use case par un `Provider` (lire le repo via `eventRepositoryProvider`/`ticketRepositoryProvider`).
6. Capture d'état : `FutureProvider(.family)` si besoin de paramètre (`userId`, `eventId`).
7. Écran :
   - Utiliser les tokens (`AppSpacing`, `AppRadius`, `AppColors`) et les widgets DS (jamais de `Card`/`AppBar`/`FilledButton` bruts).
   - Choix du routage : plein-écran → route racine (`app_router.dart` + constante dans `app_routes.dart`) + `AppShell` ; sinon branche.
   - Top bar : sous-écran plein-écran → `Column[AppTopBar(...), Expanded(scroll)]` (barre fixe, retour/titre/action). Onglet → `AppSafeTopBand` en haut + header éditorial scrollable. La zone de la barre de statut reste toujours opaque (`#080808`), jamais de contenu scroller sous les icônes système.
   - Pagination des onglets : `AppTheme.pagePadding(bottom: AppSpacing.bottomClearanceWithNav)`.

**Validation**
8. `flutter analyze` (0 issue) puis `flutter test` (140 verts).
9. Commit par étape significative, message + fichier : `feat(<feature>): <verbe> <objet>`.

---

## 7. Validation courante

- `flutter analyze` → `No issues found!`
- `flutter test` → tous les tests verts (UC domaine/data + sync C-b/C-c + 8 fichier widget tests dont login/register/guard, 140 tests).
- Lint/sorties Windows : warnings CRLF/LF bénins.