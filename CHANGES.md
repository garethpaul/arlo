# Arlo Changes

## 2026-06-09

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
