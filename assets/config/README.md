# White-label brand configs

Each file here (except `_template.json`) is one brand/market variant, loaded
at startup by `lib/core/config/flavor_config.dart`:

```
assets/config/$FLAVOR.json  ->  AppConfig.fromJson(...)
```

`$FLAVOR` comes from `--dart-define=FLAVOR=<flavor_key>` at build/run time
(see `lib/core/services/app_initializer.dart`); it defaults to `finesplus` if
not passed.

## Fields

- `brandName` — shown as the app title (`MaterialApp.title`) and should also
  drive the native app name (Android `app_name` string resource / iOS
  `CFBundleDisplayName`) once that flavor exists — see
  `docs/white-label-playbook.md`.
- `primaryColorHex` — seeds the whole Material 3 color scheme via
  `ThemeConfig.createTheme()` (`ColorScheme.fromSeed`), so one hex is enough
  for a full, consistent palette.
- `logoAssetPath`, `supportEmail`, `phoneNumber`, `viberNumber` — brand
  contact/asset info.
- `market` — region code (`UA`, `US`, `ES`, ...). Drives the licence-plate
  format and dashboard plate badge (`AppConfig.plateMarket` ->
  `PlateMarket`), the default language (`uk` for `UA`, `en` otherwise) and
  the default distance/currency/fuel units (`UA`: km/UAH/l/100km, `US`:
  mil/USD/mpg, others: km/EUR/l/100km). Defaults to `UA` if omitted (keeps
  existing configs working unchanged).
- `finesCheckEnabled` — gates the automated Ukrainian traffic-fines check
  (`core/config/fines_api.dart` + the Cloud Run backend). That feature is
  UA-portal-specific and has no equivalent elsewhere, so it must be `false`
  for any non-UA brand. When `false`, every fines mention is hidden too
  (tab, dashboard card, onboarding slide, PDF section, paywall wording,
  `?car=` links, tech-passport field) - see
  `docs/white-label-playbook.md`. Defaults to `true` if omitted.
- `facebookLoginEnabled` — shows the Facebook sign-in button. The Facebook
  app ID is shared native config and belongs to Fines+, so a brand without
  its own Facebook app sets `false` (CarPapers does; its flavor manifest
  also turns off Facebook SDK auto-init/event logging). Defaults to `true`.
- `termsUrl` / `privacyPolicyUrl` — per-brand legal links. Leave unset
  (`null`) to fall back to the global `Env.termsUrl` / `Env.privacyPolicyUrl`
  (`.env` file) — that's what `finesplus.json`/`autodosje.json` do. A brand
  with its own legal entity/domain (like CarPapers) should set its own.

## Adding a new brand

Don't hand-write a config from scratch — run:

```
scripts/new_wl_flavor.sh <flavor_key> "<Brand Name>" <#hexcolor> <support@email>
```

which scaffolds this JSON plus the matching Android string resources. See
`docs/white-label-playbook.md` for the full checklist (Android flavor,
Firebase project, iOS scheme, store listing).

## Existing files

- `carpapers.json` — first real second-market brand (US/ES). Ships with
  `finesCheckEnabled: false` and placeholder `phoneNumber`/`termsUrl`/
  `privacyPolicyUrl` — fill those in before building it for real. Its
  logo and launcher icon are the designer's interim version, pending
  approval — see `branding/carpapers/README.md`.
