#!/usr/bin/env bash
# Builds a CarPapers iOS flavor and installs it on a connected iPhone.
#
# Usage: scripts/install_ios_dev.sh <carpapers|carpapersmx|carpapersar> [device-id]
#
# Signs with a free (personal) Apple team, which cannot provision Sign in with
# Apple - so the build uses empty entitlements and Apple login will not work in
# it. Free profiles expire after 7 days; rerun this script to reinstall.
set -euo pipefail

flavor="${1:-}"
case "$flavor" in
  carpapers) bundle_id="com.carpapers.app" ;;
  carpapersmx) bundle_id="com.carpapers.mx" ;;
  carpapersar) bundle_id="com.carpapers.ar" ;;
  *) echo "Usage: $0 <carpapers|carpapersmx|carpapersar> [device-id]" >&2; exit 1 ;;
esac

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="/Users/igor/fvm/versions/3.44.9/bin:$PATH"

device="${2:-$(xcrun devicectl list devices 2>/dev/null \
  | awk '/physical/ && /connected|available/ { for (i = 1; i <= NF; i++) if ($i ~ /^[0-9A-F-]{20,}$/) { print $i; exit } }')}"
if [ -z "$device" ]; then
  echo "No connected iPhone found. Connect and unlock it, or pass the device id." >&2
  exit 1
fi

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT
cat > "$work_dir/empty.entitlements" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict/></plist>
EOF

cd "$repo_root"
# Sets FLAVOR for Dart in Generated.xcconfig - must precede every xcodebuild.
flutter build ios --flavor "$flavor" --dart-define=FLAVOR="$flavor" --no-codesign

(cd ios && xcodebuild -workspace Runner.xcworkspace -scheme "$flavor" \
  -configuration "Release-$flavor" -destination "id=$device" \
  -allowProvisioningUpdates -derivedDataPath "$work_dir/dd" \
  CODE_SIGN_ENTITLEMENTS="$work_dir/empty.entitlements" build | tail -n 3)

xcrun devicectl device install app --device "$device" \
  "$work_dir/dd/Build/Products/Release-$flavor-iphoneos/Runner.app"
xcrun devicectl device process launch --device "$device" "$bundle_id" \
  || echo "Installed, but launch failed: trust the developer profile on the iPhone (Settings > General > VPN & Device Management)."

echo "Note: flutter build may have modified ios/Podfile.lock and packages/*/pubspec.lock - check git status before committing."
