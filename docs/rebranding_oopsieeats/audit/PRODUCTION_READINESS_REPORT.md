# OopsieEats — Production Readiness Audit & Final Release Preparation Report
**Tanggal Audit & Persiapan:** 8 November 2026  
**Auditor:** Senior Mobile Software Architect, Android Release Engineer, Firebase & Supabase Specialist  
**Target Proyek:** OopsieEats (`com.oopsieeats.app`)  
**Status Evaluasi Keseluruhan:** **PRE-RELEASE AUDIT COMPLETED — READY FOR RELEASE SIGNING & REAL-DEVICE TESTING**  
*(Local Codebase: 100% VERIFIED; Firebase & Supabase Cloud: 100% CONFIGURED; Android Release Configuration: HARDENED; Owner Action Items: IDENTIFIED & DOCUMENTED)*

---

## 1. Executive Summary & Production Verdict

Seluruh tahapan migrasi identitas dari **NutriView** ke **OopsieEats** telah selesai dilaksanakan secara menyeluruh dan terverifikasi. Konfigurasi build Android, proteksi rahasia, registrasi cloud pada Firebase (`nutriview-943cd`) dan Supabase (`rnfvudxqcwcwilcyicow`) telah diuji dan divalidasi hingga level API backend.

### ⚠️ Klarifikasi Kesiapan Google Play Store (Production Reality Check)
Keberhasilan build Debug APK dan kelulusan 338 automated tests **TIDAK SAMA** dengan status siap rilis langsung ke Google Play Store (Production Ready). Untuk dapat mendistribusikan aplikasi ke pengguna akhir melalui Google Play Store, langkah-langkah rilis berikut wajib diselesaikan secara berurutan:
1. **Pembuatan Upload Keystore Lokal** (memerlukan persetujuan & eksekusi aman pemilik akun).
2. **Pendaftaran Fingerprint SHA-1 & SHA-256 Release ke Firebase Console**.
3. **Verifikasi Build Binary Release (`.aab`) dengan ProGuard/R8 Obfuscation**.
4. **Pendaftaran SHA-1 Google Play App Signing** ke Firebase Console setelah upload pertama ke Play Store (karena Google menandatangani ulang APK pengguna dengan sertifikat Play Store).
5. **Pelaksanaan 12-Point Real Device Test Plan** pada perangkat fisik Android asli.

### Ringkasan Status Mutu Teknis:
* **Analisis Statis (`flutter analyze`):** `PASSED` — 0 issues (0 errors, 0 warnings, 0 lints).
* **Automated Test Suite (`flutter test`):** `PASSED` — 338 dari 338 tests lulus (100% pass rate).
* **Gradle Tasks & Dry Run (`./gradlew tasks --dry-run`):** `PASSED` — Build configuration valid, zero syntax/DSL errors.
* **Android Application ID & Namespace:** `VERIFIED` — `com.oopsieeats.app` aktif di seluruh manifest dan gradle.
* **App Display Name:** `VERIFIED` — `OopsieEats` aktif di `AndroidManifest.xml` dan 80+ locale Android.
* **Keamanan Kunci Rilis:** `VERIFIED` — 0 file keystore atau `key.properties` yang tersimpan di repository; `.gitignore` terproteksi ketat.
* **Registrasi Firebase Android:** `COMPLETED` — Terdaftar resmi dengan App ID `1:350308179098:android:52fbbbd2d02639e47e5323`.
* **Kredensial Debug SHA-1 & SHA-256:** `REGISTERED` — Terdaftar di Firebase Apps Android SHA API.
* **Supabase Storage Isolation:** `VERIFIED` — Bucket `food-history-images` privat (`public = false`), RLS regex aktif, 0 service role key.

---

## 2. Bagian A — Arsitektur Release Signing & Keystore Android

### 1. Audit Konfigurasi Signing Android
* **Lokasi File:** `frontend/android/app/build.gradle.kts`
* **Audit Keystore Saat Ini:**
  - Telah dilakukan pencarian mendalam pada seluruh pohon direktori project (`find . -name "*.jks" -o -name "*.keystore" -o -name "key.properties"`).
  - **Hasil:** Tidak ditemukan file keystore rilis (`*.jks`/`*.keystore`) maupun file kredensial `key.properties`. Hanya `~/.android/debug.keystore` yang ada di mesin lokal pengembang.
  - **Status:** **AMBILAN AMAN** — Tidak ada kredensial atau keystore rilis yang bocor ke version control.

