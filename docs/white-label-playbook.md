# White-label playbook: adding a new brand/market

## Brands in this repo today

- `finesplus` - Fines+, UA market, fines check on. Shipping (the real
  brand, now the default flavor).
- `autodosje` - AutoDosje, UA market, fines check on. Config-level done,
  but **kept as a technical prototype only** - it's the flavor the
  white-label pipeline (template script, per-brand icon, `copyOverrides`)
  was first exercised on, not a brand planned for real release. Don't spend
  effort finishing it for shipping (Firebase project, real Play/App Store
  listing, real artwork) unless that decision changes - see item 7 below.
- `carpapers` - CarPapers, US/ES market, fines check off. Config-level
  done; needs a real Firebase project + applicationId/bundle id before it
  can actually build (see below) - unlike autodosje, this one is a real
  target market, not a prototype.

Run `python3 scripts/verify_wl_configs.py` any time to re-check all of the
above without needing a Flutter/Dart toolchain - it validates each config's
JSON, applies the same defaulting `AppConfig.fromJson` does, and cross-
checks pubspec.yaml registration, the matching Android Gradle flavor, and
whether `logoAssetPath` actually points at a real file.

## What already works after this branch

- `AppConfig` (`lib/core/config/app_config.dart`) carries `market`,
  `finesCheckEnabled`, `termsUrl`, `privacyPolicyUrl` alongside the existing
  brand/color/contact fields - all optional, so existing configs keep
  their old behavior unchanged.
- `MaterialApp.title` reads `config.brandName` instead of a hardcoded
  `'Fines+'` (`lib/app/app.dart`).
- The Terms/Privacy links on the paywall (`subscription_screen.dart`) prefer
  `config.termsUrl`/`config.privacyPolicyUrl`, falling back to the global
  `Env.termsUrl`/`Env.privacyPolicyUrl` when a brand doesn't set its own
  (that's what `finesplus.json`/`autodosje.json` do; `carpapers.json` sets
  its own since it's a different legal product).
- Every real entry point into the Ukraine fines-check is gated behind
  `config.finesCheckEnabled`, in three layers: `CarCubit.checkFines()`
  bails immediately (the actual portal call, so this is the real fix
  regardless of which UI reaches it), `CarInfoScreen` hides its own
  "Пошук" button + recaptcha step, and `HomeScreenWrapperState.openPage()`
  refuses to navigate to `HomePage.fines` as a backstop.
- With `finesCheckEnabled: false` the app also never *mentions* fines: the
  bottom-nav tab, the dashboard alert card and the onboarding fines slide
  are hidden; the buyer-report PDF drops its fines section (and skips the
  Firestore fetch for it); the paywall subtitle uses
  `subscription_subtitle_no_fines`; `?car=` deep/app links no longer open
  `FinesRoute`; and the tech-passport field (only used by the UA check) is
  hidden in the garage sheet and on `CarInfoScreen`.
- `market` drives the market-specific defaults (all overridable by the
  user in Settings):
  - **Licence plate** - `AppConfig.plateMarket` -> `PlateMarket`
    (`packages/core_utils/lib/formatters/plate_market.dart`): input
    pattern (`VehicleNumberFormatter`), validation (`CarCubit`,
    `CarInfoCubit`, garage sheet), input hint, and the dashboard
    `LicensePlateBadge` style. `UA` = `AA1234BB` + UA strip, `ES` =
    `1234BCD` (consonants only) + EU strip, `US` (and any market without
    its own rules) = free-form 1-8 letters/digits + "USA" header.
  - **Language** - `uk` for `UA`, `en` otherwise (`SettingsCubit`).
  - **Units/currency** - `UA`: km/UAH/l/100km, `US`: mil/USD/mpg, other
    markets: km/EUR/l/100km (`SettingsCubit._marketDefaults`). Amounts are
    still stored in UAH and converted for display, as before.
- iOS: the hardcoded `FirebaseOptions` in `lib/main.dart` (Fines+'s own
  project) apply only to the `finesplus` flavor (`currentFlavor` in
  `lib/core/config/flavor_config.dart`); every other flavor initializes
  Firebase from its own target's `GoogleService-Info.plist`.
- `assets/config/finesplus.json`, `autodosje.json` and `carpapers.json` are
  real brand configs, all registered in `pubspec.yaml`'s `assets:` list and
  with a matching Android `productFlavors` entry
  (`android/app/build.gradle.kts`) - `finesplus` keeps the existing
  `com.finesplus` applicationId (so it keeps updating the current Play
  Store listing); `autodosje`/`carpapers` use placeholder applicationIds.
- `assets/config/_template.json` + `scripts/new_wl_flavor.sh` scaffold a new
  brand's config file (and now also registers it in `pubspec.yaml`
  automatically) without hand-writing JSON.
