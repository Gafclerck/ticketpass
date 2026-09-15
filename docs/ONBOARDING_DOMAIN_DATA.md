# Onboarding — TicketPass (focus Domain & Data)

À lire intégralement avant de toucher au code. Objectif : tu dois être capable
d'expliquer le projet dans les petits détails et de contribuer sans casser la
couche domaine/data.

Liens : `AGENTS.md` (règles de travail), `docs/classe.md` (source de vérité du
domaine), `docs/GUIDE_IMPLEMENTATION.md` (détails UI/DS/routage),
`docs/ROADMAP_REALIGNEMENT.md` (plan + décisions). Ce document ne répète pas ce
qui est déjà dans `GUIDE_IMPLEMENTATION.md` ; il te donne l'état réel des
couches domaine/data et les réflexes à avoir.

---

## 1. Le projet en 30 secondes

TicketPass = app Flutter de billets d'événements (création d'événements,
génération de billets, achat par distribution automatique, scan/validation des
billets le jour J).

- **Clean Architecture feature-first** : chaque feature = `domain/`, `data/`,
  `presentation/`. Partagé : `core/` (DS, thème, routage, sécurité, schéma DB).
- **State management** : Riverpod. Les providers sont l'unique point d'injection.
- **Aujourd'hui** : event/ticket viennent de **fakes en mémoire** (`MockEventRepository`, `FakeTicketRepository`) ; la base locale (drift) existe en **contrat** (`app_database.dart`, datasources abstraits) non branchée. **L'auth, elle, est en Firebase réel** (Auth + Firestore `users/{uid}` + Storage) via `FirebaseAuthRepository`. Le seul claim "fake partout" est donc faux pour `features/auth`.
- **Backlog** : offlge SyncQueue (UC12-13), auth multi-users (UC14),
  chiffrement du secret de signature.

---

## 2. Archi : règles qui ne se négocient pas

