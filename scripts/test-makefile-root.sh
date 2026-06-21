#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
MAKEFILE=$ROOT/Makefile
TEMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/arlo-make-authority.XXXXXX")
trap 'rm -rf "$TEMP_ROOT"' EXIT HUP INT TERM
CONTROL="$TEMP_ROOT/control dir"; mkdir -p "$CONTROL"
LOG="$TEMP_ROOT/log"; PYTHON="$TEMP_ROOT/python tool"; XCODE="$TEMP_ROOT/xcode tool"; SHELL_LOG="$TEMP_ROOT/shell.log"
TRUSTED_PYTHON=/usr/bin/python3
test -x "$TRUSTED_PYTHON"
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
STARTUP_MARK="$TEMP_ROOT/startup-marker"
STARTUP="$TEMP_ROOT/startup.mk"; printf '%s\n' '$(shell /usr/bin/touch '"$STARTUP_MARK"')' '$(error startup file executed)' > "$STARTUP"
if (cd "$CONTROL" && MAKEFILES="$STARTUP" /usr/bin/make --no-print-directory -f "$MAKEFILE" "PYTHON=$PYTHON" lint) > "$TEMP_ROOT/startup.out" 2>&1; then exit 1; fi
grep -Eq 'startup file executed|MAKEFILES must be empty' "$TEMP_ROOT/startup.out"
test -e "$STARTUP_MARK"
LATER="$TEMP_ROOT/later.mk"; printf '%s\n' 'lint:' '>@printf replaced' > "$LATER"
if (cd "$CONTROL" && /usr/bin/make --no-print-directory -f "$MAKEFILE" -f "$LATER" "PYTHON=$PYTHON" lint) > "$TEMP_ROOT/later.out" 2>&1; then exit 1; fi
APPEND_MARK="$TEMP_ROOT/append-marker"
APPEND="$TEMP_ROOT/append.mk"
cat > "$APPEND" <<APPEND_MAKE
build check lint root-test test verify: MAKEFILE_LIST := $MAKEFILE
build::
	@/usr/bin/touch '$APPEND_MARK'
APPEND_MAKE
(cd "$CONTROL" && ARLO_COMMAND_LOG="$LOG" /usr/bin/make --no-print-directory -f "$MAKEFILE" -f "$APPEND" "PYTHON=$PYTHON" "XCODEBUILD=$XCODE" build) > "$TEMP_ROOT/append.out"
test -e "$APPEND_MARK"
FAKE_SHELL="$TEMP_ROOT/fake-shell"
cat > "$FAKE_SHELL" <<'SHELL_SCRIPT'
#!/bin/sh
printf 'shell:%s\n' "$*" >> "$ARLO_SHELL_LOG"
exec /bin/sh "$@"
SHELL_SCRIPT
chmod +x "$FAKE_SHELL"
OVERRIDE_SHELL="$TEMP_ROOT/override-shell.mk"
cat > "$OVERRIDE_SHELL" <<OVERRIDE_SHELL_MAKE
build check lint root-test test verify: MAKEFILE_LIST := $MAKEFILE
build check lint root-test test verify: override SHELL := $FAKE_SHELL
build check lint root-test test verify: override .SHELLFLAGS := -c
OVERRIDE_SHELL_MAKE
rm -f "$SHELL_LOG"
(cd "$CONTROL" && ARLO_COMMAND_LOG="$LOG" ARLO_SHELL_LOG="$SHELL_LOG" /usr/bin/make --no-print-directory -f "$MAKEFILE" -f "$OVERRIDE_SHELL" "PYTHON=$PYTHON" "XCODEBUILD=$XCODE" build) > "$TEMP_ROOT/override-shell.out"
test -s "$SHELL_LOG"
PATH_DIR="$TEMP_ROOT/path"
mkdir -p "$PATH_DIR"
cat > "$PATH_DIR/python3" <<'PYTHON_SCRIPT'
#!/bin/sh
printf 'path-python:%s\n' "$*" >> "$ARLO_COMMAND_LOG"
exit 0
PYTHON_SCRIPT
chmod +x "$PATH_DIR/python3"
rm -f "$LOG"
(
  unset PYTHON XCODEBUILD MAKEFLAGS MAKEOVERRIDES MFLAGS
  cd "$CONTROL" && PATH="$PATH_DIR:/usr/bin:/bin" ARLO_COMMAND_LOG="$LOG" /usr/bin/make --no-print-directory -f "$MAKEFILE" test
) > "$TEMP_ROOT/path-python.out"
grep -Fq "path-python:$ROOT/tests/test-wit-lifecycle.py" "$LOG"

