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
- Every real entry point into the Ukraine fines-check is gated behind
  `config.finesCheckEnabled`, in three layers: `CarCubit.checkFines()`
  bails immediately (the actual portal call, so this is the real fix
  regardless of which UI reaches it), `CarInfoScreen` hides its own
  "Пошук" button + recaptcha step, and `HomeScreenWrapperState.openPage()`
  refuses to navigate to `HomePage.fines` as a backstop. Turned out the
  bottom-nav tab was not the only way in, and not even the main one - see
  the note below.
- `assets/config/carpapers.json` is a real second brand config (US market,
  fines check off, placeholder phone/legal links).
- `assets/config/_template.json` + `scripts/new_wl_flavor.sh` scaffold the
  next brand's config file without hand-writing JSON.
- Android has a real `finesplus` / `carpapers` product-flavor split
  (`android/app/build.gradle.kts`) - `finesplus` keeps the existing
  `com.finesplus` applicationId (so it keeps updating the current Play Store
  listing); `carpapers` uses a placeholder applicationId.

## Correction: what the earlier "known gap" note actually was

This branch first shipped with a note that `AddCarScreen.onFineCheck`
still navigated to the Fines screen unconditionally. On closer look that
callback is dead code - `AddCarScreen` accepts it but no widget in that
screen ever calls it, so it was never reachable. The real, live gap was
`CarInfoScreen`: its "Пошук" button shows a recaptcha and, on success,
calls `CarCubit.checkFines()` directly - a second, independent path into
the Ukraine portal lookup that never went through the Fines screen or the
bottom nav at all. That's fixed now (see above), at the cubit level so it
holds regardless of which UI ends up calling it.

One thing deliberately left alone: `CarInfoScreen`'s car-number/tech-
passport form validation (`_carReg`/`_techReg`) is hardcoded to Ukrainian
plate and tech-passport formats. Hiding the fines-check button doesn't
change that the rest of that screen still expects a UA-shaped plate
number. Making that screen market-aware (accept a US/ES plate format,
drop the tech-passport field where it doesn't apply) is a separate,
bigger localization task, not something to fold into a feature-flag fix -
flagging it here so it doesn't get lost before CarPapers actually ships.

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
7. Make `CarInfoScreen`'s form market-aware (see the correction note above) -
   plate/tech-passport validation is still UA-only.

## Adding a brand beyond CarPapers

1. `scripts/new_wl_flavor.sh <key> "<Brand>" <#hex> <email>`
2. Fill in the generated `assets/config/<key>.json`.
3. Add a matching Android `productFlavors { create("<key>") { ... } }` block.
4. Add its Firebase project + `google-services.json` under
   `android/app/src/<key>/`.
5. Follow `ios/Flutter/Flavors/README.md` for the iOS side.
6. Build: `flutter build appbundle --flavor <key> --dart-define=FLAVOR=<key>`.
