# Laporan Kesiapan Rilis Google Play Store — NutriView (`OopsieEats`)

**Tanggal Audit & Verifikasi:** 10 November 2026  
**Nama Aplikasi (Store Branding):** OopsieEats (NutriView)  
**Application ID / Namespace:** `com.oopsieeats.app`  
**Versi Rilis:** `1.0.0+2002` (`versionName: "1.0.0"`, `versionCode: 2002`)  
**Target SDK / Compile SDK / Min SDK:** `targetSdk = 36` (Android 16), `compileSdk = 36`, `minSdk = 24` (Android 7.0)  
**Artifact Release AAB:** `frontend/build/app/outputs/bundle/release/app-release.aab`

---

## 1. Ringkasan Eksekutif & Status Kesiapan

| Track Distribusi Google Play | Status Kesiapan | Ringkasan |
| :--- | :--- | :--- |
| **Internal Testing** | **READY (`PASS`)** | Artifact `.aab` telah ditandatangani dengan upload key produksi, terobfuskasi R8 + Dart split-debug-info, lolos 358 pengujian otomatis, dan siap diunggah ke Internal Testing. |
| **Closed Testing (12 Testers / 14 Days)** | **READY (`PASS` — Teknis) / `NEEDS MANUAL ACTION` (Operasional Console)** | Secara teknis aplikasi siap penuh. Pemilik akun Play Console perlu mendaftarkan SHA-1/SHA-256 *App Signing Key* Google Play ke Firebase Console dan mengundang minimal 12 tester opt-in selama 14 hari berturut-turut. |
| **Production Release** | **READY (`PASS` — Teknis) / `NEEDS MANUAL ACTION` (Play Console Gate)** | Seluruh persyaratan teknis Google Play 2026 (API 36, 16 KB ELF page size alignment, penghapusan akun in-app & web, kebijakan privasi, keamanan rules) telah terpenuhi. |

---

## 2. Hasil Audit Teknis & Konfigurasi Project

### 2.1 Lingkungan & Toolchain
- **Flutter SDK:** `3.47.8` (channel `stable`)
- **Dart SDK:** `3.13.7`
- **Android Gradle Plugin (AGP):** `9.1.0` (Gradle `9.3.1`, Kotlin `2.4.0`, Google Services `4.4.4`)
- **Android NDK:** `28.2.13676358`
- **Java Toolchain:** OpenJDK 17 (`JavaVersion.VERSION_17`)

### 2.2 Identitas Paket & Versi
- **Application ID & Namespace:** `com.oopsieeats.app` (konsisten di `frontend/android/app/build.gradle.kts`, `frontend/android/app/google-services.json`, `MainActivity.kt`, dan merged release `AndroidManifest.xml`).
- **Versi Aplikasi:** `1.0.0+2002` di `frontend/pubspec.yaml` dan `CreatorConfig.appVersion` (`frontend/lib/core/config/creator_config.dart`).
- **SDK Levels:**
  - `minSdk = 24` (Android 7.0 Nougat)
  - `compileSdk = 36` (Android 16)
  - `targetSdk = 36` (Android 16 — melampaui batas minimum Google Play API 35)

### 2.3 Kompatibilitas 16 KB Memory Page Size (Android 15/16)
Seluruh pustaka native (`.so`) pada arsitektur 64-bit (`arm64-v8a` dan `x86_64`) di dalam `app-release.aab` telah diverifikasi menggunakan `readelf -l` dan memiliki alignment segmen `LOAD` minimal `0x4000` (16 KB) atau `0x10000` (64 KB):

| Native Library (`arm64-v8a` & `x86_64`) | ELF `LOAD` Alignment | Status 16 KB Page Size |
| :--- | :--- | :--- |
| `libapp.so` | `0x10000` (64 KB) | `PASS` |
| `libflutter.so` | `0x10000` (64 KB) | `PASS` |
| `libdartjni.so` | `0x4000` (16 KB) | `PASS` |
| `libdatastore_shared_counter.so` | `0x4000` (16 KB) | `PASS` |
| `libtensorflowlite_jni.so` | `0x4000` (16 KB) | `PASS` |
| `libtensorflowlite_gpu_jni.so` | `0x4000` (16 KB) | `PASS` |

Selain itu, `packaging { jniLibs { useLegacyPackaging = false } }` telah ditegaskan pada `frontend/android/app/build.gradle.kts` dan `aaptOptions { noCompress("tflite") }` menjaga model `assets/models/best.tflite` tetap tidak terkompresi (`Defl:N`) untuk akses *memory-mapped* langsung.

