# Daala — DESIGN.md

> **Document type:** Machine-interpretable frontend blueprint.
> **Scope:** Phase 1 skeleton (all screens rendered with **mock data, zero API calls**).
> **Purpose:** A definitive, unambiguous specification an implementation LLM can ingest to
> generate the Flutter frontend skeleton perfectly, with no guesswork and no invented UX.
>
> **Design synthesis rule (read first):**
> - **Business logic & information architecture** derive from **AirTasker** (post → offer/bid → book → escrow → complete → review).
> - **Visual aesthetic** derives from the **ANZ Plus** app: clean, high-contrast, secure, modern, intentional whitespace, flat cards with thin borders, big bold figures, restrained navigation.
> - **"ANZ aesthetic" means ANZ's *structure and discipline*, rendered in *Daala's own brand palette*** (Deep Green / Vibrant Orange / Khaki). Do **not** use ANZ's blue. Do **not** copy AirTasker's colours. The look = ANZ layout system × Daala colours.
>
> **Fixed domain vocabulary (never substitute generic words):**
> `Consumer` · `Merchant` · `Gig Post` · `Gig Request` · `Offer` · `Booking` · `Escrow` · `Dispute`.
> A **Consumer** buys services; a **Merchant** sells them. A **Gig Post** is a Merchant-led listing. A **Gig Request** is a Consumer-led listing. A **Merchant** submits an **Offer** on a **Gig Request**; a **Consumer** creates a **Booking** by accepting an **Offer** or booking a **Gig Post**. Funds are held in **Escrow**; conflicts are raised as a **Dispute**.

---

## 1. System Overview & Tech Stack

### 1.1 Frontend stack (fixed)

| Concern | Choice | Notes |
|---|---|---|
| UI framework | **Flutter (Dart, stable channel)** | Single codebase, Android + iOS; renders well on entry-level Android. Do **not** substitute React/Next — the whole project is Flutter. |
| State management | **Riverpod** (`flutter_riverpod`, code-gen optional) | All screen state via providers. Phase 1 providers return **mock repositories**. |
| Navigation | **GoRouter** | Declarative routes, deep-link ready (needed later for TradeSafe redirect). See §2.3 route table. |
| Project structure | **Feature-first** | `lib/features/<feature>/{presentation,application,domain,data}` + `lib/core/{theme,widgets,router,utils}`. |
| Local mock data | In-memory + bundled JSON assets | No Firebase/network calls in Phase 1. Repositories are interfaces with `Mock*` implementations behind a 300–800 ms artificial delay to exercise loading states. |
| Images | `cached_network_image` for remote; `Image.asset` for mock portfolios | Always provide `placeholder` (shimmer) + `errorWidget`. |
| Icons | Single outline set — **Material Symbols Rounded (Outlined)** or a Lucide/Feather-equivalent | 24 px grid, ~2 px stroke, rounded caps. One set only. |

**Performance constraints (entry-level Android, data-light — treat as hard requirements):**
- Prefer `const` constructors everywhere possible; build lists with `ListView.builder` / `SliverList` (never map a full list into a `Column`).
- Prefer **1 px borders over drop shadows** for card separation (cheaper to raster; also the ANZ look). Reserve shadows for sheets/modals only.
- No heavy or continuous animations. Transitions ≤ 250 ms. Skeleton shimmer must be a lightweight opacity/gradient sweep, not a per-pixel effect.
- Images: fixed aspect boxes, lazy-loaded, compressed mock assets. Never lay out around unbounded intrinsic image sizes.
- Currency is **ZAR**, formatted `R` + space-grouped thousands, e.g. `R1 250`, `R450`, `R37.50`. Provide one `formatZar()` util; never hand-format inline.

### 1.2 Global design tokens

Emit these as a single source of truth (`core/theme/tokens.dart`) and derive `ThemeData` from them. All values below are literal.

#### Colour tokens

**Brand**

| Token | Hex | Usage |
|---|---|---|
| `brand.green.900` | `#003716` | Primary brand. Primary button fill, active nav, brand headers, key emphasis. |
| `brand.green.700` | `#0A5A2A` | Pressed/hover of primary; secondary green accents. |
| `brand.green.50`  | `#E7EFE9` | Green tint surfaces (selected chips, verified badge bg, subtle brand panels). |
| `accent.orange.500` | `#FF823A` | **Attention accent only:** notification dots, unread badges, "NEW"/offer-count tags, active filter indicator, center Post FAB. Used sparingly — it must *pop*. |
| `accent.orange.600` | `#E86F28` | Pressed state of orange elements. |
| `accent.orange.50` | `#FFF1E8` | Orange tint (highlight rows, "action needed" banners). |
| `surface.cream` | `#F5F5DC` | Khaki/cream warm surface for occasional hero/brand moments and grouped section backgrounds. Use deliberately, not as the default page bg. |

> **CTA colour rule:** Primary action buttons are **Deep Green fill, white text** (ANZ-style confident dark button). **Orange is never the default button fill** — it is reserved for attention signals and the single center Post FAB. This keeps orange's "pop against white" quality that the brand explicitly values.

**Neutrals / ink / structure**

