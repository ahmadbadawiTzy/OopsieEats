# Dokumen Bukti Verifikasi Rilis & Kepatuhan — OopsieEats (NutriView)

**Tanggal Eksekusi:** 13 November 2026  
**Environment:** Linux (x86_64), Flutter 3.47.8, Dart 3.13.7, Android Gradle Plugin 9.1.0, Gradle 9.3.1, Kotlin 2.4.0  
**Target Rilis:** Android App Bundle (`app-release.aab`)  

Dokumen ini memuat seluruh bukti empiris (*empirical proof*) hasil eksekusi pengujian, analisis statis, verifikasi tanda tangan kriptografi, keselarasan ELF segmen native 16 KB, dan audit perizinan pada build rilis OopsieEats.

---

## 1. Bukti Verifikasi Artefak Build Rilis

### 1.1 Lokasi & Metadata Berkas
- **Path Berkas AAB:** `frontend/build/app/outputs/bundle/release/app-release.aab`
- **Ukuran Berkas:** `91,095,371 bytes` (~86.87 MiB / 91.1 MB)
- **SHA-256 Checksum:** `e00d17b1ed0272e2a28eb07c00bb839e7b515de936f99340358e733cf04de477`
- **Application ID:** `com.oopsieeats.app`
- **Version Name:** `1.0.0`
- **Version Code:** `2002`

### 1.2 Bukti Tanda Tangan Kriptografi (`jarsigner`)
Perintah eksekusi:
```bash
jarsigner -verify -verbose -certs frontend/build/app/outputs/bundle/release/app-release.aab
```

Hasil verifikasi:
```text
jar verified.

Signer Certificate:
  Owner: CN=Ahmad Badawi, OU=Mobile Engineering, O=OopsieEats, L=Jakarta, ST=DKI Jakarta, C=ID
  Issuer: CN=Ahmad Badawi, OU=Mobile Engineering, O=OopsieEats, L=Jakarta, ST=DKI Jakarta, C=ID
  Serial number: db1138abd0f04b5a
  Valid from: Sun Nov 08 14:20:55 WIB 2026 until: Thu Mar 26 14:20:55 WIB 2054
  Certificate fingerprints:
     SHA1: 7F:2A:D7:60:53:9A:BE:8D:4C:CE:C0:EA:32:66:BD:DE:A8:A5:7A:D8
     SHA256: B7:34:8D:DD:47:D5:33:C8:08:DD:15:1E:E2:39:56:9E:45:2B:1C:90:74:1D:BB:2A:06:8C:C7:9D:32:C6:BC:2C
  Signature algorithm: SHA256withRSA
  Key size: 2048-bit RSA key
```
**Status: PASS (Signed with genuine production upload keystore; ZERO debug key trace).**

---

## 2. Bukti Kompatibilitas 16 KB Memory Page Size (Android 15 / 16)

Pemeriksaan segmen `LOAD` pada seluruh pustaka native (`.so`) 64-bit di dalam `app-release.aab` menggunakan `readelf -l`:

| Pustaka Native (`.so`) | Arsitektur | ELF `LOAD` Segments Alignment | Status 16 KB Page Size |
| :--- | :--- | :--- | :--- |
| `libapp.so` | `arm64-v8a` | `0x10000` (64 KB) | `PASS (>= 16 KB)` |
| `libapp.so` | `x86_64` | `0x10000` (64 KB) | `PASS (>= 16 KB)` |
| `libflutter.so` | `arm64-v8a` | `0x10000` (64 KB) | `PASS (>= 16 KB)` |
| `libflutter.so` | `x86_64` | `0x10000` (64 KB) | `PASS (>= 16 KB)` |
| `libdartjni.so` | `arm64-v8a` | `0x4000` (16 KB) | `PASS (>= 16 KB)` |
| `libdartjni.so` | `x86_64` | `0x4000` (16 KB) | `PASS (>= 16 KB)` |
| `libdatastore_shared_counter.so` | `arm64-v8a` | `0x4000` (16 KB) | `PASS (>= 16 KB)` |
| `libdatastore_shared_counter.so` | `x86_64` | `0x4000` (16 KB) | `PASS (>= 16 KB)` |
| `libtensorflowlite_jni.so` | `arm64-v8a` | `0x4000` (16 KB) | `PASS (>= 16 KB)` |
| `libtensorflowlite_jni.so` | `x86_64` | `0x4000` (16 KB) | `PASS (>= 16 KB)` |
| `libtensorflowlite_gpu_jni.so` | `arm64-v8a` | `0x4000` (16 KB) | `PASS (>= 16 KB)` |
| `libtensorflowlite_gpu_jni.so` | `x86_64` | `0x4000` (16 KB) | `PASS (>= 16 KB)` |

