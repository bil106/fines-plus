# CarPapers brand assets — INTERIM, pending approval

Designer's first delivery, used in the app until the final version is
approved. Known issues sent back to the designer: jagged edges, a dark
artifact on the road, grainy fill on the light part of the "P", no real
vector source (auto-traced SVG, wordmark text set in Arial).

| File | Used for |
|---|---|
| `mark_1024.png` | `assets/logos/carpapers.png` (buyer-report PDF logo), and the source of the adaptive launcher icon foreground `android/app/src/carpapers/res/drawable-*/ic_launcher_foreground.png` (background `#FFFFFF` in `values/colors.xml`) |
| `android_foreground_432.png` | designer's adaptive foreground - **not used**: its mark overflows the adaptive-icon safe zone and gets clipped by round launcher masks |
| `ios_icon_1024.png` | legacy launcher icons `mipmap-*/ic_launcher.png`; later the iOS app icon |
| `play_store_icon_512.png` | Google Play listing icon (upload in Play Console) |
| `wordmark_1200x300.png` | store listing / marketing |

To replace with the final version: overwrite these files with the same
names/sizes and regenerate the Android sizes - foreground 108/162/216/324/432
px with the mark cropped from `mark_1024.png` and scaled so its bounding box
fits inside the safe-zone circle (diameter 66/108 of the canvas), legacy
icon 48/72/96/144/192 px resized from `ios_icon_1024.png`.
