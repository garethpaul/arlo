---
title: Wit Network Error Log Redaction
type: security
status: completed
date: 2026-06-15
---

# Wit Network Error Log Redaction

## Problem

Two compiled vendored Wit network failure paths log `NSError` descriptions.
Those descriptions can include failing request URLs and other connection
metadata, reopening the disclosure boundary addressed by the existing request
and response log redactions.

## Priorities

1. P0: Replace network error descriptions with domain and numeric code only.
2. P1: Preserve request callbacks, failure propagation, and useful diagnostics.
3. P2: Keep SDK replacement and network-stack modernization out of scope.

## Requirements

- Redact the audio uploader and VAD tracker network failure diagnostics.
- Do not log `NSError` descriptions, userInfo, request URLs, or request objects.
- Preserve error objects passed to delegates and all request behavior.
- Add mutation-sensitive source, guidance, and completed-plan contracts.
- Do not claim native compilation or configured-Wit execution on Linux.

## Verification

- Run POSIX shell validation and repository-root and external-directory checks.
- Reject restored error-description, full-error, metadata-removal, guidance, and
  incomplete-plan mutations.
- Audit the exact diff, generated artifacts, conflict markers, whitespace, and
  credential-shaped additions.

## Completion Evidence

- Replaced both vendored Wit network failure diagnostics with error domain and
  numeric code metadata while preserving the original error callbacks.
- Repository-root and external-directory make check passed the portable source,
  plist, workspace, documentation, and completed-plan contracts.
- Six hostile mutations were rejected for restored uploader descriptions,
  restored or additional full-error logs, removed metadata, missing guidance,
  and incomplete plan status.
- Exact-path diff, generated-artifact, conflict-marker, whitespace, and
  credential-shaped-addition audits passed.
- Native compilation and configured-Wit execution were not performed.

## Scope Boundaries

- Do not change endpoints, tokens, headers, serialized context, uploads,
  callbacks, response parsing, audio behavior, or UI behavior.
- Do not run `pod install` or regenerate the vendored project.
- Keep this pull request stacked on PR #9 and preserve base-first ordering.
