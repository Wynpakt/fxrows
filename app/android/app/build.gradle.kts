import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing comes from an out-of-band keystore, never committed:
//  - CI passes credentials via env vars (verbatim, so special characters in
//    passwords are never mangled by shell or .properties escaping).
//  - Locally, create keystore.properties yourself (git-ignored) for signed builds.
// Without credentials, release falls back to the debug keystore so
// `flutter run --release` still works locally.
val keystorePropertiesFile = rootProject.file("keystore.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(keystorePropertiesFile.inputStream())
    }
}

fun signingCredential(envKey: String, propKey: String): String? =
    System.getenv(envKey)?.takeIf { it.isNotEmpty() } ?: keystoreProperties.getProperty(propKey)

val releaseStoreFile = signingCredential("ANDROID_KEYSTORE_FILE", "storeFile")
val releaseStorePassword = signingCredential("ANDROID_KEYSTORE_PASSWORD", "storePassword")
val releaseKeyAlias = signingCredential("ANDROID_KEY_ALIAS", "keyAlias")
val releaseKeyPassword = signingCredential("ANDROID_KEY_PASSWORD", "keyPassword")
val hasReleaseSigning = releaseStoreFile != null && releaseStorePassword != null &&
    releaseKeyAlias != null && releaseKeyPassword != null

android {
    namespace = "com.wynpakt.fxrows"
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
        applicationId = "com.wynpakt.fxrows"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigning) {
                storeFile = rootProject.file(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
