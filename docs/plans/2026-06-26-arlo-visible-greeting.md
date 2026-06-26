# Arlo Visible Greeting

Status: Completed

## Goal

Prevent preloaded or off-screen Arlo controllers from emitting the synthesized
launch greeting.

## Work

- Move greeting construction and speech from `viewDidLoad` to `viewDidAppear`.
- Require active-view state and one-time controller ownership.
- Claim ownership before starting speech.
- Add lifecycle, hostile mutation, baseline, and documentation contracts.

## Verification

- The red-first lifecycle assertion failed because `viewDidLoad` emitted speech.
- Focused lifecycle and hostile visible-greeting mutations pass after the fix.
- Repository and external-directory `/usr/bin/make check` remain required.
- Hosted SDK-free, native policy, and CodeQL checks remain required on the exact PR head.

Implementation head `7739ed06f9860e77ef3533827d9a3168a307d792` passed hosted
check run `28269325572` and CodeQL run `28269325690`. Codex review stopped
before analysis with OpenAI HTTP 401; immutable manual review found no
actionable issues. The final evidence-only head must repeat hosted checks.

## Runtime Boundary

This Linux host cannot run the legacy Swift 3 iOS app. Simulator and device
confirmation of greeting timing remains a hosted or exact-commit device task.
