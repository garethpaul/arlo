# Arlo Voice and Privacy Deep Review

## Status: Completed locally

## Scope

Review PRs #1-#11 as one maintained stack, following the iOS voice path from
configuration through microphone allocation, recording ownership, streamed
request construction, HTTP response parsing, delegate delivery, UI teardown,
and diagnostics.

## Findings and Root Causes

- The initial 2016 implementation activated the play-and-record audio session
  during application launch and never owned symmetric deactivation.
- `WITRecordingSession` emitted callbacks from its initializer before `Wit`
  stored the session, making ownership checks race legitimate callbacks.
- `Wit.stop()` released the session before the streamed HTTP response arrived,
  while old sessions could still callback after replacement.
- The uploader treated partial stream writes as complete and accepted any HTTP
  status, MIME type, response size, and top-level JSON shape.
- Transport and provider errors could retain nested URLs, payloads, and
  server-controlled values in propagated `NSError` metadata.
- The vendored context setter requested location permission, started
  significant-location monitoring, and attached coordinates even though Arlo
  declared no location flow.

## Fix Shape

- Validate tokens before UI readiness, audio allocation, and header creation.
- Start recording only after session ownership is established; retain ownership
  through response completion and reject stale session/request generations.
- Activate audio at recording start and deactivate on start failure or stop.
- Centralize HTTPS query, status, MIME, size, JSON-object, and error-redaction
  rules in a Foundation-only policy used by speech and text requests.
- Fail closed on partial/stalled audio writes and remove automatic location
  collection from the maintained vendored context helper.

## Evidence

- Red-first native fake-response tests for token, URL, status, MIME, size, JSON,
  and nested-error boundaries.
- Red-first static contracts for lifecycle ownership, audio symmetry, request
  generations, body writes, project integration, and location privacy.
- Hostile source mutations must be rejected by the contracts.
- `make check`, Objective-C syntax compilation, project parsing, credential
  scans, and hosted checks must pass before merge.

## Residual Risk

No live Wit request, microphone capture, audio interruption, simulator/device
flow, transcript validation, or legacy Swift 3 full-app build is claimed. Use a
non-production provider token and synthetic speech for exact-commit device
verification. A future pod regeneration must preserve or intentionally replace
the maintained vendored privacy and network policy.
