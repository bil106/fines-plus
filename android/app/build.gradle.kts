plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics") version "3.0.6" apply false
}

android {
    namespace = "com.example.fines_plus"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.fines_plus"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    compileOptions {
      
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))
    implementation(platform("com.google.firebase:firebase-dynamic-links:21.1.0"))
    implementation(platform("com.google.firebase:firebase-crashlytics-ndk"))
    implementation(platform("com.google.firebase:firebase-analytics"))
    add("coreLibraryDesugaring", "com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
