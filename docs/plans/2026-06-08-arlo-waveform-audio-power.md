---
title: Arlo Waveform Audio Power
type: fix
status: completed
date: 2026-06-08
---

# Arlo Waveform Audio Power

## Summary

Drive the Siri-style waveform from Wit audio power notifications instead of
using the microphone button layer scale as an audio proxy.

## Requirements

- R1. Observe the Wit `WITAudioPowerChanged` notification in `ViewController`.
- R2. Normalize the Wit audio power value before updating the waveform.
- R3. Keep `CADisplayLink` as the animation cadence source.
- R4. Stop using `volumeLayer.contentsScale` as a waveform level input.
- R5. Remove notification observers during teardown.
- R6. Expose `make check` as the root SDK-free verification command.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`

This environment does not provide XcodeBuildMCP, `xcodebuild`, `pod`, or
`swift`, so simulator/device verification remains follow-up work on a matching
legacy macOS toolchain.
