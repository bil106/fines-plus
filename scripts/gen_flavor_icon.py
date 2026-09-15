#!/usr/bin/env python3
"""Generates a placeholder per-flavor Android app icon set.

This is a STOPGAP: a filled circle in the brand's primaryColorHex with the
brand's first letter in white, matching the exact file layout
flutter_launcher_icons already produces for the shared/default icon
(legacy mipmap-*/ic_launcher.png + adaptive drawable*/ic_launcher_foreground.png
+ mipmap-anydpi-v26/ic_launcher.xml + a values/colors.xml ic_launcher_background
override), so the flavor actually builds with a distinct, real icon today.
Swap these files for real brand artwork whenever it's ready - same paths,
same sizes, no other changes needed.

Usage: python3 gen_icons.py <repo_root> <flavor_key> <hex_color> <letter>
"""
import os
import sys
from PIL import Image, ImageDraw, ImageFont

FONT_PATH = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

LEGACY = [
    ("mipmap-mdpi", 48),
    ("mipmap-hdpi", 72),
    ("mipmap-xhdpi", 96),
    ("mipmap-xxhdpi", 144),
    ("mipmap-xxxhdpi", 192),
]

FOREGROUND = [
    ("drawable-mdpi", 108),
    ("drawable-hdpi", 162),
    ("drawable-xhdpi", 216),
    ("drawable-xxhdpi", 324),
    ("drawable-xxxhdpi", 432),
]

ANYDPI_XML = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background"/>
  <foreground>
      <inset
          android:drawable="@drawable/ic_launcher_foreground"
          android:inset="16%" />
  </foreground>
</adaptive-icon>
"""

COLORS_XML_TEMPLATE = """<?xml version="1.0" encoding="utf-8"?>
<resources>
\t<color name="ic_launcher_background">{hex}</color>
</resources>
"""


def make_mark(size, hex_color, letter, circle_ratio):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    d = int(size * circle_ratio)
    off = (size - d) // 2
    draw.ellipse([off, off, off + d, off + d], fill=hex_color)

    font_size = int(d * 0.55)
    font = ImageFont.truetype(FONT_PATH, font_size)
    bbox = draw.textbbox((0, 0), letter, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text(
        (size / 2 - tw / 2 - bbox[0], size / 2 - th / 2 - bbox[1]),
        letter,
        font=font,
        fill=(255, 255, 255, 255),
    )
    return img


def main():
    root, flavor, hex_color, letter = sys.argv[1:5]
    res_dir = os.path.join(root, "android/app/src", flavor, "res")

    for dirname, size in LEGACY:
        out_dir = os.path.join(res_dir, dirname)
        os.makedirs(out_dir, exist_ok=True)
        make_mark(size, hex_color, letter, circle_ratio=1.0).save(os.path.join(out_dir, "ic_launcher.png"))

    for dirname, size in FOREGROUND:
        out_dir = os.path.join(res_dir, dirname)
        os.makedirs(out_dir, exist_ok=True)
        make_mark(size, hex_color, letter, circle_ratio=0.66).save(
            os.path.join(out_dir, "ic_launcher_foreground.png")
        )

    anydpi_dir = os.path.join(res_dir, "mipmap-anydpi-v26")
    os.makedirs(anydpi_dir, exist_ok=True)
    with open(os.path.join(anydpi_dir, "ic_launcher.xml"), "w", encoding="utf-8") as f:
        f.write(ANYDPI_XML)

    values_dir = os.path.join(res_dir, "values")
    os.makedirs(values_dir, exist_ok=True)
    with open(os.path.join(values_dir, "colors.xml"), "w", encoding="utf-8") as f:
        f.write(COLORS_XML_TEMPLATE.format(hex=hex_color))

    print(f"Generated placeholder icon set for flavor '{flavor}' ({hex_color}, '{letter}') under {res_dir}")


if __name__ == "__main__":
    main()
