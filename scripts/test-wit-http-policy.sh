#!/bin/sh
set -eu

SCRIPT_DIR=$(dirname -- "$0")
case $SCRIPT_DIR in
  /*) ROOT_DIR=$(CDPATH='' cd "$SCRIPT_DIR/.." && pwd) ;;
  *) ROOT_DIR=$(CDPATH='' cd "./$SCRIPT_DIR/.." && pwd) ;;
esac

if [ "$(uname -s)" != "Darwin" ] || ! command -v xcrun >/dev/null 2>&1; then
  printf '%s\n' "Skipping native Wit HTTP policy tests; macOS Foundation is required."
  exit 0
fi

binary=$(mktemp "${TMPDIR:-/tmp}/arlo-wit-http-policy.XXXXXX")
trap 'rm -f "$binary"' EXIT HUP INT TERM

xcrun clang -fobjc-arc -framework Foundation \
  -I "$ROOT_DIR/Pods/Wit/Wit" \
  "$ROOT_DIR/tests/test-wit-http-policy.m" \
  "$ROOT_DIR/Pods/Wit/Wit/WITHTTPPolicy.m" \
  -o "$binary"
"$binary"
