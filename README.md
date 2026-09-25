# Daala

A two-sided gig marketplace for South Africa's informal economy — one account that both earns and hires. Flutter (Android + iOS), Riverpod, GoRouter, Firebase Auth + Cloud Firestore.

## Docs

| File | What it is |
|---|---|
| [CLAUDE.md](CLAUDE.md) | Operating contract: stack, folder layout, identity model, rules, roadmap, and what's outstanding. **Start here.** |
| [DESIGN.md](DESIGN.md) | Visual blueprint — the "Groundwork" tokens and component vocabulary. Machine copy lives in `lib/theme/app_theme.dart`. |
| [PRODUCT.md](PRODUCT.md) | Audience, purpose, positioning, design principles. |
| [PHASE2-SETUP.md](PHASE2-SETUP.md) | Console / DNS / store tasks only the owner can do, with status. |
| [phase2.md](phase2.md) | Original Phase 2 brief. Superseded where it conflicts with the built flow — see its header. |

## Build

```bash
flutter pub get
flutter analyze   # the verification step — must be clean
```

## Status

Phase 2 (auth & onboarding) is code-complete. Email-link sign-in is unverified end to end, and iOS needs its Firebase config generated before it can boot. Details in CLAUDE.md → *Outstanding*.
