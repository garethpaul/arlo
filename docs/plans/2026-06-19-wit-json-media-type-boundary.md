# Wit JSON Media-Type Boundary

Status: Implemented

## Problem

The shared Wit response policy accepted any `Content-Type` text containing
`+json`. That allowed non-application types and parameter values such as
`text/plain; note=+json` to cross the declared JSON media-type boundary.

## Design

Normalize only the media type before the first parameter separator. Accept the
canonical `application/json` type or an `application/` subtype with a non-empty
name ending in `+json`. Reject suffix-like text in parameters, other top-level
types, empty structured subtypes, and suffixes that do not terminate the media
type.

## Verification

- Native fake-response tests accept `application/problem+json` and reject
  non-application, empty-subtype, non-terminal, and parameter-only lookalikes.
- Portable source contracts enforce parameter normalization, application-tree
  ownership, terminal suffix matching, and a non-empty subtype.
- Hostile mutations independently weaken each structured-suffix condition and
  must be rejected by the portable lifecycle suite.
- `make check` remains the complete repository gate; hosted macOS CI compiles
  the maintained Objective-C sources and runs the native policy tests.

## Boundary

No live Wit request, microphone capture, simulator, device, or legacy Swift
workspace build is claimed by this change.
