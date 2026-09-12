# Flutter Prototype Specification
## TicketPass — Mobile Event Ticket Management App

> **Source of truth:** the React/Vite prototype at `src/` (analysed September 2026).
> This document does not modify the Design System. It describes how the Design System is used.

---

## 1. Overview

**TicketPass** is a mobile-first event ticket management application targeting three user roles:

| Role | Capabilities |
|---|---|
| **Organizer** | Create events, generate tickets, manage ticket list, assign agents |
| **Agent** | Scan tickets, prepare offline data, synchronise scan results |
| **Holder** | Browse events, view owned tickets with QR codes |
| **None** | Browse events, acquire tickets (CTA only, no real purchase flow in prototype) |

### Design Philosophy

- Dark-first glassmorphism UI on `#080808` background
- Radial ambient blue glow (`#148cfa`, 28% opacity) emanating from top-right of every screen
- All surfaces use layered translucent glass (backdrop blur + semi-transparent white)
- Editorial typography: **Inter** for UI copy, **Playfair Display** for event headlines
- Electric blue (`#148cfa`) as the single accent colour throughout

### Prototype Stack (current)
React 19 · Vite 8 · TypeScript 5.7 · Tailwind CSS v4 · custom hash-based router · React Context auth

### Target Stack (Flutter)
Flutter 3.x · Dart · `go_router` for navigation · `provider` or `riverpod` for state

---

## 2. Prototype Structure

```
TicketPass
│
├── Auth
│   ├── SplashScreen
│   ├── LoginScreen
│   └── RegisterScreen
│
├── Discovery (BottomNav tabs 1 & 2)
│   ├── HomeScreen
│   └── EventsScreen
│       └── EventDetailScreen
│           ├── [Organizer CTAs] → CreateEditEventScreen
│           │                    → GenerateTicketsScreen
│           │                    → TicketListScreen
│           ├── [Agent CTAs]    → ScannerScreen
│           │                    → PrepareOfflineScreen
│           │                    → SyncScreen
│           └── [Holder CTA]   → TicketDetailScreen
│
├── My Tickets (BottomNav tab 3)
│   └── MyTicketsScreen
│       └── TicketDetailScreen
│
└── Profile (BottomNav tab 4)
    └── ProfileScreen
```

---

## 3. Screens Inventory

