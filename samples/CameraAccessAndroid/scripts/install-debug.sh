#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
app_id="com.meta.wearable.dat.externalsampleapps.cameraaccess"
reverse_port="${OPENCLAW_GATEWAY_PORT:-18789}"
build=1
launch=1

usage() {
  cat <<'EOF'
Usage: scripts/install-debug.sh [options]

Builds and installs the Android debug APK, sets adb reverse for OpenClaw,
and launches the app.

Options:
  --skip-build       Install the existing debug APK without rebuilding.
  --no-launch        Install but do not launch the app.
  --reverse-port N   adb reverse phone localhost:N to Mac localhost:N (default: 18789).
  -h, --help         Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-build) build=0 ;;
    --no-launch) launch=0 ;;
    --reverse-port)
      reverse_port="${2:-}"
      [[ -n "$reverse_port" ]] || { echo "--reverse-port requires a value" >&2; exit 1; }
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

adb_bin="${ADB:-}"
if [[ -z "$adb_bin" ]]; then
  for candidate in \
    "$HOME/Library/Android/sdk/platform-tools/adb" \
    "${ANDROID_HOME:-}/platform-tools/adb" \
    "${ANDROID_SDK_ROOT:-}/platform-tools/adb" \
    adb; do
    if command -v "$candidate" >/dev/null 2>&1 || [[ -x "$candidate" ]]; then
      adb_bin="$candidate"
      break
    fi
  done
fi

if [[ -z "$adb_bin" ]]; then
  echo "adb not found. Set ADB=/path/to/adb or install Android SDK platform-tools." >&2
  exit 1
fi

if [[ -z "${JAVA_HOME:-}" && -x "/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/java" ]]; then
  export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
fi

cd "$project_dir"

if [[ "$build" -eq 1 ]]; then
  ./gradlew :app:assembleDebug --no-daemon
fi

apk="$project_dir/app/build/outputs/apk/debug/app-debug.apk"
if [[ ! -f "$apk" ]]; then
  echo "Debug APK not found: $apk" >&2
  exit 1
fi

device_count="$("$adb_bin" devices | awk 'NR > 1 && $2 == "device" { count++ } END { print count+0 }')"
if [[ "$device_count" -lt 1 ]]; then
  "$adb_bin" devices
  echo "No authorized Android device found. Connect phone and accept USB debugging." >&2
  exit 1
fi

"$adb_bin" reverse "tcp:$reverse_port" "tcp:$reverse_port"
"$adb_bin" install -r "$apk"

if [[ "$launch" -eq 1 ]]; then
  "$adb_bin" shell monkey -p "$app_id" -c android.intent.category.LAUNCHER 1 >/dev/null
fi

echo "Installed $apk"
echo "adb reverse active: phone 127.0.0.1:$reverse_port -> Mac 127.0.0.1:$reverse_port"
