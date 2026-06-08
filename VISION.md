## Arlo Vision

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
- Keep UI behavior simple enough to inspect from `ViewController.swift`

Next priorities:

- Add README setup and verification instructions
- Move any required voice-service configuration into documented local settings
- Modernize Swift, iOS deployment target, Wit, and waveform dependencies in a
  dedicated pass
- Add tests or manual verification notes for voice capture and speech output

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

Future assistant capabilities should make captured data, remote processing, and
user-visible actions explicit.

## What We Will Not Merge (For Now)

- Voice-service credentials or signing files
- Background recording behavior
- Broad assistant capabilities without documented intent handling
- Dependency migrations that cannot be opened through the workspace

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
