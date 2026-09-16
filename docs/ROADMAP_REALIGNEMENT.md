# Roadmap de réalignement — TicketPass

*Créée le 13/09/2026. Source de vérité produit : `docs/FLUTTER_PROTOTYPE_SPEC.md` (UI) et `docs/classe.md` (domaine).*

## Contexte (logique cible)

- Le client **n'importe jamais lui-même un billet** : au clic sur « Obtenir un billet », un mécanisme **distribue automatiquement** un billet disponible et l'attache à l'acheteur.
- L'achat/réservation se fait **depuis l'écran de détail d'un événement**.
- L'utilisateur parcourt des événements publiés par d'autres ; sur le détail, il achète s'il est simple utilisateur.
- S'il est **organisateur** (ou **contrôleur désigné**), le détail sert à **gérer l'événement** : éditer, supprimer, voir les billets, générer des billets supplémentaires, voir les participants, désigner un contrôleur, scanner.

## Règles mémoire (établies avec l'équipe)

1. **RD : on ne fait jamais de commit si tous les tests ne passent pas.**
2. **RD : après chaque phase, audit de rétro-inspection** (sources potentielles de bugs/erreurs) ; bilan envoyé à la fin de la tâche.
3. **RD : commit clair en une seule ligne**, message dans le style repo (`feat(...) : <verbe> <objet>`).
4. Chaque commit de phase est soumis à **validation explicite de l'équipe** avant d'être créé.

---

## Phase 0 — Documentation

- **Objectif** : figer le plan (ce fichier) et resynchroniser la doc d'implémentation.
- **Périmètre** :
  - Création de `docs/ROADMAP_REALIGNEMENT.md` (ce document).
  - Mise à jour **uniquement** de `docs/GUIDE_IMPLEMENTATION.md` : inventaire UC/providers/tests à jour (UC4-6, `TicketSignatureService`, `crypto`, nombre de tests). **Ne pas toucher** `docs/TicketPass_Recap_Equipe.md`.
- **Critères d'acceptation** : `flutter analyze` = 0 issue ; `flutter test` = tous verts (aucun changement de code).
- **Validation** : avant commit.

## Phase 1 — Fondations domaine/data

- **Objectif** : rendre possible la logique « achat automatique » et les rôles.
- **Périmètre** :
  - **UC19 — `acquireTicket(eventId, userId)`** sur `TicketRepository` + fake : pioche un billet `unused` de l'événement, l'attache (`VALID` + `userId`), refuse le double-billet et l'épuisement du stock.
  - **UC24 — rôles** : attribution `Role.organiser` à la création d'événement ; consultation des rôles d'un événement ; désignation d'un **contrôleur**.
  - **Participants** : liste des détenteurs de billets d'un événement.
  - Providers Riverpod associés.
  - Tests du domaine/fakes (UC19, rôles, participants).
- **Critères d'acceptation** : `flutter analyze` = 0 issue ; `flutter test` = tous verts.
- **Validation** : avant commit.

## Phase 2 — EventDetailScreen (le pivot UI)

- **Objectif** : point d'entrée unique de l'expérience (achat / gestion selon le rôle).
- **Périmètre** :
  - Route racine `/event/:id` (hors `StatefulShellRoute`) enveloppée dans `AppShell`.
  - Détection du rôle du user courant sur l'événement (organisateur / contrôleur / participant / visiteur).
  - Actions rôle :
    - visiteur → **« Obtenir un billet »** (UC19) puis redirection vers `/ticket/:id`.
    - participant → « Voir mon billet ».
    - organisateur → Modifier, Voir les billets (UC6), Supprimer.
  - Câblage `EventCard.onTap` → `/event/:id` (Home + Événements).
  - Invalidation des providers touchés après mutation.
- **Critères d'acceptation** : `flutter analyze` = 0 issue ; `flutter test` = tous verts.
- **Validation** : avant commit.

## Phase 3 — Gestion & contrôle