| Token | Hex | Usage |
|---|---|---|
| `bg.primary` | `#FFFFFF` | Default page background. |
| `bg.secondary` | `#FAF9F5` | Grouped/section background (warm off-white), input fills. |
| `ink.900` | `#14231A` | Primary text / headings (near-black, green undertone). |
| `ink.700` | `#3D4A42` | Body secondary text. |
| `ink.500` | `#6B7770` | Muted labels, captions, metadata, placeholders-as-label. |
| `ink.300` | `#A9B2AC` | Disabled text, input placeholder, empty icons. |
| `border.subtle` | `#EDEEEA` | Hairline dividers between list rows. |
| `border.default` | `#D9DDD5` | Card borders, input borders (rest state). |
| `overlay.scrim` | `rgba(20,35,26,0.45)` | Modal/bottom-sheet scrim. |

**Semantic / status** (drives all status badges — see §2.4 lifecycle)

| Token | Hex | Meaning |
|---|---|---|
| `status.open` | `#2B6CB0` (bg `#E9F1FA`) | Gig Request OPEN / Gig Post ACTIVE — accepting activity. |
| `status.pending` | `#B7791F` (bg `#FDF3E2`) | Offer pending / awaiting action. |
| `status.escrow` | `#0E7C7B` (bg `#E3F2F1`) | Funds held in **Escrow** (distinct trust-teal). |
| `status.progress` | `#3A6EA5` (bg `#EAF0F7`) | In progress. |
| `status.success` | `#1E7A46` (bg `#E7F2EC`) | Completed / funds released. |
| `status.dispute` | `#C0392B` (bg `#FBEAE8`) | **Dispute** raised. |
| `status.neutral` | `#6B7770` (bg `#F0F1ED`) | Cancelled / expired / draft. |

#### Typography scale

System-first for byte-savings; if bundling, use **Inter**. Weights: 400 / 500 / 600 / 700.

| Token | Size / Line | Weight | Usage |
|---|---|---|---|
| `display` | 32 / 40 | 700 | Rare hero numbers, onboarding. |
| `h1` | 28 / 36 | 700 | Screen titles (large). |
| `h2` | 24 / 32 | 600 | Section headers. |
| `h3` | 20 / 28 | 600 | Card/subsection titles. |
| `title` | 17 / 24 | 600 | List item titles, dialog titles. |
| `bodyLg` | 16 / 24 | 400 | Primary reading text. |
| `body` | 15 / 22 | 400 | Default body / descriptions. |
| `label` | 14 / 20 | 500 | Buttons, input labels, tabs. |
| `caption` | 13 / 18 | 400 | Metadata, timestamps, helper text. |
| `overline` | 11 / 16 | 600 | Uppercase micro-labels, badge text (letter-spacing 0.4). |
| `moneyLg` | 28 / 34 | 700 | Budget/price hero on detail screens. |
| `moneyMd` | 20 / 26 | 700 | Price on cards, offer amounts. |

#### Spacing, radius, elevation, targets

| Group | Tokens |
|---|---|
| Spacing (4 pt base) | `s2=2 · s4=4 · s8=8 · s12=12 · s16=16 · s20=20 · s24=24 · s32=32 · s40=40 · s48=48`. Screen horizontal padding = **`s16`**; section gap = **`s24`**. |
| Radius | `rSm=8 · rMd=12 (inputs, chips) · rLg=16 (cards) · rXl=20 (sheets, hero) · rPill=999 (primary buttons, filter chips, avatars)`. |
| Elevation | `e0` = flat + `border.default`; `e1` = `0 1 2 rgba(20,35,26,.06)` (raised card, rare); `e2` = `0 2 8 rgba(20,35,26,.08)` (sticky CTA bar); `e3` = `0 8 24 rgba(20,35,26,.12)` (bottom sheet / dialog). Default cards use **e0 (border), not shadow**. |
| Touch targets | Min interactive **48 × 48**. Primary button height **52**. Input height **52**. Icon button hit-box **48**. |
| Motion | Durations `fast=150ms · base=200ms · slow=250ms`; easing `standard = cubic(0.2, 0, 0, 1)`. Page transitions use platform default. |

#### Core component styling (the "ANZ look")

- **Primary button:** fill `brand.green.900`, text white `label`, height 52, radius `rPill`, full-width in flows; pressed → `brand.green.700`; disabled → fill `border.default`, text `ink.300`.
- **Secondary button:** transparent fill, 1.5 px `brand.green.900` border, green text, radius `rPill`.
- **Tertiary/text button:** green `label` text, no border, 48 hit-box.
- **Destructive:** used only for Dispute/Cancel — text or fill `status.dispute`.
- **Filter chip:** pill, rest = `bg.secondary` fill + `border.default` + `ink.700` text; selected = `brand.green.900` fill + white text; a chip carrying a count uses an `accent.orange.500` numeric badge.
- **Input:** fill `bg.secondary`, 1 px `border.default`, radius `rMd`, height 52, static top `label` (13, `ink.500`), placeholder `ink.300`; focus → 1.5 px `brand.green.900`; error → 1.5 px `status.dispute` + caption helper in `status.dispute`.
- **Card:** `bg.primary`, radius `rLg`, 1 px `border.default` (e0), padding `s16`. No shadow unless it's a floating/sticky element.
- **Status badge:** pill, `overline` text, fg + bg per §1.2 semantic pair, padding `s4 s8`.
- **List row:** min height 64, leading tinted-circle icon (40, `brand.green.50` bg) or 44 avatar, `title` + `caption` subtitle stack, optional trailing value/chevron, hairline `border.subtle` divider.
- **Avatar:** `rPill`, sizes 24/32/44/64; fallback = initials on `brand.green.50`.
- **App bar:** `bg.primary`, no shadow, `h1`/`title` leading title, optional back chevron, trailing icon actions (notification bell carries orange dot when unread).

