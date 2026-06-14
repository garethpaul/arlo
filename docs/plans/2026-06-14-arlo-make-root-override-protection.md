---
title: Arlo Make Root Override Protection
type: reliability
status: in_progress
date: 2026-06-14
---

# Arlo Make Root Override Protection

## Status: In Progress

## Problem Frame

The Makefile derives its root from `MAKEFILE_LIST`, but a command-line `ROOT`
assignment still takes precedence. A hostile caller can redirect all SDK-free
verification targets away from the checked-out repository.

## Scope Boundaries

- Protect only the repository-derived `ROOT`; preserve the intentional
  `XCODEBUILD` override.
- Preserve all existing SDK-free source, project, workflow, privacy, and
  lifecycle contracts.
- Do not modify Swift, project files, CocoaPods, or vendored dependencies.
- Keep native Xcode, simulator, microphone, and Wit behavior explicitly outside
  Linux-host validation.

## Implementation Units

### U1: Protect The Make Root

- Use GNU Make's `override` directive for the repository-derived root.
- Preserve the existing target graph and legacy toolchain messages.

### U2: Extend Static Contracts

- Require the protected assignment and this completed plan in
  `scripts/check-baseline.sh`.
- Reject overrideable-root, missing-plan, reopened-plan, and missing-evidence
  mutations.

## Verification

Pending implementation and validation.
