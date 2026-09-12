# TicketPass -> Récap Équipe : Architecture & Use Cases

*Mis à jour après la réunion du 4/09/2026*

## Décisions d'architecture

| Sujet | Décision |
|---|---|
| Style | Clean Architecture (UseCases explicites) |
| Structure des dossiers | Feature-first (`features/event/`, `features/ticket/`, `features/scan/` + `core/` partagé) |
| State management | **Riverpod** |
| Injection de dépendances | Via les **providers Riverpod** |
| Base de données locale | **drift** |
| Backend | Firebase Auth + Firestore |
| Synchronisation offline | Pattern Outbox (table `SyncQueue`) |

## Use Cases (16, répartis en 5 epics)

**Epic 1 : Gestion des événements**
- UC1 Créer un événement
- UC2 Modifier/supprimer un événement
- UC3 Consulter mes événements

**Epic 2 : Génération & gestion des billets**
- UC4 Générer des billets
- UC5 Générer le QR code sécurisé
- UC6 Consulter la liste des billets

**Epic 3 : Expérience du porteur de billet**
- UC7 Recevoir/importer un billet
- UC8 Consulter mon billet
- UC9 Historique de mes billets

**Epic 4 : Validation & contrôle d'accès**
- UC10 Scanner un billet
- UC11 Valider un billet
- UC12 Valider un billet hors-ligne
- UC13 Synchroniser les billets validés

**Epic 5 : Infrastructure & qualité**
- UC14 Authentification / gestion utilisateur
- UC15 Setup base de données locale
- UC16 Tests, documentation & démo
