# Flutter Wrapper & Engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# JNI & Native Method Preservations (Required for YOLO26n & TFLite C++ Runtime)
-keepclasseswithmembernames class * {
    native <methods>;
}

# TensorFlow Lite & YOLO26n Machine Learning Runtime
-keep class org.tensorflow.lite.** { *; }
-keep interface org.tensorflow.lite.** { *; }
-keep class com.tflite.** { *; }
-dontwarn org.tensorflow.lite.**
-dontwarn com.tflite.**

# Firebase Core, Authentication & Cloud Firestore
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-dontwarn com.google.firebase.**
-keep class com.google.firebase.** { *; }
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.firestore.** { *; }

# Google Sign-In & Google Play Services Auth
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.common.api.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-dontwarn com.google.android.gms.**

# Supabase Storage Integration & Encrypted Preferences (flutter_secure_storage)
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

# Biometric & Local Authentication
-keep class androidx.biometric.** { *; }
-dontwarn androidx.biometric.**

# Image Picker & Media Capture
-keep class io.flutter.plugins.imagepicker.** { *; }

# Play Core & Deferred Components (Suppressed for non-dynamic feature delivery)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
