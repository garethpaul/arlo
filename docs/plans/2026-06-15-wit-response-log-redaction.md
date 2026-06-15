# Wit Response Log Redaction

## Status: Completed

## Context

The checked-in Wit 4.1.0 text and audio clients write complete response bodies
to device logs whenever `WIT_DEBUG` is enabled. Those JSON payloads can contain
recognized speech, inferred entities, and service metadata even though the
application only needs timing and HTTP status diagnostics.

## Priority

High privacy containment. Voice-service response content must not cross into
device diagnostics.

## Requirements

- Remove complete response payloads from the text and audio debug logs.
- Preserve text response timing and audio response status/timing diagnostics.
- Preserve response parsing, error handling, request construction, and delegate
  delivery.
- Add fail-closed source contracts for both compiled Wit response handlers.
- Document the vendored dependency patch and regeneration risk.

## Scope Boundaries

- Do not add, expose, or validate a real Wit token.
- Do not change endpoints, requests, response parsing, audio capture, delegates,
  CocoaPods resolution, or Xcode project files.
- Do not claim native compilation, microphone, network, simulator, or physical
  device validation from Linux.
- Do not merge or close stacked pull requests without explicit authorization.

## Implementation Units

1. Retain metadata-only debug diagnostics in `Wit.m` and `WITUploader.m`.
2. Extend the portable baseline checker and maintained privacy guidance.
3. Add completion evidence only after repository/external validation and
   hostile mutations pass.

## Verification

- focused source-contract validation
- repository and external-directory `make check`
- hostile text-response, audio-response, documentation, and completed-plan
  mutations
- shell syntax, plist, workspace XML, generated-artifact, credential-pattern,
  conflict-marker, and exact-diff audits

## Verification Results

- Focused source-contract validation passed.
- The repository and external-directory `make check` passed; Linux truthfully
  used the documented source-only path because `xcodebuild` is unavailable.
- Five hostile Wit response-log mutations were rejected across text payload
  logging, audio payload logging, HTTP status removal, maintained guidance, and
  completed-plan evidence.
- Native compilation, microphone, network, simulator, and physical-device
  testing were not performed.

## Remaining Risks

- A future `pod install` can overwrite the checked-in vendored patch unless the
  response-log redaction is retained during dependency regeneration.
- Native compilation and configured-Wit response behavior require macOS/Xcode
  and a maintainer-controlled test credential.
