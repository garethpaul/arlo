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
CHECKOUT_CREDENTIAL_PLAN="$ROOT_DIR/docs/plans/2026-06-12-checkout-credential-boundary.md"
EMPTY_TOKEN_AUDIO_SESSION_PLAN="$ROOT_DIR/docs/plans/2026-06-13-arlo-empty-token-audio-session.md"
EMPTY_TOKEN_WIT_ISOLATION_PLAN="$ROOT_DIR/docs/plans/2026-06-13-arlo-empty-token-wit-isolation.md"
MAKE_ROOT_PROTECTION_PLAN="$ROOT_DIR/docs/plans/2026-06-14-arlo-make-root-override-protection.md"
DEVICE_VERIFICATION_PLAN="$ROOT_DIR/docs/plans/2026-06-14-arlo-device-verification-checklist.md"
WIT_VAD_TRACKER="$ROOT_DIR/Pods/Wit/Wit/WITVadTracker.m"
WIT_TOKEN_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-15-wit-token-log-redaction.md"
WIT_TEXT_CLIENT="$ROOT_DIR/Pods/Wit/Wit/Wit.m"
WIT_UPLOADER="$ROOT_DIR/Pods/Wit/Wit/WITUploader.m"
WIT_RESPONSE_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-15-wit-response-log-redaction.md"
WIT_REQUEST_URL_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-15-wit-request-url-log-redaction.md"

if [ ! -f "$WIT_VAD_TRACKER" ]; then
  printf '%s\n' "Compiled Wit VAD tracker source is missing." >&2
  exit 1
fi

if grep -Eq 'NSLog\([^;]*(token|url)' "$WIT_VAD_TRACKER" || \
   grep -Fq 'here is the final url' "$WIT_VAD_TRACKER"; then
  printf '%s\n' "Wit VAD tracker must not log bearer tokens or request URLs." >&2
  exit 1
fi

if ! grep -Fq 'setValue:[NSString stringWithFormat:@"Bearer %@", token]' "$WIT_VAD_TRACKER" || \
   ! grep -Fq 'initWithRequest:request delegate:self' "$WIT_VAD_TRACKER"; then
  printf '%s\n' "Wit token log redaction must preserve authenticated VAD request setup." >&2
  exit 1
fi

