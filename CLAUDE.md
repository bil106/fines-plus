# Fines+ — CLAUDE.md

Flutter app for car expense/document tracking (fines, ТО, insurance, fuel).
**Single codebase, 5 white-label flavors** (not a monorepo) — see "White-label flavors" below.

- Package name: `fines_plus`
- State management: `flutter_bloc` / `bloc` (Cubit), DI via `get_it`
- Navigation: `auto_route`
- Localization: ARB via `core_localization`
- Shared code: `packages/core*`, `packages/design_system`

---

## Non-negotiable rules

### 1) No hardcoded UI values — use the design system

**Colors** — three layers, do not mix them up:
- **Brand accent** (`primaryColorHex` in `assets/config/<flavor>.json`) → `ColorScheme.fromSeed()` in `ThemeConfig.createTheme()` (`lib/core/theme/theme_config.dart`). This is the only place the brand accent is derived — never hardcode a similar color in a screen.
- **Dashboard-redesign tokens** (`surfaceBg`, `surfaceBorder`, `divider`, `alertBg`, `alertBorder`, `alertFg`, `displayTextStyle`, `moneyTextStyle`) → `AppBrandTheme` (`packages/design_system/lib/theme/app_brand_theme.dart`), populated from `AppConfig`, read via `context.brandTheme.<token>`. Never `Color(0x...)` for these roles.
- **Fixed, brand-independent colors** → `AppColors` (`packages/design_system/lib/colors/app_colors.dart`). Expense-category colors (`catFuel`/`catService`/`catTuning`/`catCarWash`/`catOther`) are deliberately the same across all flavors. The rest of `AppColors` is a legacy palette (mixed French/English names) for screens not yet migrated to the redesign — don't add new colors there without checking whether it should be an `AppBrandTheme` token instead.
- **Dead file, do not edit expecting effect**: `packages/design_system/lib/theme/app_theme.dart` defines `appLightTheme` — it is not wired to the app anywhere. The real theme is `ThemeConfig.createTheme(config)`, wired in `lib/app/app.dart`.
- Rule of thumb: `grep -rn "Color(0x" lib/ packages/` should only ever match inside `app_colors.dart`. Any other hit is a violation.

**Radii / borders** → `AppBorders` (`packages/design_system/lib/constants/app_borders.dart`): `radiusSmall/Medium/Large/16/18/22/50`, `widthThin/Medium/Thick`.

**Spacing** → `AppSpacers` (`packages/design_system/lib/constants/app_spacers.dart`): `verticalXSmall…verticalMaxGigantic`, `horizontalXSmall…horizontalXXGigantic`. Also `AppSize`, `AppLoaders` (small/medium spinners) in the same file.

**Fonts** → never a literal font family string in a widget. `displayFontFamily` / `bodyFontFamily` / `monoFontFamily` come from `AppConfig` per flavor, resolved via `GoogleFonts.getFont()`/`getTextTheme()` in `ThemeConfig.createTheme()`.

**Before building a custom UI piece**, check `packages/design_system` for an existing token/widget first.

### 2) Localization — ARB only
- All user-visible strings go through `S.of(context)` (generated from `packages/core_localization/lib/l10n/intl_uk.arb` and `intl_en.arb`). Never hardcode user-facing text.
- A flavor that needs different wording for an *existing* string (not a new string) uses `copyOverrides` in its `assets/config/<flavor>.json`, looked up via `brandCopy()` (see `docs/white-label-playbook.md`) — it doesn't fork the ARB file.
- Check both ARB files before adding a new key; avoid duplicates.

### 3) White-label flavors — never hardcode brand-specific values
- Per-flavor config: `assets/config/<flavor>.json`, validated against `assets/config/_template.json`.
- Current flavors: `finesplus` (real, ships, UA, fines-check on — the default), `autodosje` (UA, config ready, no Firebase/applicationId yet), `carpapers` (US/ES, fines-check off, config ready, no Firebase/applicationId yet).
- New flavor: `scripts/new_wl_flavor.sh <key> "<Brand>" <#hex> <email>` → fill `REPLACE_ME` fields → add `productFlavors { create("<key>") {...} }` in `android/app/build.gradle.kts` → Firebase project + `google-services.json`/`GoogleService-Info.plist` → iOS target per `ios/Flutter/Flavors/README.md` (manual, not scripted).
- **After any `assets/config/*.json` edit, run `python3 scripts/verify_wl_configs.py`** — it catches broken JSON, an unregistered asset, a missing icon, or a `copyOverrides` typo.
- Full playbook: `docs/white-label-playbook.md`.