---

## 2. Information Architecture & Navigation Map

### 2.1 Navigation tree

```
Daala (unified account — a user can act as both Consumer and Merchant)
│
├─ AUTH FLOW  (unauthenticated shell — no bottom nav)
│   ├─ /splash                 Splash
│   ├─ /onboarding             Onboarding carousel (value props)
│   ├─ /intent                 Intent select → sets default mode (Get things done / Earn)
│   ├─ /login                  Log In
│   ├─ /signup                 Sign Up
│   ├─ /otp                    OTP verification
│   └─ /verify-identity        KYC prompt (mock; deferred to VerifyNow later)
│
└─ APP SHELL  (authenticated — persistent Bottom Nav, 5 items)
    │
    ├─ [Tab 1] /home           Home / Discovery  (feed ⇄ map toggle, search, categories)
    │     ├─ /search           Search & Filter (full-screen)
    │     ├─ /gig-request/:id  Gig Request Detail   (Merchant may make an Offer)
    │     │     └─ /gig-request/:id/offer     Make an Offer
    │     ├─ /gig-post/:id     Gig Post Detail      (Consumer may Book / Enquire)
    │     └─ /merchant/:id     Public Merchant Profile (portfolio, reviews, verification)
    │
    ├─ [Tab 2] /dashboard      Dashboard / My Gigs  (unified lifecycle, segmented tabs)
    │     ├─ /gig-request/:id/offers   Review Offers   (Consumer selects a Merchant)
    │     └─ /booking/:id              Booking / Escrow Status (timeline, complete, dispute)
    │           ├─ /booking/:id/evidence   Upload completion evidence
    │           └─ /booking/:id/review     Leave Review
    │
    ├─ [Tab 3] (center FAB) /post     Create chooser sheet
    │     ├─ /create/gig-request      Create Gig Request Wizard  (Consumer)
    │     └─ /create/gig-post         Create Gig Post Wizard     (Merchant)
    │
    ├─ [Tab 4] /messages       Messages (conversation list)
    │     └─ /messages/:threadId      Chat Thread (gig-context header)
    │
    └─ [Tab 5] /profile        Profile (own)
          ├─ /wallet           Wallet (balance, Escrow held, transactions — mock)
          ├─ /notifications    Notifications
          └─ /settings         Settings (mode switch, verification status, sign out)
```

### 2.2 Persistent navigation structures

- **Bottom Nav Bar** (`bg.primary`, top hairline `border.subtle`, height 64 + safe area). 5 items, labels always visible (`overline`):
  1. **Home** — `home` icon
  2. **Dashboard** — `dashboard`/`list` icon
  3. **Post** — **center, elevated 56 circular FAB, fill `accent.orange.500`, white `+` icon** (the only orange fill in the shell; it is the primary create affordance)
  4. **Messages** — `chat` icon, orange dot when unread
  5. **Profile** — `person` icon
  - Active item: icon + label `brand.green.900`, filled icon variant. Inactive: `ink.500`, outline icon. No animation beyond a 150 ms colour fade.
- **Top App Bar** per screen (see each spec). Detail screens use a back chevron; tab roots use a large `h1` title left-aligned with trailing action icons.
- **Consumer ⇄ Merchant mode:** a single account operates in either mode. Mode is a lightweight context switch (segmented control in Profile header and surfaced where it changes available actions), **not** a separate login. Default mode is set at `/intent`. Mode changes which primary CTA appears on a detail screen (Merchant sees "Make an Offer"; Consumer sees "Book"/"Enquire").

### 2.3 Route table (GoRouter)

| Path | Screen | Guard | Params |
|---|---|---|---|
| `/splash` | Splash | none | — |
| `/onboarding` | Onboarding | none | — |
| `/intent` | Intent Select | none | — |
| `/login` `/signup` `/otp` | Auth | none | `otp`: `{phone}` |
| `/verify-identity` | KYC prompt | auth | — |
| `/home` | Home/Discovery | auth | query: `view=feed|map` |
| `/search` | Search & Filter | auth | query: `q, category, ...` |
| `/gig-request/:id` | Gig Request Detail | auth | `id` |
| `/gig-request/:id/offer` | Make an Offer | auth (Merchant mode) | `id` |
| `/gig-request/:id/offers` | Review Offers | auth (owner) | `id` |
| `/gig-post/:id` | Gig Post Detail | auth | `id` |
| `/merchant/:id` | Public Merchant Profile | auth | `id` |
| `/create/gig-request` | Create Gig Request Wizard | auth | — |
| `/create/gig-post` | Create Gig Post Wizard | auth | — |
| `/booking/:id` | Booking / Escrow Status | auth (party) | `id` |
| `/booking/:id/evidence` | Evidence Upload | auth (party) | `id` |
| `/booking/:id/review` | Leave Review | auth (party) | `id` |
| `/dashboard` | Dashboard / My Gigs | auth | query: `tab` |
| `/messages` | Messages list | auth | — |
| `/messages/:threadId` | Chat Thread | auth | `threadId` |
| `/profile` | Profile (own) | auth | — |
| `/wallet` `/notifications` `/settings` | Sub-screens | auth | — |

