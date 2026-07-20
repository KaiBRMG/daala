# CLAUDE.md — Daala (Phase 1)

Daala is a two-sided gig marketplace: a unified, single-application ecosystem on Android and iOS with a lightweight SEO website. Every user has **one account** that can act as either a **Consumer** (needs a task done) or a **Merchant** (does the work) — the app deliberately blurs the line so people cycle between earning and spending. Mission: mobilise South Africa's informal economy and give unemployed youth and tradespeople an income and skill-growth ladder.

**You are building the Phase 1 skeleton frontend** — the visual, navigable shell with mock data and zero backend.

---

## ⭐ Source of truth

- **[DESIGN.md](DESIGN.md) is the authoritative visual blueprint** — it documents the imported **"Groundwork" Khaki** design (Creative North Star: *"The Sunlit Trade Stall"*): design tokens, colour rules, typography, elevation, and the component vocabulary the screens are built from. **Treat its tokens and named rules as a contract.**
- **This file (CLAUDE.md) is the operating contract**: stack decisions, folder conventions, and the non-negotiable rules. Where the two overlap they agree; DESIGN.md holds the exhaustive visual detail. **Read DESIGN.md before generating or editing any screen.**
- The design was imported from a Claude Design project and **transcribed 1:1 into `lib/theme/app_theme.dart`** — that theme file is the machine source of the tokens DESIGN.md describes.

---

## Stack (fixed — do not substitute)

| Concern | Choice | Notes |
|---|---|---|
| UI framework | **Flutter (Dart, stable)** | Single codebase, Android + iOS. Never React/Next. |
| State | **Riverpod** (`flutter_riverpod`) | App is wrapped in `ProviderScope`. As screens gain real state, lift it into providers; keep it out of widget internals. |
| Navigation | **GoRouter** (`go_router`) | Declarative routes in `lib/router.dart`; a `StatefulShellRoute` drives the four primary tabs. Deep-link ready (needed later for TradeSafe). |
| Typography | **`google_fonts`** | Plus Jakarta Sans, loaded via `google_fonts`. In Phase 1 this fetches once at runtime; bundle the font as an asset before ship. |
| Components | **Bespoke, token-driven** | Build `GwCard`/`TagPill`/`RoundIconButton`/etc. from `lib/theme/app_theme.dart` — never a third-party component library. |
| Data | **In-memory mock** | Screens render hard-coded fixtures inline. No repositories or network in Phase 1. |

**Dependency notes:**
- `firebase_*` and `sentry_flutter` are present in `pubspec.yaml` for **later phases**. In Phase 1 they must **not** be imported, initialised, or called. `main.dart` is a `ProviderScope` + `MaterialApp.router` bootstrap with **no Firebase init**.
- Avoid network image loading (defer `cached_network_image`); use `Image.asset` for real assets (e.g. the logo) or the token-coloured `PhotoPlaceholder` box for mock media.

---

## Folder Structure (actual)

```
lib/
├── main.dart                 # ProviderScope + MaterialApp.router (no Firebase in Phase 1)
├── router.dart               # GoRouter: StatefulShellRoute (4 tabs) + pushed/modal routes
├── theme/
│   └── app_theme.dart        # AppColors / AppRadius / AppShadows / AppText → buildAppTheme()
├── widgets/
│   ├── app_shell.dart        # Floating pill nav + central Post FAB speed-dial
│   └── ui.dart               # Cross-screen primitives: GwCard, TagPill, RoundIconButton,
│                             #   InitialsAvatar, PhotoPlaceholder, StatusBar
└── screens/                  # One file per screen (see table below)
```

- The old `lib/core/` + `lib/features/<feature>/{presentation,application,domain,data}` tree is **retired.** Do not reintroduce it. This build is flat and screen-first.
- Shared UI lives in `lib/widgets/`; shared tokens/theme in `lib/theme/`. Keep new cross-screen primitives there rather than duplicating them per screen.

