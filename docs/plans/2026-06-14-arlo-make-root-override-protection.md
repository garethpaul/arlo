---
title: Arlo Make Root Override Protection
type: reliability
status: completed
date: 2026-06-14
---

# Arlo Make Root Override Protection

## Status: Completed

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

- `sh -n scripts/check-baseline.sh` and `dash -n scripts/check-baseline.sh`
  passed.
- All four Make gates passed through `make lint`, `make test`, `make build`,
  and `make check`; the legacy Xcode build and simulator steps were truthfully
  skipped because `xcodebuild` is unavailable on this Linux host.
- `make ROOT=/tmp check` passed and still executed the repository checker.
- The full gate passed from `/tmp` through the absolute Makefile path, covering
  the external working directory.
- Four isolated hostile mutations were rejected: overrideable root, missing
  plan, reopened plan, and missing verification evidence.
- `git diff --check`, intended-path review, artifact inspection, and the
  changed-line secret scan passed.
- No simulator, Swift compilation, microphone, Wit request, or physical-device
  behavior is claimed.
