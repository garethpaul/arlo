# Arlo System Make Boundary

Status: Completed

## Problem

Hosted verification selected `make` through `PATH`, while unsafe modes and
untrusted tool selections could redirect or suppress the repository gate. GNU
Make still parses caller-supplied startup files before repository checks and
executes caller-added double-colon recipes and target-specific override
directives from additional makefiles.

## Work Completed

- Bound GitHub Actions and contributor verification to `/usr/bin/make`.
- Froze `/bin/sh`, canonical root, and literal Python and Xcode selections after
  this Makefile is loaded.
- Rejected replaced Makefile lists, raw Make-syntax tool values, single-colon
  recipe replacement, and unsafe modes.
- Added `scripts/test-makefile-root.sh` to `/usr/bin/make check`.

## Verification

- Run `/usr/bin/make check` in the repository and externally.
- Run lifecycle, mutation, and authority tests on Linux.
- Let the hosted macOS policy and CodeQL jobs cover native and static
  boundaries.

## Scope Boundary

Voice capture, Wit transport behavior, credentials, dependencies, UI state,
and app behavior are unchanged. Literal Python and Xcode paths remain caller
authority.
Caller-supplied startup makefiles, additional `-f` makefiles with appended double-colon recipes, target-specific override directives, and PATH-based default Python discovery remain caller authority; use the hosted workflow or pass literal trusted tool paths for repository-controlled verification.
