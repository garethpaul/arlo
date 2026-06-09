#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
APP_DELEGATE="$ROOT_DIR/Arlo/AppDelegate.swift"
VIEW_CONTROLLER="$ROOT_DIR/Arlo/ViewController.swift"
UI_TESTS="$ROOT_DIR/ArloUITests/ArloUITests.swift"
INFO_PLIST="$ROOT_DIR/Arlo/Info.plist"
PROJECT_FILE="$ROOT_DIR/Arlo.xcodeproj/project.pbxproj"
PODFILE="$ROOT_DIR/Podfile"
POD_LOCK="$ROOT_DIR/Podfile.lock"
MIC_ACCESSIBILITY_PLAN="$ROOT_DIR/docs/plans/2026-06-09-arlo-mic-accessibility-guard.md"
PRIVACY_PERMISSION_PLAN="$ROOT_DIR/docs/plans/2026-06-09-arlo-privacy-permission-copy.md"
WAVEFORM_POWER_PLAN="$ROOT_DIR/docs/plans/2026-06-09-arlo-waveform-power-finite-guard.md"
MAKE_GATE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-arlo-make-gate-targets.md"

if [ ! -f "$ROOT_DIR/CHANGES.md" ]; then
  printf '%s\n' "CHANGES.md must document repository maintenance." >&2
  exit 1
fi

if ! grep -Fq "Arlo Changes" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "CHANGES.md must identify the project." >&2
  exit 1
fi

if [ ! -f "$MIC_ACCESSIBILITY_PLAN" ]; then
  printf '%s\n' "Arlo mic accessibility plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$MIC_ACCESSIBILITY_PLAN" || ! grep -Fq "make check" "$MIC_ACCESSIBILITY_PLAN"; then
  printf '%s\n' "Arlo mic accessibility plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$PRIVACY_PERMISSION_PLAN" ]; then
  printf '%s\n' "Arlo privacy permission plan is missing." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$PRIVACY_PERMISSION_PLAN" || ! grep -Fq "make check" "$PRIVACY_PERMISSION_PLAN"; then
  printf '%s\n' "Arlo privacy permission plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$WAVEFORM_POWER_PLAN" ]; then
  printf '%s\n' "Arlo waveform power finite guard plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$WAVEFORM_POWER_PLAN" || ! grep -Fq "make check" "$WAVEFORM_POWER_PLAN"; then
  printf '%s\n' "Arlo waveform power finite guard plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$MAKE_GATE_PLAN" ]; then
  printf '%s\n' "Arlo make gate plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$MAKE_GATE_PLAN" || ! grep -Fq "make check" "$MAKE_GATE_PLAN"; then
  printf '%s\n' "Arlo make gate plan must record completed status and make check verification." >&2
  exit 1
fi

if grep -Fq "try!" "$APP_DELEGATE"; then
  printf '%s\n' "AppDelegate must not force-unwrap audio session setup." >&2
  exit 1
fi

if ! grep -Fq "import AVFoundation" "$APP_DELEGATE"; then
  printf '%s\n' "AppDelegate must import AVFoundation explicitly for audio session setup." >&2
  exit 1
fi

if ! grep -Fq 'private static let witAccessToken = ""' "$APP_DELEGATE"; then
  printf '%s\n' "Committed Wit token placeholder must remain empty." >&2
  exit 1
fi

if grep -Fq 'accessToken = ""' "$APP_DELEGATE"; then
  printf '%s\n' "AppDelegate must not assign a blank Wit access token at runtime." >&2
  exit 1
fi

if ! grep -Fq "if AppDelegate.isWitConfigured" "$APP_DELEGATE"; then
  printf '%s\n' "Wit token assignment must be guarded by a non-empty check." >&2
  exit 1
fi

if ! grep -Fq "static var isWitConfigured: Bool" "$APP_DELEGATE"; then
  printf '%s\n' "AppDelegate must expose a read-only Wit configuration state." >&2
  exit 1
fi

if ! grep -Fq "return !witAccessToken.isEmpty" "$APP_DELEGATE"; then
  printf '%s\n' "Wit configuration state must derive from the committed token placeholder." >&2
  exit 1
fi

if grep -Fq "print(" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must not directly print voice or intent callback data." >&2
  exit 1
