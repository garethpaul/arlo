---
title: Wit Request URL Log Redaction
type: security
status: completed
date: 2026-06-15
---

# Wit Request URL Log Redaction

## Problem

The vendored audio uploader retains a `WIT_DEBUG` diagnostic that writes the
complete speech request URL. The URL may include serialized Wit context and
other request metadata. Enabling the existing debug macro would therefore
expose request context in device logs despite the repository policy that Wit
request URLs remain private.

## Priorities

1. P0: Remove the complete request URL from the compiled debug diagnostic.
2. P1: Preserve a non-sensitive HTTP method diagnostic for troubleshooting.
3. P2: Keep vendored SDK replacement and broader network modernization outside
   this focused privacy patch.

## Requirements

- Replace the audio uploader diagnostic with method-only metadata.
- Keep request construction, serialized context, authorization headers,
  endpoint behavior, upload streaming, callbacks, and errors unchanged.
- Extend the fail-closed source contract across both the VAD tracker and audio
  uploader so future request-URL logging is rejected.
- Add mutation-sensitive source, guidance, and completed-plan contracts.
- Do not claim native compilation or configured-Wit execution on Linux.

## Implementation Units

### U1: Method-Only Uploader Diagnostic

**File:** `Pods/Wit/Wit/WITUploader.m`

Retain the request method in the optional debug log while removing `urlString`
from the format and arguments.

### U2: Cross-Client Privacy Contract

**File:** `scripts/check-baseline.sh`

Require the exact method-only diagnostic, reject request URL or serialized
context arguments in Wit request diagnostics, preserve the VAD tracker token
and URL boundary, and require completed verification evidence.

### U3: Maintained Guidance

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
and this plan.

Document that vendored Wit request diagnostics retain only non-sensitive method
metadata and never complete request URLs or serialized context.

## Verification

- Run POSIX shell validation and the focused source baseline.
- Run repository-root and external-directory `make check`.
- Reject isolated full-URL log, context-log, method-removal, guidance, and
  incomplete-plan mutations.
- Parse plist and workspace XML and audit exact intended paths, generated
  artifacts, conflict markers, whitespace, and credential-shaped additions.

## Completion Evidence

- Replaced the vendored audio uploader's complete request URL diagnostic with
  method-only metadata while leaving request construction and transport intact.
- Extended the fail-closed checker across both Wit request paths and synchronized
  repository privacy guidance.
- Five hostile mutations were rejected for restored full URLs, serialized
  context logging, removed method metadata, missing guidance, and incomplete
  plan status.
- Repository-root and external-directory make check passed the portable source,
  plist, workspace, documentation, and completed-plan contracts.
- Exact-path diff, generated-artifact, conflict-marker, whitespace, and
  credential-shaped-addition audits passed.
- Native compilation and configured-Wit execution were not performed.

## Scope Boundaries

- Do not change Wit endpoints, tokens, request headers, serialized context,
  uploads, callbacks, response parsing, audio behavior, or user interface.
- Do not run `pod install` or regenerate the vendored project.
- Keep this pull request stacked on PR #8 and preserve base-first ordering.
