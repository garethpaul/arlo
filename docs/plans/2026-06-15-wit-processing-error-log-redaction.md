# Wit Processing Error Log Redaction

## Status: Completed

## Context

The checked-in Wit uploader still writes the server-controlled
`object[@"error"]` response field to debug logs. That value can contain
voice-service or request-specific detail and remains response payload content
even though complete success responses, request URLs, tokens, and transport
error descriptions are already redacted.

## Priority

High privacy containment. Provider error payload text must not cross into
device diagnostics.

## Requirements

- Replace the Wit processing-error payload log with a constant diagnostic.
- Preserve JSON parsing, provider error detection, code mapping, the full
  propagated `NSError`, delegate ordering, and request behavior.
- Reject restored, additive, or indirect logging of `object[@"error"]`.
- Document the vendored dependency patch and regeneration risk.
- Record completed local and mutation evidence truthfully.

## Scope Boundaries

- Do not add, expose, or validate a real Wit token.
- Do not change endpoints, requests, responses, delegates, CocoaPods
  resolution, Xcode project files, or user-facing behavior.
- Do not claim native compilation, microphone, network, simulator, or physical
  device validation from Linux.
- Do not merge or close stacked pull requests without explicit authorization.

## Implementation Units

1. Replace only the response-error debug statement in `WITUploader.m` while
   leaving `NSError` construction unchanged.
2. Extend the portable baseline checker and maintained privacy guidance.
3. Add completion evidence after root/external validation and hostile
   mutations pass.

## Verification

- focused source-contract validation
- repository and external-directory `make check`
- hostile restored, additive, indirect, propagation, guidance, and plan-status
  mutations
- shell syntax, plist, workspace XML, generated-artifact, credential-pattern,
  conflict-marker, and exact-diff audits

## Verification Results

- Focused source-contract validation passed with exactly two retained
  `object[@"error"]` uses: provider error detection and `NSError` propagation.
- The repository and external-directory make check passed through the complete
  portable source, plist, workspace, documentation, and completed-plan gates.
- Six hostile mutations covering restored, additive, indirect, propagation,
  guidance, and plan-status regressions were rejected.
- Shell syntax, plist, workspace XML, generated-artifact, credential-pattern,
  conflict-marker, and exact-diff audits passed.
- Native compilation and configured-Wit execution were not performed because
  Xcode and the legacy Swift 3.0 toolchain are unavailable on Linux.

## Remaining Risks

- A future `pod install` can overwrite the checked-in vendored patch unless the
  processing-error redaction is retained during dependency regeneration.
- Native compilation and configured-Wit behavior require macOS/Xcode and a
  maintainer-controlled test credential.
