#!/usr/bin/env bash
# Builds a headless test bundle with bob and runs the unit tests.
# Bypasses the editor entirely, so `game.project` never has to change:
# tests/test.settings overrides the bootstrap collection for this build only.
#
# Usage: tools/test.sh [-p|--platform <platform>] [-t|--timeout <seconds>]
#
# Environment:
#   DEFOLD_VERSION  Defold/bob version to download when bob.jar is missing (default: 1.14.0)
#   TEST_PLATFORM   Target platform, overrides the detected host platform
#   TEST_TIMEOUT    Seconds before the test run is killed (default: 300)
#   BOB_JAR         Path to an existing bob.jar (default: ./bob.jar)
#
# Note: bob builds into ./build, the same folder the editor uses. Both use the same
# format, so they only invalidate each other's cache when the settings differ.
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

BOB="${BOB_JAR:-$ROOT/bob.jar}"
DEFOLD_VERSION="${DEFOLD_VERSION:-1.14.0}"
TIMEOUT="${TEST_TIMEOUT:-300}"
BUNDLE_DIR="dist/test-bundle"
LOG="dist/test.log"
BUILD_REPORT="dist/test-build-report.json"

die() {
	echo "error: $*" >&2
	exit 1
}

usage() {
	awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' "${BASH_SOURCE[0]}"
}

detect_platform() {
	if [ -n "${TEST_PLATFORM:-}" ]; then
		echo "$TEST_PLATFORM"
		return
	fi

	local os arch
	case "$(uname -s)" in
		Linux) os=linux ;;
		Darwin) os=macos ;;
		*) die "unsupported host OS '$(uname -s)', set TEST_PLATFORM" ;;
	esac

	case "$(uname -m)" in
		x86_64 | amd64) arch=x86_64 ;;
		arm64 | aarch64) arch=arm64 ;;
		*) die "unsupported host architecture '$(uname -m)', set TEST_PLATFORM" ;;
	esac

	echo "$arch-$os"
}

while [ $# -gt 0 ]; do
	case "$1" in
		-p | --platform) [ $# -ge 2 ] || die "$1 needs a value"; TEST_PLATFORM="$2"; shift 2 ;;
		-p=* | --platform=*) TEST_PLATFORM="${1#*=}"; shift ;;
		-t | --timeout) [ $# -ge 2 ] || die "$1 needs a value"; TIMEOUT="$2"; shift 2 ;;
		-t=* | --timeout=*) TIMEOUT="${1#*=}"; shift ;;
		-h | --help) usage; exit 0 ;;
		*) die "unknown argument '$1' (try --help)" ;;
	esac
done

PLATFORM="$(detect_platform)"
ARCH="${PLATFORM%%-*}"

command -v java >/dev/null 2>&1 || die "java not found, bob needs a JDK"
[ -f "$ROOT/tests/test.settings" ] || die "tests/test.settings is missing"

mkdir -p dist

if [ ! -f "$BOB" ]; then
	echo "Downloading bob.jar $DEFOLD_VERSION"
	curl -fL -o "$BOB" "https://github.com/defold/defold/releases/download/$DEFOLD_VERSION/bob.jar"
fi

echo "Building headless test bundle for $PLATFORM"
java -jar "$BOB" \
	--root "$ROOT" \
	--settings tests/test.settings \
	--platform "$PLATFORM" \
	--variant headless \
	--archive \
	--build-report-json "$BUILD_REPORT" \
	--bundle-output "$BUNDLE_DIR" \
	resolve build bundle

EXE="$(find "$BUNDLE_DIR" -type f -perm -u+x \( -name "*.$ARCH" -o -path "*.app/Contents/MacOS/*" \) | head -n 1)"
[ -n "$EXE" ] || die "no executable for $PLATFORM in $BUNDLE_DIR"

echo "Running tests ($EXE)"
set +e
if command -v timeout >/dev/null 2>&1; then
	timeout "$TIMEOUT" "$EXE" 2>&1 | tee "$LOG"
else
	"$EXE" 2>&1 | tee "$LOG"
fi
STATUS=${PIPESTATUS[0]}
set -e

[ "$STATUS" -eq 124 ] && echo "error: tests timed out after ${TIMEOUT}s" >&2

# A passing exit status is not enough: the suite has to report that it reached the end.
RESULT="$(grep -F 'TEST ' "$LOG" | grep -F '"event":"run_end"' | tail -n 1 || true)"
if [ -z "$RESULT" ]; then
	echo "error: no run_end event, the test run did not complete (see $LOG)" >&2
	[ "$STATUS" -eq 0 ] && STATUS=1
fi

if [ "$STATUS" -ne 0 ]; then
	echo "error: tests failed (exit $STATUS), log: $LOG" >&2
	exit "$STATUS"
fi

echo "Tests passed, log: $LOG"
