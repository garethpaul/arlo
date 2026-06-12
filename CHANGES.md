# Arlo Changes

## 2026-06-12

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
