# Arlo Waveform Power Finite Guard

Status: Completed
Date: 2026-06-09

## Goal

Keep waveform rendering stable when Wit audio-power notifications carry malformed
numeric values.

## Changes

- Returned a silent waveform level for non-finite `Float` values before
  normalization.
- Extended the SDK-free baseline to require the finite-value guard and plan.
- Documented the waveform resilience contract in the README, changelog, and
  vision.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Full Xcode build, simulator UI tests, and CocoaPods verification still require a
macOS host with the legacy Swift 3.0 toolchain.
