# arlo

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/arlo` is a preserved Swift iOS voice-assistant prototype. It uses
speech synthesis, a Wit microphone control, and a Siri-style waveform to make
the legacy voice interaction flow inspectable.

The checked-in build is intentionally safe by default: its Wit token is empty,
so voice capture remains unavailable until a future local-settings mechanism
is added. The greeting, UI, source contracts, and SDK-free verification remain
useful without a credential.

## Repository Contents

- `Arlo/` - Swift application source, storyboard, assets, and privacy metadata
- `Arlo.xcworkspace` - CocoaPods-integrated Xcode entry point
- `Arlo.xcodeproj` - legacy project settings; do not open this instead of the
  workspace after installing pods
- `Pods/`, `Podfile`, and `Podfile.lock` - reviewed vendored Wit and waveform
  dependency graph
- `ArloUITests/` - preserved legacy UI-test target without a shared scheme
- `tests/` and `scripts/` - SDK-free lifecycle, HTTP policy, workflow,
  documentation, mutation, and Make authority verification
- `DEVICE_VERIFICATION.md` - privacy-safe exact-commit voice verification matrix
- `docs/plans/` - completed maintenance decisions and validation evidence

## Getting Started

### Supported Baseline

- Git
- macOS with Xcode with Swift 3 and the iOS 9.3 SDK compatibility needed by
  this legacy project
- CocoaPods with the locked Wit 4.1.0 and SCSiriWaveformView 1.0.3 dependency
  graph; `Podfile.lock` records CocoaPods 1.0.1 provenance
- A simulator or device capable of running the selected legacy iOS target for
  native UI inspection

### Setup

```bash
git clone https://github.com/garethpaul/arlo.git
cd arlo
pod install
open Arlo.xcworkspace
```

Use the workspace after `pod install`; opening `Arlo.xcodeproj` bypasses the
CocoaPods integration. Do not run `pod update` as routine setup because that
would replace the reviewed legacy dependency graph.

## Running or Using the Project

### Checked-In Empty-Token Mode

`Arlo/AppDelegate.swift` commits `private static let witAccessToken = ""`.
In that state, the voice control stays disabled, Wit delegate registration is
skipped, and launch does not initialize the Wit singleton or activate the
play-and-record audio session at launch. The greeting and non-voice UI can
still be inspected without transmitting speech or credentials.

### Configured Voice Mode

The repository does not yet provide an ignored local settings file or build
setting for a Wit token. Do not commit a token or replace the checked-in empty
placeholder. Configured voice verification remains blocked until the separate
roadmap item introduces a documented local configuration path; when that work
lands, use only synthetic phrases and the privacy rules in
[`DEVICE_VERIFICATION.md`](DEVICE_VERIFICATION.md).

## Testing and Verification

### SDK-Free Verification

The canonical portable gate is:

```sh
/usr/bin/make check
```

It runs the root authority harness, `make lint`, `make test`, `make build`, and
the source baseline in `scripts/check-baseline.sh`. These gates validate Swift
and project contracts, Wit lifecycle and HTTP policy behavior, hostile
mutations, workflow policy, completed plans, and the documented legacy
workspace boundary without loading a credential or user audio.

### Hosted Verification

GitHub Actions runs on pushes, pull requests, and manual dispatches. Ubuntu
runs the SDK-free baseline. macOS runs the native Foundation policy tests and
compiles the maintained Objective-C Wit policy sources. The workflow uses a
commit-pinned checkout action, read-only repository access, bounded runtimes,
and does not persist checkout credentials.

The legacy baseline is Swift 3.0, iOS deployment target 9.3, CocoaPods 1.0.1
provenance, Wit 4.1.0, and SCSiriWaveformView 1.0.3.

This host does not have `xcodebuild`, `pod`, or `swift`, so full build, test, and CocoaPods verification must happen on a macOS machine with the matching legacy toolchain. The root `make test` and `make build` targets preserve the source preflight and report that Xcode workspace verification requires a checked-out macOS environment because no shared build or UI-test scheme is checked in.

### Exact-Commit Device Verification

Use [`DEVICE_VERIFICATION.md`](DEVICE_VERIFICATION.md) for the exact-commit
Arlo voice matrix. It covers empty/configured token modes, microphone
permission, recording and waveform state, delegate ownership, interruptions,
backgrounding, relaunch, privacy-safe evidence, and explicit unexecuted rows.

Full workspace, simulator, microphone, and configured-Wit verification remain
a macOS legacy-toolchain task and must not be inferred from portable or hosted
policy checks.
Caller-supplied startup makefiles, additional `-f` makefiles with appended double-colon recipes, target-specific override directives, and PATH-based default Python discovery remain caller authority; use the hosted workflow or pass literal trusted tool paths for repository-controlled verification.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- The scan found credential-adjacent names. Review configuration paths before running against real accounts.
- The voice button stays disabled until a bounded local Wit access token without whitespace or control characters is supplied outside the committed placeholder.
- The compiled vendored Wit VAD tracker sends a configured token only in the
  Authorization header and never writes the token or request URL to device logs.
- Wit request diagnostics retain only HTTP method metadata and never complete request URLs or serialized context.
- Wit network error diagnostics retain only error domain and numeric code, never descriptions, userInfo, or request metadata.
- Wit processing error diagnostics use a constant message and never provider response fields.
- Wit response diagnostics retain timing and status metadata without logging response bodies.
- Wit HTTP responses must be successful JSON objects within a one-megabyte limit; nested provider errors, request URLs, and payloads are not propagated through diagnostic errors.
- Voice capture activates the play-and-record session only after an owned recording session starts and deactivates it on failure or stop.
- The vendored Wit context setter no longer prompts for location, starts location monitoring, or attaches coordinates to voice requests.

## Security and Privacy Notes

- Review changes touching authentication or token handling; examples from the scan include Arlo/AppDelegate.swift, docs/plans/2026-06-08-arlo-audio-privacy-baseline.md, scripts/check-baseline.sh.
- Review changes touching external API calls or credential-adjacent configuration; examples from the scan include Arlo/AppDelegate.swift, docs/plans/2026-06-08-arlo-audio-privacy-baseline.md, scripts/check-baseline.sh.
- Review changes touching network requests, sockets, or service endpoints; examples from the scan include Arlo/Info.plist, Arlo/ViewController.swift, ArloUITests/Info.plist.
- Review changes touching mobile permissions or privacy-sensitive device data; examples from the scan include Arlo/Info.plist, docs/plans/2026-06-08-arlo-audio-privacy-baseline.md, scripts/check-baseline.sh.
- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include Arlo/Info.plist, Arlo/ViewController.swift, ArloUITests/Info.plist.

## Maintenance Notes

- This looks like an Apple platform project or sample. Xcode, Swift, CocoaPods, and deployment target versions may need to match the original project era.
- The waveform uses Wit `WITAudioPowerChanged` notifications for audio levels
  and keeps the display link limited to animation cadence.
- The waveform treats non-finite Wit audio-power values as silence before
  updating the UI.
- Wit audio-power notifications and recording callbacks confine waveform and
  display-link state to the main queue, ignore late levels while inactive, and
  clear the waveform when capture stops. Late recording-start callbacks cannot
  reactivate an off-screen controller.
- Waveform updates tolerate a missing storyboard outlet through an optional
  update helper.
- Waveform drawing clamps inspector wave count and density values, and skips
  drawing when UIKit does not provide a valid graphics context or bounds.
- With the committed empty Wit token, the microphone control is dimmed and disabled
  so demo builds do not invite recording attempts before local credential setup.
- The same empty-token builds do not activate the play-and-record audio session
  at launch; configured local builds retain the guarded audio setup path.
- The microphone control exposes the `arlo.voice.microphone` accessibility
  identifier for UI tests and assistive technology.
- Wit delegate is registered only while the view is visible, and active voice
  capture is stopped when the view disappears.
- A disappearing controller only stops capture or clears the delegate when it
  still owns the Wit singleton, so stale lifecycle callbacks cannot interrupt a
  newer visible voice screen.
- Wit delegate registration is skipped while the committed token placeholder is
  empty.
- Wit responses accept only `application/json` or an RFC 6838 ASCII
  restricted-name `application/*+json` media type. Unicode case-folding
  lookalikes, suffix-like text in parameters, and non-application types are
  rejected before JSON parsing.
- The empty-token lifecycle does not initialize the Wit singleton during launch
  configuration or delegate teardown; configured local builds retain token,
  speech-stop, capture-stop, and ownership behavior.
- The microphone permission text describes user-triggered Wit voice capture.
  No location permission text is declared, and the maintained vendored Wit
  context helper no longer requests, monitors, or transmits location.
- Root `make lint`, `make test`, `make build`, and `make check` keep the
  SDK-free baseline available before macOS-only workspace verification,
  including when invoked outside the repository root with `make -f`.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `docs/plans/2026-06-09-arlo-make-gate-targets.md` for the root gate
  target baseline.
- See `docs/plans/2026-06-09-arlo-wit-delegate-lifecycle.md` for the Wit
  delegate lifecycle guard.
- See `docs/plans/2026-06-09-arlo-empty-token-delegate-guard.md` for the
  empty-token Wit delegate guard.
- See `docs/plans/2026-06-09-arlo-waveform-outlet-guard.md` for the waveform
  outlet guard.
- See `docs/plans/2026-06-09-arlo-waveform-drawing-parameter-guard.md` for the
  waveform drawing parameter guard.
- See `docs/plans/2026-06-10-ci-baseline.md` for the GitHub Actions static
  baseline.
- See `docs/plans/2026-06-10-arlo-wit-delegate-ownership.md` for the singleton
  delegate ownership guard.
- See `docs/plans/2026-06-12-arlo-audio-main-thread-state.md` for main-thread
  waveform state and late-notification guards.
- See `docs/plans/2026-06-13-arlo-empty-token-audio-session.md` for the launch
  audio-session privacy boundary.
- See `docs/plans/2026-06-13-arlo-empty-token-wit-isolation.md` for the
  empty-token Wit singleton initialization boundary.
- See `docs/plans/2026-06-14-arlo-device-verification-checklist.md` for the
  simulator/device evidence matrix and runtime non-claims.
- See `docs/plans/2026-06-19-wit-json-media-type-boundary.md` for the strict Wit
  response media-type boundary.
- See `VISION.md` for project direction and contribution guardrails.
- See `CHANGES.md` for the maintenance history.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
