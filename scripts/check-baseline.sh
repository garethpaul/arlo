#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
APP_DELEGATE="$ROOT_DIR/Arlo/AppDelegate.swift"
VIEW_CONTROLLER="$ROOT_DIR/Arlo/ViewController.swift"
SIRI_WAVEFORM="$ROOT_DIR/Arlo/SiriWaveformView.swift"
UI_TESTS="$ROOT_DIR/ArloUITests/ArloUITests.swift"
INFO_PLIST="$ROOT_DIR/Arlo/Info.plist"
PROJECT_FILE="$ROOT_DIR/Arlo.xcodeproj/project.pbxproj"
PODFILE="$ROOT_DIR/Podfile"
POD_LOCK="$ROOT_DIR/Podfile.lock"
MIC_ACCESSIBILITY_PLAN="$ROOT_DIR/docs/plans/2026-06-09-arlo-mic-accessibility-guard.md"
PRIVACY_PERMISSION_PLAN="$ROOT_DIR/docs/plans/2026-06-09-arlo-privacy-permission-copy.md"
WAVEFORM_POWER_PLAN="$ROOT_DIR/docs/plans/2026-06-09-arlo-waveform-power-finite-guard.md"
MAKE_GATE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-arlo-make-gate-targets.md"
WIT_DELEGATE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-arlo-wit-delegate-lifecycle.md"
WIT_EMPTY_TOKEN_DELEGATE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-arlo-empty-token-delegate-guard.md"
WAVEFORM_OUTLET_PLAN="$ROOT_DIR/docs/plans/2026-06-09-arlo-waveform-outlet-guard.md"
WAVEFORM_DRAWING_PLAN="$ROOT_DIR/docs/plans/2026-06-09-arlo-waveform-drawing-parameter-guard.md"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
WIT_DELEGATE_OWNERSHIP_PLAN="$ROOT_DIR/docs/plans/2026-06-10-arlo-wit-delegate-ownership.md"
AUDIO_MAIN_THREAD_PLAN="$ROOT_DIR/docs/plans/2026-06-12-arlo-audio-main-thread-state.md"

if [ ! -f "$ROOT_DIR/CHANGES.md" ]; then
  printf '%s\n' "CHANGES.md must document repository maintenance." >&2
  exit 1
fi

if ! grep -Fq "Arlo Changes" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "CHANGES.md must identify the project." >&2
  exit 1
fi

if [ ! -f "$CI_WORKFLOW" ]; then
  printf '%s\n' "GitHub Actions workflow is missing." >&2
  exit 1
fi

if ! grep -Fq "ubuntu-24.04" "$CI_WORKFLOW" || ! grep -Fq "make check" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions workflow must run the SDK-free make check baseline." >&2
  exit 1
fi

if ! grep -Fq "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions must pin actions/checkout to the reviewed commit." >&2
  exit 1
fi

if ! grep -Fq "permissions:" "$CI_WORKFLOW" || ! grep -Fq "contents: read" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions must keep repository access read-only." >&2
  exit 1
fi

if ! grep -Fq "workflow_dispatch:" "$CI_WORKFLOW" || ! grep -Fq "timeout-minutes: 5" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions must support bounded manual verification." >&2
  exit 1
fi

if ! grep -Fq "cancel-in-progress: true" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions must cancel superseded baseline runs." >&2
  exit 1
fi

if [ ! -f "$CI_PLAN" ]; then
  printf '%s\n' "Arlo CI baseline plan is missing." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$CI_PLAN" || ! grep -Fq "make check" "$CI_PLAN"; then
  printf '%s\n' "Arlo CI baseline plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$WIT_DELEGATE_OWNERSHIP_PLAN" ]; then
  printf '%s\n' "Arlo Wit delegate ownership plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$WIT_DELEGATE_OWNERSHIP_PLAN" || ! grep -Fq "make check" "$WIT_DELEGATE_OWNERSHIP_PLAN"; then
  printf '%s\n' "Arlo Wit delegate ownership plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$AUDIO_MAIN_THREAD_PLAN" ]; then
  printf '%s\n' "Arlo audio main-thread state plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$AUDIO_MAIN_THREAD_PLAN" || ! grep -Fq "make check" "$AUDIO_MAIN_THREAD_PLAN"; then
  printf '%s\n' "Arlo audio main-thread state plan must record completed status and make check verification." >&2
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

