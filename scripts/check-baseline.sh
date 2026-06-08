#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
APP_DELEGATE="$ROOT_DIR/Arlo/AppDelegate.swift"
VIEW_CONTROLLER="$ROOT_DIR/Arlo/ViewController.swift"
INFO_PLIST="$ROOT_DIR/Arlo/Info.plist"
PODFILE="$ROOT_DIR/Podfile"
POD_LOCK="$ROOT_DIR/Podfile.lock"

if grep -Fq "try!" "$APP_DELEGATE"; then
  printf '%s\n' "AppDelegate must not force-unwrap audio session setup." >&2
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

if ! grep -Fq "NSMicrophoneUsageDescription" "$INFO_PLIST"; then
  printf '%s\n' "Microphone permission usage description must be present." >&2
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

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the baseline check." >&2
  exit 1
fi

printf '%s\n' "Arlo voice privacy baseline checks passed."
