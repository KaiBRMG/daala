# CLAUDE.md — Daala (Phase 1)

Daala is a two-sided gig marketplace: a unified, single-application ecosystem on Android and iOS with a lightweight SEO website. Every user has **one account** that can act as either a **Consumer** (buys services) or a **Merchant** (sells services) — the app deliberately blurs the line so people cycle between both sides. Mission: mobilise South Africa's informal economy and give unemployed youth and tradespeople an income and skill-growth ladder.

**You are building the Phase 1 skeleton frontend.**

---

## ⭐ Source of truth

- **[DESIGN.md](DESIGN.md) is the authoritative frontend blueprint** — design tokens (§1.2), navigation/route map (§2), and an exact per-screen spec (§3) with the required widget tree, data fields, and states for every screen. **Treat it as a contract, not inspiration.**
- **This file (CLAUDE.md) is the operating contract**: stack decisions, conventions, and the non-negotiable rules. Where the two overlap, they agree; DESIGN.md holds the exhaustive detail. **Read DESIGN.md before generating any screen.**

---

## Stack (fixed — do not substitute)

| Concern | Choice | Notes |
|---|---|---|
| UI framework | **Flutter (Dart, stable)** | Single codebase, Android + iOS. Never React/Next. |
| State | **Riverpod** (`flutter_riverpod`) | All screen state via providers; providers return **mock repositories** in Phase 1. |
| Navigation | **GoRouter** (`go_router`) | Named/declarative routes per DESIGN.md §2.3. Deep-link ready (needed later for TradeSafe). |
| Components | **Bespoke, token-driven** | Build `DaalaButton`/`DaalaCard`/`DaalaInput`/badges/etc. from `core/theme/tokens.dart` exactly per DESIGN.md §1.2. |
| Data | **In-memory mock + bundled JSON/asset fixtures** | Repository *interfaces* in `domain/`, `Mock*` impls in `data/` behind a **300–800 ms** artificial delay to exercise loading states. |

**pubspec reconciliation (do this first):**
- `pubspec.yaml` currently has **neither `flutter_riverpod` nor `go_router` — add them.**
- `firebase_*` and `sentry_flutter` are present for **later phases**. In Phase 1 they must **not** be imported, initialised, or called. Replace the default counter `main.dart` with a `ProviderScope` + GoRouter bootstrap **without** Firebase init.
- Avoid network image loading (defer `cached_network_image`); use `Image.asset` for mock media or a token-coloured placeholder box.

---

## Folder Structure (feature-first, per DESIGN.md)

```
lib/
├── main.dart                     # ProviderScope + GoRouter bootstrap (no Firebase in Phase 1)
├── core/
│   ├── theme/                    # tokens.dart (single source of truth) → ThemeData
│   ├── router/                   # GoRouter config + route names (DESIGN.md §2.3)
│   ├── widgets/                  # cross-feature UI: GigCard, DaalaBottomNav, StatusBadge,
│   │                             #   DaalaButton/Input/Card, Shimmer, EmptyState, ErrorState, MapPlaceholder
│   ├── models/                   # cross-feature domain types + enums (lifecycle, Money, Poster summary)
│   ├── mock/                     # shared in-memory fixtures used across features
│   └── utils/                    # formatZar(), date helpers, artificial-delay helper
└── features/
    └── <feature>/
        ├── presentation/         # screens + widgets (read providers only)
        ├── application/          # providers / notifiers (screen state)
        ├── domain/               # models + repository INTERFACES
        └── data/                 # Mock* repository implementations + fixtures
```

- **No `lib/shared/`, no `lib/app/`** — the existing empty `lib/app/*` files are superseded by `core/`.
- One feature per folder. **No cross-feature imports** — share only through `core/`.

**Feature folders (each owns the screens noted):**
| Feature | Screens |
|---|---|
| `auth` | Splash, Onboarding, Intent Select, Sign Up, Log In, OTP, Verify Identity (KYC prompt) |
| `discovery` | Home/Discovery (feed⇄map toggle), Search & Filter, MapPlaceholder |
| `gig_request` | Gig Request Detail, Create Gig Request Wizard, Make an Offer, Review Offers |
| `gig_post` | Gig Post Detail, Create Gig Post Wizard |
| `booking` | Booking/Escrow Status, Evidence Upload, Leave Review |
| `dashboard` | Dashboard / My Gigs |
| `messaging` | Messages list, Chat Thread |
| `profile` | Own Profile, Settings, Notifications, Public Merchant Profile |
| `wallet` | Wallet (balance, escrow held, transactions) |

---

## Domain Terminology (use these exact terms in code, variables, comments, routes, badges)

