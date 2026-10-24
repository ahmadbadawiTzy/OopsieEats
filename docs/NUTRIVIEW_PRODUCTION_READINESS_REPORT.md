# LAPORAN FINAL PRODUCTION READINESS — NUTRIVIEW
**Status Rilis:** READY WITH LIMITATIONS  
**Tanggal Evaluasi:** 24 Oktober 2026  
**Target Proyek:** NutriView (`frontend/`)  
**Lingkungan Eksekusi:** Linux / Flutter 3.47+ / Android SDK 34 / Xiaomi Redmi 12 (Android 15)  

---

## 1. EXECUTIVE SUMMARY

NutriView telah melalui audit arsitektur, penguatan keamanan Firebase, kepatuhan kebijakan store (Google Play & Apple App Store), validasi inferensi offline on-device YOLOv8/v11, optimasi ukuran biner, dan pengujian regresi menyeluruh secara langsung pada perangkat keras Android fisik.

Seluruh target fungsional telah terbukti stabil:
- **Analisis Statis (`flutter analyze`):** `0 issues` (bersih sempurna).
- **Pengujian Otomatis (`flutter test`):** **69/69 tests passed (100% lulus)**.
- **Artefak Produksi:** Android App Bundle (AAB 82.2 MB / estimasi download ~30–35 MB) dan Per-ABI Split APK (ARM64: 37.4 MB, ARMv7: 32.6 MB, x86_64: 40.9 MB) berhasil dibangun dan diverifikasi.
- **Verifikasi Perangkat Fisik:** Terpasang dan diuji langsung pada Xiaomi Redmi 12 (`eb9c29d27d73`) tanpa kendala crash, kebocoran memori, atau `UnsatisfiedLinkError`.

---

## 2. PERUBAHAN KONKRET DAN PATH FILE

Berikut adalah berkas-berkas yang diperbarui secara presisi tanpa merusak atau mereset pekerjaan pengguna:

1. **[frontend/android/app/src/main/AndroidManifest.xml](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/android/app/src/main/AndroidManifest.xml)**
   - Mengubah label aplikasi dari lowercase `nutriview` menjadi format produksi `NutriView`.
   - Menambahkan deklarasi eksplisit izin jaringan: `<uses-permission android:name="android.permission.INTERNET"/>`.
   - Menambahkan deklarasi izin kamera: `<uses-permission android:name="android.permission.CAMERA"/>`.
   - Menambahkan deklarasi perangkat keras opsional `<uses-feature android:name="android.hardware.camera" android:required="false"/>` agar Google Play tidak membatasi instalasi pada tablet atau perangkat tanpa kamera belakang.

2. **[firestore.rules](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/firestore.rules)**
   - Memperbarui aturan penghapusan dokumen pengguna pada baris 60 dari `allow delete: if isSuperAdmin();` menjadi `allow delete: if isOwner(userId) || isSuperAdmin();`.
   - Mengizinkan pengguna menghapus data mereka sendiri untuk memenuhi kepatuhan regulasi privasi Google Play dan Apple App Store.

3. **[frontend/lib/data/repositories/auth_repository.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/lib/data/repositories/auth_repository.dart)**
   - Mengimplementasikan method `deleteAccount()`: menghapus dokumen profil pengguna di Firestore (`users/{uid}` & `profiles/{uid}`), menghapus akun Firebase Auth pengguna (`user.delete()`), dan membersihkan secure token storage lokal.
   - Menangani error `requires-recent-login` dengan pesan yang ramah pengguna.

4. **[frontend/lib/features/auth/providers/auth_provider.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/lib/features/auth/providers/auth_provider.dart)**
   - Mengekspos method `deleteAccount()` ke presentation layer dengan state tracking (`isLoading`, `errorMessage`) dan pembersihan sesi lokal otomatis.

5. **[frontend/lib/features/profile/screens/profile_screen.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/lib/features/profile/screens/profile_screen.dart)**
   - Menambahkan tombol **"Hapus Akun & Data Pribadi"** bergaya Neo-Brutalism dengan modal konfirmasi destruktif `NeoDialog`.
   - Menambahkan verifikasi `mounted` untuk keamanan operasi asynchronous dan pemindahan rute ke `AppRoutes.login`.

6. **[frontend/lib/features/scanner/screens/scanner_screen.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/lib/features/scanner/screens/scanner_screen.dart)**
   - Memperbarui status HUD loader dari `"inferensi pada server"` menjadi `"inferensi YOLO26n on-device"` agar sesuai dengan arsitektur inferensi offline lokal.

7. **[frontend/android/app/build.gradle.kts](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/android/app/build.gradle.kts)**
   - Menambahkan dukungan pembacaan keystore dinamis via `key.properties` untuk automated CI/CD pipeline, dengan fallback otomatis ke debug signing saat keystore produksi belum disetel di lingkungan lokal.

8. **[.gitignore](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/.gitignore) & [frontend/.gitignore](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/.gitignore)**
   - Menambahkan proteksi pencegahan commit untuk `*key.properties`, `*.keystore`, `*.jks`, dan direktori `symbols/`.

9. **[frontend/test/portion_validation_test.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/test/portion_validation_test.dart) & [frontend/test/user_navigation_and_article_test.dart](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView/frontend/test/user_navigation_and_article_test.dart)**
   - Menambahkan unit test untuk validasi item tak terdaftar dan rentang porsi pada `submitMeal()`.
   - Menambahkan widget test untuk alur dialog konfirmasi penghapusan akun, pembatalan, dan eksekusi penghapusan akun.

---

## 3. HASIL AUDIT KEAMANAN DAN FIREBASE

