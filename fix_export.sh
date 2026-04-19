#!/bin/bash
# Run this after every Godot iOS export, before opening in Xcode.

TEAM_ID="73U457DV2W"
PBXPROJ="Queen Kalila.xcodeproj/project.pbxproj"
PLIST="Queen Kalila/Queen Kalila-Info.plist"

cd "$(dirname "$0")"

if [ ! -f "$PBXPROJ" ]; then
  echo "ERROR: $PBXPROJ not found. Run Godot export first."
  exit 1
fi

# Fix team: quote "Personal Team" so pbxproj parses correctly
# (Xcode resolves "Personal Team" once your Apple ID is added in Xcode → Settings → Accounts)
sed -i '' 's/= Personal Team;/= "Personal Team";/g' "$PBXPROJ"
echo "✓ Team set to Personal Team"

# Fix portrait orientation
if [ -f "$PLIST" ]; then
  sed -i '' 's/UIInterfaceOrientationLandscapeLeft/UIInterfaceOrientationPortrait/g' "$PLIST"
  sed -i '' 's/UIInterfaceOrientationLandscapeRight/UIInterfaceOrientationPortrait/g' "$PLIST"
  echo "✓ Orientation set to portrait"
fi

echo "Done. You can now open the project in Xcode."
