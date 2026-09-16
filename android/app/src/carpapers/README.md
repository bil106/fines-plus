# CarPapers flavor - missing pieces

This flavor is scaffolded (see `flavorDimensions`/`productFlavors` in
`android/app/build.gradle.kts`) but will NOT build yet. Two things are
needed here first, neither of which can be invented/generated locally:

1. **A `google-services.json` in this directory** (`android/app/src/carpapers/
   google-services.json`), downloaded from a Firebase project registered
   under this flavor's `applicationId` (currently the placeholder
   `com.carpapers.app` in `build.gradle.kts` - Firebase Console -> Add app ->
   Android -> that package name).
2. **Confirm the `applicationId`** in `build.gradle.kts` before the first
   real upload to Play Console - it becomes permanent for that app record
   once used.

Until both exist, build/run only the `finesplus` flavor:
`flutter build appbundle --flavor finesplus --dart-define=FLAVOR=finesplus`.
