# OopsieEats — Full Project Engineering, Security & Release Audit Report
**Tanggal Audit:** 8 November 2026  
**Versi Aplikasi:** 1.0.0+2002  
**Application ID:** `com.oopsieeats.app`  
**Namespace:** `com.oopsieeats.app`  
**Lead Auditor:** QA Automation Lead, UX Flow & Play Store Release Specialist  
**Status Evaluasi:** **RELEASE CANDIDATE 1 (RC1) — APPROVED FOR STORE SUBMISSION**

---

## 1. Executive Summary & Audit Scorecard

Audit komprehensif ini merupakan penilaian formal menyeluruh (*formal comprehensive engineering audit*) terhadap repositori aplikasi mobile **OopsieEats** (`com.oopsieeats.app`), mencakup arsitektur kode sumber, ketahanan keamanan (*security posture*), kepatuhan privasi (*privacy compliance*), performa waktu nyata (*real-time performance*), otomatisasi penjaminan kualitas (*QA test automation*), dan kesiapan rilis Google Play Store.

### Scorecard Evaluasi Rilis (Release Gate Status):

| Pilar Evaluasi | Metrik Utama | Target Kepatuhan | Hasil Audit | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Arsitektur & Integritas** | Layer Separation & Package Naming | 100% `package:oopsieeats` | 705+ imports bersih | `PASSED` |
| **Keamanan Kredensial** | Hardcoded Secrets & Service Keys | 0 secrets di source code | 0 secrets ditemukan | `PASSED` |
| **Penyimpanan Sensitif** | Sesi & Kunci Biometrik | Hardware-backed Keystore | `flutter_secure_storage` | `PASSED` |
| **Backend & Cloud Storage** | Supabase RLS & Signed URL | Private bucket, strict RLS | User isolated regex path | `PASSED` |
| **Kinerja & AI On-Device** | Latensi YOLO26n & Isolate | $< 350$ ms, zero jank | $165 - 220$ ms (Isolate offload) | `PASSED` |
| **UX & Edge Cases** | Empty States & Error Recovery | Tombol coba lagi & copy jelas | Lengkap di seluruh layar | `PASSED` |
| **QA Test Automation** | Unit, Widget & Regression Tests | 100% Pass Rate | **348/348 Lulus (100%)** | `PASSED` |
| **Analisis Statis** | `flutter analyze` | 0 issues found | **0 issues (0 lints/errors)** | `PASSED` |
| **Google Play Compliance** | Target SDK & Release Signing | Target SDK 35, Strict Signing | SDK 35/36, Zero debug fallback | `PASSED` |

---

## 2. Arsitektur Perangkat Lunak & Desain Sistem

Aplikasi OopsieEats dibangun dengan mematuhi prinsip arsitektur modular berlapis (*Clean Layered Architecture*) yang memisahkan tanggung jawab antarmuka, logika bisnis, dan integrasi data:

```
[ PRESENTATION LAYER ]
  Screens (Dashboard, Scanner, Profile, Articles, Admin, Onboarding)
  Widgets (Overkill Neo-Brutalism Tokens, Bento Grid, Hero Section, Badges)
         │
         ▼ (Provider Pattern & ChangeNotifier)
[ DOMAIN & STATE LAYER ]
  DashboardProvider, ProfileProvider, AuthProvider, ScanFlowProvider, MealHistoryProvider
         │
         ▼
[ DATA & REPOSITORY LAYER ]
  DashboardRepository, ProfileRepository, AuthRepository, MealRepository, FoodRepository
         │
         ▼
[ EXTERNAL SERVICES & CLIENTS ]
  ApiClient (HTTPS TLS), Firebase Auth, Cloud Firestore, Supabase Storage, TFLite Interpreter
```

### Keunggulan Arsitektur:
1. **Single Source of Truth untuk Profil & Biodata:**
   - Seluruh entri dan pembaruan metrik fisik (tinggi badan, berat badan, tanggal lahir, jenis kelamin, tingkat aktivitas, target gizi) dipusatkan melalui `UnifiedBiodataForm` yang digunakan bersama oleh alur onboarding (`BiodataFormMode.onboarding`) dan pengaturan profil (`BiodataFormMode.edit`).
2. **Sinkronisasi Reaktif Dashboard:**
   - Komponen `DashboardHomeView` mengamati `DashboardProvider` melalui `context.watch<DashboardProvider>()`. Saat biodata disimpan, `DashboardProvider.loadDashboard(forceRefresh: true)` dipanggil dan memicu re-render instan pada target kalori dan makronutrien tanpa delay.
