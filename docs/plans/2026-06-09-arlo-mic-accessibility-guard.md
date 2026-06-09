# Arlo Mic Accessibility Guard

## Status: Completed

## Goal

Give the programmatic Wit microphone control a stable accessibility contract so
the disabled empty-token state is inspectable by VoiceOver and UI tests.

## Scope

- Add a stable accessibility identifier and label to the microphone control.
- Keep the accessibility hint aligned with the configured or unavailable Wit
  state.
- Hide the decorative logo from accessibility focus.
- Replace the empty generated UI test with a source-level UI assertion for the
  disabled empty-token microphone state.
- Extend the SDK-free baseline and docs for the mic accessibility contract.

## Out Of Scope

- Adding real Wit credentials or changing token storage.
- Migrating Swift, Xcode project settings, CocoaPods, or vendored Pods.
- Running simulator UI tests on this non-macOS host.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`
