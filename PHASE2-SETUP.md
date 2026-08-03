# Phase 2 — Setup tasks

Everything in this list is work only you can do: Firebase Console configuration, DNS, hosting, and Apple/Google developer settings. The Flutter side is built and `flutter analyze` is clean.

Ordered so that nothing blocks on something below it. **Tasks 1–5 are required to sign in at all.**

---

## 1. Generate the iOS Firebase config ⚠️ blocks iOS entirely

`ios/Runner/GoogleService-Info.plist` does not exist, and `lib/firebase_options.dart` currently throws on iOS with instructions rather than shipping made-up keys.

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=daala-69a44
```

This rewrites `firebase_options.dart` (expected — do not hand-edit it afterwards) and writes the iOS plist. Register the iOS bundle id **`za.co.daala.daala`** in the Firebase Console if prompted.

---

## 2. Enable the two sign-in providers

Firebase Console → **Authentication → Sign-in method**:

- **Phone** — enable.
- **Email/Password** — enable, then tick **Email link (passwordless sign-in)**. Both are needed; the email-link credential lives under the Email provider.

---

## 3. Deploy the security rules ⚠️ nothing works without this

`firestore.rules` is written and in the repo. It defaults to deny, so with the console's default test rules in place your writes will either be wide open or fail.

```bash
firebase deploy --only firestore:rules --project daala-69a44
```

You may need to add a `firestore` block to `firebase.json` first (it currently only has the Flutter block):

```json
"firestore": { "rules": "firestore.rules", "indexes": "firestore.indexes.json" }
```

No composite indexes are needed for Phase 2 — every query is a document get.

---

## 4. Seed the legal config document

Firestore → create document **`config/legal`**:

| Field | Type | Value |
|---|---|---|
| `termsVersion` | number | `1` |
| `privacyVersion` | number | `1` |
| `termsUrl` | string | `https://www.daala.co.za/terms` |
| `privacyUrl` | string | `https://www.daala.co.za/privacy` |
| `changeSummary` | string | *(leave empty until Terms actually change)* |

The app falls back to these values if the document is missing, so it won't crash — but the Terms-update gate can't work until it exists. Bumping `termsVersion` here is what triggers the update screen for everyone, with no store release.

**Also required:** the two URLs must actually resolve. They're linked from the consent line on the phone screen, and Apple/Google both check that a privacy policy is reachable.

---

## 5. Set up `login.daala.co.za` on Firebase Hosting ⚠️ blocks email login

**Background, since this causes confusion:** Firebase Dynamic Links shut down on 25 August 2025. Email link sign-in **was migrated, not withdrawn**. The old `dynamicLinkDomain` field is gone from the SDK entirely and `linkDomain` replaced it — that's what `auth_repository.dart` uses. The one capability genuinely lost is sending someone to the app store from a link when the app isn't installed.

**It must be Firebase Hosting**, not any web host. `linkDomain` requires a Hosting custom domain on this project (the SDK rejects the default `web.app` / `firebaseapp.com` domains), and Hosting auto-serves the association files — which makes this *less* work than a manual setup, not more.

### ✅ 5.1 — Hosting custom domain — *done*
Firebase Console → **Hosting** → add custom domain `login.daala.co.za`, complete DNS verification.

### ⏸️ 5.2 — Point the Auth backend at the domain — **THE BLOCKING STEP** (deferred, not yet run)

*Two corrections to earlier versions of this file:*
1. *It said to "link the apps in Hosting → site settings". **That screen does not exist** — there is no console UI for this at all, which is why you couldn't find it.*
2. *The script first passed the literal domain to `mobileLinksConfig.domain`. That field is an **enum** (`HOSTING_DOMAIN` / `FIREBASE_DYNAMIC_LINK_DOMAIN`) selecting a mode, not a hostname — hence the rejection. Fixed.*

**After running this you must still verify which host the emailed link actually uses**, and align the manifest and entitlements to it. Full procedure in CLAUDE.md → *Email-link host: unresolved and unverified*.

Firebase's Auth backend keeps generating links on the old default domain until you explicitly tell it otherwise. Setting `linkDomain` in the app is **not sufficient on its own** — the docs are explicit that the backend config must be updated separately.

A helper script is in the repo. From the project root:

```bash
npm install firebase-admin
node tools/set-link-domain.mjs
```

It needs a service account key — Firebase Console → **Project Settings → Service accounts → Generate new private key** — saved as `tools/service-account.json`. **That file is a full-admin credential: it is already git-ignored, and it must never be committed.** Delete it once the script has run.

The script is idempotent, prints the resulting config, and can roll back (see the comment at the top).

### ✅ 5.3 — Signing fingerprints — *done*
Both SHA-1 and SHA-256 are required (the migration docs call for both, and Phone Auth needs them regardless of deep links):
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### ✅ 5.4 — iOS Associated Domains — *done for you, no Mac needed*

Xcode's "Signing & Capabilities" tab just writes an entitlements file, so I wrote it directly: **[ios/Runner/Runner.entitlements](ios/Runner/Runner.entitlements)**, declaring `applinks:login.daala.co.za`, and added `CODE_SIGN_ENTITLEMENTS` to all three Runner build configurations in `project.pbxproj`. Xcode will show the capability as already enabled when the project is next opened on a Mac.

**Portal state:** ✅ Associated Domains and ✅ Push Notifications are enabled on the App ID. Still outstanding:
- **Regenerate provisioning profiles** — any created before those capabilities were ticked don't carry them. Xcode automatic signing handles it on first build.
- **APNs `.p8` key** — deferred to Phase 5. Until it's uploaded to Firebase → Cloud Messaging, iOS phone sign-in uses a reCAPTCHA webview instead of silent push verification. Works, but worse.
- ⚠️ **Revert `?mode=developer`** in the entitlements before any release build, or Universal Links silently fail in production.

