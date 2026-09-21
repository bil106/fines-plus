# Fines Plus Agent Guide

## Scope And Sources Of Truth

These instructions apply to the whole repository.

This is a single Flutter application with local Dart packages and Firebase Cloud
Functions. It is not a Melos workspace and it is not the Holidayget monorepo.

Use the project documentation in this order:

1. `AGENTS.md` for execution and repository rules.
2. `CLAUDE.md` for detailed product, design-system, localization, and white-label
   requirements.
3. `docs/white-label-playbook.md` for flavor work.
4. Nearby code and tests for feature-specific conventions.

If documentation and the current implementation disagree, do not silently copy a
pattern from another project. Verify the intended behavior and keep the change
local unless the task explicitly includes a migration.

## Working Method

For every task:

1. Inspect the named file, error, log, or feature before diagnosing it.
2. Read the complete local flow: widget, Cubit/state, repository/data source, and
   relevant test when they participate in the behavior.
3. Check `git status --short` before editing and preserve unrelated user changes.
4. Identify the root cause, then make the smallest safe diff.
5. Preserve existing architecture, public APIs, UI, and behavior outside the task.
6. Run the narrowest relevant validation and report what was and was not run.

For non-trivial changes, give a short plan before editing. Do not perform broad
refactors, dependency upgrades, generated-file churn, or repository-wide cleanup
unless explicitly requested.

## Repository Map

```text
lib/main.dart                 app bootstrap and top-level providers
lib/app/                      app shell, startup, and auto_route configuration
lib/core/                     app-specific config, theme, helpers, and services
lib/features/<feature>/       feature data/domain/presentation code
lib/presentation/screens/     legacy screens not yet moved under features
packages/                     local reusable Dart/Flutter packages
packages/design_system/       shared tokens, theme extensions, and UI widgets
packages/core_localization/   ARB sources and generated localization code
assets/config/                per-flavor white-label configuration
functions/src/                Firebase Cloud Functions TypeScript source
functions/lib/                generated JavaScript output
test/                         Flutter unit and widget tests
scripts/                      white-label creation and validation tools
```

Feature layouts are not perfectly uniform. Follow the nearest established feature
shape and do not move legacy files merely to make the tree look cleaner.

## Architecture And State

- Use `flutter_bloc` Cubits for feature business logic and state transitions.
- Match the existing feature's state style. Many features use direct
  `Cubit<State>` classes; do not introduce Holidayget's `BaseCubit` or `BaseState`.
- Keep widgets focused on rendering, input handling, and dispatching Cubit actions.
  Do not add new direct Firebase/repository calls from widgets.
- Put persistence and remote access in repositories or data sources.
- Wire application-wide dependencies in `AppInitializer`, `main.dart`, or the
  existing feature injector, according to the current ownership pattern.
- Cancel stream subscriptions and dispose controllers owned by Cubits/widgets.
- Do not introduce a new state-management or dependency-injection framework.
- Local packages should contain genuinely reusable code. Do not add new imports
  from `package:fines_plus/...` inside `packages/`; existing reverse dependencies
  are legacy debt, not a pattern to repeat.

## Navigation

- Use `auto_route` and route declarations in `lib/app/router/app_router.dart`.
- Annotate routable pages consistently with the existing `@RoutePage` pattern.
- Prefer `context.router` or the injected `AppRouter` for page navigation.
- `Navigator.pop` is acceptable for closing dialogs and modal results; do not use
  raw `Navigator.push` to create a parallel page-routing system.
- Never hand-edit `lib/app/router/app_router.gr.dart`. Regenerate it after changing
  route declarations:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## UI And White-Label Rules

The non-negotiable UI rules are defined in `CLAUDE.md`. In particular:

- Check `packages/design_system` before creating a token or reusable widget.
- Read brand-dependent values through `AppConfig`, `ThemeConfig`, and
  `context.brandTheme`; never hardcode a brand color, font, name, or capability.
- Use `AppBorders`, `AppSpacers`, `AppSize`, and `AppLoaders` for new UI values.
- Use `AppColors` only for fixed, brand-independent roles. Add redesign/brand roles
  to `AppBrandTheme` and the flavor config instead of extending the legacy palette.
- `packages/design_system/lib/theme/app_theme.dart` is not the active application
  theme. The live theme is created by `ThemeConfig.createTheme(config)`.
