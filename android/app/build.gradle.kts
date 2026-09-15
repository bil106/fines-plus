import java.util.Properties
import java.io.FileInputStream
import com.github.triplet.gradle.androidpublisher.ReleaseStatus

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics") version "3.0.6"
    id("com.github.triplet.play")
}


val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("../key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.finesplus"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    defaultConfig {
        applicationId = "com.finesplus"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true

        ndk {
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a"))
        }
    }

    // White-label brand flavors. Each one must have a matching
    // assets/config/<flavor>.json (see AppConfig) and be built with the same
    // name passed as --dart-define=FLAVOR=<flavor>, e.g.:
    //   flutter build appbundle --flavor finesplus --dart-define=FLAVOR=finesplus
    //   flutter build appbundle --flavor carpapers --dart-define=FLAVOR=carpapers
    // The Gradle flavor here only controls applicationId/app name/app icon/
    // Firebase project (native, build-time) — it does NOT automatically set
    // FLAVOR for the Dart side, so keep both in sync by hand until this is
    // wired through a shared script (see scripts/new_wl_flavor.sh).
    flavorDimensions += "brand"
    productFlavors {
        create("finesplus") {
            dimension = "brand"
            // Same applicationId as before this flavor existed - required so
            // this keeps updating the already-published Fines+ Play Store
            // listing instead of becoming a new app.
            applicationId = "com.finesplus"
            resValue("string", "app_name", "Fines+")
        }
        create("carpapers") {
            dimension = "brand"
            // PLACEHOLDER. This becomes permanent the first time a build
            // with this applicationId is uploaded to Play Console - confirm
            // (and register a Firebase project under it, see
            // android/app/src/carpapers/README.md) before that first upload.
            applicationId = "com.carpapers.app"
            resValue("string", "app_name", "CarPapers")
        }
    }
 
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }
    lint {
    checkReleaseBuilds = false
    abortOnError = false
}

println("Keystore properties:")
keystoreProperties.forEach { key, value ->
    println("$key -> $value")
}

signingConfigs {
    create("release") {
        keyAlias = keystoreProperties.getProperty("keyAlias")
        keyPassword = keystoreProperties.getProperty("keyPassword")
        storeFile = rootProject.file("../" + keystoreProperties.getProperty("storeFile"))
        storePassword = keystoreProperties.getProperty("storePassword")
    }
}

buildTypes {
    getByName("debug") {
        // Sign debug builds with the same upload key as release so its
        // certificate fingerprint matches what's registered as an OAuth
        // client in Firebase/Google Cloud — otherwise Google Sign-In hangs
        // after account selection because the calling app is unrecognized.
        signingConfig = signingConfigs.getByName("release")
    }
    getByName("release") {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )

        ndk {
            debugSymbolLevel = "FULL"
        }

        configure<com.google.firebase.crashlytics.buildtools.gradle.CrashlyticsExtension> {
            nativeSymbolUploadEnabled = true
            unstrippedNativeLibsDir =
                file("$buildDir/intermediates/merged_native_libs/release/out/lib")
        }
    }
}




}

// Uploads app-release.aab straight to Play Console. Needs a service-account
// JSON key from Play Console > Setup > API access, placed at the project
// root (same folder as key.properties, also gitignored) as
// play-publish-key.json. Run with: ./gradlew publishBundle
// Defaults to the "internal" track — promote to production manually via
// Play Console (or `./gradlew promoteArtifact --from-track internal
// --promote-track production`) only once it's been verified there.
play {
    serviceAccountCredentials.set(rootProject.file("../play-publish-key.json"))
    track.set("internal")
    releaseStatus.set(ReleaseStatus.COMPLETED)
    defaultToAppBundles.set(true)
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))
    implementation("com.google.firebase:firebase-dynamic-links:21.1.0")
    implementation("com.google.firebase:firebase-crashlytics-ndk")
    implementation("com.google.firebase:firebase-analytics")
    // billing client управляется плагином in_app_purchase_android

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.activity:activity-ktx:1.10.1")
}

flutter {
    source = "../.."
}
