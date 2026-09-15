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

echo "Wrote $CONFIG_FILE - fill in the REPLACE_ME fields."
echo
echo "Still manual (see docs/white-label-playbook.md):"
echo "  - drop a logo at assets/logos/${FLAVOR_KEY}.png"
echo "  - Android: add a productFlavors { create(\"${FLAVOR_KEY}\") { ... } } block"
echo "    to android/app/build.gradle.kts (applicationId + resValue app_name)"
echo "    and put its google-services.json at android/app/src/${FLAVOR_KEY}/"
echo "  - iOS: follow ios/Flutter/Flavors/README.md"
echo "  - build with: flutter build appbundle --flavor ${FLAVOR_KEY} --dart-define=FLAVOR=${FLAVOR_KEY}"