### ✅ 5.5 — Android manifest — *done for you*

Added to `android/app/src/main/AndroidManifest.xml`: the `flutter_deeplinking_enabled` meta-data and an `autoVerify` intent filter.

**Note the path correction.** I previously wrote `pathPrefix="/auth"`. The real path Firebase generates links on is **`/__/auth/links`** — fixed, not configurable. The manifest now matches both that and our own `/auth/email-link` continue URL, and `router.dart` registers routes for both. With the old prefix the app would simply never have received the link.

### ⬜ 5.6 — Authorised domains
Firebase Console → **Authentication → Settings → Authorised domains** → add `login.daala.co.za`.

---

Both constants live at the bottom of `lib/auth/auth_repository.dart`: `kEmailLinkDomain` and `kEmailLinkContinueUrl`. Both now say `login.daala.co.za`.

**Minimum SDK versions** — already satisfied by `firebase_auth: ^6.5.2`. If you ever pin older: Android needs Firebase Auth 23.2.0+ / BoM 33.9.0+, iOS needs 11.8.0+.

---

## 6. App Check — the SMS toll-fraud defence 💰 ⏸️ DEFERRED (noted in CLAUDE.md)

**This is the single most important cost control in Phase 2.** Unprotected phone auth is routinely drained by bots pumping premium-rate numbers; the bill lands on you.

1. Firebase Console → **App Check** → register the Android app with **Play Integrity** and the iOS app with **DeviceCheck** (or App Attest).
2. **Enforce** App Check on **Authentication** and **Cloud Firestore**.
3. Add `firebase_app_check` to `pubspec.yaml` and activate it at the seam already marked in `lib/main.dart` (`TODO(phase2-setup)`), *before* enforcing — enforcement without an activated client locks everyone out.
4. Register a debug token for your dev devices so local runs keep working.

---

## 7. SMS region policy 💰

Firebase Console → **Authentication → Settings → SMS region policy** → **Allow only** these regions:

`ZA` · `NA` · `BW` · `ZW` · `LS` · `SZ` · `MZ`

These match `kDialRegions` in `lib/auth/phone_format.dart` — **keep the two in sync.** A region in the code but blocked in the console fails at "Send Code" with an opaque error. Narrowing this is the cheapest, highest-leverage abuse control available.

Consider also setting a **daily SMS spend cap / budget alert** in Google Cloud Billing.

---

## 8. Test phone numbers for store review

Firebase Console → **Authentication → Sign-in method → Phone → Phone numbers for testing.**

**Which number to use.** There's a trap here worth knowing about: a test number is permanently intercepted — Firebase always returns the fixed code and **never sends a real SMS to it**. So if you pick a number that a real South African later owns, that person can never sign in to Daala. Two safe choices, best first:

1. **A second number you actually own** (a spare prepaid SIM). Zero collision risk, and you can swap it out freely.
2. **A number in an unallocated range.** `+27 82 000 0000` is the conventional choice — SA mobile numbers are `06x`/`07x`/`08x`, and `082 000 0000` isn't issued. Not a guarantee, but close to one.

Avoid: a colleague's real number, or a number you picked at random.

Set the code to something obviously non-secret like `123456` — it is not a credential, it's a review fixture.

**Then record it where the reviewers will see it:**
- **App Store Connect** → your app → the version → **App Review Information → Sign-In Information** (tick "Sign-in required"), and repeat it in the Notes field.
- **Play Console** → **App content → App access** → "All or some functionality is restricted" → add instructions with the number and code.

Without this, **the first submission is rejected** — reviewers cannot receive an SMS, so they simply cannot get past the login screen.

---

## 9. Customise the sign-in email template ⏸️ DEFERRED (noted in CLAUDE.md)

Firebase Console → **Authentication → Templates → Email address sign-in.** The default is generic Firebase copy and reads as phishing to a low-trust audience. Rewrite it in Daala's voice, set the sender name, and — once the domain is live — verify a custom sender domain so it doesn't arrive from `firebaseapp.com`.

---

## 10. Android minSdk check

`android/app/build.gradle.kts` uses `flutter.minSdkVersion`. `ActionCodeSettings` in `auth_repository.dart` declares `androidMinimumVersion: '23'`. Firebase Auth and Play Integrity both need **API 23+**; confirm the resolved value isn't lower, and set `minSdk = 23` explicitly if it is.

Note: CLAUDE.md's performance target says "Android 6.0+", which *is* API 23 — so this should be consistent, just verify it.

---

## Before you can call Phase 2 done

- [ ] Sign up on a real device with a real number, end to end.
- [ ] Confirm the sign-in link email arrives, opens the **app** (not a browser), and shows "Email confirmed".
- [ ] Check the Auth console: that user has **both** a phone and an email provider on **one** uid. Two uids means the linking step failed — that's the highest-severity bug in this flow.
- [ ] Sign out, use email login, confirm you land back on the **same** uid.
- [ ] Verify `users/{uid}`, `users/{uid}/private/contact`, and one `users/{uid}/consents/{id}` document all exist with the right shape.
- [ ] Try to edit `verified` on your own user document from the client — it must be rejected.
- [ ] Bump `config/legal.termsVersion` to `2` and confirm the terms-update screen appears on next launch.
- [ ] Test on a genuinely entry-level Android device, not just the emulator.
