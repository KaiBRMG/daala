# Daala — Project Context

Daala is a two-sided gig marketplace for the South African informal sector, connecting consumers who need tasks done with merchants who offer those services. The app is a single unified application (one codebase, one account type) — users can act as both merchant and consumer.

---

## Tech Stack

| Layer | Choice |
|---|---|
| Frontend | Flutter (Android + iOS) |
| Backend / DB | Firebase (Firestore, Auth, Cloud Storage, serverless) |
| Payments / Escrow | TradeSafe API |
| Mapping | Google Maps Platform |
| KYC | VerifyNow |
| Monitoring | Firebase Crashlytics + Sentry |
| Platforms | Android & iOS |

---

## User Roles & Terminology

- **Merchant** — sells/offers services
- **Consumer** — buys/requests services
- **Gig Post** — a listing created by a **merchant** advertising a service
- **Gig Request** — a listing created by a **consumer** describing a task they need fulfilled; merchants submit bids on it

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

## Integrations & Constraints

### TradeSafe (Payments)
- Daala is **not** an FSP and **cannot** hold user funds directly (NPS Act 1998, Banks Act 1990)
- TradeSafe handles wallet management and escrow
- Required data per user for TradeSafe compliance: full legal name, verified email, SA ID number or business registration number, verified cell number, bank account details
- TradeSafe documentation: `https://docs.tradesafe.co.za/guides/quick-start/`

### VerifyNow (KYC)
- Performs real-time identity verification in-app
- Feeds verified identity data to TradeSafe for FICA compliance
- VerifyNow documentation: `https://www.verifynow.co.za/api-docs` 

### Google Maps Platform
- Address validation, map rendering, distance calculations
- Google Maps Platform documentation: `https://developers.google.com/maps/documentation?hl=en&_gl=1*z43hfg*_ga*ODQ4ODUwNjA5LjE3ODExNzg4MDc.*_ga_NRWSTWS78N*czE3ODExNzg4MDYkbzEkZzEkdDE3ODExNzg4MjgkajM4JGwwJGgw`

---

## Data & Security Requirements (POPIA)

- All PII (SA ID numbers, biometrics, banking info) encrypted in transit (SSL/TLS) and at rest
- **No** banking credentials or ID documents stored locally on device
- Account deletion triggers automated cryptographic wipe of PII from cloud

---

## Performance Constraints

- Must be **data-light** — optimise asset sizes, lazy loading, minimal background sync
- Must run on **entry-level Android devices** and older OS versions
- No assumptions about stable network conditions — handle offline/degraded states gracefully

---

# Architecture




