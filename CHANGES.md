# Arlo Changes

## 2026-06-26 15:00 - P1 - Keep launch greeting visible-view scoped

- Arlo starts its one-time synthesized greeting only after the controller becomes active and visible, preventing preloaded or off-screen views from emitting speech.
- Added red-first lifecycle coverage and hostile mutations for missing active-view, one-time, and ownership-claim boundaries.
- Preserved the greeting copy, Australian voice, recording-start interruption, token behavior, and microphone flow.
- Focused lifecycle and full hostile mutation suites passed after the initial
  assertion failed on `viewDidLoad` speech.
- Repository and external-directory `/usr/bin/make check`, shell syntax,
  Python syntax, and `git diff --check` passed. Native app execution remains
  unavailable on this Linux host and requires hosted legacy-macOS validation.
- Hosted check run `28269325572` passed the static baseline and native
  Foundation policy suite, and CodeQL run `28269325690` passed Actions and
  Python analysis on implementation head
  `7739ed06f9860e77ef3533827d9a3168a307d792`.
- Codex review was attempted against `origin/master` but stopped before analysis
  with OpenAI HTTP 401; immutable manual review found no actionable issues.

## 2026-06-26 11:05 - P1 - Prevent launch-greeting self-capture

- Wit recording start stops the app-generated greeting before recording UI activates, preventing continued self-capture after capture begins.
- Added failing-first source ordering coverage and a hostile lifecycle mutation
  for removal of the speech-stop boundary.

## 2026-06-26 01:54 - P2 - Document runnable setup boundaries

### Summary

Replaced generated setup notes with a source-backed Arlo setup and verification
guide. The guide distinguishes the safe checked-in empty-token mode from the
still-unimplemented configured voice mode without changing legacy app behavior.

### Work completed

- Documented the Swift 3/iOS 9.3, CocoaPods 1.0.1, Wit 4.1.0, and
  SCSiriWaveformView 1.0.3 baseline.
- Made `Arlo.xcworkspace` the explicit post-`pod install` entry point and warned
  against bypassing the reviewed pod integration or running routine updates.
- Documented empty-token launch behavior, the missing ignored local token
  mechanism, portable and hosted gates, and exact-commit device evidence.
- Retired only the completed README roadmap item and retained local Wit settings
  as the next distinct configuration task.

### Threads

- None. The cycle was completed directly to avoid overlapping active public
  pull requests in other repositories.

### Files changed

- `README.md` — added supported baseline, setup, token-mode, and verification guidance.
- `VISION.md` — recorded the maintained guide boundary and removed the completed item.
- `scripts/check-baseline.sh` — added fail-closed setup-guide contracts.
- `docs/plans/2026-06-26-arlo-setup-guide.md` — recorded the implementation plan.

### Validation

- `scripts/check-baseline.sh` — passed after an expected red documentation-contract run.
- Nineteen hostile setup-guide mutations — all rejected, covering toolchain,
  workspace, dependency, token-mode, canonical gate, hosted coverage, device,
  roadmap, change-history, and plan-status drift.
- `/usr/bin/make check` — passed from the checkout and an external working
  directory, including Make authority, baseline, Wit lifecycle, and mutation
  gates. Native Foundation policy tests and Xcode build/UI tests reported their
  documented non-macOS skips.

### Bugs / findings

- The previous README told users to run the CocoaPods install but then open the
  project instead of the workspace.
- The repository has no safe ignored local settings path for configured Wit
  voice mode; this remains an explicit roadmap item rather than a hidden setup step.

### Blockers

- Configured voice, simulator, microphone, and device behavior cannot be
  claimed without a future local settings mechanism and exact-commit macOS/device evidence.
- This Linux host cannot execute macOS Foundation policy tests, CocoaPods,
  `xcodebuild`, the iOS simulator, microphone capture, or live Wit behavior;
  hosted macOS checks remain required before merge.

### Next action

- Add a documented, ignored local Wit configuration path in a dedicated change.

## 2026-06-21

- Bound hosted and contributor verification to `/usr/bin/make` and added an
  executable authority harness for shell, root, Python, Xcode, startup-file,
  later-Makefile, and unsafe-mode boundaries.

## 2026-06-19