- Each Android flavor can have its **own app icon**: `finesplus` keeps the
  existing shared icon in `android/app/src/main/res/`; `autodosje` and
  `carpapers` now have their own overrides in
  `android/app/src/{autodosje,carpapers}/res/` (legacy `mipmap-*/ic_launcher.png`
  + adaptive `drawable*/ic_launcher_foreground.png` + `mipmap-anydpi-v26/
  ic_launcher.xml` + a `values/colors.xml` background color) - Gradle picks
  the flavor-specific one automatically, no wiring needed beyond the files
  existing. Real artwork isn't ready yet, so right now these are generated
  placeholders (a filled circle in the brand's `primaryColorHex` with its
  first letter) - see "Per-brand app icons" below.
- A brand can **reword a specific string** without forking the whole
  localization table, via `AppConfig.copyOverrides` + `brandCopy()`
  (`lib/core/config/brand_copy.dart`) - see "Per-brand copy overrides"
  below. Wired up as a real example on `autodosje.json`
  (`garage_setup_title`/`garage_setup_subtitle`).

## Two real bugs this surfaced (fixed)

Actually using the template to create AutoDosje, and re-verifying CarPapers
alongside it, caught two things that a purely additive "just create the
JSON" pass would have missed:

1. `assets/config/carpapers.json` (added earlier this branch) was never
   added to `pubspec.yaml`'s `assets:` list, so `loadAppConfig('carpapers')`
   would have thrown at startup - the file existed on disk but wasn't
   bundled into the app. Fixed, and `scripts/new_wl_flavor.sh` now does
   this step itself for future brands.
2. There was never an `assets/config/finesplus.json`, and nothing in this
   repo passes `--dart-define=FLAVOR=` (checked: no CI, no fastlane, no
   `.vscode`/`.idea` run config) - so the real production app has been
   silently resolving `AppConfig` from the `autolux` demo brand (a legacy
   demo flavor, since removed from the repo) via `flavor_config.dart`'s
   default this whole time. Harmless while nothing
   read `config.brandName`, but this branch's `MaterialApp.title` change
   would have made the shipping app's title regress to "AutoLux". Fixed by
   adding the real `finesplus.json` and changing the default flavor to
   `'finesplus'`.

## Correction: what the earlier "known gap" note actually was

An earlier version of this doc said `AddCarScreen.onFineCheck` still
navigated to the Fines screen unconditionally. On closer look that
callback is dead code - `AddCarScreen` accepts it but no widget in that
screen ever calls it, so it was never reachable. The real, live gap was
`CarInfoScreen`: its "Пошук" button shows a recaptcha and, on success,
calls `CarCubit.checkFines()` directly - a second, independent path into
the Ukraine portal lookup that never went through the Fines screen or the
bottom nav at all. That's fixed (see above), at the cubit level so it
holds regardless of which UI ends up calling it.

The follow-up this section used to flag - car-number input/validation
hardcoded to the Ukrainian plate format, and the tech-passport field shown
to every brand - is done: plate rules now come from `market` via
`PlateMarket`, and the tech-passport field is hidden when
`finesCheckEnabled` is false (see "What already works" above).

## Per-brand app icons (Android)

`flutter_launcher_icons`/`flutter_native_splash` in `pubspec.yaml` are
still configured globally (one `image_path`) and only ever write into
`android/app/src/main/res/` - they know nothing about flavors, and running
them again will not touch a flavor's own icon directory, so it's safe to
keep them as-is for the shared/default (`finesplus`) icon.

