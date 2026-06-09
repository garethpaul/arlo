# arlo

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

## Overview

`garethpaul/arlo` is an Apple platform application or Objective-C/Swift sample. Arlo - A voice personal assistant.

This README is based on the checked-in source, manifests, scripts, and repository metadata on the `master` branch. The project language mix found during review was: Swift (4), C/C++ headers (2), shell (1).

## Repository Contents

- `README.md` - project overview and local usage notes
- `Podfile` - Apple platform dependency metadata
- `Arlo` - source or example code
- `Arlo.xcodeproj` - Xcode project file
- `ArloUITests` - source or example code
- `docs` - source or example code
- `Podfile.lock` - Apple platform dependency metadata
- `scripts` - source or example code
- `SECURITY.md` - security reporting and disclosure guidance
- `VISION.md` - project direction and maintenance guardrails

Additional scan context:

- Source directories: Arlo, ArloUITests, docs, scripts
- Dependency and build manifests: Podfile, Podfile.lock
- Entry points or build surfaces: Arlo.xcodeproj
- Test-looking files: ArloUITests/ArloUITests.swift, ArloUITests/Info.plist

## Getting Started

### Prerequisites

- Git
- macOS with Xcode for building Apple platform projects
- CocoaPods if dependencies need to be installed

### Setup

```bash
git clone https://github.com/garethpaul/arlo.git
cd arlo
pod install
```

The setup commands above are derived from repository files. Legacy mobile, Python, or JavaScript samples may require older SDKs or package versions than a modern workstation uses by default.

## Running or Using the Project

- Open `Arlo.xcodeproj` in Xcode, choose the app or sample scheme, and run it on the matching simulator/device.

## Testing and Verification

Run the SDK-free source baseline check first:

```sh
make check
scripts/check-baseline.sh
```

Open `Arlo.xcworkspace` in Xcode for simulator or device verification. The legacy baseline is Swift 3.0, iOS deployment target 9.3, CocoaPods 1.0.1 provenance, Wit 4.1.0, and SCSiriWaveformView 1.0.3.

This host does not have `xcodebuild`, `pod`, or `swift`, so full build, test, and CocoaPods verification must happen on a macOS machine with the matching legacy toolchain.

When the required SDK or runtime is unavailable, use static checks and source review first, then verify on a machine that has the matching platform toolchain.

## Configuration and Secrets

- The scan found credential-adjacent names. Review configuration paths before running against real accounts.
- The voice button stays disabled until a non-empty local Wit access token is supplied outside the committed placeholder.

## Security and Privacy Notes

- Review changes touching authentication or token handling; examples from the scan include Arlo/AppDelegate.swift, docs/plans/2026-06-08-arlo-audio-privacy-baseline.md, scripts/check-baseline.sh.
- Review changes touching external API calls or credential-adjacent configuration; examples from the scan include Arlo/AppDelegate.swift, docs/plans/2026-06-08-arlo-audio-privacy-baseline.md, scripts/check-baseline.sh.
- Review changes touching network requests, sockets, or service endpoints; examples from the scan include Arlo/Info.plist, Arlo/ViewController.swift, ArloUITests/Info.plist.
- Review changes touching mobile permissions or privacy-sensitive device data; examples from the scan include Arlo/Info.plist, docs/plans/2026-06-08-arlo-audio-privacy-baseline.md, scripts/check-baseline.sh.
- Review changes touching file, media, JSON, XML, CSV, OCR, or data parsing; examples from the scan include Arlo/Info.plist, Arlo/ViewController.swift, ArloUITests/Info.plist.

## Maintenance Notes

- This looks like an Apple platform project or sample. Xcode, Swift, CocoaPods, and deployment target versions may need to match the original project era.
- The waveform uses Wit `WITAudioPowerChanged` notifications for audio levels
  and keeps the display link limited to animation cadence.
- The waveform treats non-finite Wit audio-power values as silence before
  updating the UI.
- With the committed empty Wit token, the microphone control is dimmed and disabled
  so demo builds do not invite recording attempts before local credential setup.
- The microphone control exposes the `arlo.voice.microphone` accessibility
  identifier for UI tests and assistive technology.
- The microphone permission text describes user-triggered Wit voice capture, and
  no location permission text is declared because this source tree has no
  location flow.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.
- See `CHANGES.md` for the maintenance history.

## Contributing

Keep changes small and tied to the project that is already present in this repository. For code changes, document the toolchain used, avoid committing generated dependency directories or local configuration, and update this README when setup or verification steps change.
