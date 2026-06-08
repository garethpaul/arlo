---
title: Arlo Audio Privacy and Lifecycle Baseline
type: fix
status: completed
date: 2026-06-08
---

# Arlo Audio Privacy and Lifecycle Baseline

## Summary

Raise the baseline for the legacy Arlo iOS voice demo by making audio-session
startup non-crashing, adding the required microphone privacy description,
cleaning up the waveform display link lifecycle, preserving empty Wit.ai
credentials, and adding source-level verification documentation.

---

## Problem Frame

The app force-tries audio session configuration during launch, which can crash
the app if the session category or activation fails. It also records audio via
the Wit mic button without a committed microphone usage description, and the
waveform `CADisplayLink` is initialized as a concrete value before being
replaced in `viewDidLoad` and is never invalidated. This host does not have
`xcodebuild`, so the pass needs source checks instead of simulator builds.

---

## Requirements

- R1. Audio session configuration must not use `try!`.
- R2. The committed Wit access token placeholder must remain empty.
- R3. `Info.plist` must include `NSMicrophoneUsageDescription`.
- R4. The waveform display link must be optional, paused when idle, and invalidated during teardown.
- R5. The source check must verify Swift version, deployment target, CocoaPods pins, privacy metadata, credential placeholders, and lifecycle safeguards.
- R6. Documentation must explain the legacy Swift/CocoaPods toolchain and the local verification limitation.

---

## Key Technical Decisions

- **Handle audio errors without aborting launch:** The app is a demo and should
  log audio-session configuration failures instead of crashing immediately.
- **Keep credentials out of source:** The Wit token remains an empty committed
  placeholder; real tokens belong in local configuration for future work.
- **Do source-level verification:** Xcode and simulator tooling are not
  available here, so this pass adds an SDK-free guardrail and documents the
  missing build step.
- **Avoid pod churn:** The repo has committed CocoaPods output from CocoaPods
  1.0.1; this pass does not run `pod install` or rewrite vendored Pods.

---

## Scope Boundaries

- This pass does not migrate Swift 3 syntax, Xcode project settings, or CocoaPods versions.
- This pass does not replace Wit.ai or SCSiriWaveformView.
- This pass does not add real Wit credentials.
- This pass does not build or launch the app on a simulator because Xcode tooling is unavailable in this environment.

---

## Implementation Units

### U1. Harden Audio Startup

- **Goal:** Prevent launch-time crashes from audio-session setup failures.
- **Files:** `Arlo/AppDelegate.swift`
- **Patterns:** Use `do/catch`, explicit `AVFoundation` import, and `NSLog` on failure.
- **Test Scenarios:**
  - Source check fails if `try! AVAudioSession` returns.
  - Source check fails if `Wit.sharedInstance().accessToken = ""` changes.
- **Verification:** `scripts/check-baseline.sh`

### U2. Guard Mic Privacy and Waveform Lifecycle

- **Goal:** Keep microphone behavior explicit and avoid retaining display-link resources unnecessarily.
- **Files:** `Arlo/Info.plist`, `Arlo/ViewController.swift`
- **Patterns:** Add microphone usage text; make `CADisplayLink` optional; pause it until recording starts; invalidate it during teardown.
- **Test Scenarios:**
  - Source check fails if microphone usage description is removed.
  - Source check fails if display-link invalidation is removed.
  - Source check fails if the per-frame `print(talk)` log returns.
- **Verification:** `scripts/check-baseline.sh`

### U3. Document and Check the Legacy Baseline

- **Goal:** Leave maintainers with a repeatable source gate and clear build limitation.
- **Files:** `README.md`, `scripts/check-baseline.sh`
- **Patterns:** Short toolchain, verification, and modernization notes.
- **Test Scenarios:**
  - README documents `scripts/check-baseline.sh`.
  - Script checks Swift 3, iOS 9.3, CocoaPods 1.0.1 lockfile pins, and missing local Xcode build support.
- **Verification:** `scripts/check-baseline.sh`, `git diff --check`

---

## Risks & Dependencies

- Runtime microphone and Wit behavior still needs an Xcode/simulator/device pass.
- Swift 3 and the old Pods may require an older Xcode toolchain.
- Real Wit token management remains follow-up work.

---

## Sources / Research

- `Arlo/AppDelegate.swift` configures `AVAudioSession` and the Wit token.
- `Arlo/ViewController.swift` owns the waveform display link and Wit mic button.
- `Arlo/Info.plist` contains app privacy metadata.
- `Podfile.lock` pins Wit 4.1.0, SCSiriWaveformView 1.0.3, and CocoaPods 1.0.1.
- `Arlo.xcodeproj/project.pbxproj` pins Swift 3.0 and iOS deployment target 9.3.