if [ ! -f "$WIT_TOKEN_LOG_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$WIT_TOKEN_LOG_PLAN" || \
   ! grep -Fq 'repository and external-directory `make check` passed' "$WIT_TOKEN_LOG_PLAN" || \
   ! grep -Fq "hostile Wit token-log mutations were rejected" "$WIT_TOKEN_LOG_PLAN"; then
  printf '%s\n' "Wit token log redaction plan must record completed verification evidence." >&2
  exit 1
fi

if ! grep -Fq "never writes the token or request URL to device logs" "$ROOT_DIR/README.md" || \
   ! grep -Fq "Keep configured Wit bearer tokens and request URLs out of application" "$ROOT_DIR/SECURITY.md" || \
   ! grep -Fq "Do not log configured voice-service tokens or credential-bearing request URLs" "$ROOT_DIR/VISION.md" || \
   ! grep -Fq "Removed the compiled vendored Wit VAD diagnostic" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Repository guidance must document Wit token log redaction." >&2
  exit 1
fi

for wit_response_source in "$WIT_TEXT_CLIENT" "$WIT_UPLOADER"; do
  if [ ! -f "$wit_response_source" ]; then
    printf '%s\n' "Compiled Wit response source is missing: ${wit_response_source#"$ROOT_DIR/"}" >&2
    exit 1
  fi

  if grep -Eq 'NSLog\(@"Wit response[^\"]*%@' "$wit_response_source" || \
     grep -Fq '[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]' "$wit_response_source"; then
    printf '%s\n' "Wit response diagnostics must not log response payloads: ${wit_response_source#"$ROOT_DIR/"}" >&2
    exit 1
  fi
done

if ! grep -Fq 'NSLog(@"Wit response (%f s)", t);' "$WIT_TEXT_CLIENT" || \
   ! grep -Fq 'NSLog(@"Wit response %ld (%f s)",' "$WIT_UPLOADER" || \
   ! grep -Fq '(long)[httpResp statusCode],' "$WIT_UPLOADER"; then
  printf '%s\n' "Wit response redaction must preserve timing and HTTP status diagnostics." >&2
  exit 1
fi

if ! grep -Fq 'debug(@"HTTP %@", req.HTTPMethod);' "$WIT_UPLOADER"; then
  printf '%s\n' "Wit uploader must retain only the non-sensitive HTTP method diagnostic." >&2
  exit 1
fi

if grep -Eq 'debug\([^;]*(urlString|contextEncoded|encoded)' "$WIT_UPLOADER" || \
   grep -Eq 'debug\(@"HTTP[^"]*%@[^\"]*%@' "$WIT_UPLOADER"; then
  printf '%s\n' "Wit uploader diagnostics must not log request URLs or serialized context." >&2
  exit 1
fi

wit_request_url_guidance='Wit request diagnostics retain only HTTP method metadata and never complete request URLs or serialized context.'
for wit_request_url_doc in "$ROOT_DIR/AGENTS.md" "$ROOT_DIR/README.md" \
  "$ROOT_DIR/SECURITY.md" "$ROOT_DIR/VISION.md" "$ROOT_DIR/CHANGES.md"; do
  if ! grep -Fq "$wit_request_url_guidance" "$wit_request_url_doc"; then
    printf '%s\n' "$wit_request_url_doc must document Wit request URL redaction." >&2
    exit 1
  fi
done

for wit_request_url_plan_contract in \
  "status: completed" \
  "repository-root and external-directory make check passed" \
  "hostile mutations" \
  "Native compilation and configured-Wit execution were not performed"; do
  if ! grep -Fqi "$wit_request_url_plan_contract" "$WIT_REQUEST_URL_LOG_PLAN"; then
    printf '%s\n' "Wit request URL log plan must record completion evidence: $wit_request_url_plan_contract" >&2
    exit 1
  fi
done

if [ ! -f "$WIT_RESPONSE_LOG_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$WIT_RESPONSE_LOG_PLAN" || \
   ! grep -Fq 'repository and external-directory `make check` passed' "$WIT_RESPONSE_LOG_PLAN" || \
   ! grep -Fq "hostile Wit response-log mutations were rejected" "$WIT_RESPONSE_LOG_PLAN"; then
  printf '%s\n' "Wit response log redaction plan must record completed verification evidence." >&2
  exit 1
fi

if ! grep -Fq "Wit response diagnostics retain timing and status metadata without logging response bodies" "$ROOT_DIR/README.md" || \
   ! grep -Fq "Keep recognized speech and inferred Wit response entities out of application and device logs" "$ROOT_DIR/SECURITY.md" || \
   ! grep -Fq "Do not log voice-service response bodies" "$ROOT_DIR/VISION.md" || \
   ! grep -Fq "Removed full Wit response bodies from debug logs" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Repository guidance must document Wit response log redaction." >&2
  exit 1
fi

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

if [ "$(grep -Fc 'uses: actions/checkout@' "$CI_WORKFLOW")" -ne 1 ] || \
   [ "$(grep -Fc 'persist-credentials: false' "$CI_WORKFLOW")" -ne 1 ]; then
  printf '%s\n' "The only checkout step must disable credential persistence." >&2
  exit 1
fi

if grep -E '^[[:space:]]*(-[[:space:]]+)?uses:' "$CI_WORKFLOW" | \
   grep -Ev '@[0-9a-f]{40}([[:space:]]+#.*)?$' >/dev/null; then
  printf '%s\n' "GitHub Actions must use immutable commit SHAs." >&2
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

if [ "$(grep -Ec '^[[:space:]]*permissions:' "$CI_WORKFLOW")" -ne 1 ] || \
   [ "$(grep -Ec '^[[:space:]]+contents:[[:space:]]*read[[:space:]]*$' "$CI_WORKFLOW")" -ne 1 ] || \
   grep -Eq 'write-all|:[[:space:]]*write|continue-on-error:[[:space:]]*true|if:[[:space:]]*false' "$CI_WORKFLOW" || \
   [ "$(grep -Ec '^[[:space:]]*(-[[:space:]]+)?run:' "$CI_WORKFLOW")" -ne 1 ]; then
  printf '%s\n' "Check workflow must keep exact read-only permissions and one required command." >&2
  exit 1
fi

if [ ! -f "$CHECKOUT_CREDENTIAL_PLAN" ] || \
   ! grep -Fq "status: completed" "$CHECKOUT_CREDENTIAL_PLAN" || \
   ! grep -Fq "make check" "$CHECKOUT_CREDENTIAL_PLAN" || \
   ! grep -Fq "external working directory" "$CHECKOUT_CREDENTIAL_PLAN" || \
   ! grep -Fq "hostile mutations rejected" "$CHECKOUT_CREDENTIAL_PLAN"; then
  printf '%s\n' "Checkout credential plan must record completed local verification." >&2
  exit 1
fi

if ! grep -Fq 'override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' "$ROOT_DIR/Makefile" || \
   ! grep -Fq '$(ROOT)scripts/check-baseline.sh' "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile verification must protect and resolve the checker from the loaded Makefile." >&2
  exit 1
fi

if [ ! -f "$MAKE_ROOT_PROTECTION_PLAN" ] || \
   ! grep -Fq "status: completed" "$MAKE_ROOT_PROTECTION_PLAN" || \
   ! grep -Fq "## Status: Completed" "$MAKE_ROOT_PROTECTION_PLAN" || \
   ! grep -Fq 'make ROOT=/tmp check' "$MAKE_ROOT_PROTECTION_PLAN" || \
   ! grep -Fq "four Make gates" "$MAKE_ROOT_PROTECTION_PLAN" || \
   ! grep -Fq "external working directory" "$MAKE_ROOT_PROTECTION_PLAN" || \
   ! grep -Fq "Four isolated hostile mutations were rejected" "$MAKE_ROOT_PROTECTION_PLAN"; then
  printf '%s\n' "Make root protection plan must record completed hostile-override and external verification." >&2
  exit 1
fi

for required_device_path in "$ROOT_DIR/DEVICE_VERIFICATION.md" "$DEVICE_VERIFICATION_PLAN"; do
  if [ ! -f "$required_device_path" ]; then
    printf '%s\n' "Required Arlo device verification file is missing: ${required_device_path#"$ROOT_DIR/"}" >&2
    exit 1
  fi
done

for device_contract in \
  'commit SHA and pull request' \
  'synthetic phrase' \
  'Empty-token launch' \
  'Empty-token teardown' \
  'Configured-token launch' \
  'Microphone permission denied' \
  'Microphone permission granted' \
  'Recording start and stop' \
  'Waveform finite values' \
  'Missing waveform outlet' \
  'Late audio power' \
  'New controller ownership' \
  'Audio interruption' \
  'Background and foreground' \
  'Do not convert `not run` into passing evidence.' \
  'access tokens, recorded audio, transcripts' \
  'every Xcode, simulator, microphone, Wit, and device row as unexecuted'; do
  if ! grep -Fq "$device_contract" "$ROOT_DIR/DEVICE_VERIFICATION.md"; then
    printf '%s\n' "Arlo device checklist must keep contract: $device_contract" >&2
    exit 1
  fi
done

if ! grep -Fq 'DEVICE_VERIFICATION.md' "$ROOT_DIR/README.md" || \
   ! grep -Fq 'explicit unexecuted rows' "$ROOT_DIR/README.md" || \
   ! grep -Fq 'Arlo device verification matrix' "$ROOT_DIR/VISION.md" || \
   ! grep -Fq 'every runtime row explicitly unexecuted' "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' 'Repository guidance must document the unexecuted Arlo device matrix.' >&2
  exit 1
fi

for device_plan_contract in \
  'Status: Completed' \
  'make check' \
  'hostile mutations' \
  'No Xcode build, iOS simulator, physical device, microphone, locally configured Wit service, or live voice scenario was executed'; do
  if ! grep -Fq "$device_plan_contract" "$DEVICE_VERIFICATION_PLAN"; then
    printf '%s\n' "Arlo device plan must keep completion evidence: $device_plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "does not persist checkout credentials" "$ROOT_DIR/README.md" || \
   ! grep -Fq "non-persisted checkout token" "$ROOT_DIR/SECURITY.md" || \
   ! grep -Fq "non-persisted checkout credentials" "$ROOT_DIR/VISION.md" || \
   ! grep -Fq "checkout credential persistence" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Repository guidance must document the checkout credential boundary." >&2
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

if ! grep -Fq "static var isWitConfigured: Bool" "$APP_DELEGATE"; then
  printf '%s\n' "AppDelegate must expose a read-only Wit configuration state." >&2
  exit 1
fi

if ! grep -Fq "return !witAccessToken.isEmpty" "$APP_DELEGATE"; then
  printf '%s\n' "Wit configuration state must derive from the committed token placeholder." >&2
  exit 1
fi

audio_session_body=$(sed -n '/private func configureAudioSession()/,/^    }/p' "$APP_DELEGATE")
if ! printf '%s\n' "$audio_session_body" | grep -Fq "guard AppDelegate.isWitConfigured else"; then
  printf '%s\n' "Audio session setup must return while the committed Wit token is empty." >&2
  exit 1
fi

audio_guard_line=$(printf '%s\n' "$audio_session_body" | grep -nF "guard AppDelegate.isWitConfigured else" | cut -d: -f1)
audio_category_line=$(printf '%s\n' "$audio_session_body" | grep -nF "setCategory(AVAudioSessionCategoryPlayAndRecord)" | cut -d: -f1)
audio_active_line=$(printf '%s\n' "$audio_session_body" | grep -nF "setActive(true)" | cut -d: -f1)
if [ -z "$audio_guard_line" ] || [ -z "$audio_category_line" ] || \
   [ -z "$audio_active_line" ] || [ "$audio_guard_line" -ge "$audio_category_line" ] || \
   [ "$audio_category_line" -ge "$audio_active_line" ]; then
  printf '%s\n' "Empty-token guard must precede audio category selection and activation." >&2
  exit 1
fi

wit_configuration_body=$(sed -n '/private func configureWit()/,/^    }/p' "$APP_DELEGATE")
for wit_configuration_contract in \
  "guard AppDelegate.isWitConfigured else" \
  "let wit = Wit.sharedInstance()" \
  "wit.accessToken = AppDelegate.witAccessToken" \
  "wit.detectSpeechStop = WITVadConfig.detectSpeechStop"; do
  if ! printf '%s\n' "$wit_configuration_body" | grep -Fq "$wit_configuration_contract"; then
    printf '%s\n' "Configured Wit setup must preserve the guarded singleton contract: $wit_configuration_contract" >&2
    exit 1
  fi
done

wit_configuration_guard_line=$(printf '%s\n' "$wit_configuration_body" | grep -nF "guard AppDelegate.isWitConfigured else" | cut -d: -f1)
wit_configuration_singleton_line=$(printf '%s\n' "$wit_configuration_body" | grep -nF "let wit = Wit.sharedInstance()" | cut -d: -f1)
if [ -z "$wit_configuration_guard_line" ] || [ -z "$wit_configuration_singleton_line" ] || \
   [ "$wit_configuration_guard_line" -ge "$wit_configuration_singleton_line" ]; then
  printf '%s\n' "Empty-token Wit configuration guard must precede singleton access." >&2
  exit 1
fi

if ! grep -Fq "empty-token builds do not activate the play-and-record audio session" "$ROOT_DIR/README.md" || \
   ! grep -Fq "2026-06-13-arlo-empty-token-audio-session.md" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the empty-token audio-session boundary and plan." >&2
  exit 1
fi

if [ ! -f "$EMPTY_TOKEN_AUDIO_SESSION_PLAN" ] || \
   ! grep -Fq "status: completed" "$EMPTY_TOKEN_AUDIO_SESSION_PLAN" || \
   ! grep -Fq "## Status: Completed" "$EMPTY_TOKEN_AUDIO_SESSION_PLAN" || \
   ! grep -Fq "make check" "$EMPTY_TOKEN_AUDIO_SESSION_PLAN" || \
   ! grep -Fq "Seven isolated hostile mutations were rejected" "$EMPTY_TOKEN_AUDIO_SESSION_PLAN" || \
   ! grep -Fq "no simulator, Swift compilation, microphone" "$EMPTY_TOKEN_AUDIO_SESSION_PLAN"; then
  printf '%s\n' "Empty-token audio-session plan must record completed status and limited verification." >&2
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

wit_release_body=$(sed -n '/private func releaseWitDelegateIfOwned(stopCapture: Bool)/,/^    }/p' "$VIEW_CONTROLLER")
for wit_release_contract in \
  "guard AppDelegate.isWitConfigured else" \
  "let wit = Wit.sharedInstance()" \
  "guard wit.delegate === self else"; do
  if ! printf '%s\n' "$wit_release_body" | grep -Fq "$wit_release_contract"; then
    printf '%s\n' "Wit delegate teardown must preserve the guarded ownership contract: $wit_release_contract" >&2
    exit 1
  fi
done

wit_release_guard_line=$(printf '%s\n' "$wit_release_body" | grep -nF "guard AppDelegate.isWitConfigured else" | cut -d: -f1)
wit_release_singleton_line=$(printf '%s\n' "$wit_release_body" | grep -nF "let wit = Wit.sharedInstance()" | cut -d: -f1)
if [ -z "$wit_release_guard_line" ] || [ -z "$wit_release_singleton_line" ] || \
   [ "$wit_release_guard_line" -ge "$wit_release_singleton_line" ]; then
  printf '%s\n' "Empty-token delegate teardown guard must precede singleton access." >&2
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

if ! grep -Fq "empty-token lifecycle does not initialize the Wit singleton" "$ROOT_DIR/README.md" || \
   ! grep -Fq "2026-06-13-arlo-empty-token-wit-isolation.md" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document empty-token Wit singleton isolation and its plan." >&2
  exit 1
fi

if ! grep -Fq "empty-token launch and teardown paths before Wit singleton access" "$ROOT_DIR/CHANGES.md" || \
   ! grep -Fq "Keep empty-token launch and teardown paths from initializing the Wit singleton" "$ROOT_DIR/VISION.md"; then
  printf '%s\n' "Repository guidance must document empty-token Wit singleton isolation." >&2
  exit 1
fi

if [ ! -f "$EMPTY_TOKEN_WIT_ISOLATION_PLAN" ] || \
   ! grep -Fq "status: completed" "$EMPTY_TOKEN_WIT_ISOLATION_PLAN" || \
   ! grep -Fq "## Status: Completed" "$EMPTY_TOKEN_WIT_ISOLATION_PLAN" || \
   ! grep -Fq "make check" "$EMPTY_TOKEN_WIT_ISOLATION_PLAN" || \
   ! grep -Fq "isolated hostile mutations were rejected" "$EMPTY_TOKEN_WIT_ISOLATION_PLAN" || \
   ! grep -Fq "no simulator, Swift compilation, microphone" "$EMPTY_TOKEN_WIT_ISOLATION_PLAN"; then
  printf '%s\n' "Empty-token Wit isolation plan must record completed status and limited verification." >&2
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
