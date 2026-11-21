# Laporan Akhir Audit Kesiapan Rilis & Kepatuhan Google Play — OopsieEats (NutriView)

**Tanggal Audit:** 13 November 2026  
**Status Evaluasi:** **READY FOR INTERNAL TESTING / READY FOR CLOSED TESTING (TEKNIS: PASS)**  
**Target Rilis:** Android App Bundle (`app-release.aab`)  
**Package Name / Namespace:** `com.oopsieeats.app`  
**Versi Aplikasi:** `1.0.0+2002` (`versionName: "1.0.0"`, `versionCode: 2002`)  
**Target SDK:** Android 16 (API Level 36) | **Min SDK:** Android 7.0 (API Level 24) | **Compile SDK:** 36  
**Signing Key:** `oopsieeats_upload` (RSA 2048-bit, Valid s.d. 2054)  
**Checksum AAB (SHA-256):** `e00d17b1ed0272e2a28eb07c00bb839e7b515de936f99340358e733cf04de477`  

---

## 1. Ringkasan Eksekutif & Release Gate Matrix

Audit menyeluruh telah dijalankan secara langsung pada kode sumber, sistem build Gradle, konfigurasi Android native, aturan keamanan backend (Firebase & Supabase), serta aset kepatuhan Google Play.

| Track Google Play | Status Kesiapan | Rincian Status |
| :--- | :--- | :--- |
| **Internal Testing** | **READY (`PASS`)** | Artefak `app-release.aab` (91.1 MB) telah dibangun dengan obfuskasi kode Dart & R8, ditandatangani dengan upload keystore produksi, lolos 359/359 automated tests dan 22 titik pemeriksaan validasi rilis. Siap diunggah langsung ke track Internal Testing. |
| **Closed Testing (12 Testers / 14 Hari)** | **READY (`PASS` Teknis) / `NEEDS MANUAL ACTION` (Console)** | Seluruh aspek teknis kode telah siap 100%. Pemilik akun developer personal perlu mengundang minimal 12–20 tester opt-in selama 14 hari berturut-turut dan mendaftarkan fingerprint *Google Play App Signing Key* ke Firebase Console. |
| **Production Access & Rollout** | **READY TO APPLY FOR PRODUCTION (Setelah Closed Testing)** | Kebijakan Google Play 2026 (Target API 36, 16 KB ELF load alignment, pemrosesan on-device AI disclaimer kesehatan, Data Safety, dan penghapusan akun mandiri in-app & web) telah terpenuhi secara menyeluruh. |

---

## 2. Project Discovery & Verifikasi Toolchain Aktual

Verifikasi dilakukan langsung pada file konfigurasi tanpa asumsi path:
- **Root Repository:** `/home/ahmadbadawi/Documents/CodinganKu/Flutter/OopsieEats`
- **Flutter Application Root:** `/home/ahmadbadawi/Documents/CodinganKu/Flutter/OopsieEats/frontend`
- **Flutter SDK:** `3.47.8` (channel `stable`, Engine revision `cf636b1dfb`)
- **Dart SDK:** `3.13.7`
- **Android Gradle Plugin (AGP):** `9.1.0`
- **Gradle Wrapper:** `9.3.1` (`gradle-9.3.1-all.zip`)
- **Kotlin Version:** `2.4.0` (JvmTarget `JVM_17`)
- **Java Runtime:** OpenJDK 17 (`JavaVersion.VERSION_17`)
- **Android NDK:** `28.2.13676358`
- **Android Build-Tools:** `36.0.0`
- **Target SDK Level:** `36` (Android 16)
- **Compile SDK Level:** `36` (Android 16)
- **Minimum SDK Level:** `24` (Android 7.0 Nougat)
- **Supported ABIs:** `arm64-v8a`, `armeabi-v7a`, `x86_64`

---

## 3. Hasil Audit Stabilitas & Fungsionalitas Inti

