#!/usr/bin/env bash
#
# Builds and verifies a distributable universal Android release.
#
# Usage:
#   ./scripts/build_android_release.sh [apk|aab]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

info() { echo "[INFO] $*"; }
fail() { echo "[ERROR] $*" >&2; exit 1; }

load_dotenv() {
  if [ ! -f .env ]; then
    return
  fi

  while IFS= read -r line || [ -n "$line" ]; do
    line="$(printf '%s' "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    case "$line" in
      ""|\#*) continue ;;
    esac

    key="${line%%=*}"
    value="${line#*=}"
    [ -n "$key" ] || continue
    value="${value#\"}"
    value="${value%\"}"
    value="${value#\'}"
    value="${value%\'}"
    if [ -z "${!key:-}" ]; then
      export "$key=$value"
    fi
  done < .env
}

assert_universal_flutter_artifact() {
  artifact="$1"
  prefix="$2"
  entries="$(jar tf "$artifact")"

  for abi in armeabi-v7a arm64-v8a x86_64; do
    for library in libapp.so libflutter.so; do
      required_entry="$prefix/$abi/$library"
      printf '%s\n' "$entries" | grep -Fxq "$required_entry" ||
        fail "Release is not universal. Missing: $required_entry"
    done
  done
}

BUILD_TYPE="${1:-apk}"
case "$BUILD_TYPE" in
  apk)
    BUILD_COMMAND="apk"
    ARTIFACT="build/app/outputs/flutter-apk/app-release.apk"
    ENTRY_PREFIX="lib"
    DISTRIBUTION_ARTIFACT="build/distributions/quraaa-universal-release.apk"
    ;;
  aab)
    BUILD_COMMAND="appbundle"
    ARTIFACT="build/app/outputs/bundle/release/app-release.aab"
    ENTRY_PREFIX="base/lib"
    DISTRIBUTION_ARTIFACT="build/distributions/quraaa-release.aab"
    ;;
  *)
    fail "Invalid build type: $BUILD_TYPE. Use apk or aab."
    ;;
esac

load_dotenv
command -v flutter >/dev/null 2>&1 || fail "flutter command not found."
command -v jar >/dev/null 2>&1 || fail "jar command not found; a JDK is required."
[ -n "${HOST:-}" ] || fail "HOST is required. Add it to .env or the process environment."
[ -n "${BASEURL:-}" ] || fail "BASEURL is required. Add it to .env or the process environment."

build_args=(
  build
  "$BUILD_COMMAND"
  --release
  --target-platform=android-arm,android-arm64,android-x64
  --dart-define=APP_ENV=production
  "--dart-define=HOST=$HOST"
  "--dart-define=BASEURL=$BASEURL"
)
[ -n "${LATEST_VERSION:-}" ] &&
  build_args+=("--dart-define=LATEST_VERSION=$LATEST_VERSION")

info "Building universal Flutter $BUILD_TYPE release..."
flutter "${build_args[@]}"
[ -f "$ARTIFACT" ] || fail "Expected artifact not found: $ARTIFACT"

assert_universal_flutter_artifact "$ARTIFACT" "$ENTRY_PREFIX"
mkdir -p build/distributions
cp "$ARTIFACT" "$DISTRIBUTION_ARTIFACT"

if [ ! -f android/key.properties ]; then
  echo "[WARNING] No release keystore is configured; this internal build uses the local debug signing key." >&2
fi

info "Verified artifact: $DISTRIBUTION_ARTIFACT"
