# Arlo CI Baseline

status: completed

## Context

Arlo is a legacy Swift 3.0 iOS app whose full build needs macOS, Xcode, and the
matching CocoaPods-era workspace. The repository also has an SDK-free
`make check` baseline that validates source, metadata, docs, and toolchain
limits. The missing guard was a hosted workflow for that static baseline.

## Changes

- Added `.github/workflows/check.yml` for GitHub Actions.
- Ran the SDK-free `make check` baseline on Ubuntu for pushes and pull
  requests, with manual dispatch available for maintenance verification.
- Pinned `actions/checkout` to a reviewed commit, limited repository access to
  read-only, and bounded runs with a timeout and concurrency cancellation.
- Left full workspace, simulator, and CocoaPods verification documented as a
  macOS legacy-toolchain responsibility.
- Extended the baseline script and docs to keep the hosted CI guard visible.

## Verification

- `make check`
- `git diff --check`
