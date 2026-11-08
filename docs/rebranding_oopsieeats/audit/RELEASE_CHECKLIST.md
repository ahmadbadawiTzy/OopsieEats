# OopsieEats — Google Play & Production Release Operational Checklist
**Tanggal Audit & Persiapan:** 8 November 2026  
**Auditor:** QA Automation Lead, UX Flow & Play Store Release Specialist  
**Target:** Rilis Android Google Play Store & Pengujian Perangkat Nyata  
**Target Proyek:** OopsieEats (`com.oopsieeats.app`)  
**Status Evaluasi:** **RELEASE CANDIDATE 1 (RC1) — ALL AUTOMATION GATES PASSED (348/348 TESTS PASS, 100%)**

Gunakan checklist operasional ini sebagai panduan langkah-demi-langkah sebelum dan sesudah mengunggah aplikasi ke Google Play Store.

---

## FASE 1: Kesiapan Kode & Konfigurasi Lokal (Local Codebase Readiness)
- [x] **Dart Package Name:** `oopsieeats` (`frontend/pubspec.yaml`)
- [x] **Android Application ID:** `com.oopsieeats.app` (`frontend/android/app/build.gradle.kts`)
- [x] **Android Namespace:** `com.oopsieeats.app` (`frontend/android/app/build.gradle.kts`)
- [x] **Android MainActivity:** `com/oopsieeats/app/MainActivity.kt`
- [x] **Android App Display Label:** `OopsieEats` (`AndroidManifest.xml` & 80+ locale XML)
- [x] **Network Security:** Strictly HTTPS TLS (`cleartextTrafficPermitted="false"`)
- [x] **Database & Backup Protection:** `android:allowBackup="false"`
- [x] **Analisis Statis:** `flutter analyze` $\rightarrow$ **0 issues found (0 warnings/errors)**
- [x] **Rangkaian Automated Tests:** `flutter test` $\rightarrow$ **348/348 tests passed (100% pass rate across 24 suites)**
- [x] **Regression Test Sinkronisasi Biodata-Home:** `frontend/test/biodata_home_sync_test.dart` $\rightarrow$ **4/4 tests passed**
  - Skenario a: Initial load computes target 2000 kcal
  - Skenario b & c: Update biodata 2450 kcal with cache invalidation / forceRefresh bypassing 15-min TTL
  - Skenario d: Switching tabs from Profile to Home refreshes dashboard state and displays 2450 kcal
  - Skenario e: DashboardRepository cache invalidation contract idempotency
- [x] **Target SDK 35 (Android 15) & Min SDK 24 Compatibility:** Terverifikasi kompatibel penuh
- [x] **TFLite Model Non-Compression:** `aaptOptions { noCompress("tflite") }` aktif
- [x] **ProGuard/R8 Rules:** Dikeraskan dan diverifikasi untuk:
  - Flutter Core & Engine (`io.flutter.**`)
  - JNI Native Methods (`native <methods>;`)
  - TensorFlow Lite & YOLO26n ML (`org.tensorflow.lite.**`, `com.tflite.**`)
  - Firebase Core, Auth, & Firestore (`com.google.firebase.**`)
  - Google Sign-In & Play Services (`com.google.android.gms.auth.api.signin.**`)
  - Supabase & Secure Storage Crypto (`androidx.security.crypto.**`)
  - Local Auth / Biometrics (`androidx.biometric.**`)
- [x] **Proteksi Kredensial Git:** `.gitignore` mengabaikan `key.properties`, `*.jks`, dan `*.keystore`

---

## FASE 2: Penegakan Keras Release Signing Android (Release Signing Enforcement)
- [x] **Debug Build Isolation:** Build debug secara eksplisit terikat pada debug keystore (`signingConfig = signingConfigs.getByName("debug")`).
- [x] **Zero Fallback pada Release Build:** Build release terikat secara eksklusif ke `signingConfigs.getByName("release")`. Tidak ada fallback ke debug signing.
- [x] **Kegagalan Eksplisit `key.properties` Hilang:** Jika `key.properties` tidak ditemukan saat build release, build gagal dengan pesan informatif:
  ```
  [CRITICAL RELEASE SIGNING ERROR] 'key.properties' is missing!
  Release builds of OopsieEats MUST be signed with an authentic upload keystore.
  Automatic fallback to debug signing is strictly forbidden for security compliance.
  ```
