#!/bin/bash
# deploy.sh — export from Godot, fix, build, and install on connected iPhone.
# Usage: ./deploy.sh
set -euo pipefail

GODOT="/Users/dap/Downloads/Godot.app/Contents/MacOS/Godot"
PROJ="Queen Kalila.xcodeproj"
SCHEME="Queen Kalila"
TEAM="73U457DV2W"

cd "$(dirname "$0")"

# ── 1. Godot export ───────────────────────────────────────────────────────────
echo "==> Exporting from Godot..."
"$GODOT" --headless --export-release "iOS" "Queen Kalila.ipa"

# ── 2. Post-export fixes (team ID quoting + portrait orientation) ─────────────
echo "==> Applying fixes..."
./fix_export.sh

# ── 3. Find connected iPhone/iPad ─────────────────────────────────────────────
echo "==> Looking for connected device..."
DEVICE_ID=$(xcrun xctrace list devices 2>&1 \
  | grep -E '(iPhone|iPad)' \
  | grep -v Simulator \
  | grep -oE '[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}' \
  | head -1)

if [ -z "$DEVICE_ID" ]; then
  echo "ERROR: No iPhone/iPad found. Plug in your device and try again."
  exit 1
fi
echo "==> Device: $DEVICE_ID"

# ── 4. Build ──────────────────────────────────────────────────────────────────
echo "==> Building (this takes a minute)..."
xcodebuild \
  -project "$PROJ" \
  -scheme "$SCHEME" \
  -destination "platform=iOS,id=$DEVICE_ID" \
  -configuration Debug \
  DEVELOPMENT_TEAM="$TEAM" \
  CODE_SIGN_IDENTITY="Apple Development" \
  SYMROOT="$PWD/.build" \
  build \
  | grep -E 'error:|Build succeeded|FAILED|warning:.*error' || true

APP="$PWD/.build/Debug-iphoneos/${SCHEME}.app"
if [ ! -d "$APP" ]; then
  echo "ERROR: Build failed — app bundle not found."
  echo "Re-run without the grep filter to see full output:"
  echo "  xcodebuild -project \"$PROJ\" -scheme \"$SCHEME\" -destination \"platform=iOS,id=$DEVICE_ID\" -configuration Debug DEVELOPMENT_TEAM=$TEAM build"
  exit 1
fi

# ── 5. Install on device ──────────────────────────────────────────────────────
echo "==> Installing on device..."
xcrun devicectl device install app --device "$DEVICE_ID" "$APP"

echo ""
echo "Done. Launch Queen Kalila on your iPhone."
