#!/usr/bin/env bash
#
# Builds a Flutter Android release artifact and uploads it to Firebase App Distribution.
#
# Usage:
#   ./scripts/release_android.sh [apk|aab] ["release notes"]
#
# Examples:
#   ./scripts/release_android.sh apk "Bug fixes and performance improvements"
#   ./scripts/release_android.sh aab "Internal beta build"

set -euo pipefail

# Move to the project root (parent of the scripts directory).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

info() { echo "[INFO] $*"; }
error() { echo "[ERROR] $*" >&2; }
fail() { error "$1"; exit 1; }

# Load environment variables from .env if it exists, without overwriting existing env vars.
load_dotenv() {
  if [ -f .env ]; then
    info "Loading environment variables from .env"
    while IFS= read -r line || [ -n "$line" ]; do
      # Trim leading/trailing whitespace.
      line="$(printf '%s' "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      case "$line" in
        ""|\#*) continue ;;
      esac
      # Extract key and value.
      key="${line%%=*}"
      value="${line#*=}"
      # Skip malformed lines.
      [ -n "$key" ] || continue
      # Remove surrounding single or double quotes if present.
      value="${value#\"}"
      value="${value%\"}"
      value="${value#\'}"
      value="${value%\'}"
      if [ -z "${!key:-}" ]; then
        export "$key=$value"
      fi
    done < .env
  fi
}

load_dotenv

# Validate required tooling.
command -v flutter >/dev/null 2>&1 || fail "flutter command not found. Make sure Flutter is installed and on PATH."
command -v firebase >/dev/null 2>&1 || fail "firebase command not found. Install the Firebase CLI (see docs/firebase_app_distribution.md)."

# Parse arguments.
BUILD_TYPE="${1:-apk}"
RELEASE_NOTES="${2:-}"
GROUPS="${FIREBASE_TESTER_GROUPS:-}"

if [ "$BUILD_TYPE" != "apk" ] && [ "$BUILD_TYPE" != "aab" ]; then
  fail "Invalid build type: $BUILD_TYPE. Use 'apk' or 'aab'."
fi

# Resolve configuration.
APP_ID="${FIREBASE_ANDROID_APP_ID:-}"
[ -n "$APP_ID" ] || fail "FIREBASE_ANDROID_APP_ID is not set. Add it to .env or set it as an environment variable."
[ -n "$GROUPS" ] || fail "FIREBASE_TESTER_GROUPS is not set. Add it to .env or set it as an environment variable."
[ -n "${HOST:-}" ] || fail "HOST is not set. Add it to .env or set it in the terminal environment."
[ -n "${BASEURL:-}" ] || fail "BASEURL is not set. Add it to .env or set it in the terminal environment."

PROJECT_ID="${FIREBASE_PROJECT_ID:-}"
APP_ENV="${APP_ENV:-production}"

# Forward only public runtime configuration to Dart. Passing the complete .env
# file could embed unrelated CI credentials in the client application.
dart_defines=(
  "--dart-define=HOST=$HOST"
  "--dart-define=BASEURL=$BASEURL"
  "--dart-define=APP_ENV=$APP_ENV"
)
[ -n "${LATEST_VERSION:-}" ] && dart_defines+=("--dart-define=LATEST_VERSION=$LATEST_VERSION")

# Determine build command and artifact path.
if [ "$BUILD_TYPE" = "apk" ]; then
  info "Building Flutter APK release..."
  flutter build apk --release "${dart_defines[@]}"
  ARTIFACT="build/app/outputs/flutter-apk/app-release.apk"
else
  info "Building Flutter AAB release..."
  flutter build appbundle --release "${dart_defines[@]}"
  ARTIFACT="build/app/outputs/bundle/release/app-release.aab"
fi

[ -f "$ARTIFACT" ] || fail "Expected artifact not found: $ARTIFACT"

# Assemble Firebase CLI arguments.
args=(
  appdistribution:distribute
  "$ARTIFACT"
  --app "$APP_ID"
  --groups "$GROUPS"
)
[ -n "$PROJECT_ID" ] && args+=(--project "$PROJECT_ID")
[ -n "$RELEASE_NOTES" ] && args+=(--release-notes "$RELEASE_NOTES")

# Distribute.
info "Uploading $ARTIFACT to Firebase App Distribution..."
info "App ID: $APP_ID"
info "Tester groups: $GROUPS"
firebase "${args[@]}"

info "Release uploaded successfully."
