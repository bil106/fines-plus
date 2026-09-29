# CarPapers Google Play release preparation — 2026-09-28

## Upload assets

- Icon: `../play_store_icon_512.png` (existing artwork).
- Feature graphic: `../feature_graphic_1024x500.png` (1024×500 RGB PNG).
- English listing text: `../store_listing.md`, section `English (en-US)`.
- Phone screenshots: `../screenshots/en/` (actual app captures, 1080×1920).
- Terms draft for owner review: `../terms_of_use_draft.md` (not published).

## Build

```sh
.fvm/flutter_sdk/bin/flutter build appbundle --flavor carpapers --dart-define=FLAVOR=carpapers --release
```

Use `build/app/outputs/bundle/carpapersRelease/app-carpapers-release.aab`.
Do **not** use `build/app/outputs/bundle/release/app-release.aab`: that is an
older unrelated artifact. This Flutter version printed the old generic path
even though Gradle successfully built the correct flavor artifact.

The manifest in the newly built CarPapers AAB was checked:

- Package: `com.carpapers.app`.
- Version: `1.0.11`, versionCode `100`.
- minSdk 24, targetSdk 36.
- `jarsigner -verify`: `jar verified`; the upload certificate is self-signed.
  The current JDK also reports ZIP streaming/manifest-order warnings. Play's
  own bundle validation has not yet been run.

**Version code is pending confirmation from the owner.** A previously used code
cannot be uploaded again. If 100 is already used, rebuild with a larger code
using `--build-number=<unused-code>`. No project-wide version bump was made.

## Confirmed locally

- Matching Firebase Android client and web OAuth client are configured.
- Public privacy and account deletion pages returned HTTP 200.
- 19 tests passed across market defaults, disabled fines history, and plates:
  `settings_cubit_market_defaults_test.dart`,
  `history_cubit_fines_disabled_test.dart`, `plate_market_test.dart`.
- White-label validator: CarPapers checks pass. Existing unrelated findings:
  missing AutoDosje logo; Fines+ uses the shared launcher icon.
- Flutter build warns that the current Gradle/AGP versions will lose support
  in a future Flutter release. Dependencies were not upgraded.
- No Dart source changed, so no new formatter/analyzer run was needed.

## Required before final submission

1. Confirm the last uploaded versionCode and use an unused larger code.
2. Review the Terms draft, publish it at
   `https://carpapers-bde41.web.app/terms`, then replace `REPLACE_ME_TERMS_URL`
   in `assets/config/carpapers.json`, run the white-label validator, and rebuild.
   `/terms` currently returns HTTP 404. Publishing Hosting is a separate action
   requiring the owner's explicit instruction under AGENTS.md.
3. Upload the assets and AAB to the **CarPapers** app in Play Console. Existing
   `play-publish-key.json` cannot access this app (HTTP 403); no release or
   listing was modified by this preparation.
4. Review App content: privacy policy, ads declaration, target audience,
   content rating, Data safety, and reviewer access. The app uses AdMob,
   Firebase Auth/Firestore/Storage/Analytics/Crashlytics/Messaging and Maps;
   do not declare “no data collected” or “no ads” without changing/validating
   the actual implementation. Data safety answers have not been audited here.
5. Add a working review account directly in Play Console's App access section,
   with English steps and access to paid features where needed. Do not put
   account passwords in this repository.
6. Verify subscription products `sub_quarter` and `yearly_2549`, base plans,
   offers and trial disclosures in this new app. Complete a Play-installed
   internal-test purchase; sideloaded APK startup does not verify billing.
7. Register Play App Signing SHA certificates in the correct Firebase Android
   app, then test Google login using a build installed from Play.
8. Select countries/pricing and a release track. Resolve Console blockers and
   testing/access requirements shown for this developer account. Submit for
   review only once these items and the store preview are checked.

Public URLs:

- Privacy: https://carpapers-bde41.web.app/privacy
- Account deletion: https://carpapers-bde41.web.app/delete-account
- Support: carpapers.support@gmail.com

## Official references

- [Graphics requirements](https://support.google.com/googleplay/android-developer/answer/9866151)
- [Target API requirements](https://support.google.com/googleplay/android-developer/answer/11926878)
- [Reviewer access](https://support.google.com/googleplay/android-developer/answer/15748846)
