# Arlo Device Verification Checklist

Status: Completed

## Problem

Portable contracts cover microphone accessibility, privacy text, main-thread
audio state, waveform validation, Wit delegate ownership, empty-token audio
session suppression, and singleton isolation, but no checklist defines
repeatable simulator or physical-device evidence for the exact commit.

## Requirements

1. Add an exact-commit matrix for empty-token launch, configured-token launch,
   microphone permission, recording, waveform, delegate callbacks,
   interruption, backgrounding, teardown, and relaunch.
2. Require synthetic phrases and sanitized Xcode, iOS, device, Wit mode,
   result, and evidence fields.
3. Keep repository checks separate from unexecuted Xcode, simulator,
   microphone, Wit service, and physical-device scenarios.
4. Add mutation-sensitive contracts for the checklist and completion evidence.

## Scope Boundaries

- Do not change Swift, storyboard, project, CocoaPods, Wit, audio-session,
  dependency, signing, or runtime behavior.
- Do not add access tokens, account data, recorded audio, transcripts, device
  identifiers, screenshots, logs, archives, or signing material.
- Do not claim Xcode, simulator, microphone, Wit service, or physical-device
  execution from portable checks.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- `sh -n scripts/check-baseline.sh` and the focused baseline checker passed.
- `make check` passed from the repository and from an external working
  directory for all portable contracts available in this Linux environment.
- Twelve hostile mutations were rejected by the checklist's static contracts.
- No Xcode build, iOS simulator, physical device, microphone, locally configured Wit service, or live voice scenario was executed;
  every runtime matrix row remains `not run`.