### 4) State management — Cubit only
- Business logic lives in a `Cubit<State>` (`flutter_bloc`/`bloc`), state classes extend `Equatable`. See `lib/features/history/presentation/cubit/` for the reference shape (sealed-ish state hierarchy: `XInitial`/`XLoading`/`XLoaded`/`XEmpty`/`XError`).
- Widgets read state via `BlocBuilder`/`BlocListener` and dispatch through the cubit — avoid calling a repository/service directly from a widget.
- DI via `get_it` (see `lib/app/startup`).

### 5) Navigation — auto_route only
- Routes are declared in `lib/app/router/app_router.dart` (`@AutoRouterConfig`). **Never hand-edit `lib/app/router/app_router.gr.dart`** — it's generated; re-run the build_runner instead.

### 6) Don't break existing UI when fixing logic
- When asked to fix logic/data/behavior, don't change styles, spacing, layout structure, or widget tree shape unless that's the actual ask. Read the existing widget fully before editing and preserve its decisions.

### 7) Code hygiene
- No dead code left behind; no old file kept alongside its replacement.
- Prefer minimal, targeted diffs; fix root causes, not symptoms.
- Don't delete code/folders silently — say what was removed and why.

### 8) Git commits
- Style already in use on this repo: short, lowercase, conventional-ish prefix — `feat:`, `fix:`, `refactor:` (see `git log --oneline`). Keep using it.
- No AI/Claude attribution in commit messages.
- Never commit or push automatically — only when explicitly asked.

---

## Repository structure

```
lib/
  app/            # app shell, startup, auto_route router
  backend/
  core/
    config/        # AppConfig (per-flavor JSON model)
    theme/         # ThemeConfig (builds ThemeData + AppBrandTheme per flavor)
    extensions/, helpers/, services/
  env/
  features/<name>/ # data / domain / presentation, one folder per feature
                    # (expenses, fines, history, home, maintenance, registration,
                    #  reminders, schedule, settings, statistics, subscription,
                    #  support, vehicle, webview, analytics, export)
  presentation/screens/  # a few screens not yet moved into features/

packages/
  core, core_cubit, core_data, core_localization, core_repository,
  core_services, core_utils, design_system

assets/config/     # per-flavor JSON (see "White-label flavors")
docs/white-label-playbook.md
scripts/           # new_wl_flavor.sh, verify_wl_configs.py, gen_flavor_icon.py
```

---

## Common commands

```bash
flutter pub get
flutter analyze

# Run a specific flavor
flutter run --flavor finesplus --dart-define=FLAVOR=finesplus

# Build (per flavor)
flutter build appbundle --flavor finesplus --dart-define=FLAVOR=finesplus

# After editing any assets/config/*.json
python3 scripts/verify_wl_configs.py

# Regenerate auto_route routes after changing app_router.dart
dart run build_runner build --delete-conflicting-outputs
```

---

## Guidance for Claude

### Before writing any code
1. Check `packages/design_system` for an existing color/radius/spacing token or widget before adding a new one.
2. Check both `intl_uk.arb`/`intl_en.arb` for an existing string before hardcoding or adding a new key.
3. Check whether a Cubit/State already exists for the feature before creating a new one.
4. If a color/font/radius/spacing value doesn't have a token yet, add the token (see rule 1) instead of hardcoding — this is the #1 way white-label breaks.

### Build verification
- Run `flutter analyze` on affected code before saying work is done.
- If `assets/config/*.json` changed, run `python3 scripts/verify_wl_configs.py`.
- Fix every `error`; pre-existing `warning`/`info` are acceptable unless touched.

### Design mockup vs. code
- The click-through design mockup (Design canvas artifact) may be ahead of the code — it's where new screens/flows get full approval before implementation. When a mockup convention (e.g. status colors: green `#1E8A4C` / amber `#B25E00` / red `#B23A3E` for ТО/insurance/fines state) gets implemented, give it a proper `AppBrandTheme`/`AppConfig` token — don't copy the mockup's hex values into widget code as literals.
- Project handover/status notes for the current redesign live in a Google Doc — see "Робочі документи" below for the current link; check there for open decisions before assuming something is finalized.


## Робочі документи

- Design canvas (Claude Artifact, джерело правди для UI): https://claude.ai/artifact/U9zexMtARry73jthp6tWMg
- Текстовий знімок поточного стану дизайну (короткий опис екранів/груп, оновлюється окремо): `docs/design.md`
- Google Doc — хендовер команди (статус впровадження, задачі, зміни по датах): https://docs.google.com/document/d/1-hfgMqRixjxjQti-_mrasZhomd-hIt0Xqav64occP0o/edit

  Google Drive API тут не дає редагувати вміст документа "на місці" — кожне
  оновлення технічно перестворює файл (новий id/URL), тому посилання вище
  завжди актуальне на момент останнього оновлення документа — воно
  переписується тут же кожного разу. Не хардкодь цей URL деінде.
