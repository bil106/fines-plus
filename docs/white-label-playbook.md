# White-label playbook: adding a new brand/market

Status as of this branch: **CarPapers (US/ES) is scaffolded, not shippable.**
Everything that's pure config/code is done; everything that requires
registering something with Google/Apple/a Firebase project is a placeholder,
clearly marked, and listed below.

## What already works after this branch

- `AppConfig` (`lib/core/config/app_config.dart`) now carries `market`,
  `finesCheckEnabled`, `termsUrl`, `privacyPolicyUrl` alongside the existing
  brand/color/contact fields - all optional, so `autolux`/`fastcar` keep
  working unchanged.
- `MaterialApp.title` reads `config.brandName` instead of a hardcoded
  `'Fines+'` (`lib/app/app.dart`).
- The Terms/Privacy links on the paywall (`subscription_screen.dart`) prefer
  `config.termsUrl`/`config.privacyPolicyUrl`, falling back to the global
  `Env.termsUrl`/`Env.privacyPolicyUrl` when a brand doesn't set its own.
- The bottom-nav "Fines" tab (`home_screen_wrapper.dart`) is hidden entirely
  when `config.finesCheckEnabled` is `false` - it's a Ukraine-government-
  portal feature with no equivalent elsewhere.
- `assets/config/carpapers.json` is a real second brand config (US market,
  fines check off, placeholder phone/legal links).
- `assets/config/_template.json` + `scripts/new_wl_flavor.sh` scaffold the
  next brand's config file without hand-writing JSON.
- Android has a real `finesplus` / `carpapers` product-flavor split
  (`android/app/build.gradle.kts`) - `finesplus` keeps the existing
  `com.finesplus` applicationId (so it keeps updating the current Play Store
  listing); `carpapers` uses a placeholder applicationId.

## Known gap in this branch (not fixed here)

`AddCarScreen.onFineCheck` (and anywhere else that calls
`openPage(HomePage.fines)` directly, e.g. from `CarInfoScreen`) still
navigates to the Fines screen regardless of `finesCheckEnabled` - only the
bottom-nav tab is gated. A CarPapers build today could still reach the
Fines screen via that button. Worth a follow-up pass through
`grep -rn "HomePage.fines" lib` before shipping CarPapers for real.

## What's still needed before CarPapers can actually build and ship

1. **Decide the real Android `applicationId`** (currently placeholder
   `com.carpapers.app` in `build.gradle.kts`) and **iOS bundle id**
   (currently placeholder `com.carpapers.app` in
   `ios/Flutter/Flavors/Carpapers.xcconfig`) - these become permanent on
   first upload, so confirm before that.
2. **Register a new Firebase project** for CarPapers, add an Android app
   under that applicationId, download `google-services.json` into
   `android/app/src/carpapers/` (see the README there).
3. **iOS**: follow `ios/Flutter/Flavors/README.md` - new Xcode build
   config/scheme/target, `GoogleService-Info.plist`, app icon, wiring
   `CFBundleDisplayName` to the xcconfig value. Deliberately left as manual
   Xcode steps rather than a scripted pbxproj edit.
4. **Fill in `assets/config/carpapers.json`**: real `phoneNumber`,
   `termsUrl`, `privacyPolicyUrl` (CarPapers needs its own ToS/Privacy pages
   if it's a distinct legal product from Fines+), and drop a logo at
   `assets/logos/carpapers.png`.
5. **Localization**: `packages/core_localization/lib/l10n/intl_en.arb`
   already exists; add `intl_es.arb` for the ES market before shipping
   there.
6. **Apple/Google developer accounts + store listings**: a different public
   name means a genuinely separate App Store Connect app record and Play
   Console app - not a locale-name override on the existing Fines+ listing,
   because the feature set differs (no fines check). Needs its own
   screenshots, description, privacy policy URL, etc.
7. Fix the known gap above (fines-check entry points outside the bottom nav).

## Adding a brand beyond CarPapers

1. `scripts/new_wl_flavor.sh <key> "<Brand>" <#hex> <email>`
2. Fill in the generated `assets/config/<key>.json`.
3. Add a matching Android `productFlavors { create("<key>") { ... } }` block.
4. Add its Firebase project + `google-services.json` under
   `android/app/src/<key>/`.
5. Follow `ios/Flutter/Flavors/README.md` for the iOS side.
6. Build: `flutter build appbundle --flavor <key> --dart-define=FLAVOR=<key>`.
