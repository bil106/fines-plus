#!/usr/bin/env bash
# Scaffolds the config-level pieces of a new white-label brand/market.
# Does NOT touch Android Gradle flavors or iOS Xcode config - those still
# need a real applicationId/bundle id decision and (for Android) a real
# google-services.json, so they stay manual. See docs/white-label-playbook.md.
#
# Usage:
#   scripts/new_wl_flavor.sh <flavor_key> "<Brand Name>" <#hexcolor> <support@email>
#
# Example:
#   scripts/new_wl_flavor.sh autoheim "AutoHeim" "#2563EB" support@autoheim.app

set -euo pipefail

if [ "$#" -lt 4 ]; then
  echo "Usage: $0 <flavor_key> \"<Brand Name>\" <#hexcolor> <support@email>" >&2
  exit 1
fi

FLAVOR_KEY="$1"
BRAND_NAME="$2"
HEX_COLOR="$3"
SUPPORT_EMAIL="$4"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$ROOT/assets/config/${FLAVOR_KEY}.json"
PUBSPEC="$ROOT/pubspec.yaml"
ASSET_LINE="    - assets/config/${FLAVOR_KEY}.json"

if [ -e "$CONFIG_FILE" ]; then
  echo "assets/config/${FLAVOR_KEY}.json already exists - not overwriting." >&2
  exit 1
fi

cat > "$CONFIG_FILE" <<EOF
{
  "brandName": "${BRAND_NAME}",
  "primaryColorHex": "${HEX_COLOR}",
  "logoAssetPath": "assets/logos/${FLAVOR_KEY}.png",
  "supportEmail": "${SUPPORT_EMAIL}",
  "phoneNumber": "REPLACE_ME",
  "viberNumber": "",
  "market": "REPLACE_ME (UA / US / ES / ...)",
  "finesCheckEnabled": false,
  "termsUrl": "REPLACE_ME",
  "privacyPolicyUrl": "REPLACE_ME"
}
EOF
echo "Wrote $CONFIG_FILE"

# Register it in pubspec.yaml's assets: list - a config file that isn't
# bundled fails silently until someone actually builds that flavor
# (rootBundle.loadString throws at startup). Insert right after the
# `assets:` line; skip if some earlier run already added it.
if grep -qF "$ASSET_LINE" "$PUBSPEC"; then
  echo "pubspec.yaml already lists ${FLAVOR_KEY}.json - left as is."
else
  python3 - "$PUBSPEC" "$ASSET_LINE" <<'PY'
import sys
pubspec_path, asset_line = sys.argv[1], sys.argv[2]
with open(pubspec_path, "rb") as f:
    raw = f.read()
crlf = b"\r\n" in raw
text = raw.decode("utf-8")
nl = "\r\n" if crlf else "\n"
body = text.replace("\r\n", "\n") if crlf else text
marker = "  assets:\n"
idx = body.index(marker) + len(marker)
body = body[:idx] + asset_line + "\n" + body[idx:]
out = body.replace("\n", nl) if crlf else body
with open(pubspec_path, "wb") as f:
    f.write(out.encode("utf-8"))
PY
  echo "Added '$ASSET_LINE' to pubspec.yaml assets:"
fi

echo
echo "Still manual (see docs/white-label-playbook.md):"
echo "  - fill in the REPLACE_ME fields in $CONFIG_FILE"
echo "  - drop a logo at assets/logos/${FLAVOR_KEY}.png"
echo "  - Android: add a productFlavors { create(\"${FLAVOR_KEY}\") { ... } } block"
echo "    to android/app/build.gradle.kts (applicationId + resValue app_name)"
echo "    and put its google-services.json at android/app/src/${FLAVOR_KEY}/"
echo "  - iOS: follow ios/Flutter/Flavors/README.md"
echo "  - run 'flutter pub get' once so the new asset is picked up"
echo "  - build with: flutter build appbundle --flavor ${FLAVOR_KEY} --dart-define=FLAVOR=${FLAVOR_KEY}"
