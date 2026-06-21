#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
MAKEFILE=$ROOT/Makefile
TEMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/arlo-make-authority.XXXXXX")
trap 'rm -rf "$TEMP_ROOT"' EXIT HUP INT TERM
CONTROL="$TEMP_ROOT/control dir"; mkdir -p "$CONTROL"
LOG="$TEMP_ROOT/log"; PYTHON="$TEMP_ROOT/python tool"; XCODE="$TEMP_ROOT/xcode tool"
printf '%s\n' '#!/bin/sh' 'printf "python:%s\\n" "$*" >> "$ARLO_COMMAND_LOG"' > "$PYTHON"
printf '%s\n' '#!/bin/sh' 'printf "xcode:%s\\n" "$*" >> "$ARLO_COMMAND_LOG"' > "$XCODE"
chmod +x "$PYTHON" "$XCODE"
: > "$LOG"
(cd "$CONTROL" && ARLO_COMMAND_LOG="$LOG" /usr/bin/make --no-print-directory -f "$MAKEFILE" "PYTHON=$PYTHON" "XCODEBUILD=$XCODE" test) > "$TEMP_ROOT/test.out"
grep -Fq "python:$ROOT/tests/test-wit-lifecycle.py" "$LOG"
for variable in PYTHON XCODEBUILD; do
  if (cd "$CONTROL" && /usr/bin/make --no-print-directory -f "$MAKEFILE" "$variable=\$(shell false)" lint) > "$TEMP_ROOT/syntax.out" 2>&1; then exit 1; fi
  grep -Fq "$variable must be a literal value, not Make syntax" "$TEMP_ROOT/syntax.out"
done
STARTUP="$TEMP_ROOT/startup.mk"; printf '%s\n' '$(error startup file executed)' > "$STARTUP"
if (cd "$CONTROL" && MAKEFILES="$STARTUP" /usr/bin/make --no-print-directory -f "$MAKEFILE" "PYTHON=$PYTHON" lint) > "$TEMP_ROOT/startup.out" 2>&1; then exit 1; fi
grep -Eq 'startup file executed|MAKEFILES must be empty' "$TEMP_ROOT/startup.out"
LATER="$TEMP_ROOT/later.mk"; printf '%s\n' 'lint:' '>@printf replaced' > "$LATER"
if (cd "$CONTROL" && /usr/bin/make --no-print-directory -f "$MAKEFILE" -f "$LATER" "PYTHON=$PYTHON" lint) > "$TEMP_ROOT/later.out" 2>&1; then exit 1; fi
if (cd "$CONTROL" && /usr/bin/make --no-print-directory -f "$MAKEFILE" MAKEFLAGS=-n "PYTHON=$PYTHON" lint) > "$TEMP_ROOT/flags.out" 2>&1; then exit 1; fi
grep -Fq 'MAKEFLAGS must not be overridden' "$TEMP_ROOT/flags.out"
for flag in -n --just-print --dry-run --recon -t --touch -q --question -i --ignore-errors; do
  if (cd "$CONTROL" && /usr/bin/make "$flag" --no-print-directory -f "$MAKEFILE" "PYTHON=$PYTHON" lint) > "$TEMP_ROOT/mode.out" 2>&1; then exit 1; fi
  grep -Fq 'non-executing or error-ignoring MAKEFLAGS are not supported' "$TEMP_ROOT/mode.out"
done
printf '%s\n' 'Make authority tests passed: external root, literal Python and Xcode selection, 2 raw Make-syntax controls, startup-file rejection, later Makefile rejection, caller MAKEFLAGS rejection, and 10 unsafe mode rejections'
