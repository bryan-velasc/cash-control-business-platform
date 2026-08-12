plugins {
    id("com.android.application")
    id("kotlin-android")

    // The Flutter Gradle Plugin must be applied
    // after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cash_control"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility =
            JavaVersion.VERSION_17

        targetCompatibility =
            JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget =
            JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId =
            "com.example.cash_control"

        // ML Kit Text Recognition v2
        // requiere Android API 23 o superior.
        minSdk = flutter.minSdkVersion

        targetSdk =
            flutter.targetSdkVersion

        versionCode =
            flutter.versionCode

        versionName =
            flutter.versionName
    }

    buildTypes {
        release {
            // Por ahora se usa la firma debug.
            //
            // Antes de publicar en Google Play
            // configuraremos un keystore de producción.
            signingConfig =
                signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // ======================================================
    // GOOGLE ML KIT - TEXT RECOGNITION
    // ======================================================
    //
    // El plugin Flutter referencia estas clases durante
    // el build release con R8.
    //
    // Agregarlas evita los errores:
    //
    // ChineseTextRecognizerOptions
    // DevanagariTextRecognizerOptions
    // JapaneseTextRecognizerOptions
    // KoreanTextRecognizerOptions
    //
    // ======================================================

    implementation(
        "com.google.mlkit:text-recognition:16.0.1"
    )

    implementation(
        "com.google.mlkit:text-recognition-chinese:16.0.1"
    )

    implementation(
        "com.google.mlkit:text-recognition-devanagari:16.0.1"
    )

    implementation(
        "com.google.mlkit:text-recognition-japanese:16.0.1"
    )

    implementation(
        "com.google.mlkit:text-recognition-korean:16.0.1"
    )
}

flutter {
    source = "../.."
}