### 2.4 Lifecycle state model (drives every status badge)

Both listing types share a unified lifecycle. In Phase 1 these states come from mock data; the same enum will later back Firestore.

```
Gig Request (Consumer-led):
  OPEN ──▶ OFFER_ACCEPTED ──▶ IN_ESCROW ──▶ IN_PROGRESS ──▶ COMPLETED
     │            │                                │
     ├──▶ EXPIRED └──▶ CANCELLED                   └──▶ DISPUTED ──▶ RESOLVED

Gig Post (Merchant-led):
  ACTIVE ──▶ BOOKED ──▶ IN_ESCROW ──▶ IN_PROGRESS ──▶ COMPLETED
     │          │                          │
     └▶ PAUSED  └──▶ CANCELLED              └──▶ DISPUTED ──▶ RESOLVED
```

| State | Badge token | Label |
|---|---|---|
| `OPEN` / `ACTIVE` | `status.open` | "Open" / "Active" |
| `OFFER_ACCEPTED` / `BOOKED` | `status.pending` | "Booked" |
| `IN_ESCROW` | `status.escrow` | "In Escrow" |
| `IN_PROGRESS` | `status.progress` | "In progress" |
| `COMPLETED` | `status.success` | "Completed" |
| `DISPUTED` | `status.dispute` | "Disputed" |
| `CANCELLED` / `EXPIRED` / `PAUSED` | `status.neutral` | "Cancelled" / "Expired" / "Paused" |

---

## 3. Core Interface Specifications

> **Global state conventions** (apply to every screen; per-screen sections only note deviations and copy):
> - **Loading:** shimmer skeletons that match the real layout's silhouette (same card count, same block heights). Shimmer = `bg.secondary` base with a slow left→right highlight sweep (`slow`, looped). Never a spinner for content areas; spinners only for button-inline actions.
> - **Empty:** centered column — muted outline icon (56, `ink.300`), `h3` headline, `body` `ink.500` subtext, optional primary button. Copy specified per screen.
> - **Error:** centered column — `error` icon (`status.dispute`), `title` "Something went wrong", `caption` `ink.500` detail, secondary "Try again" button that re-triggers the provider.
> - Every screen provides all three states even though Phase 1 mocks rarely error (a debug flag can force each state).

---

### 3.1 Home / Discovery — `/home`

**Screen objective:** Let the user discover nearby **Gig Requests** and **Gig Posts**, search, filter by category, and toggle between a scrollable feed and a map view.

**Layout structure:**
```
Scaffold(bg.primary)
 ├─ SliverAppBar (pinned, bg.primary, no shadow)
 │    ├─ Row: greeting "Molo, {firstName} 👋" (title)   ·   [notif bell + orange dot] [avatar 32]
 │    └─ SearchField (tap → /search; not focusable inline)
 ├─ SliverPersistentHeader (pinned): SegmentedToggle [ Feed | Map ]  +  right: "Filters" chip (orange dot if active)
 ├─ SliverToBoxAdapter: horizontal CategoryChipRow (scrolls x)
 └─ view == feed:
 │    └─ SliverList.builder → GigCard   (mixed Gig Requests + Gig Posts)
 └─ view == map:
      └─ SliverFillRemaining → MapPlaceholder (Phase 1 = static mock map image + pin cluster overlay; live Google Maps deferred)
 bottomNavigationBar: DaalaBottomNav (index 0)
```

**Component breakdown (ANZ look):**
- App bar is flat, white, generous top padding; greeting in `title` `ink.900`, no heavy chrome.
- **SearchField:** full-width, `bg.secondary` fill, radius `rPill`, leading search icon `ink.500`, placeholder "Search for a service or gig" `ink.300`, height 48. Tapping routes to `/search`.
- **Feed/Map toggle:** pill segmented control; selected segment `brand.green.900` fill + white, unselected `ink.700`.
- **CategoryChipRow:** filter chips (Plumbing, Electrical, Gardening, Tutoring, Cleaning, Moving, Other). "All" selected by default.
- **GigCard** (the core repeating unit — flat, `border.default`, radius `rLg`, padding `s16`, gap `s12` between cards):
  - Top row: **type tag** (`overline` pill — "REQUEST" tinted green / "SERVICE" tinted cream) · right: **status badge**.
  - Title `title` `ink.900`, max 2 lines ellipsis.
  - Meta row (`caption` `ink.500`, icon-prefixed): 📍 suburb · 🕑 timing/date · 📏 distance (e.g. "3.2 km away").
  - Optional media thumbnail (56×56, radius `rMd`) right-aligned if the listing has photos.
  - Bottom row: left = poster mini (avatar 24 + name `caption` + ⭐ rating) · right = **price** `moneyMd` `ink.900` (Gig Request shows budget; Gig Post shows "from R…").
  - If the listing has offers: small `accent.orange.500` badge "N offers".

