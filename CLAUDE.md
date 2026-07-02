# CLAUDE.md — Daala

Daala is a two-sided gig marketplace targeting the South African informal sector. It connects **consumers** (buyers who need tasks done) with **merchants** (service providers). Trust is the core value proposition — escrow payments, KYC verification, and dispute resolution are first-class features.

**Stack:** Flutter · Firebase (Blaze) · TradeSafe (escrow/wallets, GraphQL) · VerifyNow (KYC, REST) · Google Maps Platform · Sentry

---

## Folder Structure



- **Navigation:** GoRouter with named routes only
- **State management:** Riverpod — `AsyncNotifierProvider` for async, `NotifierProvider` for sync
- **No business logic in widgets** — widgets invoke providers only

---

## Domain Terminology
Use these exact terms in code, variable names, and comments. Never substitute generics like "job" or "listing".

| Term | Definition |
|---|---|
| **Consumer** | The buyer/client who needs a task done |
| **Merchant** | The service provider who fulfils tasks |
| **Gig Post** | Listing created *by a merchant* advertising their services |
| **Gig Request** | Listing created *by a consumer* describing a task they need done |
| **Offer** | A merchant's bid submitted on a Gig Request |
| **Booking** | A confirmed engagement — offer accepted or service booked directly |
| **Escrow** | Funds held by TradeSafe between booking and completion |
| **Dispute** | Formal complaint that freezes escrow pending admin review |

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

## API Integration

### TradeSafe (GraphQL)
- Docs: https://docs.tradesafe.co.za
- Auth: OAuth2 client credentials
- **All mutations via `TradeSafeService` only** — never call from widget trees
- Checkout is **redirect-based** — requires Flutter deep links to return to app
- Go-Live approval must be submitted at **W8–9** of development (critical path — do not miss)

### VerifyNow (REST)
- Auth: Bearer token
- Only 3 endpoints: identity verification, document upload, status check
- Isolated in `features/auth/services/verify_now_service.dart`
- Collect SA ID/biometrics only to pass to VerifyNow — do not persist

### Google Maps Platform
- Package: `google_maps_flutter` (first-party)
- Uses: map rendering, address autocomplete, distance calculations
- **Lazy-load only** — initialise on Map tab navigation, never on app start

---

## Performance Constraints
Daala's core users are on entry-level Android with limited data. These are non-negotiable:

- **Target:** Android 6.0+, ~2GB RAM
- **Firestore queries:** Always paginated, max 20 docs/page
- **Images:** Compress to ≤500KB before Firebase Storage upload; use `cached_network_image` with placeholders
- **Maps:** Load only when user navigates to Map tab
- **Avoid:** heavy animations that block the UI thread

---

## POPIA & Legal
- **No PII stored on device** — no SA ID numbers, bank details, or biometrics locally
- All PII over SSL/TLS only
- Account deletion must trigger cryptographic wipe of all PII from Firestore + Storage
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