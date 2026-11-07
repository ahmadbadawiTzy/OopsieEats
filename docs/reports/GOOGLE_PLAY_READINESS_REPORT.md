# LAPORAN KESIAPAN GOOGLE PLAY STORE (READINESS & COMPLIANCE) — NUTRIVIEW

**Aplikasi:** NutriView — Food Nutrition Recognition & Daily Tracking App  
**Package / Namespace:** `com.nutriview.nutriview`  
**Tanggal Audit:** 7 November 2026  
**Auditor:** Google Play Compliance Specialist & Application Security Engineer  
**Status Keseluruhan:** **READY FOR INTERNAL / CLOSED TESTING** (Dengan Manual Checklist Google Play Console)  

---

> [!IMPORTANT]
> **DISCLAIMER RESMI:**  
> Laporan audit ini disusun berdasarkan kebijakan Google Play Developer Policy dan Android Developers Guidelines per November 2026. Laporan ini bertujuan memitigasi risiko penolakan (*rejection*) dan memastikan kepatuhan teknis. **Tidak ada jaminan mutlak bahwa aplikasi pasti diterima tanpa melalui proses peninjauan resmi (*human/automated review*) dari tim Google Play Store.**

---

## 1. Matriks Kepatuhan Kebijakan Utama

| Kategori Kebijakan | Persyaratan Google Play (Nov 2026) | Status Aktual NutriView | Evaluasi |
|---|---|---|---|
| **Target API Level** | Wajib menargetkan Android 15 (API 35) atau Android 16 (API 36) untuk rilis/update baru | `flutter.targetSdkVersion` (Flutter 3.47.8 resolves to API 35/36) | **PASS** |
| **Minimum SDK** | Minimal Android 6.0 (API 23+) untuk keamanan dan biometrik modern | `minSdk = maxOf(flutter.minSdkVersion, 23)` | **PASS** |
| **64-bit Architecture** | Wajib mendukung arsitektur native 64-bit (`arm64-v8a`, `x86_64`) | Flutter NDK build menyertakan binary 64-bit lengkap | **PASS** |
| **Code Shrinking & R8** | Mengurangi ukuran dan mengaburkan simbol release | `isMinifyEnabled = true`, `isShrinkResources = true`, `proguard-rules.pro` | **PASS** |
| **Network Security** | Larangan cleartext HTTP secara default | `networkSecurityConfig="@xml/network_security_config"` (Strict HTTPS only) | **PASS** |
| **Backup Hardening** | Larangan ekspor otomatis data pengguna via ADB | `android:allowBackup="false"` dikonfigurasi di manifest | **PASS** |
| **Health Apps Policy** | Kategori *Nutrition & Weight Management*: wajib deklarasi & disclaimer non-medis | Deklarasi non-medis terpasang; tidak ada klaim diagnosis penyakit | **PASS** |
| **Account Deletion** | Wajib menyediakan opsi hapus akun & data di dalam aplikasi dan web | Fitur in-app Account Deletion cascading di `ProfileScreen` | **PASS** |
| **Data Safety & Privacy** | Deklarasi jenis data yang dikumpulkan (foto, email, info gizi) | Terisolasi di Supabase Storage & Firestore multi-tenant | **NEEDS MANUAL ACTION** |
| **Health Apps Console Form** | Pengisian kuesioner Health Apps Declaration di Google Play Console | Harus diisi secara manual oleh pemilik akun developer | **NEEDS MANUAL ACTION** |

---

## 2. Audit Android Manifest & Izin (Permissions)

File: `frontend/android/app/src/main/AndroidManifest.xml`

### A. Evaluasi Izin yang Dideklarasikan:
1. `android.permission.INTERNET`
   - **Tujuan:** Komunikasi dengan Firebase Auth, Cloud Firestore, dan Supabase Storage.
   - **Status:** **PASS** (Standar aplikasi berbasis cloud).