---

## 3. Temuan Audit & Perbaikan yang Diterapkan

| ID | Kategori | Tingkat Keparahan | Temuan Audit | Perbaikan yang Diterapkan | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **F-01** | Android Manifest & Google Play Policy | **High** | Pustaka transitif `com.google.ai.edge.litert:litert-gpu-api:1.4.0` tidak mendeklarasikan `<uses-sdk>`, sehingga Android Manifest Merger menganggap `targetSdkVersion < 4` dan menyuntikkan izin sensitif `READ_PHONE_STATE`, `WRITE_EXTERNAL_STORAGE`, dan `READ_EXTERNAL_STORAGE` ke dalam merged release manifest. | Menambahkan deklarasi `tools:node="remove"` untuk `READ_PHONE_STATE`, `WRITE_EXTERNAL_STORAGE`, dan `READ_EXTERNAL_STORAGE` pada `frontend/android/app/src/main/AndroidManifest.xml` serta pengujian regresi otomatis di `release_signing_config_test.dart`. | **FIXED (`PASS`)** |
| **F-02** | Android Target SDK & 16 KB Packaging | **Medium** | `compileSdk` dan `targetSdk` di `build.gradle.kts` bergantung implisit pada variabel default Flutter tanpa batas minimum eksplisit API 36 serta belum mendeklarasikan `useLegacyPackaging = false` secara eksplisit. | Mengatur `compileSdk = maxOf(flutter.compileSdkVersion, 36)`, `targetSdk = maxOf(flutter.targetSdkVersion, 36)`, dan `packaging.jniLibs.useLegacyPackaging = false` di `frontend/android/app/build.gradle.kts`. | **FIXED (`PASS`)** |
| **F-03** | Cloud Storage Security | **Medium** | `SupabaseStorageService.uploadProfilePhoto` memvalidasi batas ukuran file 5 MB (`SupabaseConfig.maxUploadSizeBytes`), tetapi `uploadFoodImage` belum memvalidasi ukuran payload mentah maupun hasil kompresi sebelum unggah. | Menambahkan validasi byte kosong, batas payload mentah (20 MB anti-OOM DoS), dan batas hasil kompresi (5 MB) pada `uploadFoodImage` di `frontend/lib/data/services/supabase_storage_service.dart` beserta unit test di `supabase_storage_service_test.dart`. | **FIXED (`PASS`)** |
| **F-04** | Privacy Policy & Data Safety Alignment | **Low** | Teks pada `AboutScreen` menyebutkan foto tidak pernah diunggah ke cloud, sedangkan fitur riwayat makanan menyimpan foto makanan yang telah dikompresi ke penyimpanan privat terenkripsi (sebagaimana dijelaskan di `delete-account.html`), dan versi di `CreatorConfig.appVersion` masih `1.0.0+1`. | Menyelaraskan `CreatorConfig.appVersion` ke `1.0.0+2002`, memperjelas pengungkapan pemrosesan AI *on-device* vs penyimpanan riwayat privat di `AboutScreen` dan `public/privacy.html`, serta menyediakan tautan Kebijakan Privasi & Penghapusan Akun di dalam `AboutScreen`. | **FIXED (`PASS`)** |

---

## 4. Hasil Verifikasi Kualitas & Pengujian

| Pemeriksaan | Perintah | Hasil | Status |
| :--- | :--- | :--- | :--- |
| **Resolusi Dependensi** | `flutter pub get` | Selesai tanpa konflik | `PASS` |
| **Analisis Statis** | `flutter analyze` | `No issues found!` (0 error, 0 warning) | `PASS` |
| **Unit, Widget & Regression Tests** | `flutter test` | **358 / 358 pengujian lulus (100%)** | `PASS` |
| **Build Release AAB + Obfuscation** | `flutter build appbundle --release --obfuscate --split-debug-info=../symbols/android` | Berhasil menghasilkan `app-release.aab` (~91.1 MB) | `PASS` |
| **Verifikasi Tanda Tangan Kriptografi** | `jarsigner -verify -verbose -certs app-release.aab` | `jar verified.` Ditandatangani oleh `CN=Ahmad Badawi, OU=Mobile Engineering, O=OopsieEats, L=Jakarta, ST=DKI Jakarta, C=ID` | `PASS` |
| **Skrip Validasi Otomatis** | `./scripts/validate_release.sh --skip-build --skip-tests` | 12 / 12 tahapan pemeriksaan lulus | `PASS` |