- Preserve layout, spacing, typography, and widget structure for logic-only fixes.
- Respect system insets through the app shell or an appropriate local `SafeArea`;
  do not blindly add nested `SafeArea` widgets to every `Scaffold`.

The repository still contains legacy hardcoded colors, strings, and cross-layer
imports. Do not use their existence as precedent, and do not clean them up outside
the requested scope. When touching such a value as part of the task, migrate it to
the appropriate token or localization key when that can be done safely and locally.

## Localization

- Put new user-visible copy in both
  `packages/core_localization/lib/l10n/intl_uk.arb` and `intl_en.arb`.
- Search both ARB files for an existing key before adding one.
- Access localized copy through generated `S` accessors, following nearby code.
- Use a flavor's `copyOverrides` for brand-specific wording of an existing key;
  do not fork ARB files per flavor.
- Do not hand-edit files under `packages/core_localization/lib/generated/`.
- Regenerate localization output from `packages/core_localization` when ARB sources
  change:

```bash
cd packages/core_localization
dart run intl_utils:generate
```

## White-Label Flavors

- The default and currently shipping flavor is `finesplus`.
- `autodosje` and `carpapers` have configuration/assets but incomplete native
  Firebase/application setup; do not describe them as release-ready without
  verifying the platform configuration.
- Never change flavor behavior by branching on a displayed brand name. Add or use a
  typed config field instead.
- After every `assets/config/*.json` change, run:

```bash
python3 scripts/verify_wl_configs.py
```

- Follow `docs/white-label-playbook.md` and `ios/Flutter/Flavors/README.md` when
  adding a flavor. Native Firebase files and iOS targets are manual prerequisites.

## Generated Files And Secrets

Do not hand-edit generated outputs:

- `**/*.g.dart`
- `lib/app/router/app_router.gr.dart`
- `packages/core_localization/lib/generated/**`
- `functions/lib/**`

Edit their source and run the appropriate generator. Review generated diffs and
keep them limited to the source change.

- Never print, commit, or copy secret values from `.env`, service credentials, or
  platform Firebase files into documentation, tests, logs, or chat responses.
- The environment asset is loaded as optional at runtime. Do not make local startup
  depend on a developer-specific `.env` unless the task explicitly changes that
  contract.
- Do not replace flavor-specific Firebase files or identifiers with files from a
  different app or flavor.

## Firebase Cloud Functions

- Edit TypeScript in `functions/src/`; treat `functions/lib/` as compiler output.
- Keep the existing strict TypeScript configuration.
- Run `npm run build` from `functions/` after changing function source.
- Do not deploy functions, Firestore rules, or hosting unless explicitly asked.
- Do not edit both `functions/index.js` and `functions/src/index.ts` for the same
  change without first confirming which entry point owns the deployed behavior.

## Testing And Validation

Use the cheapest relevant check first:

1. Format only changed Dart files with `dart format <files>`.
2. Run a focused test, for example `flutter test test/features/<area>/<test>.dart`.
3. Run `flutter analyze` when Dart code changed.
4. Run broader tests or a platform build when shared/bootstrap/native code changed,
   or when the task specifically requires release confidence.

Common commands:

```bash
flutter pub get
flutter analyze
flutter test
flutter run --flavor finesplus --dart-define=FLAVOR=finesplus
flutter build appbundle --flavor finesplus --dart-define=FLAVOR=finesplus
```

Treat analyzer errors and new warnings as regressions. Report unrelated pre-existing
warnings separately instead of broadening the task to fix them.

## Git And Completion

- Do not commit, merge, tag, push, deploy, or bump versions unless explicitly asked.
- Never stage with `git add .` in a dirty worktree. Stage only reviewed task files.
- Use the repository's short conventional commit style (`feat:`, `fix:`,
  `refactor:`, `chore:`) when a commit is requested.
- Do not add AI attribution to commits.
- Do not delete files or replace existing work silently. State what was removed and
  why, and prefer recoverable actions where practical.

Before marking a task complete, confirm:

- Only task-relevant files changed.
- No user changes were overwritten.
- No generated file was edited without its source.
- New UI uses design-system and brand tokens.
- New user-visible strings are localized in both languages.
- Relevant tests/analyzers/config validators were run, or the reason for skipping
  them is stated.
- The final response lists changed files, checks run, and any remaining risk.