if [ ! -f "$WIT_DELEGATE_PLAN" ]; then
  printf '%s\n' "Arlo Wit delegate lifecycle plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$WIT_DELEGATE_PLAN" || ! grep -Fq "make check" "$WIT_DELEGATE_PLAN"; then
  printf '%s\n' "Arlo Wit delegate lifecycle plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$WIT_EMPTY_TOKEN_DELEGATE_PLAN" ]; then
  printf '%s\n' "Arlo empty-token Wit delegate guard plan is missing." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$WIT_EMPTY_TOKEN_DELEGATE_PLAN" || ! grep -Fq "make check" "$WIT_EMPTY_TOKEN_DELEGATE_PLAN"; then
  printf '%s\n' "Arlo empty-token Wit delegate guard plan must record completed status and make check verification." >&2
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

if ! grep -Fq "configureWitDelegate()" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Wit delegate assignment must be scoped through a lifecycle helper." >&2
  exit 1
fi

if ! grep -Fq "if AppDelegate.isWitConfigured {" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Wit delegate assignment must be skipped while the committed token placeholder is empty." >&2
  exit 1
fi

if ! grep -Fq "releaseWitDelegateIfOwned(stopCapture:" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Wit delegate cleanup must be scoped through an ownership-aware lifecycle helper." >&2
  exit 1
fi

if ! grep -Fq "guard wit.delegate === self else" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must verify Wit delegate ownership before singleton teardown." >&2
  exit 1
fi

if ! grep -Fq "releaseWitDelegateIfOwned(stopCapture: true)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must release owned Wit capture when leaving the view." >&2
  exit 1
fi

if [ "$(grep -Fc "releaseWitDelegateIfOwned(stopCapture: true)" "$VIEW_CONTROLLER")" -ne 2 ]; then
  printf '%s\n' "ViewController must release owned Wit capture during disappearance and deinitialization." >&2
  exit 1
fi

if ! grep -Fq "releaseWitDelegateIfOwned(stopCapture: false)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must release only its owned delegate when Wit is unconfigured." >&2
  exit 1
fi

if ! grep -Fq "wit.stop()" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must stop active Wit recording before teardown." >&2
  exit 1
fi

if ! grep -Fq "wit.delegate = nil" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must clear the strong Wit singleton delegate it owns." >&2
  exit 1
fi

if ! grep -Fq "strongSelf.applyRecordingState(true)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Wit recording start must resume waveform state through the centralized helper." >&2
  exit 1
fi

if [ "$(grep -Fc "self?.applyRecordingState(false)" "$VIEW_CONTROLLER")" -ne 2 ]; then
  printf '%s\n' "Recording stop and view disappearance must reset waveform state through the centralized helper." >&2
  exit 1
fi

if ! grep -Fq "private var isRecording = false" "$VIEW_CONTROLLER"; then
  printf '%s\n' "ViewController must track whether Wit recording is active." >&2
  exit 1
fi

if ! grep -Fq "private var isViewActive = false" "$VIEW_CONTROLLER" || \
   ! grep -Fq "isViewActive = true" "$VIEW_CONTROLLER" || \
   ! grep -Fq "isViewActive = false" "$VIEW_CONTROLLER" || \
   ! grep -Fq "guard let strongSelf = self, strongSelf.isViewActive else" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Late Wit recording-start callbacks must not reactivate an inactive view." >&2
  exit 1
fi

if ! grep -Fq "private func performOnMain(_ work: @escaping () -> Void)" "$VIEW_CONTROLLER" || \
   ! grep -Fq "Thread.isMainThread" "$VIEW_CONTROLLER" || \
   ! grep -Fq "DispatchQueue.main.async(execute: work)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Wit callback state must use the shared main-thread execution helper." >&2
  exit 1
fi