**Data & content requirements (AirTasker substance):** per card —
`id, listingType (gigRequest|gigPost), title, category, statusEnum, budgetZarMinor, priceFrom (posts), suburb, distanceKm, timingLabel, thumbnailUrl?, offerCount, poster{ id, displayName, avatarUrl?, ratingAvg, isVerified }, createdAt`.

**Component states:**
- Loading: 6 `GigCard` shimmer skeletons (title bar, 2 meta lines, footer row).
- Empty (no results for filters): icon `search_off`, "No gigs nearby yet", "Try widening your filters or check back soon.", secondary button "Clear filters".
- Error: standard error block.
- Map empty: centered pin icon + "No gigs to show on the map."

---

### 3.2 Gig Request Detail — `/gig-request/:id`

**Screen objective:** Give a full picture of a Consumer's requested job so a **Merchant** can decide to **make an Offer** (or, if the viewer owns it, manage its **Offers**).

**Layout structure:**
```
Scaffold
 ├─ AppBar (back chevron, title "Gig Request", trailing: share, overflow)
 ├─ Body: SingleChildScrollView
 │    ├─ Header block: Title (h2) · status badge · budget (moneyLg) with "Budget" overline
 │    ├─ Poster card: avatar 44 · name · ⭐rating (count) · "Member since" · verified badge → tap /merchant/:id (consumer profile)
 │    ├─ Meta grid (2-col): 📍 Suburb/area · 🕑 When needed · 📅 Posted · 🏷 Category
 │    ├─ MapPlaceholder (fixed 160 h, radius rLg) — approximate location pin
 │    ├─ "Details" section: description body text
 │    ├─ PhotoGallery (horizontal, 96×96 tiles, radius rMd) — "What needs doing" images
 │    └─ "Offers (N)" preview strip (owner sees full; visitor sees count only)
 └─ StickyBottomBar (e2, bg.primary): 
        Merchant mode → Primary "Make an Offer"  (→ /gig-request/:id/offer)
        Owner (Consumer) → Primary "Review Offers (N)"  (→ /gig-request/:id/offers)
```

**Component breakdown (ANZ look):** big bold budget figure (`moneyLg`) with a muted `overline` label above — the ANZ "hero number" treatment. Poster shown in a flat bordered card. Meta as a clean 2-column key/value grid with `caption` labels in `ink.500` and `body` values in `ink.900`. Sticky CTA bar is the only shadowed element on screen.

**Data & content requirements:**
`id, title, statusEnum, budgetZarMinor, category, description, suburb, geoApprox{lat,lng}, whenNeededLabel, createdAt, photos[], offerCount, poster{ id, displayName, avatarUrl?, ratingAvg, reviewCount, memberSince, isVerified }, viewerRelationship (owner|merchant|other)`.

**Component states:**
- Loading: header shimmer (title bar + big budget block), poster row shimmer, map block shimmer, 3 text lines, gallery tile shimmers.
- Empty: n/a (a detail always has a subject) — if `id` not found → Error block "This gig is no longer available" + "Back to Home".
- Error: standard.

---

### 3.3 Gig Post Detail — `/gig-post/:id`

**Screen objective:** Present a **Merchant's** advertised service so a **Consumer** can **Book** or **Enquire**, backed by portfolio and reviews for trust.

**Layout structure:**
```
Scaffold
 ├─ Collapsing header: media carousel (16:9, page dots) OR cream hero if no media
 ├─ Body: SingleChildScrollView
 │    ├─ Title (h2) · category tag · price "from R…" (moneyLg)
 │    ├─ Merchant card: avatar 44 · name · ⭐rating(count) · "N gigs completed" · verified badge · "Responds in ~X" → /merchant/:id
 │    ├─ "About this service": description
 │    ├─ PortfolioGrid (2-col media tiles) → tap opens lightbox
 │    ├─ ServiceArea: MapPlaceholder + radius note
 │    └─ Reviews preview (top 2 + "See all N reviews")
 └─ StickyBottomBar:
        Consumer mode → Secondary "Enquire" + Primary "Book" (→ opens Booking confirm → Escrow)
        Owner (Merchant) → Primary "Edit Gig Post" (Phase 1: routes to disabled stub)
```

**Data & content requirements:**
`id, title, category, priceFromZarMinor, description, media[], serviceArea{center,radiusKm}, merchant{ id, displayName, avatarUrl?, ratingAvg, reviewCount, jobsCompleted, isVerified, responseTimeLabel }, reviews[]{ author, rating, comment, date, photo? }, viewerRelationship`.

**Component states:** Loading shimmer mirrors carousel + title + merchant row + 2 portfolio rows. Empty portfolio → inline "No photos yet" tile. Error standard.

---

### 3.4 Create Gig Request Wizard — `/create/gig-request`  *(reference wizard)*

**Screen objective:** Guide a **Consumer** through posting a **Gig Request** with the minimum friction — one decision per screen, AirTasker-style, so entry-level users never face a wall of fields.

