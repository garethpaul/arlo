# Arlo System Make Boundary

Status: Completed

## Problem

Hosted verification selected `make` through `PATH`, while startup files,
unsafe modes, later Makefiles, shell changes, Python, and Xcode selection could
redirect or suppress the repository gate.

## Work Completed

- Bound GitHub Actions and contributor verification to `/usr/bin/make`.
- Froze `/bin/sh`, canonical root, and literal Python and Xcode selections.
- Rejected startup files, replaced Makefile lists, raw Make-syntax tool values,
  later Makefiles, and unsafe modes.
- Added `scripts/test-makefile-root.sh` to `/usr/bin/make check`.

## Verification

- Run `/usr/bin/make check` in the repository and externally.
- Run lifecycle, mutation, and authority tests on Linux.
- Let the hosted macOS policy and C# analysis jobs cover native boundaries.

## Scope Boundary

Voice capture, Wit transport behavior, credentials, dependencies, UI state,
and app behavior are unchanged. Literal Python and Xcode paths remain caller
authority.