For a flavor that needs a *different* icon, Android's normal per-flavor
resource merging already does the rest: anything under
`android/app/src/<flavor>/res/` overrides `src/main/res/` for that flavor
only, with no Gradle config needed beyond the `productFlavors` entry that
already exists for it. `autodosje` and `carpapers` both have one now.

Since there's no real brand artwork for either yet, `scripts/gen_flavor_icon.py`
generates a placeholder set (filled circle in the brand's `primaryColorHex`,
first letter in white) in the exact file layout Android expects:

```
android/app/src/<flavor>/res/
  mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png   # legacy (pre-API26)
  drawable-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher_foreground.png  # adaptive foreground
  mipmap-anydpi-v26/ic_launcher.xml                          # adaptive icon wiring
  values/colors.xml                                          # ic_launcher_background
```

`scripts/new_wl_flavor.sh` now calls it automatically for every new flavor.
To swap in real artwork later, just replace those PNG files at the same
paths/sizes - nothing else needs to change. `scripts/verify_wl_configs.py`
flags any flavor with no `src/<flavor>/res/` icon at all (that's fine for
`finesplus`, which intentionally shares the default).

**iOS is not covered by this** - `ios/Runner/Assets.xcassets/AppIcon.appiconset`
is still one shared icon for every scheme/target, and per-flavor iOS icons
are part of the manual Xcode work in `ios/Flutter/Flavors/README.md`
(new target needs its own `AppIcon` asset catalog entry).

## Per-brand copy overrides (same-language reword)

Sometimes two brands share a language but need different wording for the
same string - e.g. AutoDosje wants "Ваш автодосьє" where Fines+ says "Ваш
гараж", even though both are Ukrainian. That's a different problem from
market-based locale selection (`SettingsCubit` picks the default language
from `AppConfig.market` - `uk` for `UA`, `en` otherwise - which swaps the
whole ARB table, not single strings).

The mechanism: `AppConfig.copyOverrides` is an optional
`Map<String, String>`, keyed by the exact key used in
`packages/core_localization/lib/l10n/intl_*.arb` (e.g.
`"garage_setup_subtitle"`). `brandCopy(context, key, fallback)`
(`lib/core/config/brand_copy.dart`) looks the key up in the active brand's
`copyOverrides` and returns the override if present, otherwise `fallback`.

To reword a string for one brand:

1. Confirm the ARB key you want to override already exists (it must - this
   only rewords existing strings, it never adds new ones).
2. At the call site, change `S.of(context).some_key` to
   `brandCopy(context, 'some_key', S.of(context).some_key)`.
3. Add `"some_key": "brand's wording"` under `"copyOverrides"` in that
   brand's config JSON.

Only the call sites that actually need to vary have to change - most of
the app can keep calling `S.of(context).xxx` directly. Today that's just
`garage_setup_title`/`garage_setup_subtitle`
(`lib/features/registration/presentation/screens/garage_setup_screen.dart`),
overridden for `autodosje` - a real, working example rather than unused
scaffolding, but deliberately small: extend it call-site-by-call-site as
brands actually need specific strings reworded, rather than wrapping
everything up front. `scripts/verify_wl_configs.py` flags any
`copyOverrides` key that doesn't match a real ARB key (catches typos that
would otherwise silently never override anything).

## What's still needed before AutoDosje/CarPapers can actually build and ship

