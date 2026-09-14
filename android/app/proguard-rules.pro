# Flutter engine / plugin classes accessed via reflection from method channels
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter's deferred-components loader references Play Core split-install
# classes that aren't a dependency of this app (no dynamic feature modules) —
# without this, R8 fails the build with "Missing classes" errors.
-dontwarn com.google.android.play.core.**

# Google Sign-In / Play Services / Firebase already ship consumer proguard
# rules in their AARs, but keep annotation/signature info so reflection-based
# bits (Firestore/Analytics model classes, Crashlytics) keep working and
# stack traces stay deobfuscatable.
-keepattributes Signature,*Annotation*,SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Facebook SDK relies on reflection for its login/graph classes.
-keep class com.facebook.** { *; }
-dontwarn com.facebook.**

# Play Billing (in_app_purchase_android)
-keep class com.android.vending.billing.** { *; }
