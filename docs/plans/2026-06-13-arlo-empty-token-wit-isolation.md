---
title: Arlo Empty-Token Wit Singleton Isolation
type: privacy
status: planned
date: 2026-06-13
---

# Arlo Empty-Token Wit Singleton Isolation

## Status: Planned

## Problem Frame

The committed Wit access-token placeholder is empty, the microphone control is
disabled, delegate registration is skipped, and audio-session activation is
already guarded. Launch still calls `Wit.sharedInstance()` to set speech-stop
behavior, and view teardown calls the singleton before checking delegate
ownership. The default no-token build therefore initializes voice-service state
even though voice capture cannot be used.

## Scope Boundaries

- Preserve the empty committed token placeholder and disabled microphone state.
- Preserve Wit access-token, speech-stop, delegate, capture-stop, and ownership
  behavior when a local token is supplied.
- Do not add credentials, move configuration into source control, or update
  CocoaPods, Swift, deployment targets, project files, or vendored dependencies.
- Keep verification SDK-free because this Linux host lacks `xcodebuild`, a
  simulator, microphone access, and the legacy Swift/CocoaPods toolchain.

## Implementation Units

### U1: Guard Launch-Time Wit Configuration

Files:

- Modify `Arlo/AppDelegate.swift`

Approach:

- Return from `configureWit()` before retrieving the singleton when the token
  placeholder is empty.
- Configure the access token and speech-stop behavior through one local Wit
  instance only for configured builds.

### U2: Guard Ownership Teardown Before Singleton Access

Files:

- Modify `Arlo/ViewController.swift`

Approach:

- Return from `releaseWitDelegateIfOwned(stopCapture:)` before retrieving the
  singleton when Wit is not configured.
- Preserve identity-checked capture stop and delegate clearing for configured
  builds and all existing lifecycle call sites.

### U3: Extend Source And Documentation Contracts

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `CHANGES.md`
- Modify `VISION.md`

Approach:

- Require method-local empty-token guards to precede every singleton access in
  launch configuration and delegate teardown.
- Preserve the existing audio-session, microphone, delegate ownership, and
  checkout-credential contracts.
- Add isolated hostile mutations for missing, misplaced, and bypassed guards,
  configured behavior, documentation, and completed plan evidence.

## Verification Plan

- Run `make check` from the repository and by absolute path from `/tmp`.
- Run `sh -n scripts/check-baseline.sh` and `git diff --check`.
- Require each isolated hostile mutation to fail the static checker.
- Record simulator, Swift compilation, microphone, Wit request, and physical
  device verification as unavailable rather than inferred.