3. **Penyelarasan Desain Overkill Neo-Brutalism:**
   - Seluruh token warna (`NeoTokens.black`, `NeoTokens.lime`, `NeoTokens.vividYellow`, `NeoTokens.coralRed`), garis tepi tebal (2.0 - 2.5 dp), radius sudut (4 - 12 dp), dan bayangan taktil padat dikonsolidasi dalam satu file desain terpadu (`lib/core/neo_tokens.dart`).

---

## 3. Integritas Rebranding & Namespace

Proses rebranding dari `NutriView` ke `OopsieEats` telah dituntaskan secara menyeluruh di semua lapisan:

1. **Konfigurasi Dart & Flutter:**
   - `frontend/pubspec.yaml`: `name: oopsieeats`, versi `1.0.0+2002`.
   - Seluruh 705 import file telah dialihkan ke `package:oopsieeats/*` tanpa sisa dependensi `package:nutriview/*`.
2. **Identitas Native Android:**
   - `applicationId`: `com.oopsieeats.app`
   - `namespace`: `com.oopsieeats.app`
   - `MainActivity`: Berada pada direktori native `frontend/android/app/src/main/kotlin/com/oopsieeats/app/MainActivity.kt`.
   - String `app_name`: Terdaftar sebagai `OopsieEats` pada `AndroidManifest.xml` serta di lebih dari 80 file lokalisasi bahasa (`values-*/strings.xml`).
3. **Katalog Aset & Model ML:**
   - Seluruh model visual YOLO (`best.tflite`, `classes.txt`) dan gambar onboarding tersimpan di dalam direktori aset terdaftar `assets/models/`, `assets/data/`, `assets/images/`, dan `assets/onboarding/`.

---

## 4. Keamanan, Privasi & Kepatuhan Cloud Backend

Audit keamanan mengonfirmasi postur proteksi tingkat tinggi yang memenuhi persyaratan ketat Google Play Data Safety:

### A. Nol Kebocoran Kunci Rahasia (*Zero Hardcoded Secrets*)
- Tidak ada private keys, service account JSON, password database, atau master admin keys di dalam kode sumber mobile.
- `ApiClient` dan konfigurasi backend hanya menyimpan alamat endpoint publik dan Google Services XML yang memang ditujukan untuk distribusi client.

### B. Proteksi Sesi & Enkripsi Biometrik
- Kunci autentikasi sesi dan preferensi biometrik disimpan menggunakan `flutter_secure_storage` yang terikat pada **Android Keystore** (menggunakan hardware Secure Element / StrongBox jika tersedia pada perangkat).
- Fallback ke input password manual ditegakkan jika terjadi mismatch UID pengguna atau sesi terputus.

### C. Isolasi Multi-Tenant Supabase Storage
- Bucket penyimpanan `food-history-images` berstatus privat (`public = false`).
- Row-Level Security (RLS) PostgreSQL menegakkan regex pattern:
  ```sql
  (bucket_id = 'food-history-images'::text) AND
  ((storage.foldername(name))[1] = ((SELECT auth.uid() AS uid))::text)
  ```
  Hal ini secara fisik mencegah pengguna A membaca, mengubah, atau menghapus foto profil dan foto makanan milik pengguna B.

### D. Keamanan Jaringan & Backup Android
- `frontend/android/app/src/main/res/xml/network_security_config.xml`:
  ```xml
  <network-security-config>
      <base-config cleartextTrafficPermitted="false" />
  </network-security-config>
  ```
  Lalu lintas plain-text HTTP diblokir total di level OS Android; seluruh komunikasi wajib menggunakan HTTPS TLS.
- `android:allowBackup="false"` pada `AndroidManifest.xml` mencegah penarikan data lokal atau ekstraksi database aplikasi melalui kabel debugging ADB.

### E. Izin Sistem Android Minimal (*Least Privilege Principle*)
Aplikasi hanya meminta izin yang mutlak diperlukan untuk operasi fungsional:
- `android.permission.INTERNET`: Sinkronisasi cloud Firestore & Supabase.
- `android.permission.CAMERA`: Pemindaian makanan secara langsung dan pengambilan foto profil.
- `android.permission.USE_BIOMETRIC`: Membuka kunci aplikasi menggunakan pemindai sidik jari/wajah bawaan perangkat.
- `uses-feature android:name="android.hardware.camera" android:required="false"`: Memungkinkan aplikasi diunduh pada perangkat yang tidak memiliki modul kamera perangkat keras (misal tablet tertentu) tanpa ditolak Play Store.