2. `android.permission.CAMERA`
   - **Tujuan:** Mengambil foto makanan secara langsung untuk analisis YOLO26n.
   - **Hardware Feature Guard:**
     ```xml
     <uses-feature android:name="android.hardware.camera" android:required="false"/>
     <uses-feature android:name="android.hardware.camera.autofocus" android:required="false"/>
     ```
   - **Status:** **PASS**. Dideklarasikan dengan `android:required="false"`, sehingga pengguna pada tablet atau perangkat tanpa kamera belakang tetap dapat mengunduh aplikasi dari Play Store dan menggunakan fitur input makanan manual / galeri.
3. `android.permission.USE_BIOMETRIC`
   - **Tujuan:** Otentikasi sidik jari/wajah cepat pada `LoginScreen`.
   - **Status:** **PASS** (Menggunakan AndroidX BiometricPrompt standar).

### B. Izin yang Dihindari (Least Privilege Principle):
- **TIDAK ADA** izin berbahaya (*Dangerous Permissions*) yang tidak relevan:
  - Tidak ada `READ_EXTERNAL_STORAGE` / `WRITE_EXTERNAL_STORAGE` (menggunakan Photo Picker / File Provider modern).
  - Tidak ada `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION`.
  - Tidak ada `RECORD_AUDIO`.
  - Tidak ada `QUERY_ALL_PACKAGES`.
- Aplikasi mematuhi kebijakan Google Play *Permission Minimization*.

---

## 3. Kepatuhan Kebijakan Aplikasi Kesehatan (Health Apps Policy)

Google Play menerapkan regulasi ketat untuk aplikasi dalam kategori kesehatan, kebugaran, dan nutrisi:

### A. Klasifikasi Kategori
- NutriView termasuk dalam klasifikasi: **Nutrition and Weight Management** (Pengelolaan Nutrisi & Berat Badan).

### B. Larangan Klaim Medis & Regulasi Diagnostik
- **Ketentuan Google Play:** Aplikasi nutrisi **TIDAK BOLEH** mengklaim dapat mendiagnosis, mengobati, menyembuhkan, atau mencegah penyakit medis (seperti diabetes, hipertensi, atau kanker) tanpa izin perangkat medis resmi (*Medical Device Clearance/CE/FDA*).
- **Kondisi NutriView:**
  - NutriView bertindak sebagai kalkulator estimasi gizi (kalori, protein, karbohidrat, lemak) berdasarkan pengenalan makanan YOLO26n dan database gizi umum.
  - Teks promosi, deskripsi artikel, dan antarmuka pengguna **TIDAK MENYATAKAN** diagnosis medis.
- **Rekomendasi Health Disclaimer:**
  Teks penafian (*disclaimer*) wajib tertera pada halaman *Tentang Aplikasi* (`AboutScreen`) dan deskripsi Store Listing:
  > *"NutriView adalah aplikasi pelacak nutrisi mandiri untuk tujuan informasi dan gaya hidup sehat. Estimasi kalori dan nutrisi yang disajikan bukan merupakan diagnosis medis, anjuran dokter, atau rencana diet klinis. Selalu konsultasikan kondisi kesehatan khusus Anda dengan dokter atau ahli gizi profesional berlisensi."*

---

## 4. Keamanan Data & Kebijakan Penghapusan Akun (Data Safety & Deletion)

### A. Kebijakan Penghapusan Akun (Wajib Sejak 2024)
- **Aturan Google Play:** Jika aplikasi memungkinkan pembuatan akun, pengguna harus dapat meminta penghapusan akun beserta semua data terkait, baik dari dalam aplikasi maupun melalui tautan web publik (*URL deletion request*).
- **Implementasi NutriView:**
  - **In-App Cascading Deletion:** Diimplementasikan pada `ProfileScreen` -> `AuthRepository.deleteAccount`.
  - **Alur Kerja Pembersihan Data:**
    1. Memverifikasi kesegaran sesi (*re-authentication* dengan kata sandi jika sesi > 5 menit).
    2. Menghapus seluruh dokumen `users/{uid}/meals/*` dari Cloud Firestore.
    3. Menghapus dokumen profil `users/{uid}`.
    4. Membersihkan seluruh folder foto `food-history-images/{uid}/*` dari Supabase Storage.
    5. Menghapus kredensial pengguna dari Firebase Authentication.
    6. Menghapus cache lokal dan token dari `FlutterSecureStorage`.
  - **Status:** **PASS** (Diuji dan diverifikasi pada `test/account_deletion_test.dart`).

