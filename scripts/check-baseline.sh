#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
APP_DELEGATE="$ROOT_DIR/Arlo/AppDelegate.swift"
VIEW_CONTROLLER="$ROOT_DIR/Arlo/ViewController.swift"
INFO_PLIST="$ROOT_DIR/Arlo/Info.plist"
PROJECT_FILE="$ROOT_DIR/Arlo.xcodeproj/project.pbxproj"
PODFILE="$ROOT_DIR/Podfile"
POD_LOCK="$ROOT_DIR/Podfile.lock"

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

if ! grep -Fq "if !AppDelegate.witAccessToken.isEmpty" "$APP_DELEGATE"; then
  printf '%s\n' "Wit token assignment must be guarded by a non-empty check." >&2
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

if ! grep -Fq "displayLink?.isPaused = false" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Waveform display link must resume when Wit starts recording." >&2
  exit 1
fi

if ! grep -Fq "displayLink?.isPaused = true" "$VIEW_CONTROLLER"; then
  printf '%s\n' "Waveform display link must pause when recording stops or the view disappears." >&2
  exit 1
fi

if ! grep -Fq "NSMicrophoneUsageDescription" "$INFO_PLIST"; then
  printf '%s\n' "Microphone permission usage description must be present." >&2
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

printf '%s\n' "Arlo voice privacy baseline checks passed."