**Layout structure (repeated per step):**
```
Scaffold
 ├─ AppBar: back/close (X) · linear ProgressBar (step k of n) · "Save & exit" text button
 ├─ Body: 
 │    ├─ Step question (h2, one clear question)
 │    ├─ Helper (caption ink.500)
 │    └─ Single focused input group for this step
 └─ StickyBottomBar: Primary "Continue" (disabled until step valid); final step → "Post Gig Request"
```

**Steps (order fixed):**
1. **Title** — "What do you need done?" single-line text (e.g. "Fix a leaking pipe").
2. **Category** — chip/list select; "Other" allowed (free-text sub-field).
3. **Location** — In-person vs Online toggle; if in-person → address autocomplete (Phase 1 = mock suggestions list) → confirm on `MapPlaceholder`.
4. **When** — date picker + timing preset chips ("Flexible", "Today", "This week", "On a date").
5. **Budget** — ZAR numeric field, `R` prefix, `moneyMd`; helper "You can negotiate offers later."
6. **Details** — multiline description + **photo add** (grid of add tiles; mock picker).
7. **Category-specific fields** — rendered from a category schema (e.g. Gardening → "Tools supplied?" toggle; Tutoring → subject + level). If "Other", skip.
8. **Review** — summary card of all answers, each row editable (tap → jumps to that step), then "Post Gig Request".

**Component breakdown (ANZ look):** each step is airy — a single question in `h2`, one input, a persistent Continue button. Progress bar is a thin 4 px track, filled `brand.green.900`. Selected chips fill green. Numeric budget field shows the `R` as a fixed prefix affix.

**Data captured:** `title, category, categoryFields{}, locationType, address?, geo?, whenType, date?, budgetZarMinor, description, photos[]`. On submit (Phase 1) → push a mock Gig Request into the in-memory repo and route to its detail.

**Component states:** No loading (local form). Per-field inline validation errors (`status.dispute` helper). "Save & exit" persists a **draft** (mock) and returns to Dashboard. Final submit shows an inline button spinner for ~600 ms then success.

> **Create Gig Post Wizard — `/create/gig-post`** is identical in pattern with these deltas: Step 1 "What service do you offer?"; Step 4 becomes **pricing model** (fixed / from / hourly) instead of "When"; add a **Portfolio media** step (required min 1 in spec, optional in skeleton); final CTA "Publish Gig Post". Reuse the same wizard scaffold and progress component.

---

### 3.5 Make an Offer — `/gig-request/:id/offer`

**Screen objective:** Let a **Merchant** submit a competitive **Offer** (amount + message) on a **Gig Request**.

**Layout structure:** compact form screen (or bottom sheet on tall devices).
```
AppBar: back · "Make an Offer" · context subtitle = gig title (caption, ellipsis)
Body:
 ├─ Gig summary mini-card (title, budget, poster)
 ├─ "Your offer" ZAR numeric field (moneyMd, R prefix)  + helper "Consumer's budget: R…"
 ├─ Fee preview row: "You receive after 15% platform fee: R…"  (caption ink.500)  ← mock calc
 └─ "Message to Consumer" multiline (placeholder guidance)
StickyBottomBar: Primary "Submit Offer"
```

**Data:** `gigRequestId, offerAmountZarMinor, message`. Derived display: net-after-fee (mock 15%). On submit → append mock Offer, toast "Offer sent", pop to detail with the CTA now reading "Offer submitted" (disabled).

**States:** inline validation (amount required, > 0). Submit → button spinner → success. Error → inline banner.

---

### 3.6 Review Offers — `/gig-request/:id/offers`

**Screen objective:** Let the owning **Consumer** compare **Offers** and accept one, which creates a **Booking** and moves funds into **Escrow**.

**Layout structure:**
```
AppBar: back · "Offers (N)" · trailing sort (Price | Rating)
Body: ListView.builder → OfferCard
```
**OfferCard (flat, border.default, radius rLg, padding s16):**
- Row: avatar 44 · name + verified badge · ⭐ratingAvg (reviewCount) · "N gigs · X% completion".
- **Offer amount** `moneyMd` right-aligned.
- Message excerpt (`body`, 2 lines).
- Actions: Secondary "Message" (→ chat) · Primary "Accept Offer".
- Accepting → confirm sheet ("Funds will be held in Escrow until you mark the gig complete") → routes to `/booking/:id`.

**Data:** per offer — `id, merchant{ id, displayName, avatarUrl?, isVerified, ratingAvg, reviewCount, jobsCompleted, completionRate }, amountZarMinor, message, createdAt`.

**States:** Loading = 4 OfferCard shimmers. Empty = 🕑 icon, "No offers yet", "Merchants nearby will start bidding soon." Error standard.

---

### 3.7 Booking / Escrow Status — `/booking/:id`

**Screen objective:** Single source of truth for an agreed job — show the **Escrow** state, the lifecycle timeline, and the correct next action for each party (upload evidence, mark complete, raise a **Dispute**).

