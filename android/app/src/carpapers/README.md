# CarPapers flavor (Android)

Builds and runs:
`flutter run --flavor carpapers --dart-define=FLAVOR=carpapers`.

- `google-services.json` - Firebase project `carpapers-bde41` (`.firebaserc`
  alias `carpapers`), Android app `com.carpapers.app`, with the upload key's
  SHA-1/SHA-256 registered. Add Play's app-signing SHAs there too once the
  app exists in Play Console, otherwise Google sign-in fails for
  Play-installed builds. Re-download this file after any fingerprint or
  sign-in provider change.
- `AndroidManifest.xml` - merged over `src/main`'s: turns off Facebook SDK
  auto-init/auto event logging, since the shared `facebook_app_id` is
  Fines+'s and CarPapers has no Facebook app (`facebookLoginEnabled: false`
  in `assets/config/carpapers.json`).
- `res/` - placeholder launcher icon and `app_name`.
- The `applicationId` in `build.gradle.kts` becomes permanent on the first
  Play Console upload.
