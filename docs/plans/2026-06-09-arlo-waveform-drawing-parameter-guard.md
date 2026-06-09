# Arlo Waveform Drawing Parameter Guard

status: completed

## Context

`SiriWaveformView.draw(_:)` force-unwrapped the graphics context and used
inspector-editable `numberOfWaves` and `density` values directly. A missing
context, zero-sized bounds, zero waves, or non-positive density could crash or
hang waveform rendering before the rest of the voice UI guardrails apply.

## Plan

- Guard drawing when UIKit does not provide a graphics context or drawable
  bounds.
- Clamp the rendered wave count before range iteration.
- Clamp density before advancing the x-coordinate loop.
- Remove graphics-context force unwraps from the waveform draw path.
- Extend the SDK-free baseline and maintenance docs for the drawing guard.

## Verification

- `scripts/check-baseline.sh`
- `git diff --check`
- `make check`