1. **Sens des dépendances** : `presentation → domain` (jamais l'inverse) ;
   `data → domain` seulement. Le domaine ne connaît NI Flutter, NI Riverpod,
   NI drift/firebase, NI les widgets.
2. **Entités** : classes manuelles, `copyWith` écrit à la main (PAS de
   freezed/json_serializable sur les entités). Conformes à `docs/classe.md`.
3. **Une action = un use case** : `class GetX { final Repo r; Future<X> call(...) }`.
   Le use case ne fait que déléguer au repo (sauf garde explicite, ex:
   `GenerateTickets` vérifie `quantity > 0`). Aucune logique Flutter dedans.
4. **Le repo est un contrat** (interface abstraite). Le fake l'implémente. Le
   provider Riverpod est le **seul point de bascule fake → réel** : quand le
   sprint infra arrivera, on remplacera `FakeTicketRepository.demo()` par
   `TicketRepositoryImpl` dans `ticket_providers.dart`, et RIEN d'autre ne
   bougera (ni domaine, ni présentation).
5. **Les datasources** (`TicketLocalDataSource`, `TicketRemoteDataSource`) sont
   des **contrats abstraits non branchés**. Ne les "câble" pas avant le sprint
   infra ; ne mets pas d'API drift/firebase dans le domaine ou les fakes.

---

## 3. Couche DOMAIN — inventaire exact

### 3.1 Entités (`features/<f>/domain/entities/`)

| Entité | Champs | Notes |
|---|---|---|
| `User` (auth) | `id, email, fullName, profileUrl?, createdAt` | `defaultRole => participant`. `password`/`authId` **retirés** : l'auth est déléguée à Firebase (Email/Password, `id` = uid). `classe.md` garde `password` — écart assumé côté implémentation |
| `Role` (auth) | enum `organiser, participant, controller` + `label` FR | Un user peut cumuler plusieurs rôles sur un même événement. |
| `Event` (event) | `id, title, description, eventDate, startTime, brandingUrl='', ticketsNumber=0, type, brandName, eventPlace, maxPlaces, status` | **PAS de `organizerId`** : la possession est portée par `EventUserRole(role: organiser)`. |
| `EventType` | `concert, festival, conference, exposition, theatre, sport, education, formation, other` + `label` | |
| `EventStatus` | `upcoming, ongoing, passed` + `label` | |
| `EventUserRole` | `userId, eventId, role` | Table d'association. PK composite `(user_id, event_id, role)`. |
| `Ticket` (ticket) | `id, status, uniqueCode, qrSignature, userId, eventId` | |
| `TicketStatus` | `unused, valid, used, invalid, revoked` + `label` | `revoked` conservé (rappelé dans les règles métier de `classe.md`). |

### 3.2 Contrats des repositories

`EventRepository` :
```
Future<Event> createEvent(Event, {required String userId})
Future<Event> updateEvent(Event)
Future<void> deleteEvent(String eventId)
Future<List<Event>> getMyEvents(String userId)      // UC3
Future<List<Event>> getDiscoverEvents()             // catalogue public (Home/Events)
Future<Event> getEventById(String eventId)          // détail + édition (+ participants)
Future<List<EventUserRole>> getRoles(String eventId) // UC24
Future<void> assignRole(EventUserRole)               // UC24 (idempotent)
```

`TicketRepository` (UC documentés dans le code) :
```
Future<Ticket> getTicket(String ticketId)                 // UC8
Future<List<Ticket>> getMyTickets(String userId)          // UC9
Future<List<Ticket>> generateTickets(String eventId, int quantity)  // UC4
Future<List<Ticket>> getTicketsForEvent(String eventId)   // UC6 (vue organisateur)
Future<Ticket> acquireTicket(String eventId, {required String userId}) // UC19
Future<List<String>> getParticipants(String eventId)      // ids des détenteurs
Future<Ticket> validateTicket(String ticketId)            // UC11 (VALID → USED)
```

`AuthUserRepository` (implémenté en **Firebase réel**, pas un fake) :
```
Future<User> signInWithEmail(String email, String password)   // UC14 login
Future<User> signUp({required String name, required String email, required String password})
Future<void> signOut()                                        // + reset du listenable
Future<User> updateProfile({required String userId, String? fullName, String? profileUrl})
Stream<User?> authStateChanges()                              // suscription session
User? get currentUser                                         // SYNC : restaure la session avant le 1er frame
```

### 3.3 Use cases (16 classes, 8 event + 8 ticket)

Event : `CreateEvent`, `UpdateEvent`, `DeleteEvent`, `GetDiscoverEvents`,
`GetEventById`, `GetMyEvents`, `GetEventRoles`, `AssignRole`.

Ticket : `AcquireTicket` (UC19), `GenerateTickets` (UC4, garde `quantity > 0` →
`ArgumentError`), `GetMyTickets` (UC9), `GetParticipants`,
`GetTicket` (UC8), `GetTicketsForEvent` (UC6), `ValidateTicket` (UC11).

### 3.4 Règles métier (le cœur — à connaître par cœur)

Statuts billet :
```
unused  → généré mais pas attribué (userId vide)
valid   → acheté par un participant, utilisable
used    → scanné + validé le jour J    (transition VALID → USED)
invalid → non utilisé alors que la date est passée   (pas encore implémenté en code)
revoked → invalidé par l'organisateur                (pas encore implémenté en code)
```
Création : seul `generateTickets` (UC4) et `acquireTicket` (UC19) créent/attribuent.
**UC7 (import de billet) a été supprimé** — ne le réintroduis jamais.

Rôles : l'organisateur est attribué automatiquement à la création d'événement.
`assignRole` est idempotent (pas de doublon du triplet). Rôle par défaut de
tout user = `participant`.

---

## 4. Couche DATA — état réel

### 4.1 `MockEventRepository` (`event/data/repositories/mock_event_repository.dart`)

- State en mémoire : `_eventsByUserId`, `_rolesByEventId`, `_catalogue`.
- `MockEventRepository.demo()` : seed de 3 événements (`event-demo-1/2/3`)
  dans le catalogue public.
- `createEvent` : id auto si vide (`microsecondsSinceEpoch`), ajoute aux
  événements du user + catalogue, **attribue le rôle `organiser`** au créateur.
- `updateEvent` / `deleteEvent` : propagent dans toutes les collections
  (+ suppression des rôles).
- `getEventById` : cherche d'abord dans le catalogue, puis dans les événements
  des users.
- `getRoles` : retourne une liste vide si aucun rôle.
- Ne lève que des `Exception('...')` génériques (pas de types d'erreur custom) —
  garde la même convention.

### 4.2 `FakeTicketRepository` (`ticket/data/repositories/fake_ticket_repository.dart`)

- **Fake réaliste, pas un stub** : applique les règles métier (cf. §3.4) et
  simule une latence (`latency`, défaut 200ms) pour tester les états de
  chargement. `latency: Duration.zero` dans les tests.
- `demo()` : seed — 4 billets possédés par `demo-user-id` sur `demo-event-id`
  (un par statut hormis unused) + **20 billets `unused` pour `event-demo-1`**
  (pour que l'achat UC19 fonctionne depuis le catalogue de démo).
- `generateTickets` : crée N billets `unused`, `userId` vide, id = `Uuid().v4()`.
- `acquireTicket` : refuse si l'user possède déjà un billet pour l'événement ;
  pioche le 1er billet `unused` + `userId` vide ; sinon `Exception('Plus de
  billet disponible...')`. Passe le billet à `valid` + `userId`.
- `getParticipants` : userIds distincts des billets à `userId` non vide.
- `validateTicket` : refuse si statut ≠ `valid` (message avec le label du
  statut). Passe à `used`.
- `getTicket` / `getMyTickets` / `getTicketsForEvent` : filtres simples.

### 4.3 `TicketModel` (`ticket/data/models/ticket_model.dart`)

Seul point de (dé)sérialisation. `fromJson/toJson` (clés snake_case :
`unique_code`, `qr_signature`, `user_id`, `event_id`), `toEntity`,
`fromEntity`. Parle JSON/row, jamais d'API Firebase.

### 4.4 Datasources abstraits (non branchés)

- `TicketLocalDataSource` (drift) : `fetchByUserId`, `fetchById`, `upsert`,
  `delete`.
- `TicketRemoteDataSource` (Firestore) : `fetchById`, `fetchByUserId`, `save`.
- À implémenter au sprint infra (`*Impl`). N'invente pas d'appel firebase
  avant ça.

### 4.5 Schéma drift (`core/database/app_database.dart`)

Tables `Users`, `Events`, `Tickets`, `EventUserRoles` qui **reflètent
exactement `docs/classe.md`** : même PK (`id`), `email`/`authId` uniques,
`uniqueCode` unique, FK `Tickets.userId → Users.id`, `Tickets.eventId →
Events.id`, PK composite `EventUserRoles(userId, eventId, role)`. `schemaVersion
= 1`. **Non câblé à l'exécution** (aucun `AppDatabase()` instancié nulle part).
À noter : il garde `password`/`authId` de `classe.md` alors que l'entité `User`
implémentée les a retirés (auth Firebase) — écart assumé, le schéma sera
resynchronisé au sprint infra.

---

## 5. Câblage Riverpod — la carte

Tout part de 2 providers **repos** (les seuls points de bascule du jour 1) :
- `eventRepositoryProvider` → `MockEventRepository.demo()`
- `ticketRepositoryProvider` → `FakeTicketRepository.demo()`

Chaque use case est exposé par un `Provider<UseCase>` qui lit le repo. Les
lectures asynchrones sont des `FutureProvider(.family)` :

| Provider | Type | Rôle |
|---|---|---|
| `currentUserProvider` | `Provider<User?>` | utilisateur courant (Firebase Auth) ; `null` si déconnecté — le `!` côté UI est garanti par le redirect du routeur |
| `authControllerProvider` | `NotifierProvider<AuthController, User?>` | état auth + mutations (login/signUp/signOut/updateProfile) ; notifie `authRefreshListenable` |
| `authUserRepositoryProvider` | `Provider<AuthUserRepository>` | `FirebaseAuthRepository` — l'ONLY un point d'injection auth (stub mocktail en test) |
| `myEventsProvider(userId)` | FutureProvider.family | événements créés par le user |
| `discoverEventsProvider` | FutureProvider | catalogue public |
| `eventProvider(eventId)` | FutureProvider.family | détail événement |
| `eventRolesProvider(eventId)` | FutureProvider.family | rôles sur un événement (UC24) |
| `myTicketsProvider(userId)` | FutureProvider.family | billets du porteur (UC9) |
| `ticketProvider(ticketId)` | FutureProvider.family | détail billet (UC8) |
| `eventTicketsProvider(eventId)` | FutureProvider.family | billets générés d'un événement (UC6) |
| `eventParticipantsProvider(eventId)` | FutureProvider.family | détenteurs (ids) |
| `assignRole/acquireTicket/validateTicket/...Provider` | `Provider<UseCase>` | mutations |

Use cases mutables : `createEvent`, `updateEvent`, `deleteEvent`,
`generateTickets`, `acquireTicket`, `validateTicket`, `assignRole`.

### Règle d'invalidation (ABSOLUE)

Après **création / modification / suppression** d'un événement →
`ref.invalidate(myEventsProvider(userId))` **ET**
`ref.invalidate(discoverEventsProvider)`. Exemples réels :
- `EventDetailScreen._openEdit` invalide `eventProvider`, `myEventsProvider`,
  `discoverEventsProvider`.
- `EventDetailScreen._acquire` invalide `myTicketsProvider(userId)`.
- Le scan invalide `myTicketsProvider(used.userId)` après validation.

Le caller d'une page plein-écran fait `context.push(...)` puis invalide ce qui
a été modifié derrière ; la page plein-écran fermée rend `context.pop(true)`.

### Règle d'or auth (le cœur du module)

L'UI n'utilise `currentUser!` que si les 3 conditions suivantes sont TOUJOURS
vraies **dans le bon ordre ET le bon timing** :
1. **Restauration synchrone** : `AuthUserRepository.currentUser` pose l'état
   avant le premier frame ;
2. **Guard du routeur** : `AuthRefreshListenable` + redirect GoRouter (aucun
   écran protégé ne s'affiche sans utilisateur) ;
3. **Notification manuelle** : toute mutation de la session
   (`signIn`/`signUp`/`signOut`) DOIT rappeler `authRefreshListenable.notify(...)`
   sinon routeur et état divergent.

Toute faille de ce triptyque est une faille d'ordre temporel (premier frame,
flux asynchrone, redirect différé), pas une faille d'état.

---

## 6. Sécurité des billets — `core/security/ticket_signature_service.dart`

- `sign(ticketId, eventId)` → HMAC-SHA256 hex (clé dev constante
  `'ticketpass-dev-secret-key-change-me'` — **TODO prod : sortir du code**).
- `buildQrPayload` → `'$ticketId|$eventId|$signature'` (UC5, utilisé par le
  porteur, `ticket_detail_page`).
- `verifyQrPayload` → split sur `|`, longueur 3, vérifie la signature (UC10-12,
  offlge, utilisé par `scan_event_tickets_page`).
- Ne modifie pas le format du payload : il est partagé entre génération et
  scan. Si tu changes `buildQrPayload`, tu casses la vérification.

---

## 7. Pièges (retour d'audit — ce qui te coûterait une régression)

1. **Ne pas câbler drift/firebase maintenant** : datasources contrats, pas
   d'implémentation. Le jour du sprint infra, on ne change QUE les providers
   repos.
2. **Ne pas recréer UC7 (import)** : un billet ne s'obtient que par
   `acquireTicket` (UC19) depuis le détail d'un événement.
3. **Ne jamais `Navigator.push` depuis une branche du shell** pour une page
   plein-écran : la nav flottante reste au-dessus (`StatefulShellRoute`,
   navigateur de branche). Page plein-écran = GoRoute racine + `AppShell` +
   `context.push`.
4. **Comportement du fake ≠ implémentation 100% des règles de `classe.md`**
   (normal pour un fake) :
   - `invalid`/`revoked` n'ont **pas de transition de code** (le fake les seed
     seulement). Si tu écris la transition `valid → invalid` quand la date
     passe, elle reviendra probablement au sprint métier réel.
   - `event.ticketsNumber` (capacité) et `maxPlaces` ne sont **pas vérifiés**
     lors d'un achat : un événement `ticketsNumber: 1000` n'a que 20 billets
     seedés. N'en fais pas une feature tant que le besoin produit n'est pas
     validé.
5. **`GenerateTickets` lève `ArgumentError`** (quantité ≤ 0) côté use case —
   les autres use cases lèvent des `Exception` génériques depuis les fakes.
   Ne pas "harmoniser" sans réfléchir : c'est un choix posé.
6. **Langue du code** : messages d'erreur et libellés en français, code et
   identifiants en anglais. Doc en français.
7. **Entités sans commentaires parasites** : les doc-comments expliquent le
   POURQUOI (décisions, écarts vs `classe.md`), pas le quoi.
8. **Le flux d'auth peut mourir silencieusement (B1, à corriger)** :
   `FirebaseAuthRepository.authStateChanges()` fait 1 lecture Firestore par
   événement (`asyncMap`), et `AuthController.build()` écoute **sans `onError`**.
   Une lecture KO (ex. boot hors-ligne sans cache Firestore) **termine le flux**
   single-subscription → plus aucun événement (logout/révocation ignorés,
   routeur figé « connecté »). Correctif retenu (audit du 15/09) : identité
   Auth en `map` sync + `onError` au listener, profil Firestore chargé à part.
9. **`currentUser!` n'est sûr QUE par le triptyque (cf. §5 Règle d'or auth)** :
   si tu lis `currentUserProvider` hors d'un écran protégé, ou si la session
   peut passer à null pendant un rebuild avant le redirect → le `!` crashe.
   Garde null côté page (`if (user == null) return ...`) si tu doutes.
10. **Invariant `authRefreshListenable` (B3)** : singleton global hors Riverpod,
    partagé entre `AuthController` et le `GoRouter`. Routeur et état ne restent
    cohérents QUE si chaque mutation d'auth notifie. En test, **obligatoire**
    `setUp(() => resetAuthRouting())` — l'oublier rend les tests flaky.
11. **`watchAuthStateProvider` est du code mort** : `AuthController.build()` lit
    le repo en direct. Soit il est consommé dans `build()` (cohérence use
    cases), soit il est supprimé.
12. **Erreurs Storage/Firestore non mappées** : `mapAuthError` ne couvre que
    `FirebaseAuthException` ; un échec d'upload d'avatar remonte en message
    générique « Une erreur est survenue. » — décision à prendre : mapper ou
    assumer.
13. **`image_picker` sur desktop** : Windows est supporté (endorsed
    `file_selector`) mais `maxWidth`/`maxHeight`/`imageQuality` sont **ignorés** →
    avatars non compressés sur desktop.

---

## 8. Workflow de contribution (méthodo équipe)

1. **Écran après écran**, jamais 2 écrans en même temps. Chaque étape est
   validée par l'utilisateur avant la suivante :
   Analyse & diagnostic → Plan de correction (validé) → évaluation de
   l'impact (autres écrans ?) → plan définitif (validé) → exécution → tests →
   **commit**. Puis on passe à l'écran suivant.
2. Ordre d'implémentation d'une feature :
   **Domaine** : entité (classe.md) + use case (1 action) + méthode sur le
   contrat du repo → **Data** : implémentation dans le fake (latence simulée +
   règles métier) → **Présentation** : provider + FutureProvider si async →
   écran (tokens DS + widgets `core/widgets`, jamais de `Card`/`AppBar`
   bruts).
3. **Validation obligatoire** (à chaque étape) :
   - `flutter analyze` → doit afficher `No issues found!` (0 issue).
   - `flutter test` → tous verts (78 aujourd'hui).
   - Commit clair en une ligne, style repo : `feat(<feature>): <verbe> <objet>`
     (ex. `feat(ticket): add automatic ticket acquisition (UC19)`).
4. **Règle d'or** : on ne commit JAMAIS si tous les tests ne passent pas.
5. Tests à écrire pour toute règle métier du domaine/fake (ex. UC19 :
   double-achat refusé, stock épuisé, billet pris indisponible pour un autre).

---

## 9. État de couverture par feature (ce qui existe / manque)

| Feature | Domain | Data | Présentation |
|---|---|---|---|
| `auth` | `User`, `Role`, `AuthUserRepository` (signIn/signUp/signOut/updateProfile/authStateChanges/currentUser) | `FirebaseAuthRepository` (Firebase Auth + Firestore `users/{uid}` + Storage avatar) | `authControllerProvider` (dérivé courant) + `currentUserProvider` + pages Login/Register/Profil + `AuthRefreshListenable` (guard du routeur) |
| `event` | 4 entités + `EventRepository` + 8 UC | `MockEventRepository` | recherche, détail, create/edit, participants, cards |
| `ticket` | 2 entités + `TicketRepository` + 8 UC | `FakeTicketRepository`, `TicketModel`, datasources (contrats) | wallet, détail, billet QR, liste UC6 |
| `scan` | — (pas de domaine) | — (pas de data) | scanner caméra + saisie manuelle (providers) |
| `home` | — | — | Home découverte |
| `profile` | — | — | profil |

Backlog infra non touché : SyncQueue/offlge (UC12-13, UC22-23), secret de signature chiffré, seeds réalistes par user.

## 10. Commandes utiles

```
flutter analyze        # 0 issue obligatoire
flutter test           # tous verts (78)
flutter test test/features/ticket/<fixe>   # test ciblé pendant le dev
```