**Screens (in `lib/screens/`):**
| Screen | Route | Purpose |
|---|---|---|
| `home_screen` | `/home` (tab) | Earn⇄Browse toggle, nearby gigs, stats, categories |
| `my_gigs_screen` | `/my-gigs` (tab) | The user's own gigs |
| `inbox_screen` | `/inbox` (tab) | Messages |
| `profile_screen` | `/profile` (tab) | Own profile |
| `browse_screen` | `/browse` | Search / discovery |
| `gig_detail_screen` | `/gig` | A single gig, poster, payout, Apply |
| `post_gig_screen` | `/post/:kind` | Create a gig (kind = service / request / media) |
| `wallet_screen` | `/wallet` | Balance, transactions, payment methods |
| `booking_edit_screen` | `/booking/edit` | Modal sheet: edit a booking |

Primary navigation is a **floating pill tab bar** (`app_shell.dart`): Home · My Gigs · **[+]** · Inbox · Profile, where the central orange FAB opens a Post speed-dial.

---

## Domain terminology

The product is a two-sided marketplace where one account both **earns** (as a Merchant/tasker) and **hires** (as a Consumer). Use these concepts consistently in code and structure:

| Concept | Meaning |
|---|---|
| **Gig** | The unit of work — the thing browsed, posted, applied to, and booked. |
| **Consumer** | The person who needs a task done (hires). |
| **Merchant / tasker / helper** | The person who does the work (earns). |
| **Offer / Apply** | A merchant's bid to do a gig. |
| **Booking** | A confirmed engagement between the two sides. |
| **Escrow** | Funds held safely by the platform while work is carried out. |
| **Wallet** | Balance view: available funds + funds held in escrow. |
| **Verification badge** | Trust marker unlocked by ID verification (KYC mocked in Phase 1). |
| **Category** | Home & Garden, Delivery & Errands, Moving & Hauling, Design & Creative, Cleaning, Handyman, … plus an "Other/Custom" fallback. |

**Voice — friendly, not clinical.** User-facing copy is warm and plain ("Earn Moola", "Browse Gigs", "Apply Now", "Get Help", "tasker", "helper") — this matches the design and the varied-literacy audience. There is **no strict fixed-vocabulary rule** on UI strings. Keep code identifiers clear and consistent (`Gig`, `Booking`, `Wallet`), but do not force marketing copy into a rigid taxonomy.

**Lifecycle (drives status where shown).** A gig moves through visible states — roughly `OPEN → OFFER_ACCEPTED → IN_ESCROW → IN_PROGRESS → COMPLETED` (plus `EXPIRED / CANCELLED / DISPUTED → RESOLVED`). Keep any enum backing this clean; the same states will later back Firestore. Trust cues (status, escrow, verification) are first-class UI, never fine print.

---

## Conventions

- `camelCase` variables/functions · `PascalCase` classes/enums · `_privateWidgetHelpers` for screen-local sub-widgets (the established pattern).
- **Tokens only.** Every colour, radius, shadow, and text style comes from `lib/theme/app_theme.dart` (`AppColors` / `AppRadius` / `AppShadows` / `AppText`) — **never a raw hex or magic number in a screen.** If a value is missing, add it to the tokens, don't inline it.
- **Currency is ZAR.** All money is South African Rand, formatted through a single shared helper (`R1 250`, `R450`, `R37.50`), stored as integer **minor units** (`*ZarMinor`). ⚠️ The current mock screens still carry `$`/USD and Australian placeholder content (e.g. "Fitzroy VIC") inherited from the design template — **treat these as placeholders to migrate to `R` + South African locations.** Add the formatter when wiring the first real amount.
- **Keep business logic thin in widgets.** Inline mock fixtures are fine for the Phase 1 skeleton, but as real data lands, lift it into Riverpod providers rather than growing `setState` logic inside screens.
- Shared primitives live in `lib/widgets/`; shared tokens in `lib/theme/`. No duplicated card/pill/button implementations per screen.
- Where DESIGN.md leaves a detail unspecified, pick the **most minimal, token-consistent** option and leave a `// TODO(spec):` comment — do not invent product behaviour.

---

## Performance (hard requirements — entry-level Android, data-light)

