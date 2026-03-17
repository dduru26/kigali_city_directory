plugins {
    id("com.android.application")
    // I’m using this to hook Firebase into the Android build.
    id("com.google.gms.google-services")
    id("kotlin-android")
    // I keep the Flutter Gradle plugin after Android + Kotlin plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.kigali_city_directory"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // I should replace this with my own unique applicationId later.
        applicationId = "com.example.kigali_city_directory"
        // I can change these values if I need different min/target SDKs, etc.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // I’ll add a proper signing config for release later.
            // For now I’m signing with debug so `flutter run --release` can work.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
