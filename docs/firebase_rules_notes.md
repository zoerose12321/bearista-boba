# Firebase rules notes (v0.1.64)

Bearista Boba online café sessions are a **prototype** feature that requires **real Firestore** — temporary/local codes are no longer shown.

## Setup checklist (Chrome QA)

1. Run `flutterfire configure` and replace `lib/firebase_options.dart` placeholders.
2. Enable Firestore in the Firebase console.
3. Deploy development rules from `firestore.rules` (prototype open read/write).
4. Host in one browser profile, join from another using the Firestore join code.

## Current state

- Firestore collection: `onlineCafeSessions`
- Temporary session data only (host display name, shop title, join code, visitor summaries)
- No passwords, payments, or private account data

## Security

The included `firestore.rules` file uses **open read/write** rules for local development and QA.

**Do not ship to production with these rules.**

Before App Store release:

1. Replace Firestore rules with authenticated or scoped writes (host-only updates, visitor join/leave only).
2. Add rate limiting / abuse monitoring for join codes.

## Failure behavior

If Firebase is unavailable or permission is denied, **Open My Café Online** shows:

> Online café could not connect yet. Check Firebase setup and try again.

No fake join code is displayed.
