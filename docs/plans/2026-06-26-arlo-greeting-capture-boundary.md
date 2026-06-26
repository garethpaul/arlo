# Arlo Greeting Capture Boundary

Status: Completed

## Goal

Prevent Arlo's synthesized launch greeting from continuing into an active Wit
recording request.

## Work

- Stop `AVSpeechSynthesizer` immediately inside the main-queue recording-start
  callback before recording UI state activates.
- Add lifecycle source ordering coverage.
- Add a hostile mutation that removes the speech-stop boundary.
- Update maintained setup, security, vision, agent, and change guidance.
- Extend the portable baseline with implementation, test, mutation, guidance,
  and completed-plan contracts.

## Verification

- Run the focused lifecycle test and complete hostile mutation suite.
- Run repository and external-directory `/usr/bin/make check`.
- Require hosted SDK-free and macOS policy checks on the exact pull-request head.
- Audit whitespace, generated artifacts, and secret-shaped additions.

## Completion Evidence

- Before implementation, the lifecycle assertion failed because
  `witDidStartRecording` did not stop synthesized speech.
- After implementation, the focused lifecycle and full mutation suites passed.
- The repository and external-directory `/usr/bin/make check` gates passed,
  including Make authority, baseline, lifecycle, and full hostile mutation
  suites.
- Six isolated hostile greeting-capture mutations were rejected across source,
  ordering, lifecycle assertion, fixture ownership, guidance, and plan status.
- Shell syntax, Python syntax, whitespace, generated-artifact, and likely-secret
  audits passed.
- Native Foundation policy tests, Xcode build/UI tests, simulator microphone
  capture, and configured Wit execution were not performed because this Linux
  host lacks the required macOS and legacy Swift 3.0 toolchain. Hosted checks
  must pass on the exact pull request head before merge.

## Runtime Boundary

Native compilation, simulator microphone capture, configured Wit execution, and
device audio-route verification require the legacy macOS toolchain and remain
unexecuted locally.