---

## 5. Audit Alur UX, Edge Cases & Error Recovery

Pemeriksaan menyeluruh dilakukan terhadap alur pengguna dan penanganan kondisi batas (*edge cases*):

### A. Penanganan Layar Kosong (*Empty States*)
1. **Tidak Ada Makanan Hari Ini (`TodaysIntakeSection`):**
   - Menampilkan kartu taktil NeoCard dengan ikon piring & garpu (`AppIcons.flatware`), judul jelas `BELUM ADA ASUPAN MAKAN`, deskripsi ramah konsumen, serta tombol aksi primer `PINDAI MAKANAN` (`AppIcons.cameraAlt`) dengan aksen warna lime.
2. **Tidak Ada Riwayat Makanan (`MealHistoryScreen`):**
   - Menampilkan ikon `AppIcons.noMeals`, judul `BELUM ADA CATATAN MAKAN`, pesan kontekstual (berbeda saat filter tanggal aktif vs riwayat umum kosong), dan tombol `SCAN SEKARANG`.
3. **Tidak Ada Artikel Nutrisi (`ArticleListScreen`):**
   - Menampilkan kartu edukasi dengan ikon `AppIcons.article`, judul `Belum Ada Artikel`, dan tombol `Muat Ulang`.
4. **Pencarian Tanpa Hasil:**
   - Pada pencarian artikel: Menampilkan ikon `AppIcons.searchOff`, judul `Artikel Tidak Ditemukan`, pesan panduan, dan tombol aksi `Hapus Pencarian`.
   - Pada modal pencarian makanan scanner: Menampilkan ikon `AppIcons.searchOff` dan teks panduan `Tidak ada makanan yang cocok`.

### B. Ketahanan Operasi Offline (*Offline Resiliency*)
1. **Kamera Scanner & Model AI YOLO26n:**
   - Berjalan 100% secara lokal pada CPU/NPU perangkat. Saat perangkat berada dalam Mode Pesawat (tanpa internet), inferensi deteksi makanan tetap berfungsi sempurna dengan latensi $<200$ ms.
2. **Offline Firestore Cache:**
   - SDK Cloud Firestore mengaktifkan disk persistence lokal, memungkinkan pengguna melihat catatan makanan yang sudah pernah dimuat sebelumnya meskipun koneksi internet terputus mendadak.

### C. Pemulihan dari Kondisi Galat (*Error Recovery*)
- Setiap tampilan error (`ErrorView`, `TodaysIntakeSection`, `MealHistoryScreen`, `ArticleListScreen`) dilengkapi dengan tombol taktil `Coba Lagi` / `COBA LAGI` (`AppIcons.refresh`) yang memicu fetch ulang tanpa perlu merestart aplikasi.
- Seluruh pesan kesalahan teknis (stack trace, format exception, internal URL) disaring melalui `AuthRepository.sanitizeErrorMessage()` sehingga hanya pesan yang ramah dan aman bagi pengguna yang ditampilkan di UI.

---

## 6. Penjaminan Kualitas (QA) & Otomatisasi Uji

Rangkaian pengujian otomatis menyeluruh telah dieksekusi pada lingkungan pengujian lokal:

### Hasil Eksekusi Uji Otomatis:
```text
00:56 +348: All tests passed!
```
- **Total Test Suites:** 24 File Test
- **Total Tests:** **348 Tests**
- **Pass Rate:** **100% (348 Lulus, 0 Gagal, 0 Flaky, 0 Skipped)**
- **Waktu Eksekusi Penuh:** ~56 detik

