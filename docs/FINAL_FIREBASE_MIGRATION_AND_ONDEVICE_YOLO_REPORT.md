# LAPORAN AKHIR: AUDIT LENGKAP PEMBERSIHAN FIREBASE STORAGE, INTEGRASI CMS GAMBAR EKSTERNAL, & VERIFIKASI AKHIR NUTRIVIEW

**Proyek:** NutriView  
**Status Selesai:** 100% Terverifikasi Teknis (47/47 Unit & Widget Tests Lulus, Flutter Analyze Bersih, Debug APK Berhasil, Zero Storage Dependency)  
**Tanggal Verifikasi:** 24 Oktober 2026  
**Tier Firebase:** Spark Tier Murni (Bebas Biaya $0/bulan, Tanpa Billing / Tanpa Blaze)  

---

## 1. RINGKASAN AUDIT PENGHAPUSAN FIREBASE CLOUD STORAGE

Menanggapi kebijakan Firebase yang mewajibkan upgrade ke paket Blaze untuk pembuatan bucket Cloud Storage baru, NutriView telah diaudit dan disesuaikan sehingga **100% independen dari Firebase Cloud Storage**:
1. **0 Ketergantungan Cloud Storage:**
   - Paket `firebase_storage` telah dihapus sepenuhnya dari `frontend/pubspec.yaml` dan `frontend/pubspec.lock`.
   - Tidak ada lagi import atau penggunaan `FirebaseStorage` di seluruh direktori `frontend/lib/` maupun `frontend/test/`.
2. **Konfigurasi Firebase Minimal (`firebase.json`):**
   - Bagian `"storage"` telah dihapus dari `firebase.json`.
   - File `storage.rules` telah dihapus dari repositori.
   - Hanya konfigurasi aktif (`firestore` dan `emulators`) yang dipertahankan.
   - Verifikasi dry-run `firebase deploy --only firestore:rules --dry-run` menghasilkan **Exit Code 0 (Sukses)**.
3. **Model Bisnis & Biaya:**
   - Aplikasi beroperasi murni pada **Firebase Spark Plan ($0 / No Cost)**.
   - Tidak memerlukan billing account, kartu kredit, atau upgrade ke Blaze plan.

---

## 2. AUDIT & PENYELARASAN FITUR CMS ARTIKEL

Seluruh fungsionalitas artikel edukasi gizi tetap berjalan normal dengan dukungan citra berbasis URL web eksternal:

### A. Form Input & Validasi Artikel Admin (`admin_dashboard_screen.dart`):
- Ditambahkan input field khusus `URL GAMBAR SAMPUL (OPSIONAL)` pada bottom sheet form artikel.
- **Validasi URL:** Sistem memverifikasi bahwa URL gambar yang dimasukkan diawali dengan protokol `http://` atau `https://`. Jika tidak valid, form menolak simpan dengan pesan edukatif.
- **Live Preview:** Jika URL diisi, form menampilkan pratinjau langsung gambar dengan batas kontainer Neubrutalism.
- **Penanganan URL Rusak/Gagal:** Dilengkapi `errorBuilder` yang menampilkan placeholder *"URL gambar tidak dapat dimuat"* tanpa menyebabkan aplikasi crash.

### B. Tampilan Artikel di Sisi Pengguna:
- **Detail Artikel (`article_detail_screen.dart`):**
  - Menampilkan banner gambar sampul di bagian atas kartu konten jika `coverImageUrl` tersedia.
  - Dilengkapi `errorBuilder` fallback elegan ke ikon `image_not_supported_outlined` jika gambar offline atau link mati.
  - Dilengkapi `loadingBuilder` dengan animasi progres indikator saat citra dimuat dari jaringan.
- **Daftar Artikel di Dashboard (`dashboard_screen.dart`):**
  - Menampilkan thumbnail citra di sisi kiri kartu artikel.
  - Jika `coverImageUrl` null/kosong atau gagal dimuat, sistem otomatis fallback ke ikon default `menu_book_rounded`.

---

## 3. AUDIT DATA PRODUKSI (FIRESTORE `cms_articles`)

Pemeriksaan faktual terhadap data produksi live project `nutriview-943cd` dilakukan melalui Firestore REST API:
- **Dokumen yang Ditemukan:** `projects/nutriview-943cd/databases/(default)/documents/cms_articles/1`
- **Field Data:**
  - `id`: `1`
  - `title`: `"Panduan Pola Makan Bergizi Seimbang"`
  - `slug`: `"panduan-gizi-seimbang"`
  - `status`: `"published"`
  - `author_name`: `"Tim Gizi NutriView"`
  - `content`: `"Pola makan bergizi seimbang mencakup karbohidrat kompleks..."`