### 2. Konfigurasi Gradle Release Signing yang Dikeraskan (Hardened Gradle Config)
Konfigurasi Gradle pada `frontend/android/app/build.gradle.kts` telah direfaktor mengikuti standar resmi Android Gradle Plugin (AGP):
1. Blok `signingConfigs` didefinisikan secara eksplisit sebelum blok `buildTypes`.
2. Gradle membaca `frontend/android/key.properties` jika tersedia.
3. Path keystore (`storeFile`) mendukung path absolut maupun relatif secara dinamis.
4. Jika `key.properties` tidak ditemukan (misalnya pada environment CI testing atau pengembang baru), Gradle secara otomatis melakukan fallback yang aman ke `signingConfigs.getByName("debug")` tanpa menyebabkan build failure.

```kotlin
// frontend/android/app/build.gradle.kts
signingConfigs {
    create("release") {
        val keystorePropertiesFile = rootProject.file("key.properties")
        if (keystorePropertiesFile.exists()) {
            val keystoreProperties = Properties()
            keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            val storeFilePath = keystoreProperties.getProperty("storeFile")
            if (storeFilePath != null) {
                val fileObj = File(storeFilePath)
                storeFile = if (fileObj.isAbsolute) fileObj else rootProject.file(storeFilePath)
            }
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }
}

buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
        val keystorePropertiesFile = rootProject.file("key.properties")
        signingConfig = if (keystorePropertiesFile.exists()) {
            signingConfigs.getByName("release")
        } else {
            // Fallback to debug keys when key.properties is not provided
            signingConfigs.getByName("debug")
        }
    }
}
```

### 3. Proteksi Git & Kebijakan Nol-Rahasia (Zero Secret in Git)
Telah diverifikasi bahwa baik `.gitignore` di root proyek maupun `frontend/android/.gitignore` memblokir seluruh artefak sensitif:
```gitignore
# Root .gitignore & frontend/android/.gitignore
*.jks
*.keystore
*key.properties
key.properties
```

### 4. Panduan Pembuatan Upload Keystore (Langkah untuk Pemilik Proyek)
> [!IMPORTANT]
> Keystore rilis **TIDAK DIBUAT SECARA SEPIHAK** oleh asisten AI demi mematuhi prinsip kedaulatan keamanan dan hak cipta pemilik. Silakan jalankan perintah di bawah ini secara mandiri di terminal lokal Anda.

#### Langkah 1: Buat direktori aman di luar repositori Git
```bash
mkdir -p ~/.keystores
```

#### Langkah 2: Generate Upload Keystore dengan JDK `keytool`
Jalankan perintah ini (pastikan JDK 17 atau yang lebih baru telah terpasang):
```bash
keytool -genkeypair -v \
  -keystore ~/.keystores/oopsieeats-upload-keystore.jks \
  -alias oopsieeats_upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storetype JKS
```
*Anda akan diminta memasukkan kata sandi keystore, nama lengkap, unit organisasi, kota, dan negara. Simpan kata sandi ini dengan sangat aman.*

#### Langkah 3: Konfigurasi `frontend/android/key.properties`
Buat file `frontend/android/key.properties` (file ini otomatis diabaikan oleh Git):
```properties
storePassword=<MASUKKAN_PASSWORD_KEYSTORE_ANDA>
keyPassword=<MASUKKAN_PASSWORD_KEYSTORE_ANDA>
keyAlias=oopsieeats_upload
storeFile=/home/ahmadbadawi/.keystores/oopsieeats-upload-keystore.jks
```

### 5. Panduan Pencadangan (Backup) Keystore Secara Aman
Kehilangan file keystore rilis atau kata sandinya dapat berakibat fatal:
1. **Simpan di Password Manager:** Simpan file `.jks` sebagai file attachment dan seluruh password di dalam Password Manager terenkripsi end-to-end (misal: Bitwarden, 1Password, atau KeePassXC).
2. **Offline Cold Storage:** Simpan salinan file `.jks` pada flash drive USB fisik yang dienkripsi (LUKS / BitLocker / VeraCrypt) dan simpan di lokasi fisik yang aman.
3. **Larangan Keras:** JANGAN PERNAH mengirimkan file keystore atau password melalui email, chat Telegram/WhatsApp tidak terenkripsi, atau folder Google Drive/Dropbox publik tanpa enkripsi password vault.

