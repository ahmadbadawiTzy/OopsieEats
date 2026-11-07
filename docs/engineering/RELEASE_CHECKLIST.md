# GOOGLE PLAY PRODUCTION RELEASE CHECKLIST — NUTRIVIEW

Checklist ini merupakan panduan operasional langkah-demi-langkah bagi pengembang dan tim rilis untuk mengajukan **NutriView** ke Google Play Store secara sukses dan tanpa hambatan penolakan (zero rejection).

---

## FASE 1: PRA-SYARAT TEKNIS & VALIDASI KODE (SELESAI & TERVERIFIKASI)

- [x] **Static Code Analysis**: Jalankan `flutter analyze` dari `frontend/` (Hasil: `0 errors, 0 warnings, 0 lints`).
- [x] **Automated Test Suite**: Jalankan `flutter test` dari `frontend/` (Hasil: `256/256 passed` dalam 33 detik).
- [x] **Target SDK Level**: Ditetapkan pada **API 36** (Memenuhi syarat Google Play >= API 34).
- [x] **Min SDK Level**: Ditetapkan pada **API 23** (Android 6.0 Marshmallow).
- [x] **Hardening AndroidManifest**:
  - `android:allowBackup="false"` telah terpasang.
  - `android:networkSecurityConfig="@xml/network_security_config"` telah terpasang.
- [x] **Network Security Configuration**: `network_security_config.xml` mewajibkan komunikasi HTTPS dan menolak cleartext HTTP.
- [x] **Account Deletion Flow**: Fitur in-app delete account teruji di `ProfileScreen` dengan cascading delete di Firestore dan Firebase Auth.
- [x] **R8 & Resource Shrinking**: `isMinifyEnabled = true` dan `isShrinkResources = true` aktif dengan keep rules `proguard-rules.pro`.
- [x] **TFLite Zero-Copy Mmap**: `aaptOptions { noCompress("tflite") }` terpasang di `build.gradle.kts`.

---

## FASE 2: KONFIGURASI SIGNING RELEASE (TINDAKAN PENGEMBANG)

Sebelum membuat build rilis final untuk Play Store, siapkan keystore produksi resmi:

1. Buat keystore produksi (jika belum ada):
   ```bash
   keytool -genkey -v -keystore nutriview-release-key.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias nutriview-key
   ```
2. Buat file `frontend/android/key.properties` (jangan di-commit ke Git):
   ```properties
   storePassword=RAHASIA_KEYSTORE_PASSWORD
   keyPassword=RAHASIA_KEY_PASSWORD
   keyAlias=nutriview-key
   storeFile=../nutriview-release-key.jks
   ```
3. Bangun Android App Bundle (`.aab`):
   ```bash
   cd frontend
   flutter build appbundle --release
   ```
   *Output berada di*: `frontend/build/app/outputs/bundle/release/app-release.aab`.

---

## FASE 3: GOOGLE PLAY CONSOLE — TUGAS ADMINISTRATIF