- **Temuan Faktual:** **Tidak ada dokumen artikel lama yang menggunakan path Firebase Storage (`gs://...` atau `firebasestorage.googleapis.com`)**.
- **Kesimpulan Migrasi:** **Tidak diperlukan migrasi data atau pembersihan URL pada Firestore produksi**.

---

## 4. VERIFIKASI KEAMANAN & FITUR UTAMA

1. **Firebase Authentication:**
   - Login & Registrasi Email/Password aktif pada project `nutriview-943cd`.
   - Sesi login tersimpan aman di `FlutterSecureStorage`.
2. **Cloud Firestore:**
   - Aturan keamanan `firestore.rules` aktif terpasang via Firebase CLI (`✔ firestore: released rules firestore.rules to cloud.firestore`).
   - Anti-Eskalasi Role: Aturan baris 48-58 memblokir pendaftaran akun dengan role selain `'user'` dan melarang pengguna biasa mengubah status role secara mandiri.
3. **On-Device YOLO26n ML:**
   - Model TFLite `best.tflite` (9.8 MB) dan `classes.txt` terpasang di aset Flutter dan terverifikasi terkompilasi ke dalam binary APK.
   - Inferensi berjalan 100% offline di CPU/GPU perangkat tanpa memerlukan koneksi internet atau server backend.

---

## 5. HASIL VERIFIKASI TERMINAL RESMI

| Perintah | Exit Code | Hasil Faktual |
|---|---|---|
| `flutter pub get` | `0` | Berhasil menghapus dependensi `firebase_storage`, `firebase_storage_web`, `firebase_storage_platform_interface`. |
| `flutter analyze` | `0` | **No issues found! (ran in 3.2s)** |
| `flutter test` | `0` | **00:03 +47: All tests passed! (47/47 tes lulus 100%)** |
| `flutter build apk --debug` | `0` | **✓ Built build/app/outputs/flutter-apk/app-debug.apk** (46.0s) |
| `firebase deploy --only firestore:rules --dry-run` | `0` | **✔ cloud.firestore: rules compiled successfully. Dry run complete!** |

---

## 6. DAFTAR FILE YANG DIUBAH PADA TAHAP INI

1. `frontend/pubspec.yaml`: Menghapus dependensi `firebase_storage: ^14.0.1`.
2. `frontend/pubspec.lock`: Diperbarui via `flutter pub get` (menghapus seluruh package storage).
3. `firebase.json`: Menghapus target deployment storage dan emulator storage.
4. `storage.rules`: Dihapus dari repositori karena tidak lagi digunakan.
5. `frontend/lib/features/admin/data/admin_repository.dart`: Menghapus import `firebase_storage` dan menyesuaikan `uploadMedia` menggunakan URL/Firestore.
6. `frontend/lib/features/admin/presentation/screens/admin_dashboard_screen.dart`: Menambahkan input `coverImageUrl` dengan validasi http/https dan live preview.
7. `frontend/lib/features/article/screens/article_detail_screen.dart`: Menambahkan rendering banner cover image dengan fallback error.
8. `frontend/lib/features/dashboard/screens/dashboard_screen.dart`: Menambahkan thumbnail cover image pada kartu artikel.
9. `frontend/test/article_repository_test.dart`: Menambahkan pengujian deserialisasi `cover_image_url` dan penanganan nilai null.
10. `docs/FINAL_FIREBASE_MIGRATION_AND_ONDEVICE_YOLO_REPORT.md`: Laporan akhir diperbarui.

---

## 7. STATUS RISIKO TERSISA & BATASAN

- **Aset Gambar Media CMS:** Karena Cloud Storage dinonaktifkan untuk menjaga Spark Plan $0, administrator yang ingin menyertakan gambar pada artikel disarankan menggunakan URL citra publik (misalnya dari Unsplash, Pexels, Imgur, atau link hosting web eksternal).
- **Kuota Spark Plan:** Penggunaan Cloud Firestore tetap dibatasi oleh kuota gratis harian Google (50.000 read/hari, 20.000 write/hari), yang sangat memadai untuk kebutuhan aplikasi NutriView tanpa risiko tagihan mendadak.
