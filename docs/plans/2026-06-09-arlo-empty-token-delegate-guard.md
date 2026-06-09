---
title: Arlo Empty Token Delegate Guard
type: privacy
status: completed
date: 2026-06-09
---

# Arlo Empty Token Delegate Guard

## Problem Frame

Arlo already disables the microphone button while the committed Wit access-token
placeholder is empty. The view still registered itself as the Wit singleton
delegate on appearance, which leaves the no-token demo state owning voice
callbacks even though capture is unavailable.

## Scope Boundaries

- Preserve the empty committed Wit token placeholder.
- Preserve the visible-view delegate lifecycle when a local token is supplied.
- Keep the microphone button disabled and accessible in no-token builds.
- Do not change Wit, CocoaPods, Swift, or deployment target versions.

## Implementation Units

### U1: Skip Delegate Registration Without A Token

Files:

- Modify `Arlo/ViewController.swift`

Approach:

- Keep delegate assignment inside `configureWitDelegate()`.
- Register the delegate only when `AppDelegate.isWitConfigured` is true.
- Clear the delegate through the existing cleanup helper when the token is
  empty.

### U2: Document And Enforce The Contract

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Add SDK-free checks for the empty-token delegate guard and this completed
  plan.
- Document the guard alongside the existing microphone and Wit lifecycle notes.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