- [x] **Validasi File Keystore pada Disk:** Jika file `.jks` yang didefinisikan tidak ada pada path, build release gagal dengan pesan error path absolut.
- [x] **Validasi Kelengkapan Alias & Password:** Mengharuskan `keyAlias`, `storePassword`, dan `keyPassword` terisi lengkap dan tidak kosong.
- [x] **Proteksi Kerahasiaan Password:** Password tidak pernah dicetak ke terminal atau stdout dalam kondisi apapun.
- [x] **Uji Otomatis Validasi Signing:** `frontend/test/release_signing_config_test.dart` (6/6 tests lulus) memverifikasi arsitektur signing di level CI/CD.
- [x] **Hasil Uji Dry-Run Gradle:**
  - `./gradlew assembleDebug --dry-run` $\rightarrow$ **BUILD SUCCESSFUL** (menggunakan debug key)
  - `./gradlew assembleRelease --dry-run` $\rightarrow$ **BUILD FAILED** (dengan pesan kesalahan terarah karena `key.properties` belum dibuat)

---

## FASE 3: Konfigurasi Cloud & Identitas Eksternal (Cloud Backend Readiness)
- [x] **Firebase Project Preservation:** `nutriview-943cd` (Project No: `350308179098`) aktif utuh
- [x] **Firebase Android Registration:** Terdaftar resmi dengan App ID `1:350308179098:android:52fbbbd2d02639e47e5323`
- [x] **Debug SHA-1 Registration:** Terdaftar di Firebase (`A2:A4:F8:86:DA:6A:ED:F6:27:D5:28:0E:0D:AC:7B:02:10:8A:3C:7B`)
- [x] **Debug SHA-256 Registration:** Terdaftar di Firebase (`25:1F:58:47:71:0D:4E:0F:35:FF:CD:E3:76:5F:35:D7:9A:3F:C9:F3:8D:0D:42:68:71:FA:67:47:02:D1:AE:A8`)
- [x] **Android OAuth Client ID (OopsieEats):** Terkonfigurasi (`350308179098-md8oblv9248foinfud509k81l5q98gij.apps.googleusercontent.com`)
- [x] **Web OAuth Client ID:** Konsisten (`350308179098-rj47kjc7qkab0loht39si2ek37qj7gku.apps.googleusercontent.com`)
- [x] **Google Identity Email Template:** `senderDisplayName` berhasil diubah menjadi `"OopsieEats Support"`
- [x] **Supabase Project Preservation:** `rnfvudxqcwcwilcyicow` aktif (`ACTIVE_HEALTHY`)
- [x] **Supabase Storage Bucket:** `food-history-images` privat (`public = false`), limit 5 MB
- [x] **Supabase RLS & Path Validation:** Path regex `$userId/(profile|mealId)/*` aktif & lulus uji probe
- [x] **Zero Service Role Key:** 0 kunci rahasia pada kode sumber mobile
- [ ] **GCP Console OAuth Branding:** *(Langkah Pemilik)* Ubah App Name ke `OopsieEats` di [GCP Branding Console](https://console.cloud.google.com/auth/branding?project=nutriview-943cd)

---

## FASE 4: Pembuatan & Konfigurasi Release Keystore (Langkah untuk Pemilik Proyek)
- [ ] **1. Buat Direktori Keystore Aman (di luar repositori Git):**
  ```bash
  mkdir -p ~/.keystores
  ```
- [ ] **2. Generate Upload Keystore via `keytool`:**
  ```bash
  keytool -genkeypair -v \
    -keystore ~/.keystores/oopsieeats-upload-keystore.jks \
    -alias oopsieeats_upload \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storetype JKS
  ```
- [ ] **3. Buat File Konfigurasi `frontend/android/key.properties`:**
  ```properties
  storePassword=<MASUKKAN_PASSWORD_KEYSTORE_ANDA>
  keyPassword=<MASUKKAN_PASSWORD_KEYSTORE_ANDA>
  keyAlias=oopsieeats_upload
  storeFile=/home/ahmadbadawi/.keystores/oopsieeats-upload-keystore.jks
  ```
- [ ] **4. Cadangkan Keystore:** Simpan file `.jks` dan password ke Password Manager (Bitwarden/1Password) dan media offline terenkripsi.
- [ ] **5. Daftarkan SHA-1 & SHA-256 Upload Key ke Firebase:**
  ```bash
  # Ambil sidik jari:
  keytool -list -v -keystore ~/.keystores/oopsieeats-upload-keystore.jks -alias oopsieeats_upload

  # Daftarkan ke Firebase:
  firebase apps:android:sha:create 1:350308179098:android:52fbbbd2d02639e47e5323 <UPLOAD_SHA1> --project=nutriview-943cd
  firebase apps:android:sha:create 1:350308179098:android:52fbbbd2d02639e47e5323 <UPLOAD_SHA256> --project=nutriview-943cd
  ```

---

## FASE 5: Kompilasi Binary Rilis (Release Binary Generation)
- [ ] **Build Android App Bundle (.aab) untuk Google Play Store:**
  ```bash
  cd frontend
  flutter clean
  flutter pub get
  flutter build appbundle --release
  ```
  *Output:* `frontend/build/app/outputs/bundle/release/app-release.aab`

- [ ] **Build Standalone APK (.apk) untuk Pengujian Langsung di Perangkat:**
  ```bash
  flutter build apk --release
  ```
  *Output:* `frontend/build/app/outputs/flutter-apk/app-release.apk`

---

## FASE 6: Google Play Store App Signing Registration (PENTING)
> [!IMPORTANT]
> Google Play menandatangani ulang APK yang diunduh pengguna dari Play Store dengan **Google Play App Signing Key**. Jika SHA-1 ini belum didaftarkan ke Firebase, Google Sign-In akan **GAGAL** pada versi yang diunduh pengguna dari Play Store.

- [ ] **1. Unggah `.aab` ke Google Play Console** (ke Track Internal Testing atau Closed Testing).
- [ ] **2. Buka Google Play Console:**
  Menu: **Setup (Konfigurasi)** $\rightarrow$ **App Integrity (Integritas Aplikasi)**.
- [ ] **3. Salin SHA-1 dan SHA-256:**
  Pada bagian *App signing key certificate*, salin sidik jari SHA-1 dan SHA-256.
- [ ] **4. Daftarkan ke Firebase Console:**
  ```bash
  firebase apps:android:sha:create 1:350308179098:android:52fbbbd2d02639e47e5323 <PLAY_SIGNING_SHA1> --project=nutriview-943cd
  firebase apps:android:sha:create 1:350308179098:android:52fbbbd2d02639e47e5323 <PLAY_SIGNING_SHA256> --project=nutriview-943cd
  ```

---

## FASE 7: Protokol Pengujian Perangkat Nyata (12-Point Real Device Testing)
Lakukan pengujian manual interaktif pada perangkat fisik Android:
- [ ] **1. Login Email & Sandi:** Registrasi baru, logout, login ulang, transisi lancar ke dashboard.
- [ ] **2. Google Sign-In Fisik:** Tekan tombol Google Sign-In, modal native OS muncul, token tertukar mulus ke Firebase Auth.
- [ ] **3. Logout & Re-login:** Sesi terhapus bersih dari secure storage, re-login tanpa stale data.
- [ ] **4. Update Biodata:** Ubah BB, TB, aktivitas fisik; kalkulasi BMR/TDEE dan kalori hero card terbarui deterministik.
- [ ] **5. Upload Foto Profil:** Kamera/Galeri, crop 1:1, upload ke Supabase Storage, avatar ter-render via Signed URL.
- [ ] **6. Upload Foto Makanan:** Scan kamera, input porsi, upload ke Supabase `$userId/$mealId/food_*.jpg`, muncul di log riwayat.
- [ ] **7. Validasi Signed URL TTL:** Signed URL ter-refresh otomatis setelah expired tanpa gambar rusak.
- [ ] **8. Isolasi Multi-User:** Foto dan riwayat Akun A tidak dapat diakses atau dilihat oleh Akun B.
- [ ] **9. Siklus Onboarding (FTUE):** Carousel 3 slide muncul sekali saat install baru, pembukaan selanjutnya langsung ke Splash/Dashboard.
- [ ] **10. YOLO26n Mode Offline:** Aktifkan Mode Pesawat, scan makanan, inferensi deteksi lokal bekerja instan $<200$ ms.
- [ ] **11. Cold Restart Persistence:** Force kill aplikasi dari recent apps, buka kembali, sesi langsung pulih tanpa login ulang.
- [ ] **12. Pemulihan Jaringan:** Matikan internet saat di dalam app, nyalakan kembali, error terkelola rapi dan data pulih otomatis.
