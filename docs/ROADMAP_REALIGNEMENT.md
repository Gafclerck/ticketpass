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

- **Phase 5 — Offline & SyncQueue (UC12-13, UC22-23)** : table `SyncQueue` (drift), outbox, drain via `connectivity_plus`, conflits.
- **Phase 6 — Infra & qualité** : auth Firebase multi-utilisateurs, seeds réalistes par user, chiffrement du secret de signature hors code source.

---

## Suivi d'état

| Phase | État | Validation |
|---|---|---|
| 0 — Documentation | **Fait** | 13/09 — `flutter analyze` 0 issue + `flutter test` 19/19 verts |
| 1 — Fondations (UC19 + rôles) | **Fait** | 13/09 — `flutter analyze` 0 issue + `flutter test` 29/29 verts |
| 2 — EventDetailScreen | **Fait** | 13/09 — `flutter analyze` 0 issue + `flutter test` 31/31 verts |
| 3 — Gestion & contrôle | **Fait** | 13/09 — `flutter analyze` 0 issue + `flutter test` 40/40 verts |
| 4 — Top bar + safe area | **Fait** | 13/09 — `flutter analyze` 0 issue + `flutter test` 42/42 verts |