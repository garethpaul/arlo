---
title: Arlo Empty Token Audio Session Guard
type: privacy
status: completed
date: 2026-06-13
---

# Arlo Empty Token Audio Session Guard

## Status: Completed

## Problem Frame

The committed Wit token is intentionally empty and the microphone control is
disabled in that state, but `AppDelegate` still configures and activates an
`AVAudioSessionCategoryPlayAndRecord` session during every launch. The default
demo build therefore claims audio-session resources even though it cannot start
the guarded Wit voice flow.

## Scope Boundaries

- Preserve the empty committed token, disabled microphone UI, microphone usage
  description, Wit configuration, and delegate ownership contracts.
- Preserve audio-session category and activation behavior when a maintainer
  supplies a local non-empty token.
- Preserve non-crashing `do`/`catch` error handling.
- Do not add credentials, permission prompts, Wit SDK changes, or CocoaPods
  updates.
- Full verification still requires a compatible macOS/Xcode/Swift 3.0 host.

## Implementation Units

### U1: Guard Launch-Time Audio Session Setup

Files:

- Modify `Arlo/AppDelegate.swift`

Approach:

- Return from `configureAudioSession()` when `AppDelegate.isWitConfigured` is
  false.
- Keep both category selection and session activation below the guard.
- Keep the existing caught error path for configured local builds.

### U2: Extend Static And Documentation Contracts

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `CHANGES.md`
- Modify `VISION.md`

Approach:

- Require the empty-token guard and prove it precedes both audio-session calls.
- Require documentation and completed plan evidence.
- Record the exact SDK-free validation and avoid claiming simulator/device
  microphone behavior.

## Verification

- `make check` passed the SDK-free privacy baseline and root wrappers.
- Absolute-path `make check` passed from `/tmp`.
- `sh -n scripts/check-baseline.sh` and `git diff --check` passed.
- Seven isolated hostile mutations were rejected: removed, inverted, or
  displaced guards; removed category or activation calls; restored `try!`; and
  README drift.
- `xcodebuild` is unavailable, so no simulator, Swift compilation, microphone,
  Wit request, or physical-device behavior is claimed.
