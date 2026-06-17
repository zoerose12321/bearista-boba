# Firebase rules notes (v0.1.61)

Bearista Boba online café sessions are a **prototype** feature.

## Current state

- Firestore collection: `onlineCafeSessions`
- Temporary session data only (host display name, shop title, join code, visitor summaries)
- No passwords, payments, or private account data

## Security

The included `firestore.rules` file uses **open read/write** rules for local development and QA.

**Do not ship to production with these rules.**

Before App Store release:

1. Run `flutterfire configure` and replace placeholder values in `lib/firebase_options.dart`.
2. Replace Firestore rules with authenticated or scoped writes (host-only updates, visitor join/leave only).
3. Add rate limiting / abuse monitoring for join codes.

## QA target

Chrome/web is the first supported target for hosting and joining online cafés.