**AutoDosje is intentionally not being pursued for real release right now** (it's a technical prototype - see "Brands in this repo today" above), so in practice everything below is CarPapers' punch list. Left applying to both, unmarked, in case that decision changes:

1. **Decide the real Android `applicationId`** (currently placeholders
   `com.autodosje.app` / `com.carpapers.app` in `build.gradle.kts`) and
   **iOS bundle id** (same placeholders in
   `ios/Flutter/Flavors/{Autodosje,Carpapers}.xcconfig`) - these become
   permanent on first upload, so confirm before that.
2. **Register a new Firebase project** for each, add an Android app under
   that applicationId, download `google-services.json` into
   `android/app/src/{autodosje,carpapers}/` (see the READMEs there). In that
   project: add the upload key's SHA-1/SHA-256 (`./gradlew signingReport`)
   and later Play's app-signing SHAs; enable Auth providers Email/Password
   and Google (re-download `google-services.json` after enabling Google, so
   it carries the web client ID); create Firestore and Storage (Storage
   needs the Blaze plan); then deploy the repo's rules with the project's
   `.firebaserc` alias, e.g.
   `firebase deploy --only firestore:rules,storage -P carpapers`.
   CarPapers: project `carpapers-bde41` (alias `carpapers`).
3. **iOS**: follow `ios/Flutter/Flavors/README.md` - new Xcode build
   config/scheme/target, `GoogleService-Info.plist`, app icon, wiring
   `CFBundleDisplayName` to the xcconfig value. Deliberately left as manual
   Xcode steps rather than a scripted pbxproj edit.
4. **Fill in the `REPLACE_ME` fields**: `assets/config/finesplus.json` and
   `autodosje.json` need real `supportEmail`/`phoneNumber`; `carpapers.json`
   additionally needs its own `termsUrl`/`privacyPolicyUrl` (CarPapers is a
   different legal product from Fines+/AutoDosje if it ships under a
   different entity). Drop real logos at `assets/logos/{autodosje,
   carpapers}.png` and `assets/logo/` for finesplus if it should differ
   from the current one - `scripts/verify_wl_configs.py` flags missing
   logo files.
5. **Localization**: `packages/core_localization/lib/l10n/intl_en.arb`
   already exists; add `intl_es.arb` for the ES market before shipping
   CarPapers there. AutoDosje can reuse the existing `intl_uk.arb`. The
   default locale already follows `AppConfig.market` (`uk` for `UA`, `en`
   otherwise - see "What already works").
6. **Real brand icons**: `autodosje`/`carpapers` currently ship the
   generated placeholder circle-and-letter icon (see "Per-brand app icons"
   above), not real artwork - swap
   `android/app/src/{autodosje,carpapers}/res/**` for the real thing
   whenever it's ready, and do the equivalent for iOS
   (`ios/Runner/Assets.xcassets/AppIcon.appiconset`, per-target once those
   targets exist).
7. **Apple/Google developer accounts + store listings**: a different public
   name means a genuinely separate App Store Connect app record and Play
   Console app for each, not a locale-name override on the existing Fines+
   listing - for CarPapers because the feature set differs (no fines
   check); for AutoDosje because it's a distinct public brand even though
   the feature set matches Fines+. Each needs its own screenshots,
   description, privacy policy URL, etc.

## Adding a brand beyond these three

1. `scripts/new_wl_flavor.sh <key> "<Brand>" <#hex> <email>` - scaffolds
   `assets/config/<key>.json`, registers it in `pubspec.yaml`, and generates
   a placeholder Android icon at `android/app/src/<key>/res/**` (real
   artwork can replace it any time, same paths).
2. Fill in the generated config's `REPLACE_ME` fields (and flip
   `finesCheckEnabled`/`market` if this brand needs the Ukraine fines
   check - the script defaults both off, since most new brands won't). Add
   `copyOverrides` entries only for the specific strings this brand needs
   reworded (see "Per-brand copy overrides" above) - most brands need none.
3. Add a matching Android `productFlavors { create("<key>") { ... } }`
   block to `android/app/build.gradle.kts`.
4. Add its Firebase project + `google-services.json` under
   `android/app/src/<key>/`, add a `.firebaserc` alias for it and deploy
   `firestore.rules` + `storage.rules` there (see item 2 of the list
   above).
5. Follow `ios/Flutter/Flavors/README.md` for the iOS side (icon included -
   iOS per-flavor icons aren't scripted).
6. Run `python3 scripts/verify_wl_configs.py` to catch the obvious stuff
   (missing pubspec registration, missing logo, bad JSON, unknown
   `copyOverrides` keys, missing icon override) before touching Flutter at
   all.
7. Build: `flutter build appbundle --flavor <key> --dart-define=FLAVOR=<key>`.