Target: iOS, Android 6.0+, ~2 GB RAM, expensive mobile data, bright-daylight use.
- `const` constructors everywhere possible (the screens already do this heavily — keep it up).
- Long/variable lists via `ListView.builder` / `ListView.separated` / `GridView.builder` — **never** map a large list into a `Column`.
- **Soft ambient shadows are the deliberate elevation language** (see DESIGN.md §4) — cards lift on shadows, not 1px borders. Keep shadow opacities low (≤12%) and reuse the `AppShadows` tokens; do not invent new heavier shadows.
- No heavy or continuous animation; transitions ≤ 250 ms and convey state only (tab change, sheet slide, FAB expand).
- Images: fixed aspect boxes, lazy-loaded, compressed assets. Use `PhotoPlaceholder` for mock media; never lay out around unbounded intrinsic image sizes.

---

## Rules — no exceptions

1. **Zero API calls.** No Firebase (Auth/Firestore/Storage), no TradeSafe, VerifyNow, Google Maps, or Sentry, and no other network in Phase 1. Use a token-coloured placeholder wherever a map or remote image is specified.
2. **All data is mock** — inline fixtures in Phase 1; lift into Riverpod providers as state grows. No repositories calling out to a network.
3. **Tokens only** — one `ThemeData` from `lib/theme/app_theme.dart`; no inline hex or magic numbers anywhere.
4. **Bespoke token components only** — build UI primitives from the theme, not a third-party component library.
5. **Currency is ZAR** through the shared formatter; migrate the design's `$`/placeholder content to `R` + South African context.
6. **Honour DESIGN.md's named rules** — The One Orange Rule, The Green Money Rule, The Warm-Never-White Rule, The Cushioned-Card Rule. Trust is the interface: surface people, status, and protected-money cues; never build the spammy classifieds wall.
7. **Build to spec** — implement what DESIGN.md and this file describe; don't add screens, flows, theming, or "nice-to-have" polish beyond it. Fidelity to spec outranks creativity.
8. Follow the Stack, Folder Structure, Conventions, and Performance rules above without deviation.

Deliverable: a clean, modular, **compile-ready** skeleton a human can extend phase by phase.

---

## Build / run

```bash
flutter pub get
flutter analyze
flutter run
```

---

## Development roadmap

*Currently in **Phase 1**. Firebase deps are pre-added for later phases but must not be used yet.*

### Phase 1 — Skeleton Frontend ← current
- Navigable screens with mock data · GoRouter + `ProviderScope` bootstrap · flat screen-first structure · token-driven bespoke components · **zero API calls** · see **DESIGN.md**.

### Phase 2 — Auth & Onboarding
- Firebase Auth wired; real login/register/onboarding.

### Phase 3 — Gig Posting Wizards
- Gig Post + Gig Request creation → Firestore; category-specific fields; media selection placeholders.

### Phase 4 — Gig Management & Dashboard
- Firestore models for gigs/offers; full lifecycle state machine; real-time dashboard via streams; offer/bidding + booking with atomic transactions.
- ⚠️ Submit TradeSafe Go-Live approval at end of this phase (4–8 week review before go-live).

### Phase 5 — Messaging & Media
- Firestore-backed real-time chat; Firebase Storage uploads (profiles + gig listings).

### Phase 6 — Maps Integration
- Google Maps Flutter package; map-based discovery, live gig pins, category filters, address autocomplete.

### Phase 7 — TradeSafe Escrow ⚠️ Highest risk
- OAuth2, wallet flow, escrow (fund → hold → release/refund/split), dispute triggers, deep links for redirect checkout.
- ⚠️ Decide `app.daala.co.za` (dedicated subdomain, recommended) vs `daala.co.za` for App/Universal Links + OAuth redirect verification before wiring deep links.

### Phase 8 — VerifyNow KYC
- REST integration; SA ID verification → verification badge; POPIA-compliant — no PII persisted locally.

### Phase 9 — Polish, Monitoring & QA
- Sentry + Firebase Crashlytics wired; entry-level Android perf testing; data-light optimisation; store submission prep.