Masuk ke [Google Play Console](https://play.google.com/console) dan selesaikan bagian berikut:

### 1. Kebijakan Aplikasi & Konten (App Content)
- [ ] **Kebijakan Privasi (Privacy Policy)**:
  - Masukkan tautan URL Privacy Policy publik (misal: halaman GitHub Pages atau dokumentasi web).
- [ ] **Akses Aplikasi (App Access)**:
  - Berikan akun pengujian (*demo credentials*) untuk reviewer Google:
    - *Email Pengujian*: `demo.tester@nutriview.app`
    - *Password*: (Kredensial akun penguji yang telah didaftarkan di Firebase Auth)
    - *Catatan untuk Reviewer*: Jelaskan bahwa aplikasi memerlukan login untuk menyimpan riwayat gizi, dan fitur kamera hanya memproses makanan secara lokal di perangkat.
- [ ] **Iklan (Ads Declaration)**:
  - Pilih: *"Tidak, aplikasi saya tidak berisi iklan"*.
- [ ] **Target Audiens & Konten (Target Audience)**:
  - Pilih rentang usia: **13 tahun ke atas**.
  - Konfirmasi bahwa aplikasi **TIDAK** dirancang khusus untuk anak-anak (*Not primarily directed to children*).
- [ ] **Aplikasi Berita (News Apps)**:
  - Pilih: *"Tidak, aplikasi ini bukan aplikasi berita"*.
- [ ] **Fitur Pelacakan Kontak COVID-19**:
  - Pilih: *"Tidak, aplikasi ini bukan aplikasi pelacak kontak COVID-19"*.
- [ ] **Keamanan Data (Data Safety Form)**:
  - Isi sesuai panduan pada tabel Section 4A di `docs/engineering/GOOGLE_PLAY_READINESS_AUDIT.md`:
    - Mengumpulkan Nama dan Email (untuk fungsi akun).
    - Mengumpulkan data nutrisi & makanan (Health & Fitness).
    - **Foto Kamera: TIDAK DIKUMPULKAN / TIDAK DIUNGGAH** (Ephemerally processed on-device).
    - Mendukung penghapusan data pengguna.
- [ ] **Penghapusan Akun (Account Deletion Requirement)**:
  - Berikan URL web permohonan hapus akun (misal: formulir Google Form / halaman GitHub issues/support) dan jelaskan bahwa tombol in-app deletion tersedia di menu Profil.
- [ ] **Izin Finansial & Pinjaman**:
  - Pilih: *"Tidak ada fitur finansial"*.

### 2. Rating Konten (Content Rating)
- [ ] Isi kuesioner rating IARC (International Age Rating Coalition).
  - Kategori: *Utility, Productivity, Communication, or Other*.
  - Jawab pertanyaan tentang kekerasan, pornografi, bahasa kasar: **Tidak ada**.
  - Dapatkan sertifikat rating (umumnya rated **PEGI 3** / **Everyone**).

### 3. Listing Google Play Store (Main Store Listing)
- [ ] **Nama Aplikasi**: `NutriView - Pemindai Gizi & Makanan`
- [ ] **Deskripsi Singkat (Short Description)** (Maks 80 karakter):
  `Kenali makanan dan hitung nutrisi harianmu secara instan dengan AI on-device.`
- [ ] **Deskripsi Lengkap (Full Description)**:
  (Gunakan deskripsi yang menggarisbawahi privasi pemindaian offline, data TKPI Indonesia, dan fitur pelacak gizi).
- [ ] **Aset Grafis**:
  - [ ] App Icon (512x512 PNG 32-bit).
  - [ ] Feature Graphic (1024x500 JPG/PNG).
  - [ ] Screenshot Ponsel (Minimal 4 screenshot, rasio 16:9 atau 9:16).

---

## FASE 4: STRATEGI PELUNCURAN & TRACK DISTRIBUSI

1. **Track 1: Internal Testing**:
   - Unggah build pertama `.aab` ke **Internal Testing**.
   - Unduh via link Play Store internal pada perangkat fisik Android untuk memverifikasi login Google, Firebase Auth, dan pemindai kamera berfungsi di lingkungan rilis.
2. **Track 2: Closed Testing (Jika akun developer pribadi/baru didaftarkan)**:
   - Jalankan closed testing dengan 20 tester selama 14 hari berturut-turut sesuai ketentuan akun personal Google Play 2023+.
3. **Track 3: Production Rollout**:
   - Terapkan **Staged Rollout** bertahap:
     - Hari 1: 10% pengguna.
     - Hari 3: 25% pengguna (pantau crash rate di Google Play Console).
     - Hari 5: 50% pengguna.
     - Hari 7: 100% rilis penuh jika Crash Rate < 1.09% (standar Android Vitals Google Play).

---

## FASE 5: MONITORING PASCA-PELUNCURAN

- [ ] Pantau **Android Vitals** di Play Console:
  - User-perceived Crash Rate (Target: < 0.20%).
  - User-perceived ANR Rate (Target: < 0.20%).
- [ ] Pantau kuota baca Firestore di Firebase Console.