FAIL_PATH_DIR="$TEMP_ROOT/fail-path"
FAIL_PATH_LOG="$TEMP_ROOT/fail-path.log"
FAIL_SHELL_LOG="$TEMP_ROOT/fail-shell.log"
mkdir -p "$FAIL_PATH_DIR"
cat > "$FAIL_PATH_DIR/python3" <<PYTHON_SCRIPT
#!/bin/sh
printf 'unexpected-python:%s\n' "\$*" >> '$FAIL_PATH_LOG'
exit 1
PYTHON_SCRIPT
chmod +x "$FAIL_PATH_DIR/python3"
cat > "$FAIL_PATH_DIR/sh" <<SHELL_SCRIPT
#!/bin/sh
printf 'unexpected-shell:%s\n' "\$*" >> '$FAIL_SHELL_LOG'
exit 1
SHELL_SCRIPT
chmod +x "$FAIL_PATH_DIR/sh"
rm -f "$FAIL_PATH_LOG" "$FAIL_SHELL_LOG"
(cd "$CONTROL" && PATH="$FAIL_PATH_DIR:/usr/bin:/bin" /usr/bin/make --no-print-directory -f "$MAKEFILE" "PYTHON=$TRUSTED_PYTHON" "XCODEBUILD=$XCODE" test) > "$TEMP_ROOT/literal-python.out"
test ! -e "$FAIL_PATH_LOG"
test ! -e "$FAIL_SHELL_LOG"

if [ "${ARLO_EXPLICIT_PYTHON_PROBE:-0}" != 1 ]; then
  (cd "$CONTROL" && ARLO_EXPLICIT_PYTHON_PROBE=1 /usr/bin/make --no-print-directory -f "$MAKEFILE" "PYTHON=$TRUSTED_PYTHON" "XCODEBUILD=$XCODE" root-test) > "$TEMP_ROOT/explicit-python-root-test.out"
fi

if (cd "$CONTROL" && /usr/bin/make --no-print-directory -f "$MAKEFILE" MAKEFLAGS=-n "PYTHON=$PYTHON" lint) > "$TEMP_ROOT/flags.out" 2>&1; then exit 1; fi
grep -Fq 'MAKEFLAGS must not be overridden' "$TEMP_ROOT/flags.out"
for flag in -n --just-print --dry-run --recon -t --touch -q --question -i --ignore-errors; do
  if (cd "$CONTROL" && /usr/bin/make "$flag" --no-print-directory -f "$MAKEFILE" "PYTHON=$PYTHON" lint) > "$TEMP_ROOT/mode.out" 2>&1; then exit 1; fi
  grep -Fq 'non-executing or error-ignoring MAKEFLAGS are not supported' "$TEMP_ROOT/mode.out"
done
printf '%s\n' 'Make authority tests passed: external root, literal Python and Xcode selection, trusted nested interpreter selection, explicit-Python aggregate recursion, 2 raw Make-syntax controls, startup-file boundary control, later single-colon Makefile rejection, caller-added double-colon recipe boundary control, target-specific override shell boundary control, PATH default-Python boundary control, caller MAKEFLAGS rejection, and 10 unsafe mode rejections'