| # | Route key | Flutter screen name | Role | Entry points | Bottom nav |
|---|---|---|---|---|---|
| 1 | `splash` | `SplashScreen` | Auto-redirect | App cold launch | No |
| 2 | `login` | `LoginScreen` | Auth gate | Splash, logout, back from register | No |
| 3 | `register` | `RegisterScreen` | Auth — create account | LoginScreen link | No |
| 4 | `home` | `HomeScreen` | Discovery — search & browse | Splash (auth'd), BottomNav tab 1 | Yes |
| 5 | `events` | `EventsScreen` | Discovery — all events | BottomNav tab 2 | Yes |
| 6 | `event-detail` | `EventDetailScreen` | Event detail + role CTAs | EventCard tap (Home/Events) | No |
| 7 | `create-event` | `CreateEditEventScreen` | Organizer — create/edit event | HomeScreen "Create" tab, Events FAB, EventDetail "Modifier" | No |
| 8 | `generate-tickets` | `GenerateTicketsScreen` | Organizer — batch ticket gen | EventDetail floating "Générer" | No |
| 9 | `ticket-list-org` | `TicketListScreen` | Organizer — manage tickets | EventDetail floating "Voir les billets" | No |
| 10 | `my-tickets` | `MyTicketsScreen` | Holder — owned tickets | BottomNav tab 3 | Yes |
| 11 | `ticket-detail` | `TicketDetailScreen` | Holder — QR + event info | MyTicketsScreen card tap, EventDetail "Voir mon billet" | No |
| 12 | `scanner` | `ScannerScreen` | Agent — scan QR codes | EventDetail floating "Scanner" | No (fullscreen) |
| 13 | `prepare-offline` | `PrepareOfflineScreen` | Agent — download ticket data | EventDetail floating "Mode offline" | No |
| 14 | `sync` | `SyncScreen` | Agent — upload scan results | EventDetail floating "Synchroniser" | No |
| 15 | `profile` | `ProfileScreen` | User profile + logout | BottomNav tab 4 | Yes |

---

## 4. Navigation & User Flows

### Auth Flow
```
SplashScreen (2 s delay)
  ├── user authenticated → HomeScreen
  └── not authenticated → LoginScreen
        ├── login success → HomeScreen
        ├── "S'inscrire" link → RegisterScreen
        │     └── register success → HomeScreen
        └── "Mot de passe oublié ?" → [no destination in prototype]
```

### Discovery Flow
```
HomeScreen
  ├── Avatar tap → ProfileScreen
  ├── "Create" tab → CreateEditEventScreen (mode: create)
  └── EventCard tap → EventDetailScreen
        └── [role-dependent CTAs — see §8 EventDetailScreen]

EventsScreen
  ├── FAB "+" → CreateEditEventScreen (mode: create)
  └── EventCard tap → EventDetailScreen
```

### Organizer Flow (from EventDetailScreen, role = organizer)
```
EventDetailScreen
  ├── FloatingAction "Générer des billets" → GenerateTicketsScreen
  ├── FloatingAction "Voir les billets"    → TicketListScreen
  ├── FloatingAction "Modifier"            → CreateEditEventScreen (mode: edit)
  └── FloatingAction "Assigner un agent"  → [not wired in prototype]
```

### Agent Flow (from EventDetailScreen, role = agent)
```
EventDetailScreen
  ├── FloatingAction "Scanner"      → ScannerScreen (fullscreen)
  ├── FloatingAction "Mode offline" → PrepareOfflineScreen
  └── FloatingAction "Synchroniser" → SyncScreen
```

### Holder Flow
```
MyTicketsScreen
  └── TicketCard tap → TicketDetailScreen

EventDetailScreen (role = holder)
  └── Bottom bar "Voir mon billet" → TicketDetailScreen (ticketId: "t1")
```

### Back navigation
All non-tab screens show a back button that pops the navigation stack. BottomNav tabs do not push to the stack — they replace the active shell tab.

---

## 5. Shared Components

These components appear on multiple screens and should be built as shared Flutter widgets.

### 5.1 AppShell

**Flutter widget:** `AppShell` (wraps `Scaffold`)

**Purpose:** Provides the persistent dark background with radial blue ambient glow. All non-fullscreen screens render inside this shell.

**Structure:**
```
AppShell
└── Stack
    ├── Background — full-screen radial gradient
    └── Child content (the active page widget)
```

**Background gradient:**
```
RadialGradient(
  center: Alignment(0.44, -0.92),  // 72% from left, 8% from top
  radius: 1.2,
  colors: [
    rgba(20,140,250, 0.28),   // at 0%
    rgba(20,140,250, 0.12),   // at ~24%
    transparent,               // at ~58%
  ],
  stops: [0.0, 0.24, 0.58],
)
// Over solid #080808 base
```

**Dimensions:** fills the full screen (`width: double.infinity, height: double.infinity`).

---

### 5.2 BottomNav

**Flutter widget:** `AppBottomNav`

**Purpose:** Persistent floating tab bar shown only on the 4 primary tab routes (Home, Events, MyTickets, Profile).

**Design System dependency:** Glass standard — `rgba(255,255,255,0.12)` + `blur(28px)` + `border white/14`

**Visibility:** hidden on all detail/sub-screens. Render conditionally based on active route.

**Dimensions:**
- Height: 76 px
- Horizontal margin: 16 px left and right
- Bottom margin: 16 px from screen bottom
- Border-radius: 38 px (pill)

**Layout:**
```
BottomNav (positioned absolute, bottom: 16, left: 16, right: 16)
└── Row (mainAxisAlignment: spaceAround)
    ├── NavItem — Accueil (home)
    ├── NavItem — Événements (events)
    ├── NavItem — Mes billets (my-tickets)
    └── NavItem — Profil (profile)
```

**NavItem states:**
- **Active:** icon inside 52×52 px filled circle `#148cfa`; icon stroke = white
- **Inactive:** icon in 52×52 px transparent container; icon stroke = `rgba(255,255,255,0.70)`

**Icons (SVG, 24×24, stroke-based):**

| Tab | Icon description |
|---|---|
| Accueil | House with chimney — outline |
| Événements | Ticket — outline with vertical centre line |
| Mes billets | Credit card — outline with horizontal stripe |
| Profil | Person silhouette — head circle + shoulder arc |

**Tap interaction:** `scale(0.9)` spring on press, then navigate. No animation between tabs in prototype.

---

### 5.3 EventCard

**Flutter widget:** `EventCard`

**Props:** `event: Event, compact: bool`

**Design System dependency:** None directly — custom component using DS tokens.

#### Default variant (`compact: false`)
- Full-width container
- Height: 280 px
- Border-radius: 32 px
- Border: `rgba(20,140,250,0.15)` 1 px
- Image: full cover
- Gradient overlay: `LinearGradient(to top, rgba(0,0,0,0.88) → rgba(0,0,0,0.55) at 35% → transparent at 75%)`
- Bottom overlay (padding 20 px):
  - Avatar row: 3 overlapping 24 px circles (pravatar placeholder), gap -8 px + "+2k inscrits" text
  - Headline: 26 px, bold, white, **Playfair Display**
  - Subline: 13 px, `#a7abb3`, `{date} · {location}`
  - Bottom row: price (17 px, bold, white) + "Voir l'événement" button (h=36 px, px=16, rounded-full, `#148cfa` fill, white, 13 px, semibold)
- Tap interaction: `scale(0.98)` → navigate to EventDetailScreen

#### Compact variant (`compact: true`)
- Width: 260 px, Height: 340 px
- Border-radius: 32 px
- Same gradient overlay
- Bottom overlay (padding 16 px):
  - Avatar row: 3 overlapping 24 px circles + "+2k inscrits"
  - Date/time: 11 px, `#a7abb3`, uppercase, letter-spacing
  - Headline: 22 px, bold, white, **Playfair Display**
  - Location: 13 px, `#a7abb3`
  - Bottom row: price (15 px, bold, white)
- Tap interaction: `scale(0.97)` → navigate to EventDetailScreen

> **Observation:** Compact variant is defined in the component but not instantiated anywhere in the current prototype screens.

---

### 5.4 QRCode widget (large — TicketDetailScreen)

**Flutter widget:** `TicketQRCode`

**Purpose:** Deterministic dot-grid QR-like rendering from a ticket code string. Not a real QR code standard.

**Grid:** 11 × 11 cells

**Cell dimensions:** 22 × 22 px, border-radius 3 px, gap 2 px

**Cell coloring algorithm:**
```
bool isOn(int i, String code) {
  int c = code.codeUnitAt(i % code.length);
  return (c * 3 + i * 13) % 4 != 0;
}
```

**Finder patterns (forced on):** top-left, top-right, and bottom-left 3×3 corner blocks.

**Container:** white background, padding 16 px, border-radius 20 px

**Total rendered size:** `11 * 22 + 10 * 2 + 32 = 294 px` (approx)

---

### 5.5 MiniQRCode widget (small — GenerateTicketsScreen)

**Flutter widget:** `MiniQRCode`

**Grid:** 9 × 9 cells

**Cell dimensions:** 18 × 18 px, border-radius 2 px, gap 1 px

**Cell coloring:** same deterministic algorithm as 5.4

**Finder patterns:** same 3 corners (3×3 blocks within 9×9)

**Container:** white background, padding 12 px, border-radius 16 px

---

### 5.6 FloatingAction button (EventDetailScreen)

**Flutter widget:** `FloatingActionButton` (custom, not Material FAB)

**Purpose:** Role-action button stacked on the right side of EventDetailScreen.

**Two sizes:**
- **Primary (large):** 52 × 52 px circle, `#148cfa` fill, `0 6px 20px rgba(20,140,250,0.40)` shadow
- **Secondary:** 44 × 44 px circle, `rgba(255,255,255,0.12)` fill, `blur(20px)`, `border rgba(255,255,255,0.14)`, `0 4px 12px rgba(0,0,0,0.30)` shadow

**Label pill (hover/focus reveal):**
- `px=12, py=6`, rounded-full
- Background: `rgba(8,8,8,0.82)`, `blur(16px)`, `border white/10`
- Font: 13 px, semibold, white-space no-wrap
- Primary label colour: `#148cfa`; secondary label colour: `#f5f7fa`
- Default: `opacity 0`; on hover/focus: `opacity 1` (200 ms fade)

> **Flutter note:** On mobile there is no hover state. The label pill reveal pattern does not apply. Consider showing labels always visible, or implement on long-press.

**Tap interaction:** `scale(0.9)` spring on press.

**Stack positioning:** `Positioned(right: 16, bottom: 112)` — sits above BottomNav.

---

### 5.7 Standard Back Button

Used on every sub-screen header.

**Dimensions:** 44 × 44 px circle
**Background:** `rgba(255,255,255,0.10)`
**Border:** 1 px `rgba(255,255,255,0.12)`
**Icon:** chevron-left SVG 20 × 20, white, stroke 2 px, round cap/join

---

### 5.8 Standard Sub-screen Header

Pattern used by: GenerateTicketsPage, TicketListOrgPage, MyTicketsPage (with tickets), TicketDetailPage, PrepareOfflinePage, SyncPage, ProfilePage.

```
Row (px: 20, pt: 48, pb: 16, mainAxisAlignment: spaceBetween)
├── BackButton (44×44 glass circle)
├── Text — screen title (18 px, bold, #f5f7fa)
└── SizedBox(width: 44)   ← spacer to centre the title
```

---

### 5.9 Badge

**Flutter widget:** `StatusBadge`

**Design System component:** Badge / [color variant]

**Variants used in prototype:**

| Color | Background | Text | Border |
|---|---|---|---|
| blue | `rgba(20,140,250,0.20)` | `#148cfa` | `rgba(20,140,250,0.30)` |
| green | `rgba(34,197,94,0.20)` | `#4ade80` | `rgba(34,197,94,0.30)` |
| red | `rgba(239,68,68,0.20)` | `#f87171` | `rgba(239,68,68,0.30)` |
| gray (default) | `rgba(255,255,255,0.10)` | `#a7abb3` | `rgba(255,255,255,0.12)` |

**Layout:** `Container(padding: EdgeInsets.symmetric(h:12, v:4), decoration: rounded-full)` + `Text(12 px, medium)`

---

### 5.10 Chip (filter pill)

**Flutter widget:** `FilterChip`

**Design System component:** Chip / Active and Chip / Inactive

| State | Background | Text | Border |
|---|---|---|---|
| Active | `#148cfa` | white | none |
| Inactive | `rgba(255,255,255,0.06)` | `#f5f7fa` | `rgba(255,255,255,0.14)` 1px |

**Dimensions:** height 44 px, horizontal padding 20 px, border-radius 22 px (full pill)

**Font:** 14 px, medium, no-wrap

---

### 5.11 SearchField

**Flutter widget:** `AppSearchField`

**Design System component:** SearchField

**Structure:**
```
Stack
├── Icon — magnifier SVG 20×20, positioned left: 18, colour #6f737c
└── TextField
      padding: left 50, right 20
      height: 56 px
      background: rgba(255,255,255,0.10)
      border: rgba(255,255,255,0.06) → rgba(255,255,255,0.20) on focus
      border-radius: 28 px
      font: 15 px, #f5f7fa, placeholder #6f737c
```

---

### 5.12 Button

**Flutter widget:** `AppButton`

**Design System component:** Button / [variant] / [size]

#### Variants

| Variant | Background | Text | Border | Border-radius |
|---|---|---|---|---|
| primary | `#148cfa` | white | none | 28 px |
| secondary | `rgba(255,255,255,0.10)` + `blur(24px)` | `#f5f7fa` | `rgba(255,255,255,0.14)` | 28 px |
| ghost | transparent | `#148cfa` | none | 28 px |
| icon | `rgba(255,255,255,0.10)` + `blur(24px)` | `#f5f7fa` | `rgba(255,255,255,0.12)` | full circle |

#### Sizes

| Size | Height | H-padding | Font size | Icon size (square) |
|---|---|---|---|---|
| sm | 40 px | 20 px | 14 px | 40 × 40 px |
| md | 48 px | 24 px | 16 px | 48 × 48 px |
| lg (default) | 56 px | 24 px | 15 px | 52 × 52 px |

**fullWidth:** `width: double.infinity`

**Press interaction:** `scale(0.95)` spring.

---

### 5.13 Avatar

**Flutter widget:** `UserAvatar`

**Props:** `src: String?, name: String?, size: double` (default 40)

- **With image:** circular `ClipOval` with `CachedNetworkImage` or `Image.network`, full cover
- **Fallback:** circular container, `rgba(20,140,250,0.30)` background, initials text (`size * 0.36` px, white)

**Sizes used:** 40 px (HomeScreen header avatar button), 44 px (HomeScreen header tap target), 80 px (ProfileScreen card)

---

### 5.14 GlassCard

**Flutter widget:** `GlassCard`

**Design System component:** GlassCard / Default and GlassCard / Elevated

| Mode | Background | Blur | Border |
|---|---|---|---|
| Default | `rgba(255,255,255,0.10)` | `blur(24px)` | `rgba(255,255,255,0.12)` |
| Elevated | `rgba(255,255,255,0.14)` | `blur(28px)` | `rgba(255,255,255,0.16)` |

**Border-radius:** 28 px (both modes)

**When tappable:** `scale(0.98)` spring on press.

---

## 6. Component Variants

### Button — variants used per screen

| Screen | Variant | Size | Label | fullWidth |
|---|---|---|---|---|
| LoginScreen | primary | lg | "Se connecter" | Yes |
| RegisterScreen | primary | lg | "S'inscrire" | Yes |
| HomeScreen "Buy" tab | primary (custom tab) | — | "Buy" | No |
| EventDetailScreen (none) | primary (inline) | — | "Obtenir un billet" | Yes |
| EventDetailScreen (holder) | primary | lg | "Voir mon billet" | Yes |
| GenerateTicketsScreen | primary | lg | "Générer {n} billets" | Yes |
| CreateEditEventScreen continue | primary (inline) | — | "Continuer" | Yes |
| CreateEditEventScreen final | primary | lg | "Créer l'événement" / "Mettre à jour" | Yes |
| CreateEditEventScreen delete | secondary | lg | "🗑 Supprimer l'événement" | Yes |
| MyTicketsScreen empty | primary (inline) | — | "Explorer les événements" | No |
| PrepareOfflinePage | primary | lg | "⬇️ Télécharger les billets" | Yes |
| SyncScreen | primary | lg | "🔄 Synchroniser maintenant" | Yes |
| ProfileScreen | secondary | lg | "Se déconnecter" | Yes |

### EventCard — variants used per screen

| Screen | Variant |
|---|---|
| HomeScreen list | Default (full-width, 280 px h) |
| EventsScreen list | Default (full-width, 280 px h) |

> **Observation:** Compact EventCard is implemented but not rendered in any prototype screen.

### Badge — variants used per screen

| Screen | Colors used |
|---|---|
| MyTicketsScreen | green (valid), gray (used), red (expired) |
| TicketDetailScreen | green, gray, red |
| TicketListScreen | green (Valide), gray (Utilisé) |
| ScannerPage result modal | green (valid result), red (used result) |

### GlassCard — variants used per screen

| Screen | Mode |
|---|---|
| LoginScreen form card | Elevated |
| RegisterScreen form card | Elevated |
| TicketDetailScreen QR card | Default (via inline glass style) |

---

## 7. Component States

### Button / primary
| State | Visual | Trigger |
|---|---|---|
| Default | `#148cfa` fill | — |
| Pressed | `scale(0.95)`, `#0e79dc` fill | tap down |
| Disabled | `rgba(255,255,255,0.10)`, text `#4d5057`, `cursor: not-allowed` | `enabled: false` prop |
| Loading | not represented in prototype | — |

> **Potential missing state:** loading button (SyncScreen "Synchroniser" shows a spinner label "Synchronisation en cours..." but the button itself uses a disabled state visually, not a dedicated loading variant).

### SearchField
| State | Border colour | Trigger |
|---|---|---|
| Default | `rgba(255,255,255,0.06)` | — |
| Focused | `rgba(255,255,255,0.20)` | text field focus |

### Chip
| State | Background | Trigger |
|---|---|---|
| Inactive | `rgba(255,255,255,0.06)` | — |
| Active | `#148cfa` | tap |

### BottomNav NavItem
| State | Icon circle | Trigger |
|---|---|---|
| Inactive | transparent | — |
| Active | `#148cfa` filled 52×52 circle | route matches tab |
| Pressed | `scale(0.90)` | tap down |

### EventCard
| State | Visual | Trigger |
|---|---|---|
| Default | static | — |
| Pressed | `scale(0.98)` or `0.97` (compact) | tap down |

### FloatingAction button
| State | Visual | Trigger |
|---|---|---|
| Default | icon visible, label pill hidden (opacity 0) | — |
| Hover/Focus | label pill opacity 1 | hover (web only) |
| Pressed | `scale(0.90)` | tap down |

### ScannerScreen viewfinder corners
| State | Colour | Trigger |
|---|---|---|
| Idle | `rgba(255,255,255,0.60)` | default |
| Valid | `#22c55e` (emerald) | valid scan simulation |
| Used/Invalid | `#ef4444` (red) | used/invalid scan simulation |

### PrepareOfflinePage download
| State | Visual | Trigger |
|---|---|---|
| Idle | button enabled | — |
| Downloading | button disabled, progress bar visible, incrementing | tap download |
| Complete | progress 100%, emerald "✓ Billets téléchargés" row | interval completes |

### SyncScreen
| State | Visual | Trigger |
|---|---|---|
| Unsynced | pending count = 7, gray status dot | default |
| Syncing | button disabled, spinner label | tap sync |
| Synced | pending count = 0, emerald status dot + glow, success message | timer completes |

### CreateEditEventScreen — step progression
| State | Dot width | Dot colour |
|---|---|---|
| Future step | 8 px | `rgba(255,255,255,0.20)` |
| Past step | 8 px | `rgba(20,140,250,0.50)` |
| Current step | 28 px | `#148cfa` |

### MyTicketsScreen
| State | Visual |
|---|---|
| Empty (no tickets) | Centred column with ticket icon box + title + body + CTA button |
| With tickets | Scrollable list of TicketCard |

### Potential missing states (not in prototype)
- Button / loading (spinner inside button)
- LoginScreen / loading (while checking credentials)
- EventCard / loading skeleton
- TicketListScreen / empty (no tickets for event)
- ScannerScreen / camera permission denied

---

## 8. Screen Specifications

---

### Screen: SplashScreen

**Purpose:** Brand presentation, auto-redirect after 2 s.

**Entry points:** App cold launch.

**Layout:**
```
SplashScreen (full screen, AppShell background)
└── Center
    └── Column (mainAxisSize: min, gap: 24)
        ├── AppIconBlock
        │   ├── Container (80×80, radius 28, #148cfa, shadow glow)
        │   │   └── TicketSvgIcon (44×44, white)
        │   ├── Text "Welcome to" (13px, #a7abb3, uppercase, tracking 0.12em)
        │   └── Text "TicketPass" (32px, bold, #f5f7fa, tracking -0.02em)
        └── LoadingDots (3 × 8px circles, #148cfa, staggered pulse, gap 6)
```

**Dimensions:**
- Logo container: 80 × 80 px, border-radius 28 px
- Logo icon: 44 × 44 px
- Logo shadow: `0 8px 24px rgba(20,140,250,0.40)`

**Behavior:** `Future.delayed(Duration(seconds: 2))` → navigate to HomeScreen if authenticated, else LoginScreen.

**States:** single state (loading).

**Responsive behavior:** Not defined in prototype.

**Flutter implementation notes:**
```
SplashScreen
└── Scaffold (backgroundColor: transparent)
    └── AppShell
        └── Center
            └── Column
```

---

### Screen: LoginScreen

**Purpose:** Email + password authentication.

**Entry points:** SplashScreen (unauthenticated), logout from ProfileScreen.

**Layout:**
```
LoginScreen
└── Column (px: 20, pt: 64, pb: 40, scrollable)
    ├── HeaderBlock (mb: 40)
    │   ├── LogoIcon (56×56, radius 20)
    │   ├── Title (32px bold, #f5f7fa, 2 lines)
    │   └── Subtitle (15px, #a7abb3)
    ├── GlassCard / Elevated (mb: 24, padding 24, gap 16)
    │   ├── EmailField
    │   ├── PasswordField
    │   ├── ErrorText (conditional, 13px, red-400)
    │   └── ForgotPasswordText (13px, #148cfa, right-aligned)
    ├── Button / primary / lg / fullWidth — "Se connecter"
    ├── RegisterLinkRow (text-center, mt: 20)
    └── DemoHintBox (mt: 32, radius 16, bg white/4, border white/8)
```

**Sections:**
1. Header — logo + title + subtitle
2. Form card — 2 inputs + actions
3. Primary CTA
4. Register link
5. Demo hint

**Form fields:**
| Field | Type | Label | Pre-filled | Placeholder |
|---|---|---|---|---|
| Email | email | "Email" | `alice@demo.com` | — |
| Password | password | "Mot de passe" | `demo` | — |

**Input style:** `h=56, px=20, radius=20, bg rgba(255,255,255,0.10), border rgba(255,255,255,0.12), focus-border rgba(20,140,250,0.50)`

**Actions:**
- "Se connecter" → call `login(email, password)` → navigate to HomeScreen; on failure show error text
- "Mot de passe oublié ?" → no destination in prototype
- "S'inscrire" inline button → navigate to RegisterScreen

**Navigation:**
- Success → HomeScreen
- "S'inscrire" → RegisterScreen

**States:**
- Default
- Error (login failed): error text `"Email ou mot de passe incorrect"` appears above CTA

**Flutter implementation notes:**
```
LoginScreen
└── Scaffold (backgroundColor: transparent)
    └── AppShell
        └── SafeArea
            └── SingleChildScrollView
                └── Padding(h:20, top:64, bottom:40)
                    └── Column
```

---

### Screen: RegisterScreen

**Purpose:** New account creation.

**Entry points:** LoginScreen "S'inscrire" link.

**Layout:**
```
RegisterScreen
└── Column (px: 20, pt: 64, pb: 40, scrollable)
    ├── BackButton row (mb: 32, self-start)
    ├── Title (32px bold, mb: 8)
    ├── Subtitle (15px, #a7abb3, mb: 32)
    ├── GlassCard / Elevated (padding 24, gap 16)
    │   ├── NomCompletField
    │   ├── EmailField
    │   └── MotDePasseField
    └── Button / primary / lg / fullWidth (mt: 24) — "S'inscrire"
```

**Form fields:**
| Field | Type | Label | Placeholder |
|---|---|---|---|
| Nom complet | text | "Nom complet" | — |
| Email | email | "Email" | — |
| Mot de passe | password | "Mot de passe" | — |

**Back navigation:** chevron-left SVG + "Retour" text → navigate to LoginScreen.

**Actions:**
- "S'inscrire" → `register(name, email, password)` → navigate to HomeScreen (always succeeds in prototype)

**States:** single state (no error state represented).

---

### Screen: HomeScreen

**Purpose:** Primary discovery hub — search, filter, and browse events.

**Entry points:** Auth success, BottomNav tab 1.

**Layout:**
```
HomeScreen (scrollable, pb: 112 to clear BottomNav)
├── Header (px: 20, pt: 48, pb: 16)
│   ├── LogoRow
│   │   ├── LogoIcon (40×40, radius 14, #148cfa, shadow)
│   │   └── Text "TicketPass" (17px, bold)
│   └── AvatarButton (44×44) → ProfileScreen
├── SegmentedControl (px: 20, pb: 20, centered)
│   └── GlassPill (p: 6, gap: 4, radius 28, glass standard)
│       ├── Tab "Buy" (active)
│       ├── Tab "Sell" (inactive)
│       └── Tab "Create" (inactive) → CreateEditEventScreen
├── HeroCopy (px: 20, mb: 24)
│   ├── Greeting "Bonjour {firstName} 👋" (13px, #a7abb3)
│   └── Title (32px, bold, -0.02em tracking, 2 lines)
├── SearchBar (px: 20, mb: 0)
├── CategoryChips (pl: 20, horizontal scroll, no-scrollbar)
│   └── [7 chips: Tous / Sport / Concerts / Conférence / Théâtre / Comédie / Exposition]
└── EventList (px: 20, gap: 16)
    └── EventCard (default variant) × filtered events
```

**Category filter chips:**
| Label | Key (category value) |
|---|---|
| Tous | all |
| Sport | sport |
| Concerts | concert |
| Conférence | conference |
| Théâtre | theatre |
| Comédie | comedy |
| Exposition | exhibition |

**Segmented control tabs:**
- **Buy** (active by default): filters events for purchase
- **Sell** (inactive): no action in prototype
- **Create** (inactive): navigates to CreateEditEventScreen

**Segmented control tab styling:**
- Container: `p=6, gap=4, rounded=28, bg rgba(255,255,255,0.12), blur(28px), border white/14`
- Active tab: `h=40, px=24, radius=22, bg #148cfa, text white, shadow 0 4px 12px rgba(20,140,250,0.35)`
- Inactive tab: `h=40, px=24, radius=22, text rgba(255,255,255,0.70)`

**Filtering logic:** `event.headline OR event.title` contains search string (case-insensitive) AND `event.category` matches active chip key (or all).

**Empty state:** centred text `text-[14px] text-[#6f737c]` "Aucun événement trouvé".

**Navigation:**
- Avatar button → ProfileScreen
- "Create" tab → CreateEditEventScreen (mode: create)
- EventCard tap → EventDetailScreen

**Scroll behavior:** full-page vertical scroll. Category chips horizontal scroll. Fixed BottomNav (bottom 16).

---

### Screen: EventsScreen

**Purpose:** Full event catalogue — browsable by user with organizer "mine" filter.

**Entry points:** BottomNav tab 2.

**Layout:**
```
EventsScreen (scrollable, pb: 112)
├── Header (px: 20, pt: 48, pb: 16)
│   ├── Title "Événements" (28px, bold, -0.02em, mb: 16)
│   ├── TabRow (gap: 8, mb: 16)
│   │   ├── Tab "Tous" (active/inactive pill)
│   │   └── Tab "Mes événements"
│   └── SearchField (full-width)
├── FilterChips (px: 20, mb: 20, horizontal scroll)
│   ├── Chip "Coming Soon"
│   └── Chip "History"
├── EventList (px: 20, gap: 16)
│   └── EventCard (default) × filtered events
└── FAB (fixed, bottom: 96, right: 20)
    └── CircleButton (56×56, #148cfa, shadow, + icon) → CreateEditEventScreen
```

**Tab styling:**
- Active: `h=40, px=20, rounded-full, bg #148cfa, text white`
- Inactive: `h=40, px=20, rounded-full, bg rgba(255,255,255,0.10), border rgba(255,255,255,0.12), text #f5f7fa`

**"Mes événements" filter logic:** shows only events where `USER_ROLES[event.id] === "organizer"`.

**FAB:** `56×56 px circle, bg #148cfa, shadow 0 8px 24px rgba(20,140,250,0.40)` — "+" plus SVG 24×24 white.

> **Observation:** The "Coming Soon" / "History" filter chips are rendered but not wired to any actual filtering logic in the prototype.

---

### Screen: EventDetailScreen

**Purpose:** Full event detail with role-contextual action buttons.

**Entry points:** EventCard tap from HomeScreen or EventsScreen.

**Layout:**
```
EventDetailScreen (scrollable, pb: 112 for holder/none, pb: 40 for org/agent)
├── FloatingHeader (absolute, top: 0, z: 10)
│   ├── BackButton (44×44 glass circle)
│   ├── Title (16px, semibold, #f5f7fa)
│   └── ShareButton (44×44 glass circle, share SVG)
├── HeroImage (mx: 16, mt: 16, radius: 32, height: 320)
│   ├── Cover image
│   ├── Gradient overlay (rgba(0,0,0,0.80) → transparent)
│   └── HeroOverlay (bottom p: 20)
│       ├── AvatarRow (3 × 28px circles, -8px offset, "+2k Joined")
│       └── HeadlineText (34px, bold, white, Playfair Display)
└── ContentArea (px: 20, pt: 20, gap: 20)
    ├── OrganizerRow
    │   ├── Left: Avatar (48×48) + Name (15px semibold) + Location (13px #a7abb3)
    │   └── Right: HeartButton (40×40 glass circle)
    ├── MetadataGrid (grid 2 cols, gap: 12)
    │   ├── PriceChip (h=56, px=16, radius=20, glass subtle)
    │   └── TimeChip (h=56, px=16, radius=20, glass subtle)
    ├── DescriptionSection
    │   ├── Title "À propos" (18px bold, mb: 8)
    │   └── Body (15px, #a7abb3, line-height relaxed)
    └── [Organizer only] CapacityBlock (p=16, radius=20, glass subtle)
        ├── Label + sold/capacity value (20px bold)
        └── ProgressBar (h=8, radius full, #148cfa fill)
```

**Metadata chip internal layout:**
```
MetadataChip
└── Row (gap: 12)
    ├── Icon (SVG 20×20, #148cfa)
    └── Column
        ├── Label (11px, #6f737c)
        └── Value (15px, bold, #f5f7fa)
```

**Role-dependent CTAs:**

*Role: none*
```
BottomBar (fixed, bottom: 0, px: 16, pt: 16, pb: 24)
Background: rgba(8,8,8,0.92), blur(24px), border-top white/6
└── Button "Obtenir un billet" (fullWidth, h=56, radius=28, #148cfa, 16px semibold)
```

*Role: holder*
```
BottomBar (same glass bar)
└── AppButton / primary / lg / fullWidth — "Voir mon billet" → TicketDetailScreen
```

*Role: organizer* → floating right-side stack at `right: 16, bottom: 112`
```
Column (end, gap: 12)
├── FloatingAction "Générer des billets" (primary, 52px) → GenerateTicketsScreen
├── FloatingAction "Voir les billets"   (secondary, 44px) → TicketListScreen
├── FloatingAction "Modifier"           (secondary, 44px) → CreateEditEventScreen (edit)
└── FloatingAction "Assigner un agent"  (secondary, 44px) → [not wired]
```

*Role: agent* → floating right-side stack at `right: 16, bottom: 112`
```
Column (end, gap: 12)
├── FloatingAction "Scanner"      (primary, 52px) → ScannerScreen
├── FloatingAction "Mode offline" (secondary, 44px) → PrepareOfflineScreen
└── FloatingAction "Synchroniser" (secondary, 44px) → SyncScreen
```

**Floating action icons (SVG, 20×20 or 24×24 for primary, white stroke 2px):**

| Action | Icon |
|---|---|
| Générer des billets | Ticket (rectangle + vertical divider) |
| Voir les billets | List (3 horizontal lines) |
| Modifier | Pencil |
| Assigner un agent | Person + plus sign |
| Scanner | Camera (rectangle + circle) |
| Mode offline | Download arrow |
| Synchroniser | Refresh/sync arrows |

**FloatingHeader:** uses `position: absolute` over the hero image. The header is not a persistent app bar — it overlaps the image.

> **Observation:** FloatingHeader is absolute-positioned, not sticky. It disappears under the hero on scroll. This is intentional per prototype.

**Scroll behavior:** full-page vertical scroll. Hero image scrolls with page.

---

### Screen: CreateEditEventScreen

**Purpose:** Multi-step form to create or edit an event.

**Entry points:**
- HomeScreen "Create" tab → mode: create
- EventsScreen FAB → mode: create
- EventDetailScreen "Modifier" → mode: edit (eventId in params)

**Mode:** detected from `params.mode === "edit"`. Edit mode pre-populates form from event data.

**Layout:**
```
CreateEditEventScreen (non-scrolling outer)
├── Header (px: 20, pt: 48, pb: 20, shrink-0)
│   ├── BackButton / PrevButton (44×44 glass circle)
│   ├── Column (center)
│   │   ├── Title (16px bold)
│   │   └── StepIndicator (dots row)
│   └── StepCounter "1/4" (13px, #6f737c)
├── StepTitle (px: 20, pb: 16, 24px bold, -0.015em, shrink-0)
├── StepContent (flex-1, scrollable vertically, px: 20, pb: 24)
│   └── [active step widget]
└── BottomCTA (shrink-0, px: 20, pt: 16, pb: 40, border-top white/6, glass bg)
    └── [CTA button(s)]
```

**Steps:**

| Step | Title | Can proceed condition |
|---|---|---|
| 0 | Identité | title AND headline non-empty |
| 1 | Lieu & Date | date AND location non-empty |
| 2 | Capacité | capacity non-empty |
| 3 | Récapitulatif | always (final step) |

**Step 0 — Identité:**
```
StepIdentity
├── BrandPicker
│   ├── PreviewImage (radius 24, h=176, border rgba(20,140,250,0.30))
│   └── PresetGrid (4 columns, gap: 8)
│       └── PresetThumbnail × 8 (ratio 1:1, radius 14, selected: 2px solid #148cfa + 2px offset)
├── TitleInput — label "Titre de l'événement"
├── HeadlineInput — label "Vedette / Nom principal"
├── CategoryPills (horizontal scroll, h=40, px=16)
│   └── CategoryChip × 8 (active: #148cfa, inactive: white/6 + white/14 border)
└── DescriptionTextArea (rows 3, px=20, py=16, radius 20, bg white/10, border white/12, resize none)
```

**8 BRAND_PRESETS (Unsplash):** Concert, Festival, Sport, Conférence, Théâtre, Exposition, Spectacle, Outdoor

**8 CATEGORIES:** Concert, Festival, Sport, Théâtre, Conférence, Comédie, Exposition, Autre

**Step 1 — Lieu & Date:**
```
StepDateTime
├── DateInput — label "Date"
├── TimeInput — label "Heure"
└── LocationInput — label "Lieu"
```

**Step 2 — Capacité:**
```
StepCapacity
├── CapacityInput — label "Capacité totale", type number
├── PriceInput — label "Prix par billet (€)", type number
└── InfoBox (p=16, radius 20, border rgba(20,140,250,0.20), bg rgba(20,140,250,0.06))
    └── info text (13px, #a7abb3)
```

**Step 3 — Récapitulatif:**
```
StepSummary
├── PreviewImage (radius 24, h=192)
│   ├── Cover + gradient
│   └── Overlay: "Vedette" label (11px #6f737c) + headline (22px, Playfair Display)
├── SummaryTable (radius 24, border white/12, bg rgba(255,255,255,0.06))
│   └── SummaryRow × 8 (px=20, py=14, border-bottom white/6 dashed)
│       ├── Label (13px, #6f737c)
│       └── Value (14px, #f5f7fa, semibold)
└── DescriptionText (optional, 13px, #a7abb3)
```

**Summary table rows:** Titre, Vedette, Catégorie, Date, Heure, Lieu, Capacité, Prix

**BottomCTA — non-final steps:**
- Enabled: `h=56, w=full, radius=28, #148cfa bg, white text, shadow, scale(0.98) press`
- Disabled: `h=56, w=full, radius=28, rgba(255,255,255,0.10) bg, #4d5057 text, cursor: not-allowed`

**BottomCTA — final step (create):** `AppButton / primary / lg / fullWidth` "Créer l'événement"

**BottomCTA — final step (edit):**
```
Column (gap: 12)
├── AppButton / primary / lg / fullWidth — "Mettre à jour"
└── AppButton / secondary / lg / fullWidth — "🗑 Supprimer l'événement"
```

**Success state:** `h=56, radius=28, bg rgba(34,197,94,0.20), border rgba(34,197,94,0.30), Row [✓ icon + "Événement créé !"]` replaces the CTA row.

**StepIndicator animation:**
- Current: `width 28px → 8px` (pill shape at current, small circle past/future)
- Animate with `AnimatedContainer` on width

**Header back/prev button behavior:**
- Step 0: `back()` (exits the screen)
- Steps 1–3: `prevStep()` (goes to previous step)

---

### Screen: GenerateTicketsScreen

**Purpose:** Batch-generate a specified number of tickets for an event.

**Entry points:** EventDetailScreen FloatingAction "Générer des billets".

**Layout:**
```
GenerateTicketsScreen (scrollable, pb: 40)
├── Header (standard sub-screen pattern)
└── Content (px: 20, gap: 20)
    ├── EventInfoBox (p=16, radius 20, glass subtle)
    │   ├── Label "Événement" (13px, #6f737c)
    │   └── Value "{headline} — {title}" (16px, semibold)
    ├── QuantitySection
    │   ├── Label "Nombre de billets à générer" (13px, medium, #a7abb3)
    │   └── NumberInput (h=56, px=20, radius 20, type number, min 1, max 1000, default 10)
    ├── AppButton / primary / lg / fullWidth — "Générer {qty} billets"
    └── [GeneratedPreview — conditional, shown after tap]
        └── Container (p=24, radius 28, border rgba(20,140,250,0.30), bg rgba(20,140,250,0.08))
            ├── Label "Aperçu du premier billet"
            ├── MiniQRCode (centred)
            ├── Code text (13px, font-mono, #148cfa)
            └── Count text "… et {qty-1} autres billets générés" (12px, #6f737c)
```

**Interaction:** tap "Générer" → show GeneratedPreview with MiniQRCode of the first code.

---

### Screen: TicketListScreen

**Purpose:** Organizer view of all tickets for a specific event.

**Entry points:** EventDetailScreen FloatingAction "Voir les billets".

**Layout:**
```
TicketListScreen (scrollable, pb: 40)
├── Header (standard pattern)
├── EventSubtitle (px: 20, mb: 16)
│   └── Text "{headline} — {title}" (14px, #a7abb3)
├── StatsRow (grid 3 cols, gap: 12, px: 20, mb: 20)
│   ├── StatCard "Total" (22px bold, #f5f7fa)
│   ├── StatCard "Valides" (22px bold, emerald-400)
│   └── StatCard "Utilisés" (22px bold, #a7abb3)
├── SearchField (px: 20, mb: 16)
├── FilterChips (px: 20, mb: 16, horizontal scroll)
│   └── [Tous / Valides / Utilisés]
└── TicketList (px: 20, gap: 12)
    └── TicketRow × filtered tickets
```

**StatCard:** `p=16, radius=20, bg rgba(255,255,255,0.10), border rgba(255,255,255,0.12), text-center`; value 22 px bold, label 12 px `#6f737c`

**TicketRow:**
```
TicketRow
└── Row (px=16, py=16, radius=20, bg rgba(255,255,255,0.06), border rgba(255,255,255,0.10), spaceBetween)
    ├── Column
    │   ├── Code (14px, font-mono, #f5f7fa)
    │   └── Holder (12px, #6f737c) — "Porteur: {id}" or "Non attribué"
    └── Badge (green/gray)
```

**Mock data for display:** 5 tickets (t1, t2 from MOCK_TICKETS + t3, t4, t5 added locally for event e1).

---

### Screen: MyTicketsScreen

**Purpose:** Holder's personal ticket wallet.

**Entry points:** BottomNav tab 3.

#### Empty state layout
```
MyTicketsScreen (full height, pb: 112)
└── Center
    └── Column (gap: 16)
        ├── IconBox (80×80, radius 28, bg rgba(255,255,255,0.10), border rgba(255,255,255,0.12))
        │   └── TicketSVG (32×32, white)
        ├── Title "Aucun billet" (20px, bold)
        ├── Body (14px, #6f737c, max-width, centered)
        └── CTAButton "Explorer les événements" (h=48, px=24, radius 28, #148cfa) → HomeScreen
```

#### With tickets layout
```
MyTicketsScreen (scrollable, pb: 112)
├── Header (px: 20, pt: 48, pb: 24)
│   ├── Title "Mes billets" (28px, bold, -0.02em)
│   └── Subtitle "{n} billet(s)" (14px, #a7abb3, mt: 4)
└── TicketList (px: 20, gap: 16)
    └── TicketCard × user tickets → TicketDetailScreen
```

**TicketCard:**
```
TicketCard (radius 28, overflow hidden, border white/12, bg rgba(255,255,255,0.08), blur(20px))
└── Column
    ├── ImageStrip (height: 160)
    │   ├── EventImage (full cover)
    │   ├── Gradient overlay (to top)
    │   ├── StatusBadge (top-right, absolute)
    │   └── HeadlineText (bottom-left, absolute, 20px bold, Playfair Display)
    └── DetailsRow (px=16, py=16, border-top dashed white/10, spaceBetween)
        ├── Column
        │   ├── DateTimeText (13px, #a7abb3)
        │   └── LocationText (13px, #6f737c)
        └── Column (right-align)
            ├── Label "Code" (11px, #6f737c, font-mono)
            └── CodeSnippet (last 8 chars of code, 12px, font-mono, #148cfa)
```

---

### Screen: TicketDetailScreen

**Purpose:** Show full QR code for a specific ticket with event context.

**Entry points:** TicketCard tap (MyTicketsScreen), EventDetailScreen bottom bar (holder role).

**Layout:**
```
TicketDetailScreen (scrollable, pb: 40)
├── Header (standard pattern — "Mon billet")
└── Content (px: 20, items: center, gap: 24)
    ├── QRCard (w=full, radius=32, flex-col items-center, p=32, gap=20, glass standard)
    │   ├── TicketQRCode (11×11 grid)
    │   ├── CodeSection
    │   │   ├── Label "Code billet" (11px, #6f737c, uppercase, tracking)
    │   │   └── CodeText (14px, font-mono, #148cfa, semibold)
    │   └── StatusBadge
    └── EventInfoCard (w=full, radius=24, overflow hidden, border white/12, bg rgba(255,255,255,0.08))
        ├── ImageStrip (height: 144)
        │   ├── EventImage (full cover)
        │   ├── Gradient (to top)
        │   └── HeadlineText (bottom-left, 18px bold, Playfair Display)
        └── DetailsGrid (p=16, grid 2 cols, gap: 12)
            ├── DateField
            ├── TimeField
            └── LocationField (col-span 2)
```

**Detail field structure:**
```
Column
├── Label (11px, #6f737c, medium)
└── Value (14px, #f5f7fa, semibold)
```

---

### Screen: ScannerScreen

**Purpose:** Simulated QR code scanning interface for ticket validation. Fullscreen — no AppShell, no BottomNav.

**Entry points:** EventDetailScreen FloatingAction "Scanner".

**Layout:**
```
ScannerScreen (full screen, bg: black, position: relative)
├── FakeCameraBackground (absolute, inset 0)
│   ├── GradientOverlay — linear-gradient(135°, #0a1628 → #0d2040 50% → #080808)
│   └── GridOverlay (40×40 grid, rgba(255,255,255,0.1) lines, opacity 0.1)
├── Header (relative, z: 10, px: 20, pt: 48, pb: 16)
│   ├── BackButton (44×44 glass circle)
│   └── Title "Scanner un billet" (18px, bold, white)
├── Viewfinder (relative, z: 10, flex-1, center)
│   └── ViewfinderFrame (256×256)
│       ├── CornerBrackets × 4 (32×32, 2px border on 2 sides)
│       ├── ScanLine (absolute, animated, idle state only)
│       └── ResultOverlay (absolute, conditional, non-idle)
└── BottomControls (relative, z: 10, px: 20, pb: 40)
    ├── InstructionText (center, 14px, #a7abb3, mb: 20)
    ├── SimulateLabel "Simuler un scan" (center, 11px, #6f737c, mb: 16)
    └── SimulateGrid (grid 2 cols, gap: 12)
        ├── ValidButton "✓ Valide" (h=48, radius=20, emerald glass)
        └── UsedButton "✗ Déjà utilisé" (h=48, radius=20, red glass)
```

**Corner bracket colours by state:**
- Idle: `rgba(255,255,255,0.60)`
- Valid: `#22c55e`
- Used/Invalid: `#ef4444`

**Scan line animation (idle only):**
```
Position: absolute, left: 16, right: 16, height: 2
Background: rgba(20,140,250,0.60), blur glow 0 0 8px rgba(20,140,250,0.60)
Animation: translateY(-60px) → translateY(60px), 2s ease-in-out, infinite, alternate
```

**Result overlay (non-idle):**
```
Container (absolute inset 0, rounded 12, bg: rgba(34,197,94,0.15) or rgba(239,68,68,0.15))
└── Center — emoji ✓ or ✗ (48px)
```

**Result modal (bottom sheet, shown after scan simulation):**
```
Stack (absolute inset 0, z: 20)
├── Scrim (rgba(0,0,0,0.70), blur(4px), tap to dismiss)
└── BottomSheet (absolute bottom 0, w: full, radius-top: 32, p: 32, bg rgba(15,15,20,0.98), blur(28px), border top rgba(255,255,255,0.12))
    ├── IconCircle (80×80, rounded full, valid: rgba(34,197,94,0.20) / invalid: rgba(239,68,68,0.20))
    │   └── Emoji "✓" or "✗" (36px)
    ├── Title (22px, bold, #f5f7fa)
    ├── Body (14px, #a7abb3)
    ├── EventName (13px, #6f737c)
    └── Button "Scanner un autre billet" (fullWidth, h=56, radius=28, #148cfa) → dismiss modal
```

**States:**
- `idle` — scan line animated, corner brackets white, no overlay
- `valid` — corner brackets green, result overlay green, modal shows success
- `used` — corner brackets red, result overlay red, modal shows "Déjà utilisé"

**Scanner states in prototype (wired):** only `valid` and `used` are triggered by simulation buttons. `invalid` state is defined in code but not reachable.

**Flutter implementation notes:**
```
ScannerScreen
└── Scaffold(backgroundColor: Colors.black)
    └── Stack
        ├── FakeCameraBackground
        ├── SafeArea child: Column [Header + Viewfinder + BottomControls]
        └── [Conditional] ResultModalSheet
```

> **Note:** On a real Flutter implementation, replace FakeCameraBackground with `camera` plugin + `CameraPreview`. The viewfinder overlay can be built with `CustomPaint`.

---

### Screen: PrepareOfflineScreen

**Purpose:** Agent downloads ticket data for offline scanning.

**Entry points:** EventDetailScreen FloatingAction "Mode offline".

**Layout:**
```
PrepareOfflineScreen (scrollable, pb: 40)
├── Header (standard — "Mode offline")
└── Content (px: 20, gap: 20)
    ├── EventInfoBox (p=20, radius=24, bg rgba(255,255,255,0.10), border rgba(255,255,255,0.12))
    │   ├── Title "{headline} — {title}" (16px, bold, #f5f7fa, mb: 4)
    │   └── Subtitle "{ticketsSold} billets à télécharger" (13px, #a7abb3)
    └── ActionBox (p=20, radius=24, bg rgba(255,255,255,0.06), border rgba(255,255,255,0.10))
        ├── DescriptionText (14px, #a7abb3, mb: 16)
        ├── Button / primary / lg / fullWidth — "⬇️ Télécharger les billets"
        └── [ProgressSection — conditional, shown during/after download]
            ├── ProgressLabelRow (spaceBetween)
            │   ├── Label "Progression" (13px, #a7abb3)
            │   └── Percent "{progress}%" (13px, #a7abb3)
            ├── ProgressBar (h=8, radius full, bg rgba(255,255,255,0.10))
            │   └── Fill (bg #148cfa, width: progress%, transition 200ms)
            └── [DoneRow — conditional, progress=100]
                └── Row [✓ icon + "Billets téléchargés ! Mode offline actif." (14px, semibold, emerald-400)]
```

**Download simulation:** `Timer.periodic(200ms)`, progress += 10 per tick, stops at 100. Button disabled during download.

---

### Screen: SyncScreen

**Purpose:** Agent uploads offline scan results to the server.

**Entry points:** EventDetailScreen FloatingAction "Synchroniser".

**Layout:**
```
SyncScreen (scrollable, pb: 40)
├── Header (standard — "Synchronisation")
└── Content (px: 20, gap: 20)
    ├── PendingCard (p=24, radius=28, border rgba(20,140,250,0.30), bg rgba(20,140,250,0.08), items: center, gap: 8)
    │   ├── CountText (48px, bold, #148cfa) — "7" or "0" after sync
    │   └── Label "validations en attente" (15px, #a7abb3, medium)
    ├── LastSyncCard (p=20, radius=24, bg rgba(255,255,255,0.06), border rgba(255,255,255,0.10))
    │   └── Row (spaceBetween)
    │       ├── Column
    │       │   ├── Label "Dernière synchronisation" (13px, #6f737c, medium)
    │       │   └── Value "Il y a 2 heures" (15px, #f5f7fa, semibold, mt: 2)
    │       └── StatusDot (12×12, rounded full, synced: #22c55e + glow, else #6f737c)
    ├── Button / primary / lg / fullWidth — "🔄 Synchroniser maintenant"
    └── [SuccessRow — conditional] Row [✓ + "Synchronisation réussie !" (emerald-400)]
```

**Syncing state:** button shows spinner SVG (`animate-spin`) + label "Synchronisation en cours…", disabled.

**After sync:** `pending → 0`, status dot turns emerald with glow (`box-shadow: 0 0 8px #22c55e`), success row appears.

**Hardcoded values in prototype:** pending = 7, last sync = "Il y a 2 heures".

---

### Screen: ProfileScreen

**Purpose:** User profile display with stats and navigation shortcuts.

**Entry points:** BottomNav tab 4, HomeScreen avatar button.

**Layout:**
```
ProfileScreen (scrollable, pb: 112)
├── Header (px: 20, pt: 48, pb: 24)
│   └── Title "Profil" (28px, bold, -0.02em)
├── UserCard (mx: 20, mb: 24, p=24, radius=28, border white/12, glass standard, items: center, gap: 16)
│   ├── Avatar (size: 80)
│   ├── Name (22px, bold, #f5f7fa)
│   └── Email (14px, #a7abb3, mt: 4)
├── StatsRow (grid 3 cols, gap: 12, px: 20, mb: 24)
│   └── StatCard × 3 — Événements / Billets / Validés
├── MenuItems (px: 20, gap: 8, mb: 32)
│   ├── MenuItem "Mes événements créés" 🎪 → EventsScreen
│   └── MenuItem "Mes billets" 🎫 → MyTicketsScreen
└── LogoutButton (px: 20)
    └── AppButton / secondary / lg / fullWidth — "Se déconnecter"
```

**StatCard:** `p=16, radius=20, bg rgba(255,255,255,0.06), border rgba(255,255,255,0.10), text-center`; value 22 px bold `#148cfa`, label 12 px `#6f737c`

**Hardcoded stat values:** Événements: 1, Billets: 2, Validés: 0.

**MenuItem:**
```
Row (px=16, py=16, radius=20, bg rgba(255,255,255,0.06), border rgba(255,255,255,0.10), spaceBetween, scale(0.98) press)
├── Row (gap: 16)
│   ├── Emoji icon (24px)
│   └── Label (15px, medium, #f5f7fa)
└── ChevronRight SVG (20×20, stroke #6f737c)
```

---

## 9. Layout Specifications

### Global constraints
| Property | Value |
|---|---|
| Screen background | `#080808` |
| Safe area top | 48 px from top of content (pt-12 = 48 px) on main headers |
| Horizontal page padding | 20 px (`px-5`) |
| Bottom clearance (with BottomNav) | 112 px (`pb-28`) |
| Bottom clearance (no BottomNav) | 40 px (`pb-10`) |
| Section gap (flex-col) | 20 px (`gap-5`) |
| Card gap (flex-col) | 16 px (`gap-4`) |
| Small item gap | 12 px (`gap-3`) |

### Glass layer reference
| Level | Background | Blur | Border |
|---|---|---|---|
| Subtle (inputs, ticket rows) | `rgba(255,255,255,0.06–0.10)` | none | `rgba(255,255,255,0.10–0.12)` 1 px |
| Standard (cards, BottomNav) | `rgba(255,255,255,0.12)` | 28 px | `rgba(255,255,255,0.14)` 1 px |
| Elevated (auth forms, QR card) | `rgba(255,255,255,0.14)` | 28 px | `rgba(255,255,255,0.16)` 1 px |
| Modal/dark overlay | `rgba(8,8,8,0.82–0.92)` | 16–24 px | `rgba(255,255,255,0.10–0.12)` |

### Border-radius reference
| Element | Radius |
|---|---|
| EventCard, TicketCard, GlassCard | 28–32 px |
| BottomNav container | 38 px |
| Metadata chips, stat cards | 20 px |
| Input fields, textarea | 20 px |
| Category pills, filter chips | Full pill (h/2) |
| Buttons (primary/secondary) | 28 px |
| Back button circles | Full circle |
| Logo icon container | 28 px (splash: 28 px, login: 20 px, homepage: 14 px) |
| Scanner result modal | Top corners 32 px |

### Standard heights
| Element | Height |
|---|---|
| BottomNav | 76 px |
| Button / lg | 56 px |
| Button / md | 48 px |
| Button / sm | 40 px |
| Input field | 56 px |
| Chip / filter | 44 px |
| Chip / category (Home) | 40 px |
| Metadata chip | 56 px |
| NavItem circle | 52 × 52 px |
| Back button | 44 × 44 px |
| Avatar (header) | 44 × 44 px |
| Progress bar | 8 px |

---

## 10. Responsive Behavior

**The prototype targets mobile exclusively.**

Screen widths are not specified in the prototype — the app is designed to fill the available mobile viewport width.

```
Responsive behavior:
Not explicitly defined for tablet or desktop in prototype.
```

**Observed mobile behaviors:**
- All horizontal chip lists use `overflow-x: auto` with hidden scrollbar
- Event cards are full-width minus horizontal padding (stretch)
- Compact EventCard is fixed-width 260 px (horizontal scroll container, not rendered in prototype)
- BottomNav is full-width minus 32 px (16 px each side)
- Grid layouts use fixed column counts (2 or 3), not responsive breakpoints

**Flutter recommendation:**
```
Use LayoutBuilder or MediaQuery only when the prototype explicitly
defines breakpoint behaviour. Otherwise target mobile viewport exclusively.
```

---

## 11. Forms

### Form: LoginScreen

| # | Field | Type | Label | Placeholder | Pre-filled | Required |
|---|---|---|---|---|---|---|
| 1 | email | email | "Email" | — | `alice@demo.com` | Yes |
| 2 | password | password | "Mot de passe" | — | `demo` | Yes |

**Validation trigger:** tap "Se connecter"
**Error display:** text below form `"Email ou mot de passe incorrect"`, 13 px, red-400
**Success action:** navigate to HomeScreen

---

### Form: RegisterScreen

| # | Field | Type | Label |
|---|---|---|---|
| 1 | name | text | "Nom complet" |
| 2 | email | email | "Email" |
| 3 | password | password | "Mot de passe" |

**Validation trigger:** tap "S'inscrire" (always succeeds in prototype — no error state)
**Success action:** navigate to HomeScreen

---

### Form: CreateEditEventScreen (4-step)

**Step 0 — Identité**

| Field | Type | Label | Placeholder | Required |
|---|---|---|---|---|
| imageUrl | image picker | "Image de marque" | — | No |
| title | text | "Titre de l'événement" | "ex : Design Day 2025" | Yes |
| headline | text | "Vedette / Nom principal" | "ex : Beyoncé, PSG vs OM, Jane Smith…" | Yes |
| category | pill selector | (no label) | — | No |
| description | textarea | "Description" | — | No |

**Step 1 — Lieu & Date**

| Field | Type | Label | Required |
|---|---|---|---|
| date | text | "Date" | Yes |
| time | text | "Heure" | No |
| location | text | "Lieu" | Yes |

**Step 2 — Capacité**

| Field | Type | Label | Required |
|---|---|---|---|
| capacity | number | "Capacité totale" | Yes |
| price | number | "Prix par billet (€)" | No |

**Step 3 — Récapitulatif**

Display-only. No input fields.

**Form state object:**
```dart
class EventFormState {
  String imageUrl;
  String title;
  String headline;
  String category;
  String description;
  String date;
  String time;
  String location;
  String capacity;
  String price;
}
```

**Input style (all text inputs):**
```
height: 56, paddingH: 20, borderRadius: 20
background: rgba(255,255,255,0.10)
border: rgba(255,255,255,0.12)
focusBorder: rgba(20,140,250,0.50)
font: 15px, #f5f7fa, placeholder: #6f737c
```

---

## 12. Lists & Repeated Structures

### EventCard List (HomeScreen, EventsScreen)

```
ListView (vertical, gap: 16, padding: h:20, bottom: clearance)
└── EventCard (default variant) × N
    └── Tap → EventDetailScreen
```

**Empty state:** centered text `"Aucun événement trouvé"` (14 px, #6f737c)

---

### TicketCard List (MyTicketsScreen)

```
ListView (vertical, gap: 16, padding: h:20)
└── TicketCard × N
    └── Tap → TicketDetailScreen
```

**Empty state:** full-screen centered column (see §8 MyTicketsScreen empty state)

---

### TicketRow List (TicketListScreen)

```
ListView (vertical, gap: 12, padding: h:20)
└── TicketRow × N (filtered by search + status chip)
```

No tap action on rows in prototype.

---

### ProfileMenu (ProfileScreen)

```
Column (gap: 8)
└── MenuItem × 2
    └── Tap → navigate
```

---

### Category Chips (HomeScreen, CreateEditEventScreen step 0)

```
SingleChildScrollView (horizontal, padding: left:20)
└── Row (gap: 8)
    └── FilterChip × N
```

---

### Brand Presets Grid (CreateEditEventScreen step 0)

```
GridView (crossAxisCount: 4, gap: 8)
└── PresetThumbnail × 8 (aspect-ratio 1:1, radius: 14)
    Selected: 2px solid #148cfa, 2px offset
```

---

### Summary Table (CreateEditEventScreen step 3)

```
Column (border-radius: 24, border: white/12, bg: rgba(255,255,255,0.06))
└── SummaryRow × 8
    └── Row (px:20, py:14, border-bottom: dashed white/6, spaceBetween)
        ├── Label (13px, #6f737c)
        └── Value (14px, #f5f7fa, semibold)
```

---

## 13. Assets

### Event Images (Unsplash)
All images are loaded from Unsplash URLs with `w=800&q=80` parameters.

| Event | Description | URL pattern |
|---|---|---|
| e1 — Kendrick Lamar | Concert stage/crowd | `photo-1493225457124-a3eb161ffa5f` |
| e2 — PSG vs OM | Football/sport | `photo-1489944440615-453fc2b6a9a9` |
| e3 — Paris Design Week | Conference/talk | `photo-1540575467063-178a50c2df87` |
| e4 — Lumières & Matières | Art exhibition | `photo-1578662996442-48f60103fc96` |
| e5 — Stand-up Festival | Comedy performance | `photo-1527224538127-2104bb71c51b` |
| e6 — Cyrano de Bergerac | Theatre stage | `photo-1507676184212-d03ab07a01bf` |

### Brand Preset Images (Unsplash)
8 presets in CreateEditEventPage — Concert, Festival, Sport, Conférence, Théâtre, Exposition, Spectacle, Outdoor.

### Avatar Images (Pravatar)
All avatars from `https://i.pravatar.cc/{size}?img={n}`. IDs used:

| Location | Pravatar img# | Size |
|---|---|---|
| alice@demo.com | 47 | 150 |
| bob@demo.com | 12 | 150 |
| New registered user | 3 | 150 |
| EventDetail organizer row | 47 | 48 px rendered |
| EventDetail hero avatars | 7, 8, 9 | 28 px rendered |
| EventCard default avatars | 14, 15, 16 | 24 px rendered |
| EventCard compact avatars | 21, 22, 23 | 24 px rendered |
| TicketList rows (mock) | varies | 24 px rendered |

### Icons
All icons are inline SVG (stroke-based, no icon library). All use `strokeWidth: 2`, round `linecap` and `linejoin`.

| Icon | Used in | Approximate description |
|---|---|---|
| Ticket | SplashScreen logo, BottomNav tab 2, EventDetailScreen metadata | Rectangle with vertical centre divider |
| House | BottomNav tab 1 | Roof outline + door |
| Credit card | BottomNav tab 3 | Rectangle + horizontal stripe |
| Person | BottomNav tab 4 | Head circle + shoulder arc |
| Magnifier | SearchField | Circle + handle |
| Chevron-left | Back buttons | `< ` angle |
| Chevron-right | ProfileScreen menu rows | `>` angle |
| Share | EventDetailScreen header | Box with arrow pointing up |
| Heart | EventDetailScreen organizer row | Heart outline |
| Plus | EventsScreen FAB | `+` cross |
| Pencil | FloatingAction "Modifier" | Diagonal pen |
| List | FloatingAction "Voir les billets" | 3 horizontal lines |
| Person+ | FloatingAction "Assigner" | Person + plus |
| Camera | FloatingAction "Scanner" | Rectangle + circle |
| Download | FloatingAction "Mode offline" | Down arrow to line |
| Refresh/Sync | FloatingAction "Synchroniser" | Circular arrows |
| Ticket (small) | EventDetailScreen price chip | Same as above, smaller |
| Clock | EventDetailScreen time chip | Circle + clock hands |
| Spinner | SyncScreen loading | Animated circular path (`animate-spin`) |
| Check | PrepareOfflinePage done, SyncPage done | Checkmark `✓` |

---

## 14. Design System Usage

### AppShell
```
AppShell
├── Color → --color-bg (#080808)
└── Gradient → --color-primary (#148cfa) at varying opacities
```

### Button / primary
```
AppButton (primary)
├── Background → --color-primary (#148cfa)
├── Hover → --color-primary-hover (#2a98fb)
├── Pressed → --color-primary-pressed (#0e79dc)
├── Text → white
└── Shadow → primary glow token
```

### Button / secondary
```
AppButton (secondary)
├── Background → Glass standard (rgba white 10%)
├── Border → rgba white 14%
├── Text → --color-text-1
└── Blur → 24px
```

### Badge
```
StatusBadge
├── Colors → Design System badge color tokens (blue/green/red/gray variants)
└── Typography → 12px medium, --font-ui
```

### EventCard
```
EventCard
├── Headline → --font-display (Playfair Display), bold
├── Body text → --color-text-2, --font-ui
├── Price → white, bold, --font-ui
├── Border → rgba --color-primary 15%
└── Button → Button / primary (inline, h=36)
```

### TicketQRCode / MiniQRCode
```
QRCode widgets
├── Background → white (contrast requirement for QR scanning)
├── Cell on-colour → --color-bg (#080808)
└── Container radius → Design System radius tokens (20px/16px)
```

### BottomNav
```
BottomNav
├── Glass → Glass standard level
├── Active item → --color-primary circle
├── Inactive icon → rgba white 70%
└── Typography → --font-ui
```

### FloatingAction (organizer/agent)
```
FloatingAction
├── Primary → --color-primary bg + glow
├── Secondary → Glass standard bg
├── Label pill → Glass modal level
└── Label colour → primary: --color-primary; secondary: --color-text-1
```

---

## 15. Flutter Widget Architecture

### Directory structure recommendation

```
lib/
├── main.dart
├── app.dart                     ← MaterialApp + GoRouter setup
│
├── core/
│   ├── constants/
│   │   ├── colors.dart          ← DS color tokens
│   │   ├── typography.dart      ← DS font tokens
│   │   └── spacing.dart         ← DS radius/spacing constants
│   ├── models/
│   │   ├── event.dart
│   │   └── ticket.dart
│   └── data/
│       └── mock_events.dart
│
├── shared/
│   ├── widgets/
│   │   ├── app_shell.dart
│   │   ├── app_bottom_nav.dart
│   │   ├── app_button.dart
│   │   ├── glass_card.dart
│   │   ├── app_search_field.dart
│   │   ├── filter_chip_widget.dart
│   │   ├── status_badge.dart
│   │   ├── user_avatar.dart
│   │   └── back_button_circle.dart
│   └── qr/
│       ├── ticket_qr_code.dart  ← 11×11 large QR
│       └── mini_qr_code.dart    ← 9×9 small QR
│
└── features/
    ├── auth/
    │   ├── screens/
    │   │   ├── splash_screen.dart
    │   │   ├── login_screen.dart
    │   │   └── register_screen.dart
    │   └── providers/
    │       └── auth_provider.dart
    │
    ├── discovery/
    │   ├── screens/
    │   │   ├── home_screen.dart
    │   │   └── events_screen.dart
    │   └── widgets/
    │       ├── event_card.dart
    │       ├── segmented_control.dart
    │       └── category_chips.dart
    │
    ├── event_detail/
    │   ├── screens/
    │   │   └── event_detail_screen.dart
    │   └── widgets/
    │       ├── floating_action_button_stack.dart
    │       ├── event_hero_image.dart
    │       ├── metadata_chip.dart
    │       └── bottom_cta_bar.dart
    │
    ├── organizer/
    │   ├── screens/
    │   │   ├── create_edit_event_screen.dart
    │   │   ├── generate_tickets_screen.dart
    │   │   └── ticket_list_screen.dart
    │   └── widgets/
    │       ├── step_indicator.dart
    │       ├── brand_picker.dart
    │       └── summary_table.dart
    │
    ├── tickets/
    │   ├── screens/
    │   │   ├── my_tickets_screen.dart
    │   │   └── ticket_detail_screen.dart
    │   └── widgets/
    │       └── ticket_card.dart
    │
    ├── agent/
    │   ├── screens/
    │   │   ├── scanner_screen.dart
    │   │   ├── prepare_offline_screen.dart
    │   │   └── sync_screen.dart
    │   └── widgets/
    │       ├── viewfinder_frame.dart
    │       └── scan_result_modal.dart
    │
    └── profile/
        └── screens/
            └── profile_screen.dart
```

### Widget classification

| Widget | Classification |
|---|---|
| `AppShell`, `AppBottomNav` | Shared — layout |
| `AppButton`, `GlassCard`, `StatusBadge`, `FilterChipWidget`, `AppSearchField`, `UserAvatar`, `BackButtonCircle` | Shared — Design System |
| `TicketQRCode`, `MiniQRCode` | Shared — utility |
| `EventCard` | Shared — feature-crossing |
| `SegmentedControl`, `CategoryChips`, `EventHeroImage`, `MetadataChip`, `FloatingActionButtonStack`, `BottomCtaBar`, `StepIndicator`, `BrandPicker`, `SummaryTable`, `TicketCard`, `ViewfinderFrame`, `ScanResultModal` | Feature-specific |

### Screen → Flutter structural mapping

```
HomeScreen
└── Scaffold (bg: transparent)
    └── AppShell
        └── SafeArea
            └── Stack
                ├── CustomScrollView (slivers)
                │   ├── SliverToBoxAdapter — Header
                │   ├── SliverToBoxAdapter — SegmentedControl
                │   ├── SliverToBoxAdapter — HeroCopy
                │   ├── SliverToBoxAdapter — SearchField
                │   ├── SliverToBoxAdapter — CategoryChips (horizontal scroll)
                │   └── SliverList — EventCard list
                └── AppBottomNav (positioned bottom)

EventDetailScreen
└── Scaffold (bg: transparent)
    └── AppShell
        └── Stack
            ├── CustomScrollView
            │   ├── SliverToBoxAdapter — HeroImage (320px)
            │   └── SliverToBoxAdapter — ContentArea (Column)
            ├── Positioned (top: 0) — FloatingHeader
            └── [Role-dependent]
                ├── Positioned (bottom: 0) — BottomCtaBar (none/holder)
                └── Positioned (right: 16, bottom: 112) — FloatingActionStack (org/agent)

ScannerScreen
└── Scaffold (backgroundColor: Colors.black)
    └── Stack
        ├── FakeCameraBackground (Positioned.fill)
        ├── SafeArea child: Column [Header + Expanded(Viewfinder) + BottomControls]
        └── [Conditional] GestureDetector + BottomSheet overlay

CreateEditEventScreen
└── Scaffold (bg: transparent)
    └── AppShell
        └── SafeArea
            └── Column
                ├── Header (shrink-wrap)
                ├── StepTitle (shrink-wrap)
                ├── Expanded — SingleChildScrollView — active step widget
                └── BottomCTA (shrink-wrap, glass bg)
```

---

## 16. Prototype Inconsistencies

**[Medium]** `pb-28` (112 px bottom clearance) is used on role `none/holder` in EventDetailScreen, while `pb-10` (40 px) is used for `organizer/agent` — correct in intent (organizer/agent use floating buttons that don't overlap) but the logic inverts what one might expect.

**[Medium]** EventDetailScreen header uses `position: absolute` overlaid on the hero image, which means it scrolls out of view when the user scrolls. All other screens use a fixed/sticky sub-screen header pattern. This is intentional per the design but inconsistent with the rest.

**[Low]** CompactEventCard is implemented in EventCard.tsx but never instantiated in any screen. It may be intended for a horizontal scroll discovery section not yet built.

**[Low]** HomeScreen segmented control "Sell" tab has no action wired — tap does nothing except visual state change.

**[Low]** EventDetailScreen "Assigner un agent" FloatingAction has no `onClick` handler — it renders but does nothing on tap.

**[Low]** ScannerScreen exposes an `"invalid"` state in code but neither simulation button triggers it — only `valid` and `used` are reachable.

**[Low]** ProfileScreen stats (Événements: 1, Billets: 2, Validés: 0) are hardcoded and not derived from the mock data or auth state.

**[Low]** Compact EventCard avatar rows use pravatar img 21/22/23, while default EventCard uses 14/15/16 and EventDetail hero uses 7/8/9. These numbers have no semantic meaning — purely placeholder.

---

## 17. Open Questions

- **Responsive layout:** Tablet and desktop behaviours are not defined in the prototype.
- **Real camera integration:** ScannerScreen uses a simulated background. The integration with a device camera (camera plugin, permission handling, camera preview widget) is not defined.
- **QR code reading logic:** The prototype simulates scan results with buttons. The actual barcode/QR decoding implementation is not specified.
- **"Assigner un agent" flow:** The FloatingAction is rendered but leads nowhere. The screen or modal for agent assignment is not prototyped.
- **"Vendre un billet" (Sell) tab:** The HomeScreen "Sell" tab is not implemented — the complete secondary marketplace flow is absent.
- **"Mot de passe oublié ?" flow:** Link is present but no destination screen exists.
- **Real ticket purchase:** The "Obtenir un billet" CTA exists for unauthenticated/visitor users but the purchase flow (payment, confirmation) is not prototyped.
- **Offline data model:** PrepareOfflinePage simulates a download with a progress bar but the actual data format stored locally is not defined.
- **Loading states for API calls:** No screens show a loading skeleton or spinner while data is fetching (all data is synchronous from mock). This will require design decisions for async implementation.
- **Error states for network failures:** Not represented in any screen.
- **EventDetail "share" button:** Rendered but no action wired.
- **Pagination / infinite scroll:** Not defined — event list shows all mock events at once.
- **Push notifications:** Not referenced anywhere in the prototype.
- **Authentication persistence:** The prototype re-authenticates on app launch (starts at SplashScreen → LoginScreen). Session persistence strategy is not defined.

---

## 18. Flutter Implementation Checklist

### Core Infrastructure
- [ ] Configure `go_router` with all 15 routes
- [ ] Implement `AuthProvider` (Provider or Riverpod)
- [ ] Create `EventModel` and `TicketModel` data classes
- [ ] Wire Google Fonts — Inter + Playfair Display
- [ ] Define design token constants (colors, radius, spacing)
- [ ] Build `AppShell` with radial gradient background
- [ ] Build `AppBottomNav` with glass morphism and active state

### Shared Widgets
- [ ] `AppButton` — 4 variants (primary, secondary, ghost, icon) × 3 sizes
- [ ] `GlassCard` — 2 modes (default, elevated)
- [ ] `AppSearchField` with embedded magnifier icon
- [ ] `FilterChipWidget` — active/inactive states
- [ ] `StatusBadge` — 4 colour variants
- [ ] `UserAvatar` — image + initials fallback
- [ ] `BackButtonCircle` — standard back navigation
- [ ] `TicketQRCode` — 11×11 deterministic dot grid
- [ ] `MiniQRCode` — 9×9 deterministic dot grid

### Auth Screens
- [ ] `SplashScreen` — animated logo + 2 s auto-redirect
- [ ] `LoginScreen` — form + error state + demo hint
- [ ] `RegisterScreen` — 3-field form

### Discovery
- [ ] `HomeScreen` — segmented control + search + category chips + event list
- [ ] `EventsScreen` — tabs + search + filter chips + event list + FAB
- [ ] `EventCard` — default variant (compact optional)

### Event Detail
- [ ] `EventDetailScreen` — hero image + floating header + content + role-dependent CTAs
- [ ] Role detection logic (`USER_ROLES` map equivalent)
- [ ] `FloatingActionButtonStack` — organizer (4 actions) + agent (3 actions)
- [ ] `BottomCtaBar` — holder/none glass bar

### Organizer Tools
- [ ] `CreateEditEventScreen` — 4-step form with `StepIndicator`
- [ ] `StepIdentity` — image picker + text inputs + category pills
- [ ] `StepDateTime` — 3 text inputs
- [ ] `StepCapacity` — 2 number inputs + info box
- [ ] `StepSummary` — preview + summary table
- [ ] `GenerateTicketsScreen` — quantity input + generated preview
- [ ] `TicketListScreen` — stats + search + filter chips + ticket rows

### Holder Tickets
- [ ] `MyTicketsScreen` — empty state + ticket card list
- [ ] `TicketCard` — image strip + status badge + details row
- [ ] `TicketDetailScreen` — QR card + event info card

### Agent Tools
- [ ] `ScannerScreen` — fullscreen camera placeholder + viewfinder + simulation buttons
- [ ] `ScanResultModal` — bottom sheet overlay (valid/used states)
- [ ] `PrepareOfflineScreen` — download simulation with progress bar
- [ ] `SyncScreen` — pending count + sync button + status dot

### Profile
- [ ] `ProfileScreen` — user card + stats + menu items + logout

### States & Interactions
- [ ] Scale press animations on all tappable elements
- [ ] FloatingAction label pill reveal (long-press on mobile, hover on web)
- [ ] ScannerScreen corner bracket colour transitions (300 ms)
- [ ] PrepareOfflinePage progress bar timer simulation
- [ ] SyncScreen spinner + completion transition
- [ ] CreateEditEventScreen step indicator animated width transition
- [ ] CreateEditEventScreen success state (emerald confirmation row)