### B. Audit Kerahasiaan Kredensial
- File `SupabaseConfig.dart` hanya berisi `anonKey` (public key yang aman untuk client-side).
- **TIDAK ADA** `service_role` key atau secret admin yang bocor pada repositori aplikasi.
- Firestore Security Rules (`firestore.rules`) menerapkan isolasi multi-tenant ketat:
  `match /users/{userId}/meals/{mealId} { allow read, write: if isOwner(userId); }`
  Pengguna A tidak dapat membaca atau menulis data makanan Pengguna B.

---

## 5. Daftar Tindakan Manual (Manual Action Checklist)

Langkah-langkah berikut **wajib diselesaikan secara manual** oleh developer di Google Play Console sebelum mengirimkan aplikasi untuk review produksi:

- [ ] **1. Form Deklarasi Aplikasi Kesehatan (Health Apps Declaration):**
  - Buka Google Play Console -> *Policy and programmes* -> *App content* -> *Health apps*.
  - Pilih kategori: *Nutrition and Weight Management*.
  - Centang opsi bahwa aplikasi tidak memberikan diagnosis medis klinis.
- [ ] **2. Kuesioner Keamanan Data (Data Safety Section):**
  - Deklarasikan data yang dikumpulkan:
    - *Personal info:* Email, Nama, Usia/Tanggal Lahir, Jenis Kelamin, Tinggi/Berat Badan (untuk perhitungan target harian).
    - *Photos and videos:* Foto makanan (hanya digunakan untuk fungsi pengenalan nutrisi, disimpan di storage privat).
    - *Health & Fitness:* Info nutrisi dan target kalori.
  - Nyatakan bahwa data dienkripsi saat transit (*HTTPS/TLS*) dan pengguna dapat meminta penghapusan data.
- [ ] **3. URL Permintaan Hapus Akun Publik (Account Deletion Web Page):**
  - Google Play mewajibkan adanya tautan web publik (bisa dihosting di Firebase Hosting/GitHub Pages) yang menjelaskan cara pengguna meminta penghapusan akun di luar aplikasi.
- [ ] **4. Kebijakan Privasi (Privacy Policy URL):**
  - Pastikan tautan `https://nutriview.app/privacy` aktif dan dapat diakses publik tanpa login.
- [ ] **5. Kredensial Akun Pengujian Reviewer (App Access):**
  - Siapkan akun demo aktif (email + password) di Google Play Console -> *App content* -> *App access* agar tim reviewer Google Play dapat langsung login dan menguji fitur pemindaian serta riwayat makan tanpa kendala registrasi.
- [ ] **6. Keystore & Signing Config:**
  - Buat file `android/key.properties` lokal yang mengarah ke keystore release resmi untuk menghasilkan berkas `.aab` (Android App Bundle).

---

## 6. Ringkasan Status Akhir

| Aspek | Status | Catatan |
|---|---|---|
| **Kompilasi & Build** | **PASS** | Debug & Test lolos; 0 issues di Flutter Analyze |
| **Layout & Sizing Card** | **PASS** | Bebas overflow di seluruh form factor (320px–430px) |
| **Kepatuhan Izin Manifest** | **PASS** | Minimalis, kamera opsional, HTTPS enforced |
| **In-App Account Deletion** | **PASS** | Cascading cleanup Firestore & Supabase Storage |
| **Keamanan Storage & Rules** | **PASS** | Multi-tenant isolation terverifikasi |
| **Google Play Console Setup** | **NEEDS MANUAL ACTION** | Pengisian formulir konten & Data Safety oleh developer |