### 3.1 Siklus Hidup Autentikasi & Navigasi
- Alur `SplashScreen` menginisialisasi sesi Firebase Auth dan profil secara paralel.
- Guard rilis di `main.dart` melindungi seluruh rute fitur utama (`dashboard`, `scanner`, `portionInput`, `mealHistory`, `profile`): pengguna terotentikasi yang belum mengisi biodata fisik akan dialihkan secara otomatis ke layar `CompleteProfileScreen`.
- Saat logout, callback `authProvider.onLogout` membersihkan seluruh data profil, state dashboard, cache katalog pangan, cache artikel edukasi, dan cache URL Supabase untuk mencegah kebocoran data antar-sesi pengguna.

### 3.2 Sinkronisasi Biodata ke Beranda (Zero Stale Data)
- Perubahan biodata fisik di `BiodataScreen` (BB, TB, aktivitas fisik, tujuan) memicu perhitungan ulang BMR/TDEE berbasis formula Mifflin-St Jeor.
- Callback `profileProvider.onProfileUpdated` di `main.dart` menginvalidasi cache TTL repositori dan memanggil `dashboardProvider.updateTargetFromBiodata()`.
- Ringkasan kalori harian dan sisa kalori pada kartu hero Beranda langsung diperbarui secara instan tanpa perlu restart aplikasi atau memicu request ganda ke basis data.

### 3.3 Pemindai Makanan & AI Inference (On-Device)
- Model `assets/models/best.tflite` dipasok dengan opsi `noCompress("tflite")` di Gradle untuk pemetaan memori langsung (*direct memory-mapped access*).
- Komputasi inferensi visi komputer YOLO dijalankan pada background Isolate terpisah (`compute()`), mencegah frame drops atau freeze UI pada thread utama.

### 3.4 Penyimpanan Riwayat Foto (Supabase Storage)
- Foto riwayat makanan dan foto profil dikompresi otomatis (maks. 1024x1024 px, JPEG 80%) sebelum diunggah ke bucket privat Supabase `food-history-images`.
- Ditegakkan perlindungan batas muatan mentah 20 MB (*anti-OOM DoS*) dan batas berkas pasca-kompresi 5 MB.
- Akses foto menggunakan *Signed URL* privat dengan masa kedaluwarsa 1 jam dan in-memory URL cache.

### 3.5 Penghapusan Akun & Hak Privasi Pengguna (GDPR & Google Play Compliant)
- Fitur in-app (*Profil → Hapus Akun & Data*) menghapus secara tuntas dokumen pengguna di Firestore `users/{uid}`, subkoleksi `meals`, file foto di Supabase Storage folder `uid/`, kredensial Firebase Auth, dan data lokal `FlutterSecureStorage`.
- Tersedia halaman web publik mandiri di `public/delete-account.html` (`https://nutriview-943cd.web.app/delete-account`) sesuai mandat Google Play.

---

## 4. Hasil Audit Kompatibilitas Android & 16 KB Page Size

### 4.1 16 KB Memory Page Size Alignment (Android 15 & 16)
Seluruh berkas binary native `.so` 64-bit (`arm64-v8a` dan `x86_64`) di dalam `app-release.aab` telah diekstrak dan diperiksa menggunakan `readelf -l`. Seluruh segmen `LOAD` memiliki alignment memori `0x4000` (16 KB) atau `0x10000` (64 KB):
- `libapp.so`: `0x10000` (64 KB) — `PASS`
- `libflutter.so`: `0x10000` (64 KB) — `PASS`
- `libdartjni.so`: `0x4000` (16 KB) — `PASS`
- `libdatastore_shared_counter.so`: `0x4000` (16 KB) — `PASS`
- `libtensorflowlite_jni.so`: `0x4000` (16 KB) — `PASS`
- `libtensorflowlite_gpu_jni.so`: `0x4000` (16 KB) — `PASS`

Pengaturan `packaging { jniLibs { useLegacyPackaging = false } }` di `build.gradle.kts` memastikan sistem operasi Android 15/16 memuat berkas native langsung dari paket aplikasi tanpa uncompress legacy.