fi

if ! grep -Fq "import AVFoundation" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must import AVFoundation explicitly for speech and audio types." >&2
  exit 1
fi

if ! grep -Fq "var displayLink: CADisplayLink?" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Waveform display link must be optional until configured." >&2
  exit 1
fi

if ! grep -Fq "displayLink?.invalidate()" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Waveform display link must be invalidated during teardown." >&2
  exit 1
fi

if ! grep -Fq "displayLink = nil" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Waveform display link must be released after invalidation." >&2
  exit 1
fi

if ! grep -Fq "configureDisplayLink()" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Waveform display link must be configured through a lifecycle helper." >&2
  exit 1
fi

if ! grep -Fq "displayLink?.isPaused = false" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Waveform display link must resume when Wit starts recording." >&2
  exit 1
fi

if ! grep -Fq "displayLink?.isPaused = true" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Waveform display link must pause when recording stops or the view disappears." >&2
  exit 1
fi

if grep -Fq "volumeLayer.contentsScale" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Waveform levels must not use display layer scale as an audio proxy." >&2
  exit 1
fi

if ! grep -Fq 'Notification.Name(rawValue: "WITAudioPowerChanged")' "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must observe Wit audio power notifications." >&2
  exit 1
fi

if ! grep -Fq "NotificationCenter.default.addObserver" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must register for audio power notifications." >&2
  exit 1
fi

if ! grep -Fq "NotificationCenter.default.removeObserver(self)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must unregister notification observers during teardown." >&2
  exit 1
fi

if ! grep -Fq "private var currentAudioLevel: CGFloat = 0" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must track the current normalized audio level." >&2
  exit 1
fi

if ! grep -Fq "normalizedWaveLevel(fromPower" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must normalize Wit audio power before updating the waveform." >&2
  exit 1
fi

if ! grep -Fq "guard power.isFinite else" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must reject non-finite Wit audio power values before updating the waveform." >&2
  exit 1
fi

if ! grep -Fq "return 0" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must render silence for invalid waveform levels." >&2
  exit 1
fi

if ! grep -Fq "waveView.updateWithLevel(currentAudioLevel)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Waveform updates must use the current normalized audio level." >&2
  exit 1
fi

if ! grep -Fq "configureVoiceButtonState()" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Voice button state must be configured explicitly." >&2
  exit 1
fi

if ! grep -Fq "btnVoiceRecog.isEnabled = AppDelegate.isWitConfigured" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Voice button must be disabled while the committed Wit token is empty." >&2
  exit 1
fi

if ! grep -Fq "btnVoiceRecog.alpha = AppDelegate.isWitConfigured ? 1.0 : 0.35" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Voice button must visibly indicate unavailable Wit configuration." >&2
  exit 1
fi

if ! grep -Fq 'btnVoiceRecog.accessibilityIdentifier = "arlo.voice.microphone"' "$VIEW_CONTROLLER"; then
  printf '%s\n' "Voice button must expose a stable accessibility identifier." >&2
  exit 1
fi

if ! grep -Fq 'btnVoiceRecog.accessibilityLabel = "Voice input"' "$VIEW_CONTROLLER"; then
  printf '%s\n' "Voice button must expose an accessibility label." >&2
  exit 1
fi

if ! grep -Fq "Requires a local Wit access token." "$VIEW_CONTROLLER"; then
  printf '%s\n' "Voice button must explain the empty-token disabled state to accessibility clients." >&2
  exit 1
fi

if ! grep -Fq "logo.isAccessibilityElement = false" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Decorative microphone logo must not duplicate voice button accessibility focus." >&2
  exit 1
fi

if ! grep -Fq "testMicrophoneControlStartsDisabledWithoutWitToken" "$UI_TESTS"; then
  printf '%s\n' "UI tests must cover the empty-token microphone accessibility state." >&2
  exit 1
fi

if ! grep -Fq 'buttons["arlo.voice.microphone"]' "$UI_TESTS"; then
  printf '%s\n' "UI tests must locate the microphone control by accessibility identifier." >&2
  exit 1
fi

if ! grep -Fq 'XCTAssertFalse(microphoneButton.isEnabled)' "$UI_TESTS"; then
  printf '%s\n' "UI tests must assert the microphone control starts disabled without a token." >&2
  exit 1