Konfigurasi pendukung di `frontend/android/app/build.gradle.kts`:
```kotlin
packaging {
    jniLibs {
        useLegacyPackaging = false
    }
}
aaptOptions {
    noCompress("tflite")
}
```

---

## 3. Bukti Audit Perizinan & Merged AndroidManifest.xml

Lokasi berkas: `frontend/build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml`

### 3.1 SDK & Package Identity
```xml
package="com.oopsieeats.app"
android:versionCode="2002"
android:versionName="1.0.0"
android:minSdkVersion="24"
android:targetSdkVersion="36"
```

### 3.2 Izin Aktif pada Merged Release Manifest
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
<uses-permission android:name="com.google.android.providers.gsf.permission.READ_GSERVICES" />
<uses-permission android:name="com.oopsieeats.app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION" />
```

### 3.3 Konfirmasi Penghapusan Izin Berbahaya (Stripped Permissions)
- `READ_PHONE_STATE`: **TIDAK DITEMUKAN** (Berhasil dihapus via `tools:node="remove"`).
- `WRITE_EXTERNAL_STORAGE`: **TIDAK DITEMUKAN** (Berhasil dihapus via `tools:node="remove"`).
- `READ_EXTERNAL_STORAGE`: **TIDAK DITEMUKAN** (Berhasil dihapus via `tools:node="remove"`).
- `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION`: **TIDAK DITEMUKAN**.
- `RECORD_AUDIO`: **TIDAK DITEMUKAN**.

### 3.4 Proteksi Keamanan Jaringan & Cadangan Data
```xml
android:allowBackup="false"
android:usesCleartextTraffic="false"
android:networkSecurityConfig="@xml/network_security_config"
```

---

## 4. Bukti Hasil Analisis Statis & Pengujian Otomatis

### 4.1 `flutter analyze`
```text
Analyzing frontend...                                           
No issues found! (ran in 4.8s)
```
**Status: PASS (0 errors, 0 warnings, 0 lints).**

### 4.2 `flutter test`
```text
00:48 +359: All tests passed!
```
- Total test files: 42
- Total tests: 359 / 359 lulus (100% pass rate).
- Mencakup:
  - Unit test kalkulator gizi BMR/TDEE & umur
  - Sinkronisasi biodata ke ringkasan kalori Beranda (`biodata_home_sync_test.dart`)
  - Validasi porsi gramasi makanan (`portion_validation_test.dart`)
  - Pipeline background isolate YOLO (`scanner_benchmark_test.dart`)
  - Keamanan batas unggah Supabase Storage (`supabase_storage_service_test.dart`)
  - Penegakan upload keystore tanpa fallback debug (`release_signing_config_test.dart`)
  - Widget & UI testing onboarding, login, register, profile, scanner, meal history.

### 4.3 Skrip Validasi Rilis (`./scripts/validate_release.sh --skip-build --skip-tests`)
```text
==============================================================================
VALIDATION SUMMARY: 22 PASSED, 0 FAILED
==============================================================================
```
22 dari 22 titik pemeriksaan lulus tanpa kegagalan.

---

## 5. Bukti Aset Grafis Google Play Store

| Berkas Aset | Path Berkas | Format & Dimensi Aktual | Status |
| :--- | :--- | :--- | :--- |
| **App Icon** | `docs/branding/nutriview_playstore_512.png` | PNG 512 x 512, 32-bit RGBA | `PASS` |
| **Feature Graphic** | `docs/play_store_assets/final/feature_graphic_1024x500.png` | PNG 1024 x 500, 24-bit RGB | `PASS` |
| **Screenshot 01** | `docs/play_store_assets/final/01_hero.png` | PNG 1080 x 1920 (9:16) | `PASS` |
| **Screenshot 02** | `docs/play_store_assets/final/02_ai_scanner.png` | PNG 1080 x 1920 (9:16) | `PASS` |
| **Screenshot 03** | `docs/play_store_assets/final/03_nutrition_analysis.png` | PNG 1080 x 1920 (9:16) | `PASS` |
| **Screenshot 04** | `docs/play_store_assets/final/04_meal_history.png` | PNG 1080 x 1920 (9:16) | `PASS` |
| **Screenshot 05** | `docs/play_store_assets/final/05_personal_profile.png` | PNG 1080 x 1920 (9:16) | `PASS` |
| **Screenshot 06** | `docs/play_store_assets/final/06_nutrition_articles.png` | PNG 1080 x 1920 (9:16) | `PASS` |
