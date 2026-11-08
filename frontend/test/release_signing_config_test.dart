import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android Release Signing & Security Compliance Audit', () {
    late String buildGradleContent;
    late String rootGitignoreContent;
    late String androidGitignoreContent;
    late String proguardContent;

    setUpAll(() {
      // Resolve paths relative to frontend/ or repository root
      final projectDir = Directory.current.path.endsWith('frontend')
          ? Directory.current.parent
          : Directory.current;

      final buildGradleFile = File('${projectDir.path}/frontend/android/app/build.gradle.kts');
      final rootGitignoreFile = File('${projectDir.path}/.gitignore');
      final androidGitignoreFile = File('${projectDir.path}/frontend/android/.gitignore');
      final proguardFile = File('${projectDir.path}/frontend/android/app/proguard-rules.pro');

      expect(buildGradleFile.existsSync(), isTrue, reason: 'build.gradle.kts must exist');
      expect(rootGitignoreFile.existsSync(), isTrue, reason: 'Root .gitignore must exist');
      expect(androidGitignoreFile.existsSync(), isTrue, reason: 'Android .gitignore must exist');
      expect(proguardFile.existsSync(), isTrue, reason: 'proguard-rules.pro must exist');

      buildGradleContent = buildGradleFile.readAsStringSync();
      rootGitignoreContent = rootGitignoreFile.readAsStringSync();
      androidGitignoreContent = androidGitignoreFile.readAsStringSync();
      proguardContent = proguardFile.readAsStringSync();
    });

    test('1. Debug build strictly uses debug signing config', () {
      expect(
        buildGradleContent,
        contains('debug {\n            signingConfig = signingConfigs.getByName("debug")'),
        reason: 'Debug build must be explicitly assigned to debug signing config',
      );
    });

    test('2. Release build strictly requires release signing config (ZERO fallback to debug)', () {
      // Must set release signing
      expect(
        buildGradleContent,
        contains('signingConfig = signingConfigs.getByName("release")'),
        reason: 'Release build must be bound directly to release signing config',
      );

      // Must NOT contain fallback to debug in release build
      final releaseBlockMatch = RegExp(r'release\s*\{([^}]+)\}', dotAll: true).firstMatch(buildGradleContent);
      expect(releaseBlockMatch, isNotNull, reason: 'Release block must exist in build.gradle.kts');

      final releaseBlockText = releaseBlockMatch!.group(1)!;
      expect(
        releaseBlockText,
        isNot(contains('signingConfigs.getByName("debug")')),
        reason: 'Release build MUST NOT have any fallback to debug signing config',
      );
    });

    test('3. Root and Android .gitignore strictly ignore all keystore and key.properties artifacts', () {
      expect(rootGitignoreContent, contains('*.jks'));
      expect(rootGitignoreContent, contains('*.keystore'));
      expect(rootGitignoreContent, contains('*key.properties'));

      expect(androidGitignoreContent, contains('key.properties'));
      expect(androidGitignoreContent, contains('**/*.keystore'));
      expect(androidGitignoreContent, contains('**/*.jks'));
    });

    test('4. ProGuard and R8 rules preserve Firebase Auth, Google Sign-In, Supabase, and YOLO26n', () {
      // YOLO26n / TensorFlow Lite & Native JNI
      expect(proguardContent, contains('-keep class org.tensorflow.lite.** { *; }'));
      expect(proguardContent, contains('native <methods>;'));

      // Firebase Auth & Firestore
      expect(proguardContent, contains('-keep class com.google.firebase.** { *; }'));
      expect(proguardContent, contains('-keep class com.google.firebase.auth.** { *; }'));
      expect(proguardContent, contains('-keep class com.google.firebase.firestore.** { *; }'));

      // Google Sign-In & Play Services
      expect(proguardContent, contains('-keep class com.google.android.gms.auth.api.signin.** { *; }'));
      expect(proguardContent, contains('-keep class com.google.android.gms.common.api.** { *; }'));

      // Supabase & Secure Storage Crypto
      expect(proguardContent, contains('-keep class androidx.security.crypto.** { *; }'));

      // Biometrics
      expect(proguardContent, contains('-keep class androidx.biometric.** { *; }'));
    });

    test('5. TFLite model is guarded against zip compression in aaptOptions', () {
      expect(
        buildGradleContent,
        contains('noCompress("tflite")'),
        reason: 'aaptOptions must specify noCompress("tflite") for direct memory-mapped access',
      );
    });

    test('6. Release signing verification hook is registered in gradle.taskGraph.whenReady', () {
      expect(buildGradleContent, contains('gradle.taskGraph.whenReady'));
      expect(buildGradleContent, contains('[CRITICAL RELEASE SIGNING ERROR]'));
      expect(buildGradleContent, contains('Automatic fallback to debug signing is strictly forbidden'));
    });
  });
}
