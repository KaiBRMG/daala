# Daala — Project Context

Daala is a two-sided gig marketplace for the South African informal sector, connecting **consumers** (buyers who need tasks done) with **merchants** (service providers who offer those services). The app is a single unified application (one codebase, one account type) — users can act as both merchant and consumer. Trust is the core value proposition — escrow payments, KYC verification, and dispute resolution are first-class features.

---

## Tech Stack

| Layer | Choice |
|---|---|
| Frontend | Flutter (Android + iOS) |
| Backend / DB | Firebase (Firestore, Auth, Cloud Storage, serverless — Blaze plan) |
| Payments / Escrow | TradeSafe API (GraphQL) |
| Mapping | Google Maps Platform |
| KYC | VerifyNow (REST) |
| Monitoring | Firebase Crashlytics + Sentry |
| Platforms | Android & iOS |

- **Navigation:** GoRouter with named routes only
- **State management:** Riverpod — `AsyncNotifierProvider` for async, `NotifierProvider` for sync
- **No business logic in widgets** — widgets invoke providers only

---

## User Roles & Terminology

Use these exact terms in code, variable names, and comments. Never substitute generics like "job" or "listing".

| Term | Definition |
|---|---|
| **Consumer** | The buyer/client who needs a task done |
| **Merchant** | The service provider who fulfils tasks |
| **Gig Post** | Listing created *by a merchant* advertising their services |
| **Gig Request** | Listing created *by a consumer* describing a task they need done; merchants submit bids on it |
| **Offer** | A merchant's bid submitted on a Gig Request |
| **Booking** | A confirmed engagement — offer accepted or service booked directly |
| **Escrow** | Funds held by TradeSafe between booking and completion |
| **Dispute** | Formal complaint that freezes escrow pending admin review |

Users can create both types of listings. The distinction is about who initiates.

---

## MVP Features

### 1. Gig Posting Wizard
- Collects: title, description, budget, date, location, category
- Category-specific fields (e.g. gardener → tools supplied; tutor → subjects)
- Launch with a fixed set of standardized categories + an `Other/Custom` fallback
- Two wizard flows: one for Gig Posts (merchant), one for Gig Requests (consumer)

### 2. Gig Management Dashboard
- Real-time lifecycle tracking: created → offers → booked → in progress → escrow → complete
- Displays active listings, incoming/outgoing offers, and escrow status
- Supports the two transaction models:
  - **Gig Request flow**: consumer posts → merchants bid → consumer selects
  - **Gig Post flow**: merchant posts → consumer enquires or books directly

### 3. Escrow Payments (via TradeSafe)
- Funds move from buyer wallet → escrow the moment an agreement is locked
- Merchant completes work → buyer marks complete → funds auto-release to merchant wallet
- Dispute flow: buyer raises dispute → funds freeze → support team reviews comms + photos → admin decision (release / refund / split)
- Photo evidence upload is available at job completion for both parties

### 4. Real-Time Messaging
- In-app text chat scoped to a specific gig

### 5. Media Content Posting
- Merchants: photo/video portfolio on profile and on Gig Posts
- Consumers: photo upload on Gig Requests (show what needs fixing)
- Stored in Firebase Cloud Storage

### 6. Map Discovery
- Live gig listings rendered on a local map
- Category filters to reduce clutter
- Powered by Google Maps Platform

### 7. Safety & Trust
- Double-sided ratings: after gig completion, both parties rate each other (5 stars + optional text + optional photo)
- Reviews are public and anonymous
- Report/flag system for suspicious profiles or listings
- ID verification badge: users upload SA ID during onboarding → VerifyNow checks → verified badge unlocked

---

## Core Data Models (Firestore)

### `users/{userId}`
```
uid, displayName, email, phone
role: 'consumer' | 'merchant' | 'both'
isVerified: bool            // VerifyNow KYC status
verificationBadge: bool
tradeSafeAccountId: String
rating: double, reviewCount: int
createdAt: Timestamp
```