- **Objectif** : compléter le rôle de l'organisateur et activer le contrôle.
- **Périmètre** :
  - Page **Participants** (détenteurs de billets d'un événement).
  - Écran **générer des billets** (quantité → UC4) + invalidation des fourmisseurs.
  - **Scanner / validation (UC10-11)** : `features/scan`, caméra `mobile_scanner` (repli « saisie manuelle » testable), vérification du payload QR (`TicketSignatureService.verifyQrPayload`), transition `VALID → USED` (`validateTicket`), accès réservé aux organisateurs/contrôleurs.
  - **Génération de billets** : dialog factorisé sur le **détail** de l'événement (organisateur), retiré de la page d'édition.
- **Critères d'acceptation** : `flutter analyze` = 0 issue ; `flutter test` = tous verts.
- **Validation** : avant commit.

## Phase 4 — Barre de navigation en haut (SafeArea + top bar fixe)

- **Contexte** : depuis l'edge-to-edge Android 15 (imposé), l'app dessine derrière la barre de statut : la UI (images, textos, halo) peut chevaucher les icônes système (heure/batterie/réseau).
- **Périmètre** :
  - `SystemUiOverlayStyle.dark` (icônes claires) au niveau racine (`main.dart`) + `appBarTheme` durci (`surfaceTintColor` transparent, `scrolledUnderElevation` 0).
  - Nouveau `core/widgets/app_top_bar.dart` : `AppTopBar` (barre FIGE, fond `#080808` derrière la zone safe-area + `PageHeader` retour/titre/action) et `AppSafeTopBand` (bande opaque pour les onglets).
  - Sous-écrans plein-écran refactorisés en `Column[AppTopBar, Expanded(scroll)]` : `ticket_detail`, `event_tickets`, `event_participants`, `create/edit_event`, `scan` (+ `_AccessDenied`).
  - Onglets (Home/Événements/Mes billets/Profil) : `AppSafeTopBand` en haut, headers éditoriaux scrollables conservés.
  - `EventDetailScreen` : bande supérieure pleine + `FloatingHeader` ancré dessous (le hero ne passe plus sous les icônes).
  - Tests widget `app_top_bar_test` (barre figée au scroll, bande opaque).
- **Critères d'acceptation** : `flutter analyze` = 0 issue ; `flutter test` = tous verts.
- **Validation** : avant commit.

## Backlog (hors périmètre de cette tâche)

- **Produit restant autour du sync** : couvrir explicitement UC12-13 / UC22-23 si leur périmètre dépasse le cœur technique livré (outbox + drain + conflits — cf. « Sprint sync »), nettoyer la doc des écrans impactés par le refetch auto.
- **Phase 6 — Infra & qualité** : seeds réalistes par user (l'auth Firebase multi-utilisateurs est désormais FAIT — cf. « Sprint auth & identité »), chiffrement du secret de signature hors code source.

---

## Sprint auth & identité — FAIT (big-bang TEMPORAIRE)

- **Objectif** : remplacer l'identité démo par une vraie authentification Firebase (login, register, profil, avatar) + garde du routeur.
- **⚠️ Écart méthodo assumé** : livré en **big-bang** (login + register + profil + routeur + `main` d'un coup) et validé d'un bloc, au lieu de l'écran-par-écran. Justifié par le fait que le garde du routeur est transversal (aucun écran testable en isolation). **C'est une exception TEMPORAIRE** : retour strict au cycle écran-par-écran (analyse → plan validé → évaluation d'impact → exécution → tests → commit) dès la prochaine étape.
- **Périmètre livré** : module `features/auth` complet (domaine/data/présentation) branché Firebase réel (Auth + Firestore `users/{uid}` + Storage avatar) ; `User.id` = uid ; `currentUserProvider` source unique ; pages `/login` et `/register` (routes racine) ; `ProfilePage` réelle (signOut, avatar cliquable) ; `AuthRefreshListenable` (guard/redirect + retour sur la destination visée) ; `main.dart` (init Firebase try/catch + support de Garde) ; docs synchronisées.
- **Critères d'acceptation** : `flutter analyze` 0 issue ; `flutter test` 78/78 verts — **atteints le 15/09**.
- **Validation** : en attente de l'équipe avant commit (RD4).

## Audit rétro-inspection — module auth (15/09/2026) — RD2

Bilan post-landing (détail et règles à connaître : `docs/ONBOARDING_DOMAIN_DATA.md` §Pièges).

| ID | Sévérité | Constat | Correctif retenu |
|---|---|---|---|
| B1 | 🔴 | `authStateChanges()` fait **1 lecture Firestore par événement** (`asyncMap`) et le listener d'`AuthController` n'a pas d'`onError` ; une lecture KO (ex. boot hors-ligne) **termine le flux** (single-subscription) → logout/révocation ignorés, routeur figé « connecté » | Option A : identité en `map` sync (pas d'`asyncMap`), profil enrichi chargé à part ; `onError` au listener |
| B2 | 🟠 | `ref.watch(currentUserProvider)!` (8 pages) : une déconnexion asynchrone peut rebuilder avant le redirect → `!` sur null | Garde null par page OU assertion unique dans le provider |
| B3 | 🟠 | `authRefreshListenable` = singleton global hors Riverpod ; invariant manuel « toute mutation d'état DOIT notifier » ; oubli de `resetAuthRouting()` = tests flaky | Invariant documenté (fait) ; rattacher l'état de routage à l'état auth si possible |
| B4 | 🟡 | `watchAuthStateProvider` inutilisé ; erreurs Storage/Firestore non mappées ; `image_picker` desktop ignore maxWidth/quality | Consommer ou supprimer le provider ; mapper Storage ; note desktop |

**Invariant central du module** : l'UI n'utilise `currentUser!` que parce que (1) restauration synchrone `currentUser`, (2) guard du routeur, (3) notification du listenable à chaque mutation — sont TOUJOURS vrais, dans le bon ordre **et le bon timing**. Tous les bugs vus sont des failles d'ordre temporel (flux/erreur asynchrone vs premier frame du routeur).

**Non fait, à planifier** : tests widget du Profil (signOut, avatar), test du chemin d'erreur du flux, email vérification / password reset, règles Firebase Firestore (`/users/{uid}`) + Storage à écrire, nettoyage des anciens avatars Storage, résolution de la divergence `classe.md` (password/authId) vs entité vs schéma drift.

---

## Sprint sync — offline (ex-Phase 5) — FAIT (18/09/2026)

- **Objectif** : cache local drift + convergence vers Firestore (source de vérité), en **local-first** : l'app lis reste fonctionnelle hors-ligne et chaque écriture est rejouée.
- **Périmètre livré (slice C, commits)** :
  - **C-a (`cce271c`)** : `EventRoleModel`, `TicketModel.updatedAtMs`, `EventRemoteDataSource` (create/update merge, suppression cascade par lots 400, `assignRole` `arrayUnion`) ; `TicketRemoteDataSource` (saveGenerated/fetch/fetchMyTickets collectionGroup, `claimTicket`/`validateTicketEntry` en transaction **CAS**, rejeu idempotent, `TicketStateConflictException`) ; règles `deploy/firestore.rules` (create auth, le reste organiser/owner). **106 tests**.
  - **C-b (`d8a713f`)** : `core/sync/sync_store.dart` — outbox `SyncOutbox`, `claimDue` (CAS anti-course), `markFailed` backoff exponentiel **2 s → 5 min**, **max 8 tentatives** puis `cancelled` ; `sync_handlers.dart` (mapping op → datasource). **121 tests**.
  - **C-c (`85680c9`)** : enqueue outbox **dans les mêmes transactions drift** que les écritures ; `SyncEngine` (`runOnce` single-flight, conflit → `cancelled` + pull de réconciliation) ; `PullService` (upsert events `/ max(local, count)`, rôles réassemblés sans perdre les assigns pendants, suppression des absents sauf pending, **tombstones** jamais recréés, mes billets + billets staff) ; `SyncLifecycle` (auth + `connectivity_plus`, boot hors-ligne différé) ; `syncRevisionProvider` → refetch auto des FutureProviders du catalogue ; câblage `main()` (ProviderContainer + `UncontrolledProviderScope`). **141 tests**.
  - **C-d (`6f556b0`)** : suppression du code mort (`TicketLocalDataSource`, `watchAuthStateProvider` — audit B4). **141 tests**.
- **Décisions validées** : conflit CAS → `cancelled` + pull ; boot offline → pas de pull/drain, reprise sur reconnect ; `ticketsNumber` local = `max(local, count)` jamais écrit dans Firestore ; suppression propagée par cascade client + tombstone (un `delete` pending empêche le pull de recréer l'event).
- **Critères d'acceptation** : `flutter analyze` 0 issue ; `flutter test` **141/141** verts — atteints le 18/09.

---

## Suivi d'état

| Phase | État | Validation |
|---|---|---|
| 0 — Documentation | **Fait** | 13/09 — `flutter analyze` 0 issue + `flutter test` 19/19 verts |
| 1 — Fondations (UC19 + rôles) | **Fait** | 13/09 — `flutter analyze` 0 issue + `flutter test` 29/29 verts |
| 2 — EventDetailScreen | **Fait** | 13/09 — `flutter analyze` 0 issue + `flutter test` 31/31 verts |
| 3 — Gestion & contrôle | **Fait** | 13/09 — `flutter analyze` 0 issue + `flutter test` 40/40 verts |
| 4 — Top bar + safe area | **Fait** | 13/09 — `flutter analyze` 0 issue + `flutter test` 42/42 verts |
| Sprint auth & identité | **Fait (big-bang temporaire)** | 15/09 — `flutter analyze` 0 issue + `flutter test` 78/78 verts — correctifs d'audit B1-B4 à planifier |
| 5 — Offline & sync (slice C) | **Fait** | 18/09 — `flutter analyze` 0 issue + `flutter test` 141/141 verts (~✓ B4 : `watchAuthStateProvider` supprimé en C-d) |