---
title: Arlo Empty Token Mic Guard
type: fix
status: completed
date: 2026-06-08
---

# Arlo Empty Token Mic Guard

## Summary

Keep the Wit microphone control disabled when the checked-in token placeholder
is empty, while preserving the existing no-secret-in-source baseline.

## Requirements

- R1. The committed Wit access token placeholder remains empty.
- R2. Runtime Wit token assignment is guarded by a non-empty configuration state.
- R3. The microphone button is disabled and visibly dimmed until Wit is configured.
- R4. README and changelog notes document the placeholder-token behavior.
- R5. The SDK-free baseline verifies the source-level guard.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`

This environment does not provide XcodeBuildMCP, `xcodebuild`, `pod`, or
`swift`, so simulator/device verification remains follow-up work on a matching
legacy macOS toolchain.
