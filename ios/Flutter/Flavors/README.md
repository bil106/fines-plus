# iOS brand flavors - manual steps required

Unlike Android (Gradle `productFlavors`, fully scripted in
`android/app/build.gradle.kts`), a second iOS brand needs new Xcode build
configurations/scheme/target, which is not safe to script blindly (the
project file is easy to corrupt silently and there's no way to verify a
pbxproj edit compiles outside Xcode itself). This directory only has the
non-wired xcconfig scaffolds (`Finesplus.xcconfig`, `Carpapers.xcconfig`) -
nothing here changes the current build yet.

To actually add the CarPapers iOS build, in Xcode:

1. **Duplicate the `Runner` target** (or add new build configurations
   `Debug-carpapers`/`Release-carpapers`/`Profile-carpapers` to the existing
   target - either works, a duplicated target is usually less fiddly).
2. Have each new/duplicated configuration `#include` the matching file here
   (`Finesplus.xcconfig` for the existing ones once you're ready to switch
   them over, `Carpapers.xcconfig` for the new ones).
3. Set that configuration's **Bundle Identifier** and **Product Name** build
   settings to `$(BUNDLE_ID)` / reference `$(APP_DISPLAY_NAME)`, and update
   `Info.plist`'s `CFBundleDisplayName` to `$(APP_DISPLAY_NAME)` (only once
   the include is actually wired in - otherwise it evaluates to empty).
4. Add a second **App Icon** asset set and point the CarPapers configuration
   at it.
5. Add **`GoogleService-Info.plist`** for the CarPapers Firebase project
   (register the app there first, under `com.carpapers.app` once you've
   confirmed that's the final bundle id) - add it only to the CarPapers
   target/configuration, not `Runner`'s existing one.
6. Create a matching **Scheme** (Product > Scheme > New Scheme) so
   `flutter build ipa --flavor carpapers` (paired with
   `--dart-define=FLAVOR=carpapers`, same as Android) has something to build.

None of this is done yet - the CarPapers iOS build does not exist. This
README plus the two xcconfig files are the starting point for whenever you
sit down in Xcode to do it.