**Layout structure:**
```
AppBar: back · "Booking"
Body: SingleChildScrollView
 ├─ Gig summary card (title, counterparty avatar+name, amount)
 ├─ EscrowStatusPanel (surface.cream or status.escrow tint):
 │     "R… held securely in Escrow"  + trust-teal shield icon
 ├─ LifecycleTimeline (vertical stepper):
 │     Agreed → Funds in Escrow → In Progress → Completed → Released
 │     (current step highlighted brand.green.900; done = check; future = ink.300)
 ├─ EvidenceSection: uploaded completion photos (grid) + "Add photo"
 └─ MessagesLink row → open chat thread
StickyBottomBar (party- & state-dependent):
   Consumer, IN_PROGRESS  → Primary "Mark as Complete" (releases Escrow)  + text "Raise a Dispute" (status.dispute)
   Merchant, IN_ESCROW    → Primary "Start Work" / "Mark work done"
   Any, DISPUTED          → disabled banner "Under review by Daala"
```

**Component breakdown (ANZ look):** the Escrow panel is the emotional anchor — a calm tinted panel with a shield icon and a big reassuring amount, echoing ANZ's secure/trustworthy tone. Timeline uses simple filled/outlined dots and a 2 px connector.

**Data:** `id, gig{ title, listingType }, amountZarMinor, escrowState, lifecycleState, counterparty{...}, evidence[], viewerRole (consumer|merchant), timeline[]{ step, doneAt? }`.

**States:** Loading shimmer for summary + panel + timeline. No empty. Error standard. Actions show inline spinners; state transitions update mock immediately.

---

### 3.8 Dashboard / My Gigs — `/dashboard`

**Screen objective:** Give the user a real-time overview of everything they're involved in, across both roles and the whole lifecycle.

**Layout structure:**
```
Scaffold
 ├─ AppBar: "My Gigs" (h1) · trailing wallet-glance chip (shows available balance) → /wallet
 ├─ SegmentedTabs (scrollable): Active · Offers · In Escrow · Completed · Drafts
 │     (optional secondary Consumer/Merchant filter)
 └─ TabView → ListView.builder → DashboardGigRow
 bottomNavigationBar (index 1)
```
**DashboardGigRow (list row, hairline divider):** leading type icon in tinted circle · title (`title`) · subtitle "with {counterparty} · {timing}" (`caption`) · trailing **status badge** + amount (`moneyMd`). Tap routes by state → detail / offers / booking.

**Data:** per row — `id, listingType, title, counterpartyName?, statusEnum, amountZarMinor, updatedAt, unreadFlag`.

**States:** Loading = 6 row shimmers. Empty (per tab): tailored copy, e.g. Active → 📋 "No active gigs", "Post a Gig Request or offer your services to get started.", primary "Post a Gig". Error standard.

---

### 3.9 Messages list — `/messages`  &  Chat Thread — `/messages/:threadId`

**List objective:** Show all gig-scoped conversations. **Thread objective:** Discuss a specific gig and its logistics.

**Messages list layout:** AppBar "Messages" (h1) + search field; `ListView.builder → ConversationRow`:
- avatar 44 · name (`title`) · **gig-context subtitle** (`caption` `ink.500`, e.g. "Re: Fix a leaking pipe") · last-message line (1 line ellipsis) · right: timestamp (`caption`) + unread count badge (`accent.orange.500`).

**Chat thread layout:**
```
AppBar: back · avatar 32 + name · trailing "View gig"
GigContextHeader (pinned, bg.secondary): thumbnail · gig title · amount · status badge → tap to detail/booking
Body: reversed ListView → message bubbles
   - own: brand.green.900 bg, white text, right-aligned, radius rLg (tail corner tightened)
   - other: bg.secondary, ink.900, left-aligned
   - timestamp caption under grouped runs; date separators centered
Composer (bottom, e2): [attach +] TextField (rPill) [send ▷ orange when non-empty]
```
**Data:** conversation — `threadId, counterparty{...}, gigRef{ id, type, title, amountZarMinor, statusEnum, thumbnailUrl? }, lastMessage, lastTs, unreadCount`. Message — `id, senderId, text, sentAt, attachments[]?`.

**States:** List Loading = 8 row shimmers; Empty = 💬 "No messages yet", "Your conversations about gigs will appear here." Thread Loading = bubble shimmers; Error standard. Composer send shows optimistic append.

---

### 3.10 Public Merchant Profile — `/merchant/:id`

**Screen objective:** Establish trust — this is the conversion surface. Portfolio, rating, verification, and history must be legible at a glance.

**Layout structure:**
```
Scaffold
 ├─ ProfileHeader (bg.primary): avatar 64 · name · verified badge · category tags
 │     StatsRow (3-up, dividers): ⭐ ratingAvg (reviewCount)  ·  Gigs completed  ·  Completion %
 │     Secondary meta: "Responds in ~X" · "Member since {year}" · service area
 ├─ Tabs: Portfolio · Reviews · About
 │     Portfolio → 2-col media grid (lightbox)
 │     Reviews   → ReviewCard list (author avatar, ⭐, comment, date, optional photo)
 │     About     → bio + skills/categories + verification details
 └─ StickyBottomBar: Primary "See {name}'s Gigs" / "Message"
```
**Data:** `id, displayName, avatarUrl?, isVerified, categories[], ratingAvg, reviewCount, jobsCompleted, completionRate, responseTimeLabel, memberSince, serviceArea, bio, portfolio[], reviews[]`.

**States:** Loading shimmer for header stats + 4 portfolio tiles. Empty portfolio/reviews → inline tile copy. Error standard.

---

### 3.11 Wallet — `/wallet`

