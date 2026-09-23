#!/usr/bin/env python3
"""Generates lib/features/vehicle/data/car_models.dart - the model list
offered for each make in lib/features/vehicle/data/car_makes.dart - and
assets/licenses/vehiclesdb.txt, the attribution shown on the in-app licenses
page (Settings -> Ліцензії та джерела).

Source: VehiclesDB (https://vehiclesdb.com), CC-BY 4.0, reconciled from
official vehicle registers of 14 countries (Ukraine included). The release is
pinned so re-running this script is reproducible; bump VERSION to refresh.
CC-BY 4.0 requires a visible credit plus the upstream register notices from
the dataset's ATTRIBUTION.md - both are regenerated into the license asset
from the same pinned release, so they never drift from the data.

Selection per make (the raw dataset is noisy - trims, camper conversions,
chassis codes):
  - cars registered in Ukraine, plus cars popular across several EU
    registers (keeps new models; drops Asia-only JDM/Thai models);
  - vans only when popular across several registers (Transit, Sprinter -
    not the UK-only motorhome conversions filed under the base make);
  - makes with almost no Ukrainian/popular models fall back to their
    reasonably popular global models;
  - EXCLUDE drops known junk, EXTRA adds Ukrainian-market models the
    registers miss.
Models are ordered most popular first, then alphabetically.

Usage: python3 scripts/gen_car_models.py
"""
import json
import os
import re
import subprocess
import sys
import urllib.request

VERSION = "2026.09.1"
BASE_URL = f"https://cdn.jsdelivr.net/gh/vehiclesdb/vehiclesdb@{VERSION}"

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MAKES_FILE = os.path.join(ROOT, "lib/features/vehicle/data/car_makes.dart")
OUT_FILE = os.path.join(ROOT, "lib/features/vehicle/data/car_models.dart")
LICENSE_FILE = os.path.join(ROOT, "assets/licenses/vehiclesdb.txt")

# car_makes.dart name -> VehiclesDB make name, where they differ.
MAKE_ALIASES = {
    "VAZ (Lada)": "Lada",
    "Seat": "SEAT",
}

POPULAR_MAX_DECILE = 3
POPULAR_MIN_COUNTRIES = 4
FALLBACK_MIN_MODELS = 5
FALLBACK_MAX_DECILE = 8
MAX_NAME_LENGTH = 22

EXCLUDE = {
    "ZAZ": {"T13110"},
    "VAZ (Lada)": {"Vaz 2101", "Niva 2121", "Niva 1600"},
    "Hyundai": {"Tuscon", "Atoz"},
    "Volkswagen": {"7HK", "19 E", "28", "251", "Kasten", "E-Up !"},
    "Mercedes-Benz": {"Hymer", "Mb", "W", "Electric", "Clc", "Cl"},
    "Renault": {"F"},
    "Ford": {"L T D"},
    "Isuzu": {"Ubs"},
    "Geely": {"Mk", "LC"},
    "Fiat": {"230 L", "220L", "500 Lounge"},
    "Peugeot": {"230L", "222"},
}

# Makes whose registers list old type codes ("108 D", "300 E") next to the
# model names people actually use (A-Class, Sprinter).
DROP_NUMERIC_NAMES = {"Mercedes-Benz"}

EXTRA = {
    "ZAZ": ["Tavria", "Slavuta", "Vida", "Chance"],
    "VAZ (Lada)": ["Kalina", "Priora"],
    "Daewoo": ["Nexia"],
    "Geely": ["Coolray", "Atlas", "Monjaro", "Emgrand X7", "Tugella", "Geometry C"],
    "Chery": ["Tiggo 4", "Arrizo 8"],
    "Haval": ["Dargo", "H6 HEV"],
}


def fetch(path):
    with urllib.request.urlopen(f"{BASE_URL}/{path}") as resp:
        return resp.read().decode("utf-8")


def markdown_to_text(markdown):
    text = re.sub(r"<!--.*?-->", "", markdown, flags=re.S)
    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r"\1 (\2)", text)
    text = re.sub(r"^#+\s*", "", text, flags=re.M)
    return re.sub(r"\n{3,}", "\n\n", text).strip()