### 6. Perbedaan Fundamental: Upload Key vs. Google Play App Signing Key
Memahami perbedaan kedua sertifikat ini sangat krusial untuk mencegah kegagalan Google Sign-In pada aplikasi yang diunduh dari Play Store:

| Fitur | Upload Key (Kunci Pengunggah) | Google Play App Signing Key (Kunci Distribusi) |
| :--- | :--- | :--- |
| **Lokasi Pembuatan** | Komputer lokal pengembang (`~/.keystores/`) | Server Google Cloud HSM (Hardware Security Module) |
| **Fungsi Utama** | Menandatangani binary `.aab` sebelum diunggah ke Play Console | Menandatangani APK terpecah (split APK) yang diunduh pengguna |
| **Dikelola Oleh** | Pengembang / Pemilik Aplikasi | Google Play Console |
| **Dapat Direset?** | Ya, dapat meminta reset ke Google Play Support jika hilang | Tidak, permanen sepanjang masa hidup aplikasi |
| **Pengaruh ke Firebase** | Harus didaftarkan ke Firebase Console | **WAJIB didaftarkan ke Firebase Console** agar Google Sign-In berfungsi di Play Store! |

---

## 3. Bagian B — Status Google OAuth & Integrasi Firebase

### 1. Pelestarian Project Firebase `nutriview-943cd`
* **Firebase Project ID:** `nutriview-943cd` (Project Number: `350308179098`)
* Seluruh data Firestore, user authentication, dan security rules dipertahankan 100% tanpa modifikasi destruktif.

### 2. Registrasi Android Package `com.oopsieeats.app`
* **Status:** `COMPLETED & VERIFIED`
* **Firebase Android App ID:** `1:350308179098:android:52fbbbd2d02639e47e5323`
* **Display Name:** `OopsieEats`
* **Aplikasi Legacy (`com.nutriview.nutriview`):** App ID `1:350308179098:android:95f5dda5c337a14a7e5323` tetap dipertahankan.

### 3. Fingerprint Debug Terdaftar (Active Debug Fingerprints)
* **Debug SHA-1:** `A2:A4:F8:86:DA:6A:ED:F6:27:D5:28:0E:0D:AC:7B:02:10:8A:3C:7B` (SHA ID: `24d3ace85eac1ee9`)
* **Debug SHA-256:** `25:1F:58:47:71:0D:4E:0F:35:FF:CD:E3:76:5F:35:D7:9A:3F:C9:F3:8D:0D:42:68:71:FA:67:47:02:D1:AE:A8` (SHA ID: `7966ca40da27b50c`)

### 4. Langkah Pendaftaran SHA-1 & SHA-256 Rilis
Saat Anda telah membuat Release Keystore, jalankan langkah pendaftaran ini:

#### A. Daftarkan Upload Key ke Firebase:
1. Ekstrak SHA-1 dan SHA-256 dari release keystore:
   ```bash
   keytool -list -v -keystore ~/.keystores/oopsieeats-upload-keystore.jks -alias oopsieeats_upload
   ```
2. Daftarkan ke Firebase menggunakan Firebase CLI:
   ```bash
   firebase apps:android:sha:create 1:350308179098:android:52fbbbd2d02639e47e5323 <UPLOAD_SHA1> --project=nutriview-943cd
   firebase apps:android:sha:create 1:350308179098:android:52fbbbd2d02639e47e5323 <UPLOAD_SHA256> --project=nutriview-943cd
   ```

