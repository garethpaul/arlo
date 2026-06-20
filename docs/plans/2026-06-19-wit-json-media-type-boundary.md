# Wit JSON Media-Type Boundary

Status: Implemented

## Problem

The shared Wit response policy accepted any `Content-Type` text containing
`+json`. That allowed non-application types and parameter values such as
`text/plain; note=+json` to cross the declared JSON media-type boundary.

## Design

Separate the media type before the first parameter separator and trim only HTTP
space/tab OWS. Validate the original subtype as an RFC 6838 ASCII
`restricted-name` before any case-insensitive comparison. Accept canonical
`application/json` or a valid `application/` subtype ending in `+json` using
ASCII-only case comparison. Reject Unicode case-folding lookalikes, suffix-like
text in parameters, other top-level types, malformed or overlong subtypes, and
suffixes that do not terminate the media type.

## Verification

- Native fake-response tests accept valid restricted-name tokens, suffixes, and
  parameters while rejecting Unicode confusables, controls, invalid punctuation,
  malformed boundaries, and overlong names through the production response path.
- Portable source contracts enforce parameter separation, ASCII OWS, RFC 6838
  grammar and length, validation-before-comparison order, application-tree
  ownership, and ASCII-only terminal suffix matching.
- Hostile mutations weaken grammar, length, case handling, and suffix conditions;
  each mutant must be rejected by the portable or native policy suite.
- `make check` remains the complete repository gate; hosted macOS CI compiles
  the maintained Objective-C sources and runs the native policy tests.

## Boundary

No live Wit request, microphone capture, simulator, device, or legacy Swift
workspace build is claimed by this change.
