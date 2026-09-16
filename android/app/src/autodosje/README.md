# AutoDosje flavor - missing pieces

Same situation as `android/app/src/carpapers/README.md`: this flavor is
scaffolded in `android/app/build.gradle.kts` but will not build yet.

1. **A `google-services.json` in this directory**, from a Firebase project
   registered under this flavor's `applicationId` (currently the placeholder
   `com.autodosje.app`).
2. **Confirm the `applicationId`** before the first real upload to Play
   Console - it becomes permanent for that app record once used.

Until both exist, build/run the `finesplus` flavor instead:
`flutter build appbundle --flavor finesplus --dart-define=FLAVOR=finesplus`.
