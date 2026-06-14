# Arlo Device Verification Matrix

Use this matrix only for an exact implementation commit. Record the commit SHA and pull request
before testing so microphone, audio-session, Wit, delegate, and lifecycle
evidence cannot be transferred to a different build.

## Evidence Rules

- Use a synthetic phrase that contains no personal, account, health, location,
  or business-sensitive information.
- Record the Xcode and Swift versions, iOS version, simulator or device class,
  empty-token or locally configured mode, result, and evidence identifier.
- Do not include access tokens, recorded audio, transcripts, device identifiers,
  account data, unrelated notifications, signing details, or raw logs.
- Store durable evidence outside git. Link only a sanitized run, screenshot, or
  short non-content log excerpt by stable identifier.
- Record each result as `pass`, `fail`, `blocked`, or `not run`, with an owner
  and follow-up for every result other than `pass`.
- Do not convert `not run` into passing evidence.

## Run Identity

| Field | Value |
| --- | --- |
| Commit SHA | `not run` |
| Pull request | `not run` |
| Xcode / Swift | `not run` |
| iOS / device or simulator | `not run` |
| Wit mode | `not run` |
| Microphone permission state | `not run` |
| Synthetic phrase | `not run` |
| Evidence location | `not run` |

## Verification Matrix

| Scenario | Expected evidence | Result | Evidence |
| --- | --- | --- | --- |
| Empty-token launch | Voice control remains disabled and no Wit singleton or play-and-record audio session is initialized. | `not run` | `not run` |
| Empty-token teardown | Dismissal and teardown avoid Wit singleton access and audio-session mutation. | `not run` | `not run` |
| Configured-token launch | A locally configured token preserves guarded audio setup and enables voice only after readiness. | `not run` | `not run` |
| Microphone permission denied | Denial leaves capture inactive, waveform reset, and the UI usable without repeated background capture. | `not run` | `not run` |
| Microphone permission granted | User-triggered capture starts only after permission and visible-controller ownership. | `not run` | `not run` |
| Recording start and stop | Recording state, display link, button state, and waveform transition on the main queue. | `not run` | `not run` |
| Waveform finite values | Non-finite and missing audio-power values render as silence rather than corrupting the waveform. | `not run` | `not run` |
| Missing waveform outlet | A missing storyboard outlet does not crash asynchronous audio-power handling. | `not run` | `not run` |
| Late audio power | Queued power notifications after capture stops cannot reactivate the waveform. | `not run` | `not run` |
| View disappear during capture | Leaving the voice view stops active capture only when the controller still owns the Wit delegate. | `not run` | `not run` |
| New controller ownership | A stale controller cannot clear or stop a newer visible controller's Wit session. | `not run` | `not run` |
| Audio interruption | Phone, route, or session interruption returns the UI to a non-recording state without background capture. | `not run` | `not run` |
| Background and foreground | Backgrounding stops capture and foregrounding does not resume it without user action. | `not run` | `not run` |
| Speech output | The preserved greeting/output path remains user-visible and does not expose voice-service credentials. | `not run` | `not run` |
| Process relaunch | Relaunch starts without stale audio session, delegate, waveform, transcript, or captured-audio state. | `not run` | `not run` |

## Current Status

No Xcode build, iOS simulator, physical device, microphone, locally configured
Wit service, or live voice scenario was executed for this checklist. Treat every Xcode, simulator, microphone, Wit, and device row as unexecuted
until evidence is attached to the exact commit.
