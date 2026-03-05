plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.abhinav_tracking"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.abhinav_tracking"

        minSdk = flutter.minSdkVersion               // ✅ CORRECT SYNTAX
        targetSdk = 36           // ✅ CORRECT
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Use debug signing for now
            signingConfig = signingConfigs.getByName("debug")  // ✅ CORRECT
            isMinifyEnabled = false                            // ✅ CORRECT
            isShrinkResources = false                          // ✅ CORRECT
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
