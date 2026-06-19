---
title: Checkout Credential Boundary
date: 2026-06-12
status: completed
execution: code
---

# Checkout Credential Boundary

## Summary

Prevent the canonical SDK-free Check job from leaving its GitHub token in the
working copy after checkout, while preserving the legacy Swift application,
workflow triggers, and verification behavior.

## Requirements

- Set `persist-credentials: false` on the only checkout step.
- Add exact SDK-free contracts for the checkout count, immutable action pin,
  credential setting, read-only permissions, and absence of bypasses.
- Preserve the existing Ubuntu 24.04 `make check` job and default CodeQL setup.
- Pass repository/external-working-directory checks and focused mutations.

## Scope And Verification

This unit changes only the Check workflow, static contracts, guidance, and
evidence. It does not alter Swift, Objective-C, CocoaPods, Xcode project, audio,
Wit token, UI, or runtime behavior.

## Work Completed

- Disabled checkout credential persistence on the only checkout step.
- Added exact SDK-free contracts for checkout count, action pin, permissions,
  command count, bypass absence, documentation, and plan evidence.
- Preserved the default CodeQL setup and every application/dependency file.

## Verification Completed

- The untouched baseline passed from the repository and an external working directory.
- `make check` passed after implementation with the documented unavailable
  macOS/Xcode toolchain limitation.
- Focused hostile mutations rejected missing credential protection, duplicate
  checkout, mutable action, write permission, command bypass, documentation,
  and incomplete plan drift; all hostile mutations rejected as expected.
- Workflow YAML parsing, `sh -n scripts/check-baseline.sh`, `git diff --check`,
  and the secret-pattern scan passed.

## Hosted Verification

Exact-head Check and default CodeQL evidence will be recorded after push.
Tracker reconciliation remains pending until both are terminal green.