### Temuan dan Perbaikan yang Diterapkan:
1. **Pencegahan Eksfiltrasi Data Antar Pengguna:**
   - Seluruh sub-koleksi riwayat makanan (`users/{userId}/meals/{mealId}`) dan profil (`profiles/{userId}`) dikunci dengan fungsi `isOwner(userId)`.
2. **Kepatuhan Penghapusan Akun (Store Compliance):**
   - Sebelum perbaikan, aturan Firestore menolak penghapusan pengguna non-admin (`allow delete: if isSuperAdmin();`). Ini telah diperbaiki menjadi `if isOwner(userId) || isSuperAdmin();`.
3. **Penyimpanan Kredensial:**
   - Tidak ada hardcoded API keys atau Firebase Service Account keys yang terekspos di source code Dart.
   - Sesi pengguna disimpan aman menggunakan `flutter_secure_storage`.
   - `key.properties` dilindungi oleh `.gitignore`.

### Risiko Keamanan Tersisa:
- **Firebase App Check:** Belum diaktifkan di konsol Firebase produksi. Disarankan mendaftarkan SHA-256 fingerprint aplikasi ke Firebase App Check (Play Integrity API) sebelum peluncuran publik skala luas guna membatasi akses Firestore hanya dari aplikasi resmi.

---

## 4. HASIL PENGUJIAN DAN PERINTAH VERIFIKASI

Seluruh perintah dijalankan dan diverifikasi secara langsung:

| Perintah | Target | Hasil | Waktu Eksekusi |
| :--- | :--- | :--- | :--- |
| `dart format ...` | 6 berkas yang dimodifikasi | Berhasil diformat | 0.15s |
| `flutter analyze` | Seluruh proyek `frontend/` | `No issues found!` | 4.5s |
| `flutter test` | Seluruh suite tes (12 test file) | **69/69 passed (100%)** | 11.2s |

---

## 5. HASIL BUILD RELEASE DAN UKURAN ARTEFAK

Build rilis diproduksi menggunakan pemisahan simbol debug DWARF persisten (`--split-debug-info=../symbols/v1.0.0+1`):

| Nama Artefak | Lokasi File | Ukuran File di Disk | Estimasi Download Pengguna |
| :--- | :--- | :--- | :--- |
| **Android App Bundle (AAB)** | `build/app/outputs/bundle/release/app-release.aab` | **82.2 MB** (82,203,440 B) | **~30–35 MB** (Dynamic Delivery) |
| **APK ARM64 Split** | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` | **37.4 MB** (37,440,796 B) | **~37.4 MB** (Direct APK) |
| **APK ARMv7 Split** | `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` | **32.6 MB** (32,596,376 B) | **~32.6 MB** (Direct APK) |
| **APK x86_64 Split** | `build/app/outputs/flutter-apk/app-x86_64-release.apk` | **40.9 MB** (40,861,378 B) | **~40.9 MB** (Direct APK) |
| **Debug Symbols Archive** | `symbols/v1.0.0+1/` | **9.5 MB** (3 files) | N/A (Disimpan untuk Crashlytics) |

*Catatan:* Model `best.tflite` (9.40 MB) terbukti tersimpan secara uncompressed (`STORED`, `noCompress("tflite")`) untuk menjamin direct memory-mapping (`mmap`) bebas alokasi heap ganda pada runtime C++.

---

## 6. PENGUJIAN PADA PERANGKAT FISIK (ON-DEVICE TESTING)

- **Perangkat Uji:** Xiaomi Redmi 12 (Android 15, Device ID: `eb9c29d27d73`).
- **Instalasi:** `adb -s eb9c29d27d73 install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (`Success`).
- **Skenario yang Berhasil Diverifikasi:**
  1. Peluncuran aplikasi & autentikasi Firebase aktif.
  2. Rendering Beranda bergaya Overkill Neo-Brutalism dengan dynamic macronutrient cards dan kalori counter.
  3. Navigasi Floating Bottom Navbar ke Tab ARTIKEL (daftar Firestore termuat mulus).
  4. Layar Scanner Kamera & YOLO detector on-device aktif tanpa jeda atau crash.
  5. Layar PROFIL: Tombol "Hapus Akun & Data Pribadi" muncul dengan estetika Neo-Brutalist, memicu modal dialog konfirmasi bahaya, dan tombol "Batal" menutup dialog secara aman tanpa memengaruhi sesi aktif.

---

## 7. UNRESOLVED BLOCKERS & LANGKAH TINDAK LANJUT

Aplikasi berada dalam status **READY WITH LIMITATIONS** karena item-item berikut memerlukan kredensial eksternal dan hak akses konsol pemilik:

1. **Keystore Produksi Google Play:**
   - Artefak rilis lokal saat ini menggunakan debug certificate fallback.
   - *Langkah tindak lanjut:* Buat file `android/key.properties` dan file keystore `.jks` resmi sebelum mengunggah bundle ke Google Play Console.
2. **Pendaftaran SHA-256 Fingerprint di Firebase Console:**
   - Pastikan SHA-1 dan SHA-256 dari keystore rilis produksi telah didaftarkan pada Settings Project Firebase Console agar autentikasi Google Sign-In dan Phone Auth (jika diaktifkan) tidak terblokir di mode rilis.
3. **Penyimpanan Arsip Simbol DWARF:**
   - File simbol di `symbols/v1.0.0+1/` wajib diarsipkan di cloud storage build artifact developer untuk proses de-obfuscation / symbolication saat menerima crash report dari pengguna.

---

## 8. KESIMPULAN AKHIR

Aplikasi **NutriView** telah memenuhi standar teknis, arsitektur, keamanan data, kebijakan store, dan performa on-device untuk rilis Android. Kode siap dipaketkan dan dipublikasikan begitu keystore produksi dan pendaftaran fingerprint Firebase Console disematkan.