### 4.2 Izin Android (Prinsip Least-Privilege)
Merged release manifest hanya memuat izin esensial yang diperlukan fungsi aplikasi:
- `INTERNET` & `ACCESS_NETWORK_STATE`: Akses cloud backend terenkripsi.
- `CAMERA`: Pengambilan foto makanan & foto profil (`required="false"`).
- `USE_BIOMETRIC` & `USE_FINGERPRINT`: Autentikasi lokal perangkat.
- Izin sensitif warisan `READ_PHONE_STATE`, `WRITE_EXTERNAL_STORAGE`, dan `READ_EXTERNAL_STORAGE` berhasil dieliminasi dengan `tools:node="remove"`.

---

## 5. Hasil Pengujian & Bukti Kualitas Kode

| Parameter Kualitas | Target Standar | Hasil Aktual | Status |
| :--- | :--- | :--- | :--- |
| **Kompilasi Dependensi** | Clean resolution | `flutter pub get` selesai tanpa konflik | `PASS` |
| **Analisis Statis Dart** | 0 Issues | `flutter analyze` melaporkan **0 issues found** | `PASS` |
| **Automated Test Suite** | 100% Pass Rate | **359 / 359 pengujian lulus** (42 test suites) | `PASS` |
| **Release Build AAB** | Obfuscated release bundle | `flutter build appbundle --release --obfuscate` menghasilkan `app-release.aab` (91.1 MB) | `PASS` |
| **Tanda Tangan Kriptografi** | Production upload certificate | `jarsigner` terverifikasi (`CN=Ahmad Badawi, OU=Mobile Engineering, O=OopsieEats`) | `PASS` |
| **Audit Kebocoran Secrets** | Zero tracked secrets | 0 keystore, 0 key.properties, 0 secret keys di Git | `PASS` |
| **Skrip Validasi 12-Tahap** | All checks pass | `./scripts/validate_release.sh` mencatat **22 checks passed, 0 failed** | `PASS` |

---

## 6. Pembagian Tugas Otomatis vs. Tindakan Manual Pemilik Akun

### A. Pekerjaan Teknis yang Telah Diselesaikan Secara Penuh (Automated):
1. Pengaturan target SDK 36 dan penegakan 16 KB page-size alignment.
2. Penghapusan izin sensitif warisan pada Android Manifest.
3. Sinkronisasi real-time biodata ke Beranda dan pembersihan cache saat logout.
4. Pengerasan upload keystore (fail-fast, no debug fallback).
5. Validasi ukuran upload Supabase Storage (anti-OOM DoS dan limit 5 MB).
6. Pembuatan aset grafis Feature Graphic 1024x500 (`feature_graphic_1024x500.png`).
7. Pembuatan dokumen panduan deployment, testing checklist, security audit, dan changelog.
8. Kompilasi AAB rilis final terverifikasi `app-release.aab`.

### B. Tindakan Manual Wajib oleh Pemilik Akun di Console (External Manual):
1. **Firebase Deployment:** Jalankan `firebase deploy --only hosting,firestore:rules` untuk mempublikasikan halaman legal dan aturan Firestore terbaru ke proyek `nutriview-943cd`.
2. **Play Console App Creation:** Buat aplikasi `OopsieEats` di Google Play Console.
3. **Play App Signing Fingerprint ke Firebase:** Salin SHA-1 & SHA-256 dari Play App Signing ke Firebase Console agar Google Sign-In berfungsi pada aplikasi terunduh Play Store.
4. **Isi Formulir App Content:** Isi kuesioner Data Safety, Health Apps, Target Audience (18+), Content Rating (IARC), dan App Access menggunakan data yang disediakan di panduan.
5. **Unggah Aset Grafis & AAB:** Unggah icon, feature graphic, screenshots, dan berkas `app-release.aab` ke track Internal Testing / Closed Testing.
6. **Closed Testing (14 Hari):** Undang minimal 12–20 tester opt-in selama 14 hari berturut-turut sebelum mengajukan akses produksi.
