# AGENTS.md

## Repository purpose

`garethpaul/arlo` is an Apple platform application or Objective-C/Swift sample. Arlo - A voice personal assistant.

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `Podfile` - CocoaPods dependency definition
- `Arlo.xcodeproj` - Xcode project
- `Arlo.xcworkspace` - Xcode workspace
- `Arlo` - repository source or sample assets
- `ArloUITests` - repository source or sample assets

## Development commands

- Install dependencies: `pod install`
- Full baseline: `/usr/bin/make check`
- Combined verification: `/usr/bin/make verify`
- Lint/static checks: `/usr/bin/make lint`
- Tests: `/usr/bin/make test`
- Build: `/usr/bin/make build`
- Local Apple development: `open Arlo.xcworkspace`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Language mix noted in the README: Swift (4), C/C++ headers (2), shell (1).
- Use the CocoaPods workspace when present; update `Podfile.lock` only with an intentional dependency change.
- Preserve legacy Xcode project settings and signing assumptions unless the change is explicitly about modernization.

## Testing guidance

- Test-related files detected: `ArloUITests/ArloUITests.swift`
- Start with the narrowest relevant test or Make target, then run `/usr/bin/make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- The scan found credential-adjacent names. Review configuration paths before running against real accounts.
- The voice button stays disabled until a non-empty local Wit access token is supplied outside the committed placeholder.
- This looks like an Apple platform project or sample. Xcode, Swift, CocoaPods, and deployment target versions may need to match the original project era.
- The waveform uses Wit `WITAudioPowerChanged` notifications for audio levels and keeps the display link limited to animation cadence.
- The waveform treats non-finite Wit audio-power values as silence before updating the UI.
- Wit recording start stops the app-generated greeting before recording UI activates, preventing continued self-capture after capture begins.
- Arlo starts its one-time synthesized greeting only after the controller becomes active and visible, preventing preloaded or off-screen views from emitting speech.
- Waveform updates tolerate a missing storyboard outlet through an optional update helper.
- Wit request diagnostics retain only HTTP method metadata and never complete request URLs or serialized context.
- Wit network error diagnostics retain only error domain and numeric code, never descriptions, userInfo, or request metadata.
- Wit processing error diagnostics use a constant message and never provider response fields.
- `Pods/` is vendored dependency code; do not hand-edit it unless intentionally updating dependencies.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `/usr/bin/make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
