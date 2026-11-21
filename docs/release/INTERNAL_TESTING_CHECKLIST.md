# Checklist Pengujian Internal Testing — OopsieEats (NutriView)

**Tujuan Dokumen:** Memastikan seluruh alur kritis, integritas data, dan kompatibilitas sistem berjalan sempurna saat aplikasi diuji melalui jalur **Internal Testing** Google Play Store sebelum dipromosikan ke Closed Testing atau Production.

---

## 1. Persiapan Pra-Pengujian

- [ ] Unduh aplikasi dari tautan Internal Testing Google Play Store (*Join on Android*).
- [ ] Pastikan versi yang terpasang adalah `1.0.0 (2002)`.
- [ ] Pastikan sidik jari SHA-1 dan SHA-256 milik *Google Play App Signing Key* sudah ditambahkan ke Firebase Console (`nutriview-943cd`).

---

## 2. Checklist Pengujian Fitur Kritis

| No | Skenario Pengujian | Langkah Aksi | Kriteria Keberhasilan / Verifikasi | Status |
| :---: | :--- | :--- | :--- | :---: |
| **01** | **Instalasi via Play Store** | Pasang aplikasi dari link opt-in Internal Testing. | Aplikasi terpasang lancar, icon Neo-Brutalist OopsieEats muncul di launcher. | [ ] |
| **02** | **Onboarding Carousel** | Buka aplikasi pertama kali, geser 3 slide onboarding, uji tombol lewati & tombol mulai. | Animasi berjalan 60 FPS, tidak ada glitch visual, navigasi mengarah ke Login / Register. | [ ] |
| **03** | **Registrasi Akun Baru** | Buat akun baru dengan email & password valid di layar Register. | Akun terdaftar di Firebase Auth, navigasi otomatis mengarah ke form Lengkapi Biodata. | [ ] |
| **04** | **Lengkapi Biodata Awal** | Isi formulir biodata (jenis kelamin, tanggal lahir, TB, BB, aktivitas fisik, tujuan). | Target kalori harian BMR/TDEE terhitung otomatis; navigasi masuk ke Beranda utama. | [ ] |
| **05** | **Google Sign-In** | Buka aplikasi di perangkat lain / log out, lalu tap tombol *Masuk dengan Google*. | Dialog Google Account Picker muncul, otentikasi berhasil tanpa error `ApiException: 10`. | [ ] |
| **06** | **Izin Kamera (Runtime)** | Buka tab Scan untuk pertama kali. | Dialog izin kamera Android muncul; aplikasi meminta izin kamera dengan sopan dan menangani status *Granted* maupun *Denied*. | [ ] |
| **07** | **Pemindai Makanan (AI Inference)** | Arahkan kamera ke makanan (misal: nasi, ayam, telur) atau pilih dari galeri. | Model TFLite mendeteksi bounding box & label makanan on-device dalam waktu < 300 ms tanpa freeze UI. | [ ] |
| **08** | **Input Porsi & Simpan Riwayat** | Masukkan porsi makanan dalam gram (misal: 150g), lalu tap Simpan ke Riwayat. | Nilai kalori dan makronutrien terhitung sesuai TKPI; item tersimpan ke Firestore `users/{uid}/meals`. | [ ] |
| **09** | **Sinkronisasi Unggah Supabase** | Periksa item makan yang baru disimpan pada riwayat. | Foto makanan terkompresi (< 5 MB) berhasil terunggah ke bucket privat Supabase dan tampil via Signed URL. | [ ] |
| **10** | **Pembaruan Ringkasan Kalori Beranda** | Kembali ke Beranda utama setelah menyimpan makanan. | Kalori yang dikonsumsi bertambah, sisa kalori berkurang secara akurat tanpa perlu restart aplikasi. | [ ] |
| **11** | **Pembaruan Biodata Real-Time** | Buka Profil → Kelola Biodata, ubah berat badan (misal dari 70 kg ke 65 kg), simpan, lalu kembali ke Beranda. | Target kalori harian di Beranda langsung diperbarui secara dinamis (recalculated) tanpa data basi (*no stale data*). | [ ] |
| **12** | **Unggah & Ganti Foto Profil** | Buka Profil → tap avatar → pilih foto dari galeri. | Foto profil terpotong proporsional, terkompresi, terunggah ke Supabase, dan avatar profil langsung terupdate. | [ ] |
| **13** | **Keamanan Biometrik** | Aktifkan Kunci Biometrik di Pengaturan Profil, minimize aplikasi, lalu buka kembali. | Prompt biometrik Android (sidik jari / wajah) muncul dan membuka kunci sesi dengan mulus. | [ ] |
| **14** | **Offline & Reconnect Behavior** | Aktifkan Airplane Mode, buka aplikasi, jelajahi Beranda dan Riwayat Makan. Nonaktifkan Airplane Mode. | Data lokal dari cache Firestore/SharedPreferences tetap tampil tanpa crash (*graceful offline*); sinkronisasi pulih saat internet aktif kembali. | [ ] |
| **15** | **App Restart & Data Persistence** | Tutup paksa aplikasi (Kill task), lalu buka kembali dari launcher. | Sesi login tetap aktif, data kalori hari ini dan preferensi pengguna tetap tersimpan utuh. | [ ] |
| **16** | **Logout Akun** | Buka Profil → tap Keluar / Logout. | Seluruh cache lokal, dashboard provider, dan Supabase URL cache dibersihkan; navigasi kembali ke layar Login. | [ ] |
| **17** | **Penghapusan Akun Permanen (In-App)** | Menggunakan akun uji coba, buka Profil → Hapus Akun & Data → konfirmasi password. | Dokumen Firestore `users/{uid}`, subkoleksi `meals`, file foto Supabase, kredensial Auth, dan storage lokal terhapus permanen; kembali ke Login. | [ ] |
| **18** | **Verifikasi Bebas Crash (Android Vitals)** | Pantau Play Console → Android Vitals selama pengujian. | Crash rate = 0%, ANR rate = 0%. | [ ] |

---

## 3. Catatan Pengujian Tambahan
- Jika Google Sign-In gagal dengan kode 10: Periksa apakah SHA-1 Play App Signing sudah didaftarkan di Firebase Console.
- Jika foto gagal diunggah: Periksa koneksi internet dan pastikan ukuran berkas awal tidak melebihi 20 MB.
