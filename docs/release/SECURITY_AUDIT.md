# Laporan Audit Keamanan Aplikasi Mobile — OopsieEats (NutriView)

**Tanggal Audit:** 13 November 2026  
**Klasifikasi:** Confidential / Production Security Baseline  
**Target:** OopsieEats Android Release (`com.oopsieeats.app`, `versionCode: 2002`)  
**Lead Auditor:** Senior Mobile Application Security Engineer  

---

## 1. Ringkasan Eksekutif Keamanan

Audit keamanan komprehensif telah dilakukan terhadap seluruh lapisan aplikasi OopsieEats, meliputi arsitektur autentikasi, otorisasi backend, integritas penyimpanan cloud, validasi input, proteksi tanda tangan kriptografi, proteksi binary (R8/ProGuard), serta analisis kebocoran rahasia.

| Domain Keamanan | Status | Tingkat Risiko | Temuan Utama & Mitigasi |
| :--- | :--- | :--- | :--- |
| **Penyimpanan Kredensial & Secrets** | `PASS` | Low (Residual) | Zero hardcoded secret keys. `key.properties`, keystore, dan service-account tidak terlacak di Git. Supabase service role key tidak didistribusikan ke client. Kredensial lokal tersimpan via `FlutterSecureStorage` (Android Keystore / EncryptedSharedPreferences). |
| **Aturan Otorisasi Firestore** | `PASS` | Negligible | Multi-tenant isolation (`isOwner(userId)`). Anti-privilege escalation (`data.role == prev.role`). Validasi ketat batas panjang string, tipe data, skema kolom terizinkan (`hasOnlyAllowedUserFields`), serta subkoleksi `meals` terisolasi penuh. |
| **Supabase Binary Storage Security** | `PASS` | Low | Akses foto privat via *Signed URL* jangka pendek (TTL 1 jam). Perlindungan anti-path traversal (`userId/` prefix enforcement). Validasi ukuran unggah ganda (maks 20 MB raw anti-OOM DoS dan maks 5 MB post-compression JPEG). |
| **Proteksi Jaringan & Transport Security** | `PASS` | Negligible | `usesCleartextTraffic="false"` ditegakkan di manifest rilis. Seluruh koneksi ke Firebase, Google Identity, dan Supabase menggunakan HTTPS/TLSv1.3. `network_security_config.xml` aktif menolak trafik HTTP tidak terenkripsi. |
| **Integritas Rilis & Anti-Reverse Engineering** | `PASS` | Low | R8 minification & resource shrinking aktif (`isMinifyEnabled = true`, `isShrinkResources = true`). Obfuskasi kode Dart aktif via `--obfuscate --split-debug-info`. Pustaka native 64-bit teruji kompatibel 16 KB page-size. Tanda tangan rilis mengikat upload key produksi tanpa fallback debug. |
| **Alur Penghapusan Akun & Data (GDPR/Play Compliance)** | `PASS` | Negligible | Penghapusan akun cascade penuh (In-App & Web): membersihkan Firestore `users/{uid}`, subkoleksi `meals`, Supabase Storage folder `uid/`, kredensial Firebase Auth, dan cache lokal. |

---

## 2. Analisis Otorisasi & Aturan Keamanan Firestore (`firestore.rules`)

File target: `firestore.rules` (257 baris)

### 2.1 Isolasi Multi-Tenant Pengguna
- Aturan `match /users/{userId}` menerapkan `allow read: if isSignedIn() && (request.auth.uid == userId || isAdmin());`. Pengguna non-admin tidak dapat membaca data profil pengguna lain.
- Subkoleksi `users/{userId}/meals/{mealId}` dan catch-all `users/{userId}/{allSubcollections=**}` dibatasi ketat menggunakan `isOwner(userId)` (`request.auth.uid == userId`). Akses silang antar-pengguna dicegah di tingkat basis data.

### 2.2 Pencegahan Eskalasi Hak Istimewa (Anti-Privilege Escalation)
Pada operasi pembuatan akun (`isValidUserCreate`):
```javascript
data.role == 'user' &&
data.is_active == true
```
Pengguna yang mendaftar secara mandiri tidak dapat menyuntikkan `role: 'admin'`.

