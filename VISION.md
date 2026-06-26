## Arlo Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

Arlo is a Swift iOS voice personal assistant prototype. It combines speech
synthesis, Wit.ai voice capture, and a Siri-style waveform UI.

The repository is useful as a preserved experiment in mobile voice interaction,
assistant presentation, and early Swift/CocoaPods integration.

The goal is to keep the prototype understandable while making any future voice,
credential, or dependency work explicit and safe.

The current focus is:

Priority:

- Preserve the voice greeting, microphone button, waveform, and Wit delegate flow
- Keep the CocoaPods workspace as the build entry point
- Avoid committing Wit.ai credentials, generated signing material, or user audio
- Keep the microphone control accessible and test-addressable
- Keep Wit delegate ownership scoped to the visible voice view lifecycle
- Keep Wit singleton teardown conditional on the calling controller still
  owning the delegate
- Keep Wit delegate registration disabled while the committed token is empty
- Keep empty-token launches from activating unavailable voice audio resources
- Keep empty-token launch and teardown paths from initializing the Wit singleton
- Keep waveform rendering resilient to malformed voice-power values
- Keep asynchronous audio and recording UI state confined to the main queue
- Ignore late Wit audio levels after recording becomes inactive
- Prevent stale Wit recording-start callbacks from reactivating hidden views
- Keep waveform updates resilient to missing storyboard outlets
- Keep waveform drawing resilient to invalid inspector parameters
- Keep iOS privacy permission text specific to the app behavior that exists
- Keep root lint, test, and build gates tied to the SDK-free iOS baseline
- Keep GitHub Actions aligned with the SDK-free `make check` baseline
- Keep non-persisted checkout credentials in hosted verification
- Keep UI behavior simple enough to inspect from `ViewController.swift`
- Keep exact-commit Arlo device verification matrix evidence separate from
  portable checks, with unexecuted Xcode, microphone, Wit, and device rows
  explicit
- Keep README setup and verification guidance synchronized with the workspace,
  token boundary, and canonical gates

Next priorities:

- Move any required voice-service configuration into documented local settings
- Modernize Swift, iOS deployment target, Wit, and waveform dependencies in a
  dedicated pass
- Add tests or manual verification notes for voice capture and speech output
- Execute the device verification matrix with synthetic phrases and
  privacy-safe permission, recording, lifecycle, and interruption evidence

Contribution rules:

- One PR = one focused voice, UI, build, or documentation change.
- Open and build the workspace after running `pod install`.
- Document toolchain limits when an Apple build cannot be verified locally.
- Keep assistant behavior conservative until intents and privacy expectations
  are documented.

## Security And Privacy

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Voice input and intent recognition are sensitive. Do not commit access tokens,
recorded audio, transcripts, or service credentials.
Do not log configured voice-service tokens or credential-bearing request URLs,
including from checked-in vendored SDK code.
Wit request diagnostics retain only HTTP method metadata and never complete request URLs or serialized context.
Wit network error diagnostics retain only error domain and numeric code, never descriptions, userInfo, or request metadata.
Wit processing error diagnostics use a constant message and never provider response fields.
Do not log voice-service response bodies; retain only non-sensitive timing and
status diagnostics.
Do not declare unused privacy permissions, and keep microphone permission copy
specific about user-triggered Wit voice capture.

Future assistant capabilities should make captured data, remote processing, and
user-visible actions explicit.

## What We Will Not Merge (For Now)

- Voice-service credentials or signing files
- Background recording behavior
- Broad assistant capabilities without documented intent handling
- Dependency migrations that cannot be opened through the workspace

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
