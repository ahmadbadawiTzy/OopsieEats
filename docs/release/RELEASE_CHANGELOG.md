# Changelog Rilis Produksi — OopsieEats (NutriView)

Seluruh perubahan teknis, pengerasan keamanan (*security hardening*), penyelarasan kebijakan Google Play 2026, dan optimasi performa didokumentasikan di bawah ini.

---

## [1.0.0+2002] — 13 November 2026

### 🛡️ Security Hardening & Google Play Policy Compliance
- **Target SDK 36 (Android 16):** Menegaskan `compileSdk = maxOf(flutter.compileSdkVersion, 36)` dan `targetSdk = maxOf(flutter.targetSdkVersion, 36)` di `frontend/android/app/build.gradle.kts`.
- **Penghapusan Izin Transitif Warisan:** Mengeliminasi izin `READ_PHONE_STATE`, `WRITE_EXTERNAL_STORAGE`, dan `READ_EXTERNAL_STORAGE` yang diinjeksikan secara otomatis oleh pustaka transitif GPU LiteRT melalui deklarasi `tools:node="remove"` di `AndroidManifest.xml`.
- **Kompatibilitas 16 KB Memory Page Size:** Mengatur `useLegacyPackaging = false` pada `packaging.jniLibs` dan memverifikasi alignment segmen `LOAD` >= `0x4000` (16 KB) pada seluruh pustaka `.so` 64-bit (`arm64-v8a` dan `x86_64`).
- **Penegakan Tanda Tangan Rilis (Fail-Fast):** Menambahkan hook Gradle `gradle.taskGraph.whenReady` pada `build.gradle.kts` untuk menghentikan build jika `key.properties` atau berkas keystore `.jks` tidak valid, mencegah fallback ke kunci debug.
- **Validasi Unggahan Supabase Storage:**
  - Menambahkan validasi byte kosong (0 byte) dan batas muatan mentah 20 MB (*anti-OOM DoS protection*).
  - Menegaskan batas pasca-kompresi 5 MB (`SupabaseConfig.maxUploadSizeBytes`).
  - Mengisolasi folder penyimpanan foto per UID pengguna (`userId/`) dengan validasi anti-path traversal.
- **Halaman Legal Publik (Web):**
  - Memutakhirkan `public/privacy.html` dengan rincian pemrosesan AI *on-device* vs penyimpanan foto riwayat privat.
  - Memvalidasi alur penghapusan akun mandiri di `public/delete-account.html` dan in-app via `AuthRepository.deleteAccount`.

### 🔄 State Synchronization & Core Bug Fixes
- **Sinkronisasi Dinamis Biodata ke Beranda:** Menghubungkan callback `profileProvider.onProfileUpdated` di `main.dart` untuk memanggil `dashboardRepository.invalidateUserCache()` dan `dashboardProvider.updateTargetFromBiodata()`. Target kalori harian BMR/TDEE di Beranda kini langsung terhitung ulang saat biodata diperbarui tanpa perlu restart aplikasi atau mengalami race condition.
- **Pembersihan Cache Komprehensif Saat Logout:** Memperbarui callback `authProvider.onLogout` di `main.dart` untuk membersihkan seluruh data profil, dashboard, katalog pangan, artikel, dan cache URL foto Supabase.

### 🎨 Visual & Store Presence
- **Neo-Brutalism Onboarding Experience:** Mengintegrasikan 3 slide onboarding carousel dengan stiker visual teroptimasi, kartu informasi nutrisi, dan animasi transisi 60 FPS.
- **Google Play Feature Graphic (1024x500):** Menghasilkan aset grafis banner promosi resmi `docs/play_store_assets/final/feature_graphic_1024x500.png` bergaya Neo-Brutalism beresolusi 1024x500 px.
- **Phone Screenshots (1080x1920):** Memverifikasi 6 tangkapan layar perangkat fisik Android resmi pada direktori `docs/play_store_assets/final/`.

### 🧪 Automated Testing & Release Automation
- **Ekspansi Test Suite:** Menambah cakupan pengujian menjadi 359 tests (100% lulus), mencakup pengujian sinkronisasi biodata-beranda, proteksi batas memori storage, dan konfigurasi signing.
- **Skrip Validasi 12-Tahap:** Menghadirkan skrip otomatis `scripts/validate_release.sh` yang menjalankan 22 titik pemeriksaan kesiapan rilis.
- **Build AAB Final:** Menghasilkan Android App Bundle terobfuskasi `frontend/build/app/outputs/bundle/release/app-release.aab` (91.1 MB) ditandatangani dengan upload certificate produksi.
