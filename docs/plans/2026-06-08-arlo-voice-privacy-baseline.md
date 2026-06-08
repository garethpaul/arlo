# Arlo Voice Privacy Baseline

## Status

Completed

## Context

`arlo` is a legacy Swift iOS voice assistant prototype built with CocoaPods. It initializes AVAudioSession, configures Wit.ai voice capture, speaks a greeting, and displays a Siri-style waveform.

The current app force-unwraps audio-session setup with `try!`, which can crash during launch if the audio session cannot be configured. It also sets an empty Wit access token directly and logs voice/intention-related callbacks with `print(...)`. Voice input and intent results are privacy-sensitive, so the baseline should preserve empty committed credentials and avoid direct logging of captured audio or inferred intent data.

## Objectives

- Replace launch-time `try!` audio-session setup with explicit error handling.
- Keep the committed Wit.ai token placeholder empty without assigning a blank token at runtime.
- Remove direct debug logging of voice levels, audio callbacks, and Wit outcomes.
- Add an SDK-free source baseline script for credential, permission, and logging drift.
- Document the CocoaPods workspace and Xcode verification limits.

## Work Items

1. Update `AppDelegate.swift` to configure audio and Wit through small helper methods.
2. Keep a local empty token placeholder and only assign `Wit.sharedInstance().accessToken` when a non-empty token is supplied locally.
3. Remove direct `print(...)` calls that expose voice callback state or intent outcomes.
4. Add `scripts/check-baseline.sh` and `README.md`.
5. Run source checks plus any available Xcode discovery/build command.

## Verification

- `scripts/check-baseline.sh`
- `command -v xcodebuild` (not available in this Linux environment)
- `xcodebuild -list -workspace Arlo.xcworkspace` when Xcode is available

## Follow-Up Candidates

- Move Wit credentials into a documented local plist or xcconfig.
- Modernize Swift syntax, deployment target, CocoaPods, Wit, and waveform dependencies in a dedicated migration.
- Add simulator/device verification for microphone permissions, waveform animation, and speech synthesis.