| Term | Definition |
|---|---|
| **Consumer** | The buyer who needs a task done |
| **Merchant** | The service provider |
| **Gig Post** | Listing created *by a Merchant* advertising their services |
| **Gig Request** | Listing created *by a Consumer* for a task they need done |
| **Offer** | A Merchant's bid on a Gig Request |
| **Booking** | A confirmed engagement (Consumer accepts an Offer, or books a Gig Post) |
| **Escrow** | Funds held securely by the platform while work is carried out |
| **Dispute** | A raised conflict that freezes escrowed funds pending resolution |
| **Wallet** | A user's balance view: available funds + funds held in Escrow |
| **Verification badge** | Trust marker unlocked by ID verification (KYC mocked in Phase 1) |
| **Category** | Gig category (Plumbing, Electrical, Gardening, Tutoring, Cleaning, Moving, …) with an **"Other/Custom"** fallback |

**Never** rename these to generic marketplace words (job/task/listing/seller/buyer/payment).

### Lifecycle enum (drives every status badge — verbatim, from DESIGN.md §2.4)
```
Gig Request:  OPEN → OFFER_ACCEPTED → IN_ESCROW → IN_PROGRESS → COMPLETED
              (+ EXPIRED, CANCELLED, DISPUTED → RESOLVED)
Gig Post:     ACTIVE → BOOKED → IN_ESCROW → IN_PROGRESS → COMPLETED
              (+ PAUSED, CANCELLED, DISPUTED → RESOLVED)
```
Same enum will later back Firestore — keep it clean.

---

## Conventions

- `camelCase` variables/functions · `PascalCase` classes/enums.
- **No business logic in widgets** — widgets read providers only; logic lives in `application/` notifiers and `domain/` repositories.
- **Every** colour, spacing, radius, elevation, and text style references a token from `core/theme/tokens.dart` — **never a hard-coded hex or magic number.**
- All currency is **ZAR** via a single `formatZar()` util (`R1 250`, `R450`, `R37.50`) — never hand-format inline. Store money as integer **minor units** (`*ZarMinor`).
- Mock fixtures live in a feature's `data/` (or `core/mock/` if cross-feature) — never inline in widgets or providers.
- One feature per folder; no cross-feature imports except through `core/`.
- Where DESIGN.md genuinely leaves a detail unspecified, pick the **most minimal, token-consistent** option and leave a `// TODO(spec):` comment — do not invent product behaviour.

---

## Performance (hard requirements — entry-level Android, data-light)

Target: iOS, Android 6.0+, ~2 GB RAM, expensive mobile data.
- `const` constructors everywhere possible.
- Long lists via `ListView.builder` / `SliverList` — **never** map a full list into a `Column`.
- **1 px borders over drop shadows** for cards. Shadows only on sheets/sticky bars/dialogs.
- No heavy or continuous animations; transitions ≤ 250 ms. Shimmer = lightweight opacity/gradient sweep, not a per-pixel effect.
- Images: fixed aspect boxes, lazy-loaded, compressed mock assets. Never lay out around unbounded intrinsic image sizes.

---

## Rules — no exceptions

1. **Zero API calls.** No Firebase (Auth/Firestore/Storage), no TradeSafe, VerifyNow, Google Maps, Sentry, or any network. Render `MapPlaceholder` wherever a map is specified.
2. **All data is mock**, served through repository *interfaces* (`domain/`) with `Mock*` impls (`data/`) behind a 300–800 ms delay, exposed via Riverpod providers.
3. **Every screen implements all three states** — loading (shimmer matching the real silhouette), empty, error — per DESIGN.md's "Global state conventions" (§3). Copy is specified per screen.
4. **Tokens only** — derive one `ThemeData` from `core/theme/tokens.dart`; no inline hex or magic numbers anywhere.
5. **Fixed vocabulary + lifecycle enum verbatim** in class names, routes, and badge labels.
6. **Bespoke token components only** — build UI primitives from `core/theme/tokens.dart`, not a third-party component library.
7. **Build exactly what DESIGN.md specifies** — do not add screens, fields, flows, animations, theming, or "nice-to-have" polish it does not describe. Fidelity to spec outranks creativity.
8. Follow the Stack, Folder Structure, Conventions, and Performance rules above without deviation.

Deliverable: a clean, modular, **compile-ready** skeleton a human can extend phase by phase.

---

## Build / run

```bash
flutter pub add flutter_riverpod go_router   # if not yet in pubspec
flutter pub get
flutter analyze
flutter run
```

---

## Development roadmap

*Currently in **Phase 1**. Firebase deps are pre-added for later phases but must not be used yet.*

### Phase 1 — Skeleton Frontend ← current
- ~25 screens with mock data · GoRouter + Riverpod setup · feature-first structure · **zero API calls** · see **DESIGN.md**.

### Phase 2 — Auth & Onboarding
- Firebase Auth wired; real login/register/onboarding replaces mock screens.

### Phase 3 — Gig Posting Wizards 
- Gig Post + Gig Request wizards → Firestore; category-specific fields; media selection placeholders.

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
