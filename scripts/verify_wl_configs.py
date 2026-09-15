#!/usr/bin/env python3
"""Static sanity check for assets/config/*.json white-label brands.

Does NOT replace `flutter analyze`/`flutter build` - there's no Flutter/Dart
toolchain assumed here on purpose, so this only catches what's checkable
without one: JSON validity, the exact defaulting AppConfig.fromJson applies,
whether each flavor is registered in pubspec.yaml's assets: list (a config
that exists on disk but isn't bundled fails silently at runtime - this is
what caught the missing carpapers.json/finesplus.json bug), whether a
matching Android Gradle productFlavor exists, whether logoAssetPath actually
points at a real file, whether every copyOverrides key actually exists in
the ARB string tables (a typo'd key silently never overrides anything), and
whether the flavor has its own Android launcher icon (src/<flavor>/res/) or
is knowingly sharing the default one in src/main/res/.

Usage: python3 scripts/verify_wl_configs.py
"""
import json
import os
import re
import xml.etree.ElementTree as ET

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIG_DIR = os.path.join(ROOT, "assets/config")
PUBSPEC = os.path.join(ROOT, "pubspec.yaml")
GRADLE = os.path.join(ROOT, "android/app/build.gradle.kts")
L10N_DIR = os.path.join(ROOT, "packages/core_localization/lib/l10n")


def app_config_from_json(d):
    """Mirrors AppConfig.fromJson's exact defaulting (app_config.g.dart)."""
    return {
        "brandName": d["brandName"],
        "primaryColorHex": d["primaryColorHex"],
        "logoAssetPath": d["logoAssetPath"],
        "supportEmail": d["supportEmail"],
        "phoneNumber": d["phoneNumber"],
        "viberNumber": d["viberNumber"],
        "market": d.get("market", "UA"),
        "finesCheckEnabled": d.get("finesCheckEnabled", True),
        "termsUrl": d.get("termsUrl"),
        "privacyPolicyUrl": d.get("privacyPolicyUrl"),
        "copyOverrides": d.get("copyOverrides"),
    }


def all_arb_keys():
    """Union of every string key across all intl_*.arb files."""
    keys = set()
    for fname in os.listdir(L10N_DIR):
        if not fname.endswith(".arb"):
            continue
        arb = json.loads(open(os.path.join(L10N_DIR, fname), encoding="utf-8").read())
        keys.update(k for k in arb if not k.startswith("@"))
    return keys


def has_flavor_icon(flavor_key):
    """True if this flavor has its own launcher icon override (rather than
    silently sharing whatever's in src/main/res/)."""
    return os.path.exists(os.path.join(ROOT, "android/app/src", flavor_key, "res/mipmap-mdpi/ic_launcher.png"))


def main():
    pubspec_text = open(PUBSPEC, encoding="utf-8").read()
    gradle_text = open(GRADLE, encoding="utf-8").read()
    # Only flavors declared inside productFlavors { ... }, not signingConfigs
    # create("release") etc. - scope the search to that block.
    flavors_block_match = re.search(r"productFlavors\s*\{(.*?)\n    \}", gradle_text, re.DOTALL)
    gradle_flavors = set(re.findall(r'create\("(\w+)"\)', flavors_block_match.group(1))) if flavors_block_match else set()

    files = sorted(f for f in os.listdir(CONFIG_DIR) if f.endswith(".json") and not f.startswith("_"))

    problems = []
    arb_keys = all_arb_keys()

    print(
        f"{'flavor':12} {'parses':7} {'brand':10} {'market':6} {'fines?':7} "
        f"{'in_pubspec':11} {'gradle_flavor':13} {'logo':6} {'own_icon':9} copy_overrides"
    )
    print("-" * 120)

    for fname in files:
        key = fname[:-5]
        path = os.path.join(CONFIG_DIR, fname)
        raw = open(path, encoding="utf-8").read()
        try:
            cfg = app_config_from_json(json.loads(raw))
        except Exception as e:
            print(f"{key:12} FAIL    ({e})")
            problems.append(f"{fname}: does not parse - {e}")
            continue

        in_pubspec = f"assets/config/{fname}" in pubspec_text
        has_gradle_flavor = key in gradle_flavors
        logo_exists = os.path.exists(os.path.join(ROOT, cfg["logoAssetPath"]))
        fines = cfg["finesCheckEnabled"]
        own_icon = has_flavor_icon(key)
        overrides = cfg["copyOverrides"] or {}
        bad_keys = sorted(k for k in overrides if k not in arb_keys)

        print(
            f"{key:12} {'OK':7} {cfg['brandName']:10} {cfg['market']:6} {str(fines):7} "
            f"{str(in_pubspec):11} {str(has_gradle_flavor):13} {str(logo_exists):6} {str(own_icon):9} "
            f"{len(overrides)} ({len(bad_keys)} bad)"
        )

        if not in_pubspec:
            problems.append(f"{fname}: NOT in pubspec.yaml assets: - loadAppConfig('{key}') will throw at startup")
        if not logo_exists:
            problems.append(f"{fname}: logoAssetPath does not exist on disk ({cfg['logoAssetPath']})")
        if not own_icon:
            problems.append(
                f"{fname}: no android/app/src/{key}/res/ launcher icon - shares src/main/res/'s icon "
                f"(fine if that's intentional, e.g. finesplus is the default brand)"
            )
        for bad_key in bad_keys:
            problems.append(f"{fname}: copyOverrides has key '{bad_key}' which doesn't exist in any intl_*.arb")

    print()
    print("Gradle productFlavors:", sorted(gradle_flavors))
    print()
    if problems:
        print("Problems found:")
        for p in problems:
            print(" -", p)
    else:
        print("No problems found.")


if __name__ == "__main__":
    main()