def write_license(dataset, attribution_md):
    # Only the upstream register notices - the "Crediting VehiclesDB" section
    # above them is addressed to integrators, the credit itself goes first.
    notices = attribution_md[attribution_md.index("The VehiclesDB dataset"):]
    credit = dataset["attribution"]
    text = "\n\n".join([
        f"{credit['text']} ({credit['url']}), release {dataset['version']}, "
        "licensed under Creative Commons Attribution 4.0 "
        "(https://creativecommons.org/licenses/by/4.0/).",
        "Changes: the car model suggestions use a filtered subset of the "
        "dataset (models registered in Ukraine or popular across EU "
        "registers, known junk entries removed) plus a few manually added "
        "models the registers miss.",
        markdown_to_text(notices),
    ])
    os.makedirs(os.path.dirname(LICENSE_FILE), exist_ok=True)
    with open(LICENSE_FILE, "w", encoding="utf-8") as f:
        f.write(text + "\n")
    print(f"Wrote {LICENSE_FILE}")


def our_makes():
    with open(MAKES_FILE, encoding="utf-8") as f:
        return re.findall(r"^  '(.+)',$", f.read(), re.M)


def decile(model):
    return model.get("global_decile") or 99


def is_clean(name):
    return len(name) <= MAX_NAME_LENGTH and "/" not in name


def pick(make_name, raw_models):
    excluded = EXCLUDE.get(make_name, set())
    candidates = [
        m
        for m in raw_models
        if is_clean(m["name"])
        and m["name"] not in excluded
        and not (make_name in DROP_NUMERIC_NAMES and m["name"][0].isdigit())
    ]

    def popular(model):
        return decile(model) <= POPULAR_MAX_DECILE and len(model.get("availability", [])) >= POPULAR_MIN_COUNTRIES

    def wanted(model):
        if model["kind"] == "car":
            in_ukraine = "ua" in model.get("availability", [])
            return in_ukraine or (popular(model) and "eu" in model.get("regions", []))
        if model["kind"] == "van":
            return popular(model)
        return False

    chosen = [m for m in candidates if wanted(m)]
    if len(chosen) < FALLBACK_MIN_MODELS:
        chosen = [m for m in candidates if m["kind"] in ("car", "van") and decile(m) <= FALLBACK_MAX_DECILE]

    chosen.sort(key=lambda m: (decile(m), m["name"].lower()))
    names, seen = [], set()
    for name in [m["name"] for m in chosen] + EXTRA.get(make_name, []):
        if name.lower() not in seen:
            seen.add(name.lower())
            names.append(name)
    return names


def dart_string(value):
    return "'" + value.replace("\\", "\\\\").replace("'", "\\'") + "'"


def main():
    dataset = json.loads(fetch("dist/vehicles.json"))
    by_name = {m["name"]: m for m in dataset["makes"]}

    lines = [
        "// GENERATED by scripts/gen_car_models.py - do not edit by hand.",
        f"// Source: VehiclesDB {dataset['version']} (https://vehiclesdb.com), CC-BY 4.0.",
        "",
        "/// Models offered for each make in [carMakes], most popular first.",
        "/// Options of the model dropdown in the car form (showCarFormSheet).",
        "const Map<String, List<String>> carModels = {",
    ]
    for make in our_makes():
        source = by_name.get(MAKE_ALIASES.get(make, make))
        if source is None:
            sys.exit(f"Make '{make}' not found in VehiclesDB - add it to MAKE_ALIASES")
        models = pick(make, source["models"])
        lines.append(f"  {dart_string(make)}: [")
        lines.extend(f"    {dart_string(m)}," for m in models)
        lines.append("  ],")
        print(f"{make}: {len(models)} models")
    lines.append("};")

    with open(OUT_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    # Match what `dart format` would do to the file, so re-running is a no-op.
    subprocess.run(["dart", "format", OUT_FILE], check=True, stdout=subprocess.DEVNULL)
    print(f"Wrote {OUT_FILE}")

    write_license(dataset, fetch("ATTRIBUTION.md"))


if __name__ == "__main__":
    main()
