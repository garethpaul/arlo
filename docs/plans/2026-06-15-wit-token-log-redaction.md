# Wit Token Log Redaction

## Status: Planned

## Context

The checked-in Wit 4.1.0 runtime compiles `WITVadTracker.m`, whose initializer
unconditionally logs the final request URL and bearer token. A locally
configured production credential can therefore be copied into device logs even
when the app itself keeps the token out of source control.

## Priority

Critical credential containment. Authentication tokens must never cross into
application or device diagnostics.

## Requirements

- Remove the credential-bearing URL and token log from the compiled Wit source.
- Preserve VAD tracker setup, request construction, network behavior, and error
  handling.
- Add a fail-closed source contract that rejects token or request-URL logging in
  `WITVadTracker.m`.
- Document the vendored dependency patch and its regeneration risk.

## Scope Boundaries

- Do not add, rotate, expose, or validate a real Wit token.
- Do not change Wit endpoints, request parameters, audio capture, response
  parsing, CocoaPods resolution, or Xcode project files.
- Do not claim microphone, network, simulator, or physical-device validation
  from Linux.
- Do not merge or close stacked pull requests without explicit authorization.

## Implementation Units

1. Remove the unconditional credential-bearing `NSLog` call.
2. Extend the baseline checker and maintained security documentation.
3. Record completed repository/external validation and hostile mutation
   evidence.

## Verification

- focused baseline source-contract validation
- repository and external-directory `make check`
- hostile token-log, URL-log, documentation, and completed-plan mutations
- shell syntax, plist, workspace XML, generated-artifact, credential-pattern,
  and exact-diff audits

## Remaining Risks

- A future `pod install` can overwrite the checked-in vendored patch unless the
  same privacy fix is retained during dependency regeneration.
- Native compilation and live configured-Wit behavior require macOS/Xcode and
  a maintainer-controlled test credential.
