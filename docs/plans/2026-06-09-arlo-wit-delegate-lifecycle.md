# Arlo Wit Delegate Lifecycle

Status: Completed
Date: 2026-06-09

## Goal

Keep the Wit singleton from retaining a stale `ViewController` after the voice
view disappears, and stop active capture before the view tears down.

## Changes

- Moved Wit delegate assignment into the visible view lifecycle.
- Cleared the strong Wit singleton delegate when the view disappears.
- Stopped active Wit recording before display-link and speech teardown.
- Extended the SDK-free baseline and README notes for the delegate lifecycle
  guard.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`

Full Xcode build, simulator UI tests, and CocoaPods verification still require a
macOS host with the legacy Swift 3.0 toolchain.