Pada operasi pembaruan akun (`isValidUserUpdateByOwner`):
```javascript
data.role == prev.role &&
data.is_active == prev.is_active &&
(!('uid' in prev) || data.uid == prev.uid) &&
(!('id' in prev) || data.id == prev.id) &&
(!('email' in prev) || data.email == prev.email) &&
(!('created_at' in prev) || data.created_at == prev.created_at)
```
Pengguna dilarang memanipulasi kolom `role`, status `is_active`, atau identitas permanen akun (`uid`, `id`, `email`, `created_at`).

### 2.3 Validasi Skema & Batasan Tipe Data (Anti-Schema Pollution)
- Fungsi `hasOnlyAllowedUserFields` memastikan tidak ada kolom asing yang disuntikkan ke dokumen pengguna.
- Panjang karakter dibatasi: `full_name` (1–100 karakter), `email` (3–100 karakter), `photo_url` / `photo_path` (<= 500 karakter).
- Sub-map `profile` memvalidasi rentang fisik logis: usia 1–120 tahun, tinggi badan 50–250 cm, berat badan 20–300 kg, serta enum terbatas untuk jenis kelamin, aktivitas, dan tujuan diet.

### 2.4 Akses Katalog Pangan & Modul CMS
- Koleksi `/foods/{foodId}`: Dapat dibaca oleh semua pengguna terautentikasi (`allow read: if isSignedIn()`), namun operasi tulis/ubah/hapus dibatasi khusus untuk Administrator (`isAdmin()`).
- Koleksi `/cms_audit_logs/{logId}`: Bersifat *immutable* (`allow update, delete: if false`). Administrator hanya dapat menambahkan log miliknya sendiri (`request.resource.data.performed_by == request.auth.uid`).

---

## 3. Analisis Penyimpanan Binary Supabase (`SupabaseStorageService`)

File target: `frontend/lib/data/services/supabase_storage_service.dart`

### 3.1 Perlindungan Path Traversal
Metode `_sanitizePath` dan `_validateUserOwnership` memvalidasi bahwa path penyimpanan tidak memuat urutan traversal seperti `../`, `..\\`, atau karakter kontrol berbahaya:
```dart
if (path.contains('..') || path.startsWith('/') || path.contains(r'\')) {
  throw ArgumentError('Invalid storage path format');
}
```
Setiap operasi unggah foto makanan (`uploadFoodImage`) dan foto profil (`uploadProfilePhoto`) memvalidasi bahwa prefix path berawal tepat dari `userId/` milik pengguna yang sedang terotentikasi.

### 3.2 Proteksi Denial of Service (Memory & Quota Protection)
- **Validasi Byte Kosong:** Menolak payload 0 byte.
- **Batas Payload Mentah (20 MB):** Mencegah serangan *Out-Of-Memory (OOM)* saat decoding gambar beresolusi raksasa di thread background.
- **Batas Pasca-Kompresi (5 MB):** Menolak berkas yang melebihi batas kuota `SupabaseConfig.maxUploadSizeBytes`.
- **Downscaling & Kompresi:** Otomatis mengubah ukuran citra ke dimensi maksimum 1024x1024 px dengan kompresi JPEG 80%, menghemat bandwidth dan kapasitas penyimpanan.

### 3.3 Enkripsi Akses via Signed URL
Bucket `food-history-images` dikonfigurasi sebagai bucket privat. URL publik langsung tidak diekspos; aplikasi menggunakan *Signed URL* berjangka waktu terbatas (*TTL 1 jam*) dengan mekanisme caching in-memory untuk meminimalkan permintaan token ke Supabase.

---

## 4. Analisis Rahasia, Kunci API & Lingkungan

### 4.1 Pemindaian Repositori Git (`git ls-files`)
Pemindaian terhadap seluruh file yang terlacak di Git memastikan tidak ada berkas sensitif yang terunggah:
- Zero `.jks` / `.keystore` terdaftar di Git.
- Zero `key.properties` terdaftar di Git.
- Zero `.env` terdaftar di Git.
- Zero file `service-account*.json` terdaftar di Git.
- File konfigurasi rilis `frontend/android/key.properties` dilindungi oleh file `.gitignore` tingkat root dan tingkat android.