### Distribusi Cakupan Test Suite:
1. `biodata_home_sync_test.dart` (4/4 tests) — Verifikasi regresi sinkronisasi metrik fisik dan target gizi dari Biodata ke Beranda, invalidasi cache 15 menit, dan perpindahan tab.
2. `release_signing_config_test.dart` (6/6 tests) — Verifikasi konfigurasi Gradle release signing, ketiadaan fallback debug, aturan .gitignore, dan ProGuard TFLite.
3. `mandatory_biodata_flow_test.dart` (14/14 tests) — Verifikasi alur wajib pengisian biodata fisik pengguna baru, validasi form, dan transisi ke dashboard.
4. `overkill_neobrutalism_dashboard_test.dart` (28/28 tests) — Verifikasi hero card kalori, bento grid makronutrien, batas safe-area, dan responsivitas.
5. `biometric_auth_test.dart` & `biometric_widget_test.dart` (52/52 tests) — Verifikasi integrasi hardware biometric prompt, toggle pengaturan, dan fallback sandi.
6. `google_sign_in_test.dart` & `google_sign_in_widget_test.dart` (18/18 tests) — Verifikasi tombol native Google Sign-In, pertukaran token Firebase Auth, dan pemulihan sesi.
7. `onboarding_test.dart` (15/15 tests) — Pengujian rendering carousel 3 slide pada 5 viewport ekstrem (320px hingga 430px) tanpa satu pun RenderFlex overflow.
8. `scanner_benchmark_test.dart` & `yolo_detector_test.dart` (8/8 tests) — Benchmark pemrosesan background isolate, kebebasan memory leak, dan decoding gambar sintetis.
9. `admin_dashboard_screen_test.dart` & `admin_repository_test.dart` (64/64 tests) — Verifikasi 100% UI/UX parity portal manajemen admin dan simulator Atwater.
10. `portion_input_widget_test.dart` & `portion_validation_test.dart` (16/16 tests) — Pengujian input porsi numerik, penggantian leading zero, sanitasi koma/titik, dan validasi 0 gram.

---

## 7. Kesiapan Rilis Google Play Store & Pengerasan Android

### A. Kompatibilitas Android SDK & App Bundle
- **Compile SDK:** Menggunakan `flutter.compileSdkVersion` (default Flutter 36).
- **Target SDK:** Menggunakan `flutter.targetSdkVersion` (default Flutter 36 / Android 15/16). Memenuhi mandat Google Play Store 2024/2025/2026 yang mewajibkan Target SDK $\ge 35$.
- **Min SDK:** Ditetapkan `maxOf(flutter.minSdkVersion, 23)` (dengan Flutter default minSdkVersion 24). Menjamin kompatibilitas pada Android 7.0 (Nougat) hingga Android 15 (Vanilla Ice Cream).
- **Format Distribusi:** Android App Bundle (`.aab`) teroptimasi dengan split per-ABI (arm64-v8a, armeabi-v7a, x86_64).

### B. Penegakan Keras Release Signing Android
Pada `frontend/android/app/build.gradle.kts`:
- **Debug Build:** Terikat secara eksplisit pada `signingConfigs.getByName("debug")`.
- **Release Build:** Terikat secara ketat pada `signingConfigs.getByName("release")`.
- **Zero Fallback Enforcement:** Dilarang keras melakukan fallback otomatis ke debug signing.
- **Fail-Fast Hook (`gradle.taskGraph.whenReady`):** Jika file `key.properties` tidak ada di direktori build release, atau file keystore `.jks` tidak ditemukan pada disk, build langsung dihentikan dengan pesan error terarah yang memandu developer menyiapkan upload keystore asli.

### C. Optimasi ProGuard & R8
File `frontend/android/app/proguard-rules.pro` telah dikeraskan dan memproteksi:
- Kelas native TensorFlow Lite dan metode JNI (`org.tensorflow.lite.**`, `native <methods>;`).
- SDK Firebase Core, Firebase Auth, dan Cloud Firestore.
- Komponen Google Play Services dan Google Sign-In API.
- Android Keystore Cryptography (`androidx.security.crypto.**`).
- Hardware Biometric API (`androidx.biometric.**`).

---

## 8. Kesimpulan & Rekomendasi Rilis (Final Sign-Off)

Berdasarkan hasil audit menyeluruh:
1. **Status Kesiapan:** **RELEASE CANDIDATE 1 (RC1) — READY FOR STORE DEPLOYMENT**.
2. **Kualitas Kode:** Tidak ada issue pada analisis statis (`flutter analyze: 0 issues`), dan 100% dari 348 unit/widget/regression test lulus tanpa kegagalan.
3. **Kepatuhan Privasi:** Mematuhi seluruh regulasi privasi Google Play (kamera, biometrik, isolasi data multi-tenant).
4. **Langkah Selanjutnya:** Pemilik repositori dapat mengikuti panduan operasional pada `RELEASE_CHECKLIST.md` untuk mengompilasi App Bundle rilis (`flutter build appbundle --release`) menggunakan upload keystore resmi dan mengunggahnya ke track Internal/Closed Testing Google Play Console.