fi

if ! grep -Fq "NSMicrophoneUsageDescription" "$INFO_PLIST"; then
  printf '%s\n' "Microphone permission usage description must be present." >&2
  exit 1
fi

if ! grep -Fq "Arlo uses the microphone when you tap Voice input to send speech to Wit.ai." "$INFO_PLIST"; then
  printf '%s\n' "Microphone permission text must describe user-triggered Wit voice capture." >&2
  exit 1
fi

if grep -Fq "NSLocationWhenInUseUsageDescription" "$INFO_PLIST"; then
  printf '%s\n' "Unused location permission description must not be declared." >&2
  exit 1
fi

if ! grep -Fq "SWIFT_VERSION = 3.0;" "$PROJECT_FILE"; then
  printf '%s\n' "Project must document the legacy Swift 3.0 setting." >&2
  exit 1
fi

if ! grep -Fq "IPHONEOS_DEPLOYMENT_TARGET = 9.3;" "$PROJECT_FILE"; then
  printf '%s\n' "Project must preserve the legacy iOS 9.3 deployment target." >&2
  exit 1
fi

if ! grep -Fq "pod 'Wit', '~> 4.1.0'" "$PODFILE"; then
  printf '%s\n' "Podfile must keep the expected Wit dependency pin." >&2
  exit 1
fi

if ! grep -Fq "Wit (4.1.0)" "$POD_LOCK"; then
  printf '%s\n' "Podfile.lock must keep Wit 4.1.0 resolved." >&2
  exit 1
fi

if ! grep -Fq "SCSiriWaveformView (1.0.3)" "$POD_LOCK"; then
  printf '%s\n' "Podfile.lock must keep SCSiriWaveformView 1.0.3 resolved." >&2
  exit 1
fi

if ! grep -Fq "COCOAPODS: 1.0.1" "$POD_LOCK"; then
  printf '%s\n' "Podfile.lock must keep the documented CocoaPods 1.0.1 provenance." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the baseline check." >&2
  exit 1
fi

if [ ! -f "$ROOT_DIR/Makefile" ]; then
  printf '%s\n' "Makefile is missing." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must run the SDK-free baseline check." >&2
  exit 1
fi

if ! grep -Fq "lint:" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a lint gate." >&2
  exit 1
fi

if ! grep -Fq "test:" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a test gate." >&2
  exit 1
fi

if ! grep -Fq "build:" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a build gate." >&2
  exit 1
fi

if ! grep -Fq "verify: lint test build" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a combined verify gate." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the make check wrapper." >&2
  exit 1
fi

if ! grep -Fq "make lint" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the lint gate." >&2
  exit 1
fi

if ! grep -Fq "make test" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the test gate." >&2
  exit 1
fi

if ! grep -Fq "make build" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the build gate." >&2
  exit 1
fi

if ! grep -Fq "WITAudioPowerChanged" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the waveform audio-power baseline." >&2
  exit 1
fi

if ! grep -Fq "non-finite Wit audio-power values" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the waveform finite-value guard." >&2
  exit 1
fi

if ! grep -Fq "The voice button stays disabled until a non-empty local Wit access token is supplied" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the empty-token voice button guard." >&2
  exit 1
fi

if ! grep -Fq "arlo.voice.microphone" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the microphone accessibility identifier." >&2
  exit 1
fi

if ! grep -Fq "microphone permission text" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the microphone permission text baseline." >&2
  exit 1
fi

if ! grep -Fq "Arlo.xcworkspace" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the CocoaPods workspace entry point." >&2
  exit 1
fi

if ! grep -Fq "Swift 3.0" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the legacy Swift baseline." >&2
  exit 1
fi

if ! grep -Fq "CocoaPods 1.0.1" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document CocoaPods lockfile provenance." >&2
  exit 1
fi

if ! grep -Fq 'This host does not have `xcodebuild`, `pod`, or `swift`' "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document local Apple toolchain limitations." >&2
  exit 1
fi

if ! grep -Fq "CHANGES.md" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must point to CHANGES.md." >&2
  exit 1
fi

printf '%s\n' "Arlo audio privacy baseline checks passed."