**Screen objective:** Show money at rest and in motion, reinforcing Escrow trust. Mock in Phase 1.

**Layout structure:**
```
AppBar: back · "Wallet"
Body:
 ├─ BalanceHero (surface.cream card, radius rXl): "Available" (moneyLg) + row "In Escrow: R…" (status.escrow)
 ├─ ActionRow: Primary "Withdraw" (disabled stub) · Secondary "Top up" (disabled stub)
 └─ "Transactions" → ListView → TxnRow: icon (in/out/escrow) · label + counterparty (title/caption) · date · amount (green in / ink out) · status badge
```
**Data:** `availableZarMinor, inEscrowZarMinor, transactions[]{ id, type (credit|debit|escrowHold|escrowRelease), label, counterparty?, date, amountZarMinor, status }`.

**States:** Loading = hero shimmer + 5 txn shimmers. Empty txns = 🧾 "No transactions yet." Error standard.

---

### 3.12 Auth cluster — `/intent`, `/signup`, `/login`, `/otp`, `/verify-identity`

**Objective:** Get a user in with minimal friction and set their default mode; collect just enough for a unified account.

- **Intent Select:** two large tappable cards — "Get things done" (Consumer default) / "Earn money" (Merchant default); note that both are always available. Below: "I'll do both" tertiary. Sets `defaultMode`.
- **Sign Up:** fields — full name, phone (ZA `+27` prefix) or email, password (show/hide), T&Cs checkbox. Primary "Create account" → `/otp`.
- **Log In:** phone/email + password, "Forgot password" tertiary, Primary "Log in".
- **OTP:** 4–6 boxed digit inputs (auto-advance), resend timer (`caption`), Primary "Verify".
- **Verify Identity (KYC prompt):** explains why (Escrow/FICA) in plain language; Primary "Verify now" (mock success) · tertiary "Skip for now". Real VerifyNow integration deferred.

**Look:** centered, generous whitespace, single-column, one clear primary button per screen — ANZ onboarding calm. Brand mark at top; cream hero optional on Intent.

**States:** field-level validation; button spinner on submit; error banner for "invalid code / credentials" (mock triggers).

---

### 3.13 Remaining skeleton screens (tabulated)

| Screen | Route | Objective | Key elements | Empty/Error |
|---|---|---|---|---|
| Splash | `/splash` | Brand load + auth check | Centered logo on `brand.green.900` or cream; no controls | n/a |
| Onboarding | `/onboarding` | Convey value in 3 slides | PageView, dots, "Skip"/"Next", final "Get started" | n/a |
| Search & Filter | `/search` | Query + refine listings | Focused search field; filter groups (category, distance slider, budget range, listing type, sort); "Show N results" sticky primary; recent searches | Empty results block |
| Notifications | `/notifications` | Activity log | Grouped list rows (offer received, booking, escrow, dispute, review); unread = orange dot; tap → deep target | Empty "You're all caught up" |
| Leave Review | `/booking/:id/review` | Post-gig dual review | 5-star selector (large), optional comment, optional photo, Primary "Submit review" | Inline validation |
| Settings | `/settings` | Account controls | Mode switch, verification status, notifications toggles, legal links, Sign out (destructive) | n/a |
| Create Gig Post Wizard | `/create/gig-post` | Merchant listing | See §3.4 deltas | as wizard |

---

## 4. Prompt Engineering Guide for Implementation LLMs

**To the implementing model:** Treat this file as a *contract*, not inspiration. Generate a **Flutter** skeleton only — `flutter_riverpod` for state, `GoRouter` for the routes in §2.3, and a strict **feature-first** structure (`lib/features/<feature>/{presentation,application,domain,data}`, shared code in `lib/core/{theme,widgets,router,utils}`). Begin by emitting `core/theme/tokens.dart` from the literal values in §1.2 and derive a single `ThemeData`; **every** colour, radius, spacing, and text style in every widget must reference a token — never a hard-coded hex or magic number. Build each screen in §3 exactly to its stated widget tree, data fields, and the three mandatory states (loading shimmer / empty / error), using the §3 "Global state conventions" so state handling is uniform. All data is **mock**: define domain models and repository *interfaces* in `domain/`, provide `Mock*` implementations in `data/` that return the specified fields from in-memory fixtures behind a 300–800 ms delay (so loading states are visible), and expose them through Riverpod providers — **make no network, Firebase, TradeSafe, VerifyNow, or Google Maps calls**; render the `MapPlaceholder` where a map is specified. Honour the fixed domain vocabulary and lifecycle enum (§2.4) verbatim in class names, badge labels, and route names — do not rename `Gig Request`/`Gig Post`/`Offer`/`Booking`/`Escrow`/`Dispute` to generic marketplace terms. Respect the performance rules in §1.1: `const` constructors, `*.builder` lists, borders over shadows, `formatZar()` for all currency. Do **not** add screens, fields, flows, animations, theming, or "nice-to-have" polish that this document does not specify; where a detail is genuinely unspecified, choose the most minimal, token-consistent option and leave a `// TODO(spec):` comment rather than inventing product behaviour. The deliverable is a clean, modular, compile-ready skeleton whose structure a human can extend phase by phase — fidelity to this spec outranks creativity.