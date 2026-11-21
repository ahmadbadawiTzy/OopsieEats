import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.oopsieeats.app"
    compileSdk = maxOf(flutter.compileSdkVersion, 36)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.oopsieeats.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = maxOf(flutter.targetSdkVersion, 36)
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }

    aaptOptions {
        noCompress("tflite")
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
                val storeFilePath = keystoreProperties.getProperty("storeFile")?.trim()
                if (!storeFilePath.isNullOrBlank()) {
                    val fileObj = File(storeFilePath)
                    storeFile = if (fileObj.isAbsolute) fileObj else rootProject.file(storeFilePath)
                }
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // STRICT SECURITY COMPLIANCE:
            // Release build MUST use authentic release signing config.
            // Under NO circumstance is fallback to debug signing permitted.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

gradle.taskGraph.whenReady {
    val isReleaseBuildRequested = allTasks.any { task ->
        task.name.contains("Release", ignoreCase = false) &&
        (task.name.startsWith("assemble") ||
         task.name.startsWith("bundle") ||
         task.name.startsWith("package") ||
         task.name.startsWith("validateSigning"))
    }

    if (isReleaseBuildRequested) {
        val keystorePropertiesFile = rootProject.file("key.properties")
        if (!keystorePropertiesFile.exists()) {
            throw GradleException(
                """
                |========================================================================================
                | [CRITICAL RELEASE SIGNING ERROR] 'key.properties' is missing!
                |----------------------------------------------------------------------------------------
                | Location expected: ${keystorePropertiesFile.absolutePath}
                |
                | Release builds of OopsieEats MUST be signed with an authentic upload keystore.
                | Automatic fallback to debug signing is strictly forbidden for security compliance.
                |
                | HOW TO FIX:
                | 1. Generate an upload keystore:
                |    keytool -genkeypair -v -keystore ~/.keystores/oopsieeats-upload-keystore.jks \
                |      -alias oopsieeats_upload -keyalg RSA -keysize 2048 -validity 10000 -storetype JKS
                |
                | 2. Create 'frontend/android/key.properties':
                |    storeFile=/home/ahmadbadawi/.keystores/oopsieeats-upload-keystore.jks
                |    storePassword=<your-keystore-password>
                |    keyAlias=oopsieeats_upload
                |    keyPassword=<your-key-password>
                |
                | Reference: docs/rebranding_oopsieeats/audit/RELEASE_CHECKLIST.md
                |========================================================================================
                """.trimMargin()
            )
        }

        val keystoreProps = Properties()
        FileInputStream(keystorePropertiesFile).use { keystoreProps.load(it) }

        val storeFilePath = keystoreProps.getProperty("storeFile")?.trim()
        if (storeFilePath.isNullOrEmpty()) {
            throw GradleException(
                """
                |========================================================================================
                | [CRITICAL RELEASE SIGNING ERROR] 'storeFile' is missing or empty in key.properties!
                |----------------------------------------------------------------------------------------
                | Path to key.properties: ${keystorePropertiesFile.absolutePath}
                | Please define 'storeFile=<path-to-upload-keystore.jks>' in key.properties.
                |========================================================================================
                """.trimMargin()
            )
        }

        val resolvedKeystoreFile = File(storeFilePath).let {
            if (it.isAbsolute) it else rootProject.file(storeFilePath)
        }
        if (!resolvedKeystoreFile.exists() || !resolvedKeystoreFile.isFile) {
            throw GradleException(
                """
                |========================================================================================
                | [CRITICAL RELEASE SIGNING ERROR] Keystore file does not exist on disk!
                |----------------------------------------------------------------------------------------
                | Specified storeFile : '$storeFilePath'
                | Resolved file path  : '${resolvedKeystoreFile.absolutePath}'
                |
                | The upload keystore file was not found at the specified location.
                | Please check the path in 'key.properties' or generate a keystore at that path.
                |========================================================================================
                """.trimMargin()
            )
        }

        val keyAlias = keystoreProps.getProperty("keyAlias")?.trim()
        if (keyAlias.isNullOrEmpty()) {
            throw GradleException(
                """
                |========================================================================================
                | [CRITICAL RELEASE SIGNING ERROR] 'keyAlias' is missing or empty in key.properties!
                |----------------------------------------------------------------------------------------
                | Please define 'keyAlias=<alias-name>' in key.properties.
                |========================================================================================
                """.trimMargin()
            )
        }

        val storePassword = keystoreProps.getProperty("storePassword")
        if (storePassword.isNullOrEmpty()) {
            throw GradleException(
                """
                |========================================================================================
                | [CRITICAL RELEASE SIGNING ERROR] 'storePassword' is missing or empty in key.properties!
                |----------------------------------------------------------------------------------------
                | Please define 'storePassword=<password>' in key.properties.
                | Note: Passwords are never printed to terminal or saved in Git.
                |========================================================================================
                """.trimMargin()
            )
        }

        val keyPassword = keystoreProps.getProperty("keyPassword")
        if (keyPassword.isNullOrEmpty()) {
            throw GradleException(
                """
                |========================================================================================
                | [CRITICAL RELEASE SIGNING ERROR] 'keyPassword' is missing or empty in key.properties!
                |----------------------------------------------------------------------------------------
                | Please define 'keyPassword=<password>' in key.properties.
                | Note: Passwords are never printed to terminal or saved in Git.
                |========================================================================================
                """.trimMargin()
            )
        }
    }
}
