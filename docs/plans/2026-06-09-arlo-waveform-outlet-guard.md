# Arlo Waveform Outlet Guard

status: completed

## Context

`ViewController` updated the Siri waveform through an implicitly unwrapped
IBOutlet. If storyboard wiring drifted or the outlet was unavailable during a
display-link or Wit delegate callback, waveform updates could crash the voice
screen.

## Objectives

- Preserve the existing waveform display link and Wit audio-power flow.
- Keep invalid audio-power values rendering as silence.
- Make waveform updates tolerate a missing storyboard outlet.
- Keep the guard covered by the SDK-free baseline checker.

## Work Completed

- Made the waveform outlet optional.
- Added `updateWaveform(level:)` as the single optional-outlet update path.
- Routed display-link and stop-recording updates through the helper.
- Extended `scripts/check-baseline.sh`.
- Updated README, VISION, and CHANGES notes.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