if [ "$(grep -Fc "performOnMain { [weak self] in" "$VIEW_CONTROLLER")" -lt 4 ]; then
  printf '%s\n' "Audio notification, recording callbacks, and view teardown must capture the controller weakly on the main queue." >&2
  exit 1
fi

if ! grep -Fq "guard let strongSelf = self, strongSelf.isRecording else" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Late Wit audio power updates must be ignored while recording is inactive." >&2
  exit 1
fi

if ! grep -Fq "private func applyRecordingState(_ recording: Bool)" "$VIEW_CONTROLLER" || \
   ! grep -Fq "displayLink?.isPaused = !recording" "$VIEW_CONTROLLER" || \
   ! grep -Fq "updateWaveform(level: 0)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Recording start and stop state must be centralized and reset the waveform." >&2
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

if ! grep -Fq "@IBOutlet weak var waveView: SiriWaveformView?" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Waveform outlet must be optional so missing storyboard wiring is non-fatal." >&2
  exit 1
fi

if ! grep -Fq "private func updateWaveform(level: CGFloat)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Waveform updates must be isolated behind an optional-outlet helper." >&2
  exit 1
fi

if ! grep -Fq "waveView?.updateWithLevel(level)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Waveform helper must tolerate a missing waveform outlet." >&2
  exit 1
fi

if ! grep -Fq "updateWaveform(level: currentAudioLevel)" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Waveform updates must use the current normalized audio level." >&2
  exit 1
fi

if grep -Fq "waveView.updateWithLevel" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Waveform updates must not call an implicitly unwrapped outlet directly." >&2
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

if grep -Fq "context!" "$SIRI_WAVEFORM"; then
  printf '%s\n' "SiriWaveformView drawing must not force-unwrap the graphics context." >&2
  exit 1
fi

if ! grep -Fq "guard let context = UIGraphicsGetCurrentContext(), bounds.width > 0, bounds.height > 0" "$SIRI_WAVEFORM"; then
  printf '%s\n' "SiriWaveformView drawing must guard missing context and empty bounds." >&2
  exit 1
fi

if ! grep -Fq "let renderedWaveCount = max(1, numberOfWaves)" "$SIRI_WAVEFORM"; then
  printf '%s\n' "SiriWaveformView drawing must clamp inspector wave count before range iteration." >&2
  exit 1
fi

if ! grep -Fq "let renderedDensity = max(CGFloat(1), density)" "$SIRI_WAVEFORM"; then
  printf '%s\n' "SiriWaveformView drawing must clamp inspector density before waveform iteration." >&2
  exit 1
fi

if ! grep -Fq "0...renderedWaveCount" "$SIRI_WAVEFORM" || ! grep -Fq "x += renderedDensity" "$SIRI_WAVEFORM"; then
  printf '%s\n' "SiriWaveformView drawing must use clamped wave count and density values." >&2
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

if ! grep -Fq 'ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must resolve repository-root commands from its own location." >&2
  exit 1
fi

if ! grep -Fq '$(ROOT)scripts/check-baseline.sh' "$ROOT_DIR/Makefile"; then
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

if ! grep -Fq "GitHub Actions" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the GitHub Actions baseline." >&2
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

if ! grep -Fq "Wit delegate is registered only while the view is visible" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the Wit delegate lifecycle guard." >&2
  exit 1
fi

if ! grep -Fq "still owns the Wit singleton" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the Wit delegate ownership guard." >&2
  exit 1
fi

if ! grep -Fq "Wit delegate registration is skipped" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the empty-token Wit delegate guard." >&2
  exit 1
fi

if ! grep -Fq "Waveform updates tolerate a missing storyboard outlet" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the waveform outlet guard." >&2
  exit 1
fi

if ! grep -Fq "Waveform drawing clamps inspector wave count and density values" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the waveform drawing parameter guard." >&2
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

if [ ! -f "$WAVEFORM_OUTLET_PLAN" ]; then
  printf '%s\n' "Arlo waveform outlet guard plan is missing." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$WAVEFORM_OUTLET_PLAN" || ! grep -Fq "make check" "$WAVEFORM_OUTLET_PLAN"; then
  printf '%s\n' "Arlo waveform outlet guard plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$WAVEFORM_DRAWING_PLAN" ]; then
  printf '%s\n' "Arlo waveform drawing parameter guard plan is missing." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$WAVEFORM_DRAWING_PLAN" || ! grep -Fq "make check" "$WAVEFORM_DRAWING_PLAN"; then
  printf '%s\n' "Arlo waveform drawing parameter guard plan must record completed status and make check verification." >&2
  exit 1
fi

printf '%s\n' "Arlo audio privacy baseline checks passed."