- Validated local Wit tokens before enabling voice UI, allocating audio, or constructing Authorization headers.
- Moved audio-session activation into the owned recording lifecycle and added symmetric failure/stop deactivation.
- Preserved recording-session ownership until its response arrives and rejected stale session and text-request completions.
- Added bounded HTTPS query, status, MIME, response-size, JSON-object, and sanitized-error policy shared by speech and text requests.
- Removed undeclared location permission, monitoring, and coordinate attachment from the vendored Wit context setter.
- Added native fake-response tests, static lifecycle contracts, hostile mutations, and a hosted macOS compile gate.
- Restricted accepted response media types to `application/json` or an RFC 6838
  ASCII restricted-name `application/*+json` subtype before parameter handling,
  without Unicode case folding.

- Wit processing error diagnostics use a constant message and never provider response fields.
- Wit network error diagnostics retain only error domain and numeric code, never descriptions, userInfo, or request metadata.
- Wit request diagnostics retain only HTTP method metadata and never complete request URLs or serialized context.
- Removed full Wit response bodies from debug logs while retaining response
  timing and HTTP status diagnostics.
- Removed the compiled vendored Wit VAD diagnostic that logged configured
  bearer tokens and request URLs, and added a fail-closed source contract.

## 2026-06-14

- Added an exact-commit Arlo device verification matrix for empty/configured
  token modes, microphone permission, recording and waveform state, delegate
  ownership, interruption, backgrounding, relaunch, and privacy-safe evidence, with every runtime row explicitly unexecuted.

## 2026-06-13

- Guarded empty-token launch and teardown paths before Wit singleton access while
  preserving configured token, speech-stop, capture-stop, and delegate behavior.
- Prevented the default empty-token build from configuring or activating a
  play-and-record audio session during launch.
- Preserved audio-session setup and caught failures for locally configured Wit
  builds.

## 2026-06-12

- Disabled checkout credential persistence in the canonical SDK-free Check job
  and added exact repository contracts for that boundary.
- Confined Wit audio-power and recording callback UI state to the main queue.
- Added explicit recording state so late audio notifications cannot restore a
  stale waveform after capture stops.
- Prevented queued recording-start callbacks from reactivating an off-screen
  voice controller.
- Centralized recording start/stop display-link and waveform reset behavior.

## 2026-06-10

- Made Wit singleton teardown ownership-aware so stale view lifecycle callbacks
  cannot stop capture or clear the delegate of a newer visible controller.
- Made root Makefile checks location-independent and pinned CI to the stable
  Ubuntu 24.04 runner image.
- Added a GitHub Actions workflow that runs the SDK-free `make check` baseline
  while keeping full workspace verification scoped to a macOS legacy toolchain.
- Pinned the checkout action and limited the workflow token to read-only
  repository access with bounded execution.

## 2026-06-09

- Guarded waveform drawing against missing graphics contexts, empty bounds, and
  invalid inspector wave-count or density values.
- Routed waveform updates through an optional outlet helper so storyboard wiring
  drift cannot crash display-link or recording-stop callbacks.
- Skipped Wit singleton delegate registration while the committed access-token
  placeholder is empty.
- Scoped the Wit singleton delegate to the visible view lifecycle and stop
  active voice capture when the view disappears.
- Added root `make lint`, `make test`, `make build`, and `make check` gates
  around the SDK-free Arlo baseline and documented Xcode scheme limits.
- Guarded waveform normalization so non-finite Wit audio-power values render as
  silence instead of reaching the waveform view.
- Tightened privacy metadata by removing the unused location usage description
  and replacing generic microphone text with user-triggered Wit capture copy.
- Added a stable `arlo.voice.microphone` accessibility identifier and VoiceOver
  label/hint to the Wit microphone control.
- Hid the decorative microphone logo from accessibility focus and replaced the
  generated empty UI test with a disabled empty-token microphone assertion.
- Extended the SDK-free baseline and README notes for the microphone
  accessibility contract.

## 2026-06-08

- Disabled the Wit mic button while the committed access token placeholder is
  empty.
- Updated waveform metering to use Wit `WITAudioPowerChanged` audio power
  notifications instead of display-layer scale.
- Added `make check` as the SDK-free Arlo baseline wrapper.
- Added a changelog for repository maintenance.
- Restored README verification notes for the source-level privacy and lifecycle baseline.
- Extended the baseline script to require changelog and local toolchain-limit documentation.
