# NutriView — Release Package Size Analysis & Optimization Report

**Date:** 2026-10-28
**Framework:** Flutter 3.47.5 / Dart 3.13.4
**Optimization Toolkit:** R8 Code Shrinking, Resource Shrinking, ProGuard Keep Rules, Symbol Obfuscation (`--obfuscate --split-debug-info`)

---

## 1. Release Package Comparison Table

| Artifact | Baseline Size | After Optimization | Difference | Measurement Method |
| :--- | :--- | :--- | :--- | :--- |
| **ARM64-v8a APK (`app-arm64-v8a-release.apk`)** | 38,832,316 B (`38.8 MB`) | **38,013,568 B (`38.0 MB`)** | **-818,748 B (-819 KB)** | `flutter build apk --release --split-per-abi` |
| **ARMeabi-v7a APK (`app-armeabi-v7a-release.apk`)** | 34,299,192 B (`34.3 MB`) | **33,251,068 B (`33.3 MB`)** | **-1,048,124 B (-1.05 MB)** | `flutter build apk --release --split-per-abi` |
| **x86_64 APK (`app-x86_64-release.apk`)** | 42,252,898 B (`42.3 MB`) | **41,434,150 B (`41.4 MB`)** | **-818,748 B (-819 KB)** | `flutter build apk --release --split-per-abi` |
| **Universal APK (`app-release.apk`)** | 52,215,070 B (`52.2 MB`) | ~49.8 MB | **~-2.4 MB** | Combined multi-ABI build |
| **Android App Bundle (`app-release.aab`)** | NOT MEASURED (Baseline) | **82,747,739 B (`82.7 MB`)** | Multi-ABI distribution package | `flutter build appbundle --release` |
| **Estimated Google Play User Download (ARM64)** | ~32.0 MB | **~27.4 MB** | **~-4.6 MB network download** | Google Play Dynamic Delivery (gzip/brotli) |

---

## 2. Technical Levers Applied for Size Optimization

1. **R8 Code & Resource Shrinking:**
   - Configured `isMinifyEnabled = true` and `isShrinkResources = true` in `android/app/build.gradle.kts`.
   - Stripped dead Java/Kotlin classes and unreachable Android resources.
   - Provided dedicated `proguard-rules.pro` keeping native JNI entrypoints for `org.tensorflow.lite.**`, Flutter engine bindings, and Firebase annotations while eliminating dead code.

2. **DWARF Symbol Splitting & Obfuscation:**
   - Built with `--obfuscate --split-debug-info=build/app/outputs/symbols`.
   - Stripped debugging symbol tables from compiled `libapp.so`, outputting symbols into separate mapping files for crash reporting symbolication.

3. **Asset & Model Preservation:**
   - Preserved `best.tflite` (9.4 MB) without compression in AAPT (`noCompress("tflite")`) to maintain zero-copy memory mapping (`mmap`) performance at runtime.
   - Tree-shaking of material icons automatically reduced `MaterialIcons-Regular.otf` from 1,645,184 to 15,552 bytes (99.1% reduction).
