# Arlo Make Gate Targets

Status: Completed
Date: 2026-06-09

## Goal

Expose standard root verification targets for the legacy iOS sample without
claiming that a full Xcode build or simulator UI-test run can execute on hosts
without the matching Apple toolchain.

## Changes

- Added root `make lint`, `make test`, `make build`, `make verify`, and
  `make check` targets.
- Kept each target tied to the SDK-free source baseline so privacy, token,
  waveform, accessibility, CocoaPods, and project-setting guardrails run on any
  host.
- Made `make test` and `make build` report the missing Xcode/shared-scheme
  limitation instead of silently implying simulator or device verification ran.
- Extended README, changelog, vision, and source-baseline checks for the new
  gate contract.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`

Full Xcode build, simulator UI tests, and CocoaPods verification still require a
macOS host with the legacy Swift 3.0 toolchain.