#### B. Daftarkan Google Play App Signing Key ke Firebase (Setelah Upload Pertama ke Play Store):
1. Buka [Google Play Console](https://play.google.com/console) $\rightarrow$ Pilih `OopsieEats` $\rightarrow$ Menu **Setup (Konfigurasi)** $\rightarrow$ **App Integrity (Integritas Aplikasi)**.
2. Salin **SHA-1 certificate fingerprint** dan **SHA-256 certificate fingerprint** dari bagian *App signing key certificate*.
3. Daftarkan ke Firebase:
   ```bash
   firebase apps:android:sha:create 1:350308179098:android:52fbbbd2d02639e47e5323 <PLAY_SIGNING_SHA1> --project=nutriview-943cd
   firebase apps:android:sha:create 1:350308179098:android:52fbbbd2d02639e47e5323 <PLAY_SIGNING_SHA256> --project=nutriview-943cd
   ```

### 5. Konsistensi Klien OAuth 2.0
* **Android OAuth Client (OopsieEats):** `350308179098-md8oblv9248foinfud509k81l5q98gij.apps.googleusercontent.com` (Type 1 — Android Client, otomatis diaktifkan oleh Google Identity backend).
* **Web OAuth Client:** `350308179098-rj47kjc7qkab0loht39si2ek37qj7gku.apps.googleusercontent.com` (Type 3 — Web Client, konsisten di `auth_repository.dart` dan `google-services.json`).
* **Legacy Android OAuth Client:** `350308179098-b99q7a9vj8hksq9r7q835948fcl9r38v.apps.googleusercontent.com` (tetap aktif).

### 6. Dokumentasi Tindakan Pemilik pada Google Auth Platform Branding
* **Latar Belakang:** API resmi Google Cloud (`projects.brands`) sengaja tidak menyediakan method `PATCH`/`PUT` untuk memodifikasi identitas OAuth Consent Screen yang sudah aktif demi mencegah pembajakan nama brand pihak ketiga tanpa audit keamanan Google.
* **Tindakan Pemilik Akun (1-Click UI):**
  1. Kunjungi [Google Cloud Console > Google Auth Platform > Branding](https://console.cloud.google.com/auth/branding?project=nutriview-943cd).
  2. Klik **Edit App** pada bagian *App Information*.
  3. Ubah **App name** menjadi `OopsieEats`.
  4. Simpan perubahan.

---

## 4. Bagian C — Validasi Supabase Storage & Keamanan Data

### 1. Integritas Proyek & Bucket
* **Supabase Project Ref:** `rnfvudxqcwcwilcyicow`
* **Status Proyek:** `ACTIVE_HEALTHY`
* **Storage Bucket:** `food-history-images`
* **Visibilitas:** `public = false` (Privat — tidak dapat diakses tanpa Signed URL berbatas waktu).
* **Batas Ukuran:** Maksimal 5.242.880 bytes (5 MB).
* **Format File yang Diizinkan:** `image/jpeg`, `image/png`, `image/webp`.

### 2. Aturan Row Level Security (RLS) & Isolasi Folder
Akses storage diatur ketat melalui kebijakan RLS pada `storage.objects`:
1. **Verifikasi Kepemilikan User UID:** `(storage.foldername(name))[1] = auth.uid()::text` (Pengguna hanya dapat membaca/menulis ke folder dengan nama UID mereka sendiri).
2. **Validasi Regex Struktur Path:** `name ~ '^[a-f0-9\-]+/(profile|meal_[a-f0-9\-]+)/.*\.(jpg|jpeg|png)$'`
3. **Penyimpanan Foto Profil:** `$userId/profile/profile_avatar.jpg`
4. **Penyimpanan Foto Makanan:** `$userId/$mealId/food_*.jpg`

### 3. Bukti Pengujian Siklus Nyata (Live Probe Test)
Pengujian interaktif langsung melalui endpoint Supabase Storage membuktikan:
* Upload file probe $\rightarrow$ Berhasil (`HTTP 200`).
* Generate Signed URL (TTL 60 detik) $\rightarrow$ Berhasil menghasilkan URL dengan token HMAC.
* Download konten via Signed URL $\rightarrow$ Berhasil (`HTTP 200`).
* Akses langsung tanpa token tanda tangan $\rightarrow$ **Ditolak (`HTTP 404 NoSuchBucket/Object`)**.
* Upload file non-gambar (text/plain) $\rightarrow$ **Ditolak (`HTTP 415 InvalidMimeType`)**.
* Upload ke folder user lain tanpa hak $\rightarrow$ **Ditolak (`HTTP 403 AccessDenied`)**.
* Penghapusan probe $\rightarrow$ Berhasil dibersihkan (`HTTP 200`), verifikasi ulang menghasilkan `404`.

### 4. Verifikasi Nol Kunci Rahasia (Zero Service Role Key)
Pemeriksaan kode statis dan pemindaian regex pada seluruh direktori `frontend/lib/` dan `frontend/android/` membuktikan:
* **`service_role key`:** 0 ditemukan (Hanya komentar peringatan arsitektural di `supabase_config.dart` yang mengingatkan agar jangan pernah mengekspos kunci ini).
* Klien mobile hanya menggunakan `anonKey` (`sb_publishable_zkmZHcq6D4fTB1L9qvIvYw_izbuSHDj`) yang aman untuk didistribusikan.

---

## 5. Bagian D — Persiapan Android Release Build

### 1. Matriks Konfigurasi Build Android
Berdasarkan audit mendalam terhadap `frontend/android/app/build.gradle.kts` dan `frontend/pubspec.yaml`:

| Parameter Build | Nilai Terkonfigurasi | Status | Catatan Produksi |
| :--- | :--- | :--- | :--- |
| **Application ID** | `com.oopsieeats.app` | `VERIFIED` | Unik, konsisten dengan Firebase |
| **Namespace** | `com.oopsieeats.app` | `VERIFIED` | Konsisten dengan Kotlin package |
| **Version Code** | `2002` | `VERIFIED` | Integer naik dari `pubspec.yaml` (`1.0.0+2002`) |
| **Version Name** | `1.0.0` | `VERIFIED` | Semantic versioning untuk Play Store |
| **Compile SDK** | `flutter.compileSdkVersion` | `VERIFIED` | Android 14/15/16 ready |
| **Min SDK** | `24` (efektif via plugins) | `VERIFIED` | Mendukung 95%+ perangkat Android aktif |
| **Target SDK** | `flutter.targetSdkVersion` (36) | `VERIFIED` | Memenuhi syarat Google Play (min SDK 34/35) |
| **R8 / ProGuard Minify** | `isMinifyEnabled = true` | `VERIFIED` | Mengurangi ukuran APK dan mengaburkan kode |
| **Resource Shrinking** | `isShrinkResources = true` | `VERIFIED` | Menghapus resource grafis yang tidak terpakai |
| **TFLite Compression Guard** | `aaptOptions { noCompress("tflite") }` | `VERIFIED` | Wajib agar YOLO26n dapat di-memory map cepat |
| **Network Security Config** | `cleartextTrafficPermitted="false"` | `VERIFIED` | Wajib HTTPS, memblokir lalu lintas HTTP polos |
| **Backup Protection** | `android:allowBackup="false"` | `VERIFIED` | Mencegah ekstraksi database lokal via ADB |

### 2. Aturan ProGuard / R8 (`frontend/android/app/proguard-rules.pro`)
Aturan pengaburan kode telah dikonfigurasi secara spesifik agar tidak merusak library penting:
* **Flutter Core & Engine:** Dilindungi (`io.flutter.**`).
* **TensorFlow Lite Native Bindings:** Dilindungi (`org.tensorflow.lite.**`, `com.tflite.**`).
* **Firebase & Google Play Services:** Dilindungi (`com.google.firebase.**`).
* **Line Number & Exceptions:** Dipertahankan untuk Crashlytics stack trace deobfuscation.

### 3. Perintah Eksekusi Build Rilis Resmi
Gunakan perintah berikut di root folder `frontend/`:

```bash
# 1. Pastikan dependencies bersih
flutter clean
flutter pub get

# 2. Build Android App Bundle (.aab) untuk diunggah ke Google Play Console:
flutter build appbundle --release

# 3. Atau build Standalone APK release untuk pengujian mandiri di perangkat fisik:
flutter build apk --release
```
*Hasil artefak bundle:* `frontend/build/app/outputs/bundle/release/app-release.aab`  
*Hasil artefak APK:* `frontend/build/app/outputs/flutter-apk/app-release.apk`

---

## 6. Bagian E — Rencana Pengujian Komprehensif Perangkat Nyata (12-Point Real Device Test Plan)

> [!NOTE]
> Rangkaian 338 automated test telah memvalidasi logika unit, provider state, dan rendering widget simulasi. Namun, interaksi native OS (kamera fisik, dialog akun Google OS, sensor biometrik, hardware GPU TFLite, dan siklus suspensi Android) **WAJIB diuji pada perangkat fisik nyata** sebelum rilis publik.

Gunakan checklist 12-titik pengujian operasional ini:

### 1. Autentikasi Email & Kata Sandi (Email & Password Lifecycle)
* **Tindakan:** Lakukan registrasi akun baru dengan format email valid dan kata sandi $\ge 8$ karakter. Lalu logout dan lakukan login kembali.
* **Kriteria Keberhasilan:** Transisi animasi tombol neobrutalist responsif, validasi field mencegah input kosong/invalid, session token tersimpan di secure storage, dan pengguna langsung diarahkan ke Dashboard.

### 2. Google Sign-In dengan Akun Google Fisik (Native Google Identity Flow)
* **Tindakan:** Tekan tombol "Lanjutkan dengan Google" di Login Screen pada perangkat fisik dengan akun Google aktif.
* **Kriteria Keberhasilan:** Dialog Google Account Picker native OS muncul, setelah akun dipilih token OAuth ditukarkan ke Firebase Auth tanpa error `10: DEVELOPER_ERROR`, dan nama/email/avatar terisi otomatis.

### 3. Siklus Logout & Re-Login (Session Cleanliness)
* **Tindakan:** Buka tab Profil, tekan tombol Logout, konfirmasi dialog. Lalu coba login kembali.
* **Kriteria Keberhasilan:** Seluruh token sesi lokal, kredensial secure storage, dan state in-memory terhapus bersih. Layar kembali ke Login tanpa meninggalkan data pengguna sebelumnya (no stale data).

### 4. Pembaruan Biodata & Sinkronisasi Nutrisi (BMR/TDEE Calculation)
* **Tindakan:** Buka menu Biodata pada Profil, ubah Berat Badan (kg), Tinggi Badan (cm), dan Tingkat Aktivitas Fisik. Simpan formulir.
* **Kriteria Keberhasilan:** Nilai BMR dan TDEE dihitung ulang secara deterministik, target kalori harian pada Daily Calorie Hero Card di Dashboard langsung terbarui secara real-time.

### 5. Upload & Tampilan Foto Profil (Profile Photo Pipeline)
* **Tindakan:** Buka dialog ubah foto profil, pilih sumber dari Kamera atau Galeri perangkat, lakukan crop 1:1, dan simpan.
* **Kriteria Keberhasilan:** Gambar dikompresi di bawah 5 MB, diunggah ke Supabase Storage pada path `$userId/profile/*`, avatar di pojok kanan atas Dashboard dan tab Profil langsung menampilkan foto baru menggunakan Signed URL yang valid.

### 6. Upload & Tampilan Foto Riwayat Makanan (Meal Photo Pipeline)
* **Tindakan:** Ambil foto makanan menggunakan kamera aplikasi, konfirmasi hasil deteksi, input porsi dalam gram, dan simpan log makanan.
* **Kriteria Keberhasilan:** Foto makanan tersimpan di Supabase path `$userId/$mealId/food_*.jpg`, metadata makanan tersimpan di Firestore, dan kartu riwayat makanan menampilkan foto makanan yang baru saja diambil.

### 7. Validasi Expired Signed URL & Auto-Refresh (Signed URL Resiliency)
* **Tindakan:** Biarkan aplikasi berjalan atau buka kembali setelah masa berlaku token signed URL (TTL 1 jam) terlewati.
* **Kriteria Keberhasilan:** Service storage secara otomatis meminta Signed URL baru ke backend Supabase tanpa menampilkan gambar rusak (broken image placeholder) atau menyebabkan crash.

### 8. Uji Isolasi Akun & Data (Multi-User Security Isolation)
* **Tindakan:** Login sebagai Pengguna A, catat riwayat makanan dan foto profil. Logout, lalu login sebagai Pengguna B.
* **Kriteria Keberhasilan:** Pengguna B sama sekali tidak dapat melihat, memodifikasi, atau memuat foto makanan maupun data profil milik Pengguna A.

### 9. Siklus Hidup Onboarding Pengguna Pertama (FTUE Lifecycle)
* **Tindakan:** Hapus data aplikasi (*Clear Storage*) atau install APK rilis pada perangkat baru. Selesaikan carousel onboarding 3 slide. Tutup dan buka kembali aplikasi.
* **Kriteria Keberhasilan:** Carousel onboarding muncul tepat satu kali pada peluncuran pertama. Pada pembukaan aplikasi berikutnya, onboarding dilewati secara permanen dan langsung menampilkan Splash $\rightarrow$ Dashboard / Login.

### 10. Food Scanner YOLO26n Mode Offline (Local AI Inference)
* **Tindakan:** Aktifkan **Mode Pesawat (Airplane Mode)** pada perangkat (matikan seluruh Wi-Fi dan data seluler). Buka fitur pemindai kamera dan arahkan ke objek makanan.
* **Kriteria Keberhasilan:** Model YOLO26n TFLite melakukan inferensi secara 100% offline pada CPU/GPU perangkat dengan latensi $<200$ ms, bounding box dan label deteksi makanan tetap muncul dengan presisi tanpa membutuhkan koneksi internet.

### 11. Terminasi Aplikasi & Cold Restart (App Kill State Persistence)
* **Tindakan:** Saat berada di Dashboard, lakukan force kill aplikasi melalui Android Recent Apps. Buka kembali aplikasi dari app drawer.
* **Kriteria Keberhasilan:** Aplikasi melakukan cold boot melalui Splash Screen tanpa crash, memulihkan sesi autentikasi dari secure storage, dan langsung masuk ke Dashboard tanpa meminta kredensial ulang.

### 12. Mode Offline & Pemulihan Jaringan (Network Resiliency & Reconnect)
* **Tindakan:** Matikan koneksi internet saat bernavigasi di dalam aplikasi (buka riwayat makanan atau artikel). Nyalakan kembali koneksi internet.
* **Kriteria Keberhasilan:** Aplikasi menampilkan feedback error visual neobrutalist yang elegan dan ramah pengguna (tidak blank/crash), dan data langsung tersinkronisasi otomatis saat koneksi internet pulih.

---

## 7. Bagian F — Matriks Risiko Teknis & Tindakan Pemilik (Action Items)

| Item Pekerjaan | Pelaksana | Status | Risiko Teknis Jika Dilewati |
| :--- | :--- | :--- | :--- |
| **Pembuatan Upload Keystore** | Pemilik Proyek | `PENDING` | Tidak dapat menghasilkan binary produksi tertandatangani untuk Play Store |
| **Registrasi Upload SHA ke Firebase** | Pemilik Proyek | `PENDING` | Build release mandiri (non-Play Store) akan gagal saat Google Sign-In |
| **Registrasi Play App Signing SHA ke Firebase** | Pemilik Proyek | `PENDING (Post-Upload)` | **CRITICAL:** Pengguna Play Store akan mengalami error saat login dengan Google |
| **Google Auth Platform Branding** | Pemilik Proyek | `PENDING (GCP UI)` | Layar izin web OAuth browser masih menampilkan nama lama |
| **Pengujian Perangkat Nyata (12-Point)** | QA / Pemilik | `PENDING` | Risiko crash pada varian Android tertentu atau masalah izin kamera fisik |
| **Privacy Policy URL di Play Console** | Pemilik Proyek | `PENDING` | Penolakan aplikasi oleh tim review Google Play Store |
| **Account Deletion Flow** | Telah Tersedia di Kode | `VERIFIED` | Memenuhi syarat kepatuhan Google Play Data Safety |

---

## 8. Kesimpulan & Rekomendasi Selanjutnya

Proyek **OopsieEats** kini telah memiliki arsitektur yang kokoh, terstandarisasi, dan bersih dari sisa-sisa migrasi identitas NutriView. Kode sumber telah melewati seluruh gerbang mutu analitik dan pengujian otomatis tanpa satupun error.

**Langkah Lanjutan:**
1. Pemilik proyek membuat upload keystore menggunakan panduan di Bagian A.
2. Pemilik proyek mendaftarkan SHA-1 dan SHA-256 release ke Firebase.
3. Jalankan `flutter build appbundle --release`.
4. Unggah file `.aab` ke Google Play Console (Internal Testing Track).
5. Salin SHA-1 Google Play App Signing dan daftarkan ke Firebase.
6. Lakukan pengujian langsung pada perangkat fisik menggunakan panduan di Bagian E.
