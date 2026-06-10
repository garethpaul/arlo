# Arlo Wit Delegate Ownership Guard

## Status: Completed

## Context

Arlo uses Wit through a process-wide singleton with a strong delegate. The
visible controller assigned itself as delegate, but every disappearing or
deinitializing controller stopped capture and cleared that singleton
unconditionally. During overlapping navigation lifecycle callbacks, an older
controller could therefore interrupt capture and detach a newer visible
controller that had already become the delegate.

## Objectives

- Keep delegate registration scoped to a configured, visible voice view.
- Stop capture and clear the singleton only when the calling controller still
  owns the delegate.
- Make repeated disappear and deinitialization cleanup harmless.
- Preserve the legacy Swift 3.0 and Wit 4.1.0 compatibility boundary.
- Keep the ownership contract verifiable without Xcode or CocoaPods.

## Work Completed

- Replaced unconditional stop and clear helpers with one ownership-aware
  release helper.
- Added an identity guard against the Wit singleton's current delegate before
  mutating capture or delegate state.
- Reused the helper for view disappearance, deinitialization, and the
  unconfigured-token path.
- Extended the SDK-free baseline to enforce the helper, identity guard, owned
  stop, owned clear, completed plan, rooted Makefile, and stable CI runner.
- Updated README, VISION, and CHANGES with the singleton ownership contract.

## Verification

- `make check`
- `make -f /tmp/arlo-second-pass/Makefile check`
- `scripts/check-baseline.sh`
- Baseline mutation checks for ownership, stop, clear, plan, Makefile, and CI
  contracts
- `sh -n scripts/check-baseline.sh`
- `git diff --check`

The current host does not provide Xcode, Swift, or CocoaPods. Workspace
compilation, simulator UI tests, and live Wit capture remain manual checks on a
macOS host with the documented legacy toolchain.

## Follow-Up Candidates

- Add a coordinator abstraction only when the app gains multiple voice screens
  or a modernized Wit client.
- Exercise overlapping navigation transitions and recording teardown in a
  simulator with a local, non-committed Wit token.
