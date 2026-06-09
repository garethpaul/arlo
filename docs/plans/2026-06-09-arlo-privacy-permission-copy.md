---
title: Arlo Privacy Permission Copy
type: privacy
status: completed
date: 2026-06-09
---

# Arlo Privacy Permission Copy

## Problem Frame

`Info.plist` contained a generic microphone usage string and a location usage
description even though this source tree has no CoreLocation flow. For a voice
assistant prototype, permission copy should explain the actual user-triggered
voice capture behavior and avoid declaring unused privacy surfaces.

## Scope Boundaries

- Preserve the existing Wit microphone flow and empty-token guard.
- Do not add real Wit credentials or change runtime audio capture behavior.
- Do not modernize Swift, CocoaPods, or deployment targets in this pass.
- Keep verification SDK-free because this host lacks `xcodebuild`, `pod`, and
  `swift`.

## Implementation Units

### U1: Tighten Privacy Metadata

Files:

- Modify `Arlo/Info.plist`

Approach:

- Replace the generic microphone usage description with copy that names
  user-triggered voice input and Wit.ai processing.
- Remove the unused location usage description because no app source references
  CoreLocation or location requests.

### U2: Guard The Permission Contract

Files:

- Modify `scripts/check-baseline.sh`

Approach:

- Fail if the microphone usage string stops describing user-triggered Wit voice
  capture.
- Fail if the unused location usage description returns.
- Fail if README stops documenting the permission-text baseline.

### U3: Document The Privacy Decision

Files:

- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Record that committed privacy permission text must match actual app behavior.
- Keep future assistant/privacy work from expanding permissions silently.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