### `gigs/{gigId}`
```
id, type: 'post' | 'request'
ownerId, title, description
category: String            // 'plumber' | 'tutor' | 'gardener' | 'electrician' | 'other'
categoryMeta: Map           // category-specific fields (e.g. subjects for tutor)
budget: num                 // ZAR
location: GeoPoint, locationLabel: String
mediaUrls: List<String>
status: GigStatus
createdAt: Timestamp, expiresAt: Timestamp?
```

### `offers/{offerId}`
```
id, gigId (must be type:'request')
merchantId, consumerId
amount: num                 // ZAR
message: String
status: OfferStatus
createdAt: Timestamp
```

### `bookings/{bookingId}`
```
id, gigId, offerId?         // null if direct booking on a Gig Post
consumerId, merchantId
agreedAmount: num           // ZAR
tradeSafeTransactionId: String
escrowStatus: EscrowStatus
status: BookingStatus
completedAt: Timestamp?
```

---

## State Machines

### GigStatus
```
draft → active → in_progress → completed
                             ↘ disputed → resolved
```

### OfferStatus
```
pending → accepted
        → rejected
        → withdrawn
```

### BookingStatus
```
awaiting_payment → active → completed
                          ↘ disputed → resolved_merchant | resolved_consumer | resolved_split
```

### EscrowStatus (maps to TradeSafe)
```
pending → funded → released | refunded | split
```

---

## Integrations & Constraints

### TradeSafe (Payments)
- Daala is **not** an FSP and **cannot** hold user funds directly (NPS Act 1998, Banks Act 1990)
- TradeSafe handles wallet management and escrow
- Required data per user for TradeSafe compliance: full legal name, verified email, SA ID number or business registration number, verified cell number, bank account details
- Auth: OAuth2 client credentials
- **All mutations via `TradeSafeService` only** — never call from widget trees
- Checkout is **redirect-based** — requires Flutter deep links to return to app
- Go-Live approval must be submitted at **W8–9** of development (critical path — do not miss)
- Docs: `https://docs.tradesafe.co.za/guides/quick-start/`

### VerifyNow (KYC)
- Performs real-time identity verification in-app
- Feeds verified identity data to TradeSafe for FICA compliance
- Auth: Bearer token
- Only 3 endpoints: identity verification, document upload, status check
- Isolated in `features/auth/services/verify_now_service.dart`
- Collect SA ID/biometrics only to pass to VerifyNow — do not persist
- Docs: `https://www.verifynow.co.za/api-docs`

### Google Maps Platform
- Address validation, map rendering, distance calculations
- Package: `google_maps_flutter` (first-party)
- **Lazy-load only** — initialise on Map tab navigation, never on app start
- Docs: `https://developers.google.com/maps/documentation`

---

## Performance Constraints

Daala's core users are on entry-level Android with limited data. These are non-negotiable:

- **Target:** Android 6.0+, ~2GB RAM, older OS versions
- **Firestore queries:** Always paginated, max 20 docs/page
- **Images:** Compress to ≤500KB before Firebase Storage upload; use `cached_network_image` with placeholders
- **Maps:** Load only when user navigates to Map tab
- **Avoid:** heavy animations that block the UI thread
- No assumptions about stable network conditions — handle offline/degraded states gracefully

---

## POPIA & Legal

- All PII (SA ID numbers, biometrics, banking info) encrypted in transit (SSL/TLS) and at rest
- **No** PII stored on device — no SA ID numbers, bank details, biometrics, or ID documents locally
- Account deletion triggers automated cryptographic wipe of PII from Firestore + Storage
- Daala is **not an FSP** — funds must never move directly between users outside TradeSafe

---

## Coding Conventions
- `camelCase` variables/functions · `PascalCase` classes/enums · `snake_case` Firestore fields
- Wrap all Firestore and API calls in try/catch; surface errors via a `Failure` sealed class
- Use Firestore **batch writes or transactions** for any operation touching more than one document
- **Update Firestore Security Rules** alongside every data model change — never leave rules open

---

## Current Phase
**Phase 1 — Skeleton Frontend**
- ~25 screens, mock data, zero real API calls
- GoRouter navigation wired
- Riverpod providers returning mock data only

**Do not wire real Firebase or API calls during Phase 1.** Integration begins in Phase 4.
