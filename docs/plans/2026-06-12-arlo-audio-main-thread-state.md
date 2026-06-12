# Arlo Audio Main-Thread State

Status: Completed

## Context

Wit audio-power notifications and recording delegate callbacks update waveform
state and `CADisplayLink.isPaused` directly. The legacy SDK does not establish a
main-thread guarantee in this repository, so callbacks from an audio or network
queue can race the display link or mutate UIKit-adjacent state off the main
thread. A late power notification can also restore a stale nonzero level after
recording has stopped.

## Priority

Audio callbacks are asynchronous and user-triggered. Main-thread confinement
and an explicit recording-state guard prevent intermittent UI races and ensure
the waveform returns to zero when capture ends.

## Prioritized Engineering Backlog

1. Confine audio and recording UI state to the main queue now.
2. Add simulator/device coverage for Wit callback ordering when a maintained
   Xcode scheme and compatible SDK are available.
3. Replace the vendored legacy Wit integration and Swift 3 project in a
   separately scoped modernization effort.

## Requirements

- R1. Audio-power state mutations must execute on the main thread.
- R2. Recording start and stop callbacks must mutate display-link and waveform
  state on the main thread.
- R3. Audio levels must be ignored while recording is inactive.
- R3a. Late recording-start callbacks must not reactivate an inactive view.
- R4. Stopping capture must pause the display link, clear the stored level, and
  render a zero waveform.
- R5. Queued main-thread work must capture the view controller weakly.
- R6. Existing Wit delegate ownership, token, privacy, accessibility, and
  display-link lifecycle guards must remain intact.
- R7. README, security guidance, vision, changes, and the static baseline must
  document and protect the threading contract.

## Scope Boundaries

- Do not add real Wit credentials or modify microphone permission copy.
- Do not migrate Swift, CocoaPods, Wit, or waveform dependencies.
- Do not claim simulator or device verification from this Linux environment.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`

## Work Completed

- Added a shared main-thread execution helper using weak controller captures.
- Added explicit recording state and ignored late audio levels while inactive.
- Added visible-view state so stale recording-start callbacks are ignored after
  disappearance.
- Routed recording start, stop, teardown, display-link, and waveform mutations
  through centralized main-thread state handling.
- Extended the static baseline and maintenance documentation.
