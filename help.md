# TicketPass — Guide de démarrage (pour débutants Flutter)

Ce fichier explique ce qui a été installé dans le projet, pourquoi, et comment

---

## 1. C'est quoi ce projet ?

TicketPass est une app mobile de billetterie : un organisateur crée un
événement, génère des billets avec un QR code, et un agent de contrôle scanne
ces QR codes à l'entrée pour valider les billets — même sans connexion internet.

Le travail est découpé en **5 epics** (des grands blocs de fonctionnalités) et
**16 use cases** (des actions précises, ex: "UC10 Scanner un billet"). Tu retrouveras parfois des commentaires `// UC10` dans le code plus tard — ça sert juste à savoir quelle fonctionnalité du cahier des charges ce bout de
code réalise.

---

## 2. Lancer le projet

```bash
flutter pub get      # télécharge toutes les dépendances (voir section 4)
flutter run           # lance l'app sur un simulateur/téléphone connecté
```

Autres commandes utiles pendant le développement :

```bash
flutter analyze        # vérifie que le code ne contient pas d'erreurs/mauvaises pratiques
flutter test           # lance les tests automatiques (dossier test/)
dart run build_runner build   # génère du code automatique (voir section 5)
```

---

## 3. La structure des dossiers

Tout le code vit dans `lib/`. Il est organisé en **feature-first** : 

```
lib/
  main.dart          
  core/              → code partagé par TOUTES les fonctionnalités
  features/  
    auth/            → connexion / inscription (UC14)
    event/           → gérer les événements (UC1-UC3)
    ticket/          → gérer les billets (UC4-UC9)
    scan/            → scanner et valider les billets (UC10-UC13)
```

### `core/` — le code partagé

| Dossier | À quoi il servira |
|---|---|
| `core/theme/` | Les couleurs, polices, styles de l'app entière |
| `core/routing/` | La navigation entre les écrans (quel écran s'ouvre pour quelle URL/action) |
| `core/database/` | La base de données locale sur le téléphone (pour fonctionner hors-ligne) |
| `core/network/` | Détecter si le téléphone est connecté à internet ou non |
| `core/sync/` | Renvoyer vers le serveur les données créées hors-ligne, une fois reconnecté |
| `core/providers/` | Des "fournisseurs" d'objets partagés (ex: la connexion à Firebase) — voir lexique |
| `core/errors/` | Une façon commune de représenter les erreurs dans toute l'app |
| `core/utils/`, `core/widgets/` | Petites fonctions et composants réutilisables un peu partout |

**Pour l'instant, tous ces dossiers sont vides** (avec juste un fichier
`.gitkeep` pour que Git les garde en mémoire même vides).

### `features/<nom>/` — chaque fonctionnalité, en 3 sous-dossiers

C'est le principe de la **Clean Architecture** : dans chaque fonctionnalité,
le code est séparé en 3 rôles très différents, un peu comme un restaurant :

| Sous-dossier | Rôle | Analogie restaurant |
|---|---|---|
| `domain/` | Les règles métier pures, sans aucun lien avec Flutter, Firebase ou une base de données. | La recette de cuisine — elle existe indépendamment du restaurant qui la sert |
| `data/` | Le code qui va vraiment chercher/écrire les données (Firebase, base locale). | La cuisine — c'est là qu'on prépare vraiment le plat |
| `presentation/` | Ce que l'utilisateur voit et touche : écrans, boutons, texte. | La salle et le serveur — ce que le client voit |

Concrètement, dans `domain/` :
- `entities/` — les "objets" du monde métier (ex: un `Event`, un `Ticket`)
- `repositories/` — des contrats ("je promets qu'il existera une façon de récupérer un événement"), sans dire comment
- `usecases/` — une action précise (ex: "créer un événement")

Dans `data/` :
- `models/` — la version d'un objet métier qui sait se transformer en JSON (pour Firebase) ou en ligne de base de données
- `datasources/` — le code qui appelle vraiment Firebase ou la base locale
- `repositories/` — la vraie implémentation du contrat promis dans `domain/`

Dans `presentation/` :
- `screens/` — les pages complètes de l'app
- `widgets/` — des petits morceaux d'interface réutilisables (ex: une carte d'événement)
- `providers/` — le pont entre l'écran et la logique métier (voir lexique "Provider" plus bas)

---

## 4. Les dépendances installées (`pubspec.yaml`)

Une **dépendance**, c'est une bibliothèque de code écrite par quelqu'un
d'autre qu'on réutilise au lieu de tout coder nous-mêmes. Voici celles déjà
ajoutées au projet et ce qu'elles font, en langage simple :

### Pour l'affichage
- **`cupertino_icons`** — des icônes de style iPhone (Flutter les inclut par défaut).

### Pour gérer l'état de l'app (Riverpod)
- **`flutter_riverpod`** — la bibliothèque de "state management" (voir lexique). Elle permet à plusieurs écrans de partager les mêmes données sans avoir à se les passer manuellement de widget en widget.

### Pour la navigation
- **`go_router`** — remplace le système de navigation basique de Flutter (`Navigator.push`) par un système où chaque écran a une "adresse" (comme une URL de site web, ex: `/tickets`), plus facile à gérer quand l'app a beaucoup d'écrans.

### Pour la base de données locale (fonctionner hors-ligne)
- **`drift`** — une bibliothèque qui permet d'écrire des tables de base de données en Dart (au lieu du langage SQL brut) et de les manipuler avec du code Dart typé.
- **`sqlite3_flutter_libs`** — fournit le vrai moteur de base de données (SQLite) que `drift` utilise en dessous.
- **`path_provider`** et **`path`** — pour trouver où sauvegarder le fichier de base de données sur le téléphone.

### Pour le backend (serveur distant)
- **`firebase_core`** — la brique de base pour utiliser n'importe quel service Firebase.
- **`firebase_auth`** — gère les comptes utilisateurs (inscription, connexion, mot de passe oublié...).
- **`cloud_firestore`** — la base de données en ligne de Firebase, où seront stockés les événements et billets de façon centralisée.

### Pour détecter la connexion internet
- **`connectivity_plus`** — permet de savoir si le téléphone est en ligne ou hors-ligne, pour choisir entre valider un billet directement ou le mettre en attente.

### Pour écrire moins de code répétitif
- **`freezed_annotation`** — permet de définir des objets (comme `Event`) sans écrire à la main tout le code de comparaison/copie (voir section 5).
- **`json_annotation`** — permet de convertir automatiquement un objet Dart en JSON et inversement (utile pour parler à Firebase).
- **`uuid`** — génère des identifiants uniques (ex: un ID de billet impossible à deviner).

### Dépendances de développement (`dev_dependencies`)
Celles-ci ne sont utilisées que pendant que tu codes, elles ne sont jamais incluses dans l'app finale installée sur le téléphone :
- **`flutter_test`** — pour écrire des tests automatiques.
- **`flutter_lints`** — signale les mauvaises pratiques dans ton code pendant que tu écris.
- **`build_runner`**, **`drift_dev`**, **`freezed`**, **`json_serializable`** — les outils qui génèrent automatiquement du code (voir section 5).

---