### 4.2 Kunci Klien Firebase & Supabase
- **Firebase API Key (`AIzaSy...`):** Merupakan *Client Identifier* publik yang memang diperuntukkan bagi aplikasi seluler Android/Web sesuai desain Google Firebase. Keamanan data tidak bergantung pada kerahasiaan API key tersebut, melainkan ditegakkan oleh Firebase Authentication dan Cloud Firestore Security Rules.
- **Supabase Key (`sb_publishable_...`):** Merupakan *anonymous publishable key* dengan hak akses publik terbatas. Kunci berkekuatan tinggi (*service_role key*) **tidak pernah** dimasukkan ke dalam kode aplikasi mobile.

---

## 5. Audit Konfigurasi Tanda Tangan & Build Rilis Android

File target: `frontend/android/app/build.gradle.kts`

### 5.1 Larangan Keras Fallback ke Debug Key
```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        signingConfig = signingConfigs.getByName("release")
    }
}
```
Sistem build menerapkan validasi *fail-fast* melalui listener Gradle `gradle.taskGraph.whenReady`. Apabila `key.properties` atau file upload keystore tidak tersedia di mesin build, proses kompilasi rilis langsung dihentikan dengan pesan error eksplisit dan tidak akan pernah berpindah ke `signingConfigs.debug`.

### 5.2 Status Tanda Tangan Kriptografi
- **Keystore:** `/home/ahmadbadawi/.keystores/oopsieeats-upload-keystore.jks`
- **Alias:** `oopsieeats_upload`
- **Algoritma:** RSA 2048-bit with SHA256withRSA
- **Distinguished Name (DN):** `CN=Ahmad Badawi, OU=Mobile Engineering, O=OopsieEats, L=Jakarta, ST=DKI Jakarta, C=ID`
- **Masa Berlaku:** 8 November 2026 s.d. 26 Maret 2054
- **Upload SHA-1:** `7F:2A:D7:60:53:9A:BE:8D:4C:CE:C0:EA:32:66:BD:DE:A8:A5:7A:D8`
- **Upload SHA-256:** `B7:34:8D:DD:47:D5:33:C8:08:DD:15:1E:E2:39:56:9E:45:2B:1C:90:74:1D:BB:2A:06:8C:C7:9D:32:C6:BC:2C`

---

## 6. Audit Izin Android (*Android Permissions Least Privilege*)

Pemeriksaan pada *merged release* `AndroidManifest.xml` (`frontend/build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml`):

### 6.1 Izin yang Diizinkan & Justifikasi
1. `android.permission.INTERNET` — Komunikasi HTTPS ke Firebase Auth, Firestore, dan Supabase Storage.
2. `android.permission.ACCESS_NETWORK_STATE` — Pengecekan status koneksi jaringan sebelum sinkronisasi data.
3. `android.permission.CAMERA` — Pengambilan foto makanan untuk AI inference dan foto profil (`android.hardware.camera required="false"`).
4. `android.permission.USE_BIOMETRIC` & `USE_FINGERPRINT` — Autentikasi lokal sidik jari/wajah via Android BiometricPrompt.

### 6.2 Izin Berbahaya yang Berhasil Dihapus
Izin transitif warisan berikut telah dihapus secara eksplisit menggunakan `tools:node="remove"`:
- `android.permission.READ_PHONE_STATE` (Dihapus)
- `android.permission.WRITE_EXTERNAL_STORAGE` (Dihapus)
- `android.permission.READ_EXTERNAL_STORAGE` (Dihapus)

Aplikasi tidak meminta izin lokasi, mikrofon, kontak, kalender, SMS, atau media gallery legacy.

---

## 7. Kesimpulan & Status Kesiapan Keamanan

Aplikasi **OopsieEats** memenuhi seluruh standar keamanan minimum Google Play Store dan OWASP Mobile Application Security Verification Standard (MASVS Level 1). Tidak ditemukan kerentanan berstatus *CRITICAL* maupun *HIGH*.
