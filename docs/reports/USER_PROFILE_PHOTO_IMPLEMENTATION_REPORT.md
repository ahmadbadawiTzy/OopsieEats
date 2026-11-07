# NutriView Real User Profile Photo Implementation Report

**Tanggal:** 7 November 2026  
**Status:** IMPLEMENTED, TESTED & VERIFIED  
**Engineer Roles:** Senior Flutter Engineer, UI/UX Engineer, Supabase Storage Specialist, Mobile Application Security Engineer  

---

## 1. Ringkasan Eksekutif

Sistem foto profil pengguna pada NutriView telah diperbarui secara menyeluruh:
1. **Penghapusan Avatar Karakter Game & Placeholder Generik:**
   Avatar ilustrasi kartun bawaan (`chef_pro`, `runner_ace`, dll.) tidak lagi digunakan sebagai foto profil pengguna.
2. **Sistem Foto Profil Asli (Real User Photos):**
   Pengguna dapat mengambil foto langsung menggunakan kamera perangkat (`ImageSource.camera`) atau memilih foto dari galeri (`ImageSource.gallery`).
3. **Modal Pratinjau & Validasi Sebelum Simpan:**
   Setiap foto yang dipilih menampilkan dialog preview persegi 1:1 terlebih dahulu dengan validasi ukuran maksimum (5 MB) dan format gambar. Upload hanya dipicu setelah pengguna menekan "Simpan Foto".
4. **Isolate-Backed Image Preprocessing & Supabase Storage:**
   Foto diproses di latar belakang menggunakan `Isolate.run`:
   - Rotasi EXIF dinormalisasi (`bakeOrientation`).
   - Center crop persegi 1:1 tanpa distorsi aspek rasio.
   - Resize proporsional ke dimensi maksimum 512x512 piksel.
   - Kompresi JPEG efisien dengan kualitas 85%.
   - File diunggah ke Supabase Storage pada path terisolasi: `{userId}/profile/profile_{timestamp}.jpg`.
5. **Persistensi Data Multi-Tenant & Signed URLs:**
   - Path permanen (`photo_path`) dan URL bertanda tangan (`photo_url`) disimpan ke dokumen Cloud Firestore `users/{uid}`.
   - Saat pembaruan foto, file lama di Supabase Storage otomatis dibersihkan (lifecycle cleanup).
6. **Fallback Inisial Nama Controlled Neo-Brutalism:**
   Ketika belum ada foto atau setelah foto dihapus, sistem otomatis menampilkan inisial 1–2 huruf kapital nama pengguna (misal: "AB" untuk Ahmad Badawi, "B" untuk Budi) di atas palet warna dinamis Neo-Brutalism dengan border hitam pekat 2px dan bayangan offset keras tanpa blur.
7. **Sinkronisasi Reaktif Lintas Halaman:**
   Pembaruan foto profil langsung tersinkronisasi di `ProfileProvider` dan `AuthProvider`, memperbarui header Dashboard, drawer, dan Profile Screen secara instan tanpa perlu restart atau reload manual.
8. **Pengujian Menyeluruh:**
   Seluruh 305 automated tests di project lulus 100% (`All tests passed!`), dan `flutter analyze` melaporkan `No issues found!`.

---

## 2. Arsitektur Komponen & Data Flow

```
[ Pengguna ] ── (Pilih Kamera / Galeri)
      │
      ▼
[ ImagePicker ] ── (Validasi Ukuran <= 5MB)
      │
      ▼
[ Modal Preview 1:1 ] ── (Konfirmasi "Simpan Foto")
      │
      ▼
[ SupabaseStorageService ] ── Isolate.run() Worker:
      │                      ├─ EXIF Orientation Bake
      │                      ├─ Center Crop 1:1 Square
      │                      ├─ Max Resize 512x512
      │                      └─ JPEG Encode Quality 85%
      │
      ▼ Upload Binary ke Supabase Storage:
      `{userId}/profile/profile_{timestamp}.jpg`
      │
      ▼ Generate Signed URL (1 jam + In-Memory Cache)
      │
      ▼
[ Cloud Firestore ] ── Set doc `users/{uid}`:
      ├─ photo_path: "{userId}/profile/profile_{timestamp}.jpg"
      ├─ photo_url: signedUrl
      ├─ avatar_preset: FieldValue.delete()
      └─ updated_at: ISO-8601 Timestamp
      │
      ▼ Hapus Foto Lama (jika path lama berbeda)
      │
[ State Management ]
      ├─ ProfileProvider._user diperbarui
      └─ AuthProvider.updateUserPhoto() diperbarui secara reaktif
      │
      ▼
[ Reusable UI Component ]
  `UserProfileAvatar` ── Menampilkan foto jaringan (memCacheWidth/Height)
                         atau Fallback Inisial Nama (misal: "AB")
```

---

## 3. Detail File yang Diimplementasikan & Dimodifikasi

### A. Konfigurasi & Service Storage
1. **`lib/core/config/supabase_config.dart`**
   - Menambahkan konfigurasi bucket profil:
     ```dart
     static const String profileBucket = String.fromEnvironment(
       'SUPABASE_PROFILE_BUCKET',
       defaultValue: bucket,
     );
     ```
2. **`lib/data/services/supabase_storage_service.dart`**
   - Menambahkan isolate worker `_compressProfilePhotoWorker`:
     - Normalisasi orientasi EXIF (`bakeOrientation`).
     - Center-cropping persegi 1:1 (`copyCrop`).
     - Resize proporsional ke maksimal 512x512 piksel (`copyResize`).
     - Encoding JPEG kualitas 85 (`encodeJpg`).
   - Menambahkan `uploadProfilePhoto({required String userId, required Uint8List imageBytes})`.
   - Menambahkan `deleteProfilePhoto(String path)` dengan cache invalidation.
   - Menambahkan helper pengujian `@visibleForTesting Future<...> compressProfilePhoto()`.

### B. Data Model & Repositori
3. **`lib/data/models/user.dart`**
   - Menambahkan field `final String? photoPath;`.
   - Memperbarui `fromJson`, `toJson`, dan `copyWith(..., {bool clearPhoto = false})`.
4. **`lib/data/repositories/profile_repository.dart`**
   - Menginjeksi `SupabaseStorageService`.
   - Pada `getUser()`: mendeteksi `photo_path` dan meresolve signed URL dinamis jika diperlukan.
   - Menambahkan `updateProfilePhoto(Uint8List imageBytes)`: mengunggah ke storage, menyimpan `photo_path` dan `photo_url` ke Firestore, menghapus file lama, dan mengembalikan user terkini.
   - Menambahkan `deleteProfilePhoto()`: menghapus `photo_path` dan `photo_url` dari Firestore via `FieldValue.delete()`, serta menghapus file fisik di Supabase Storage.

### C. State Management
5. **`lib/features/profile/providers/profile_provider.dart`**
   - Menambahkan `Future<bool> updateProfilePhoto(Uint8List imageBytes)`.
   - Menambahkan `Future<bool> deleteProfilePhoto()`.
6. **`lib/features/auth/providers/auth_provider.dart`**
   - Menambahkan `void updateUserPhoto({String? photoUrl, String? photoPath, bool clearPhoto = false})` untuk sinkronisasi state instan antar widget tanpa full rebuild aplikasi.

### D. Reusable UI Components
7. **`lib/shared/neo/user_profile_avatar.dart` (KOMPONEN BARU)**
   - Menampilkan foto asli dari network URL dengan `memCacheWidth` dan `memCacheHeight` untuk efisiensi memori GPU.
   - Fallback inisial nama deterministik:
     - `extractInitials('Ahmad Badawi')` -> `"AB"`
     - `extractInitials('Budi')` -> `"B"`
     - Fallback kosong -> `"U"`
   - Typography monospace bold 900 pada palet warna Neo-Brutalism (`lime`, `lilac`, `tangerine`, `hazard`, `mintGreen`, `skyBlue`).
   - Aksesibilitas: wrapping inisial dengan `ExcludeSemantics` dan pemberian semantics label eksplisit `Foto profil <Nama>`.
8. **`lib/shared/neo/neo_avatar.dart`**
   - Didelegasikan ke `UserProfileAvatar` untuk rendering profil asli atau inisial nama, sambil mempertahankan backward compatibility jika ada pengujian spesifik yang menyematkan `avatarPreset`.
9. **`lib/features/dashboard/screens/dashboard_screen.dart`**
   - Header dashboard memuat `photoUrl` pengguna dari `ProfileProvider` dan `AuthProvider` secara reaktif.

### E. Profile Screen Redesign
10. **`lib/features/profile/screens/profile_screen.dart`**
    - Menghapus badge karakter kartun (`Karakter: Chef Pro ...`).
    - Menghubungkan avatar header besar (96dp) dan tombol edit kamera ke `_openPhotoActionSheet`.
    - Mengganti tombol "Pilih Karakter Avatar" menjadi "Ubah Foto Profil".
    - Menyediakan Modal Bottom Sheet Neo-Brutalism dengan pilihan:
      1. Ambil Foto dengan Kamera (`ImageSource.camera`)
      2. Pilih dari Galeri (`ImageSource.gallery`)
      3. Hapus Foto Profil (tampil dinamis jika sudah ada foto)
      4. Batal
    - Dialog Pratinjau Foto 1:1 (`_showPhotoPreviewDialog`) sebelum proses upload.
    - Dialog Konfirmasi Hapus Foto Profil (`_handleDeletePhoto`).

---

## 4. Hasil Verifikasi & Pengujian

### A. Static Analysis (`flutter analyze`)
```bash
$ flutter analyze
Analyzing frontend...
No issues found! (ran in 3.3s)
```
- 0 errors
- 0 warnings
- 0 lints

### B. Automated Test Suite (`flutter test`)
```bash
$ flutter test
...
00:36 +305: All tests passed!
```
- **Total Test Cases:** 305 tests
- **Passed:** 305 passed
- **Failed:** 0 failed
- **Baru Ditambahkan:** `test/user_profile_photo_test.dart` (8 unit & widget test cases menguji ekstraksi inisial, semantic labels, kompresi 1:1 isolate, provider state, dan model persistence).

---

## 5. Ringkasan Kepatuhan & Keamanan

| Kriteria | Status | Catatan |
|:---|:---:|:---|
| **Foto Asli (Kamera & Galeri)** | PASS | Menggunakan `ImagePicker` dengan camera dan gallery. |
| **Preview Sebelum Simpan** | PASS | Modal dialog 1:1 dengan tombol "Batal" dan "Simpan Foto". |
| **Kompresi Client-Side** | PASS | `Isolate.run` crop square 1:1, max 512px, JPEG quality 85. |
| **Ukuran Maksimum** | PASS | Dibatasi maksimal 5 MB dengan feedback error snackbar. |
| **Isolasi Supabase Storage** | PASS | Path `{userId}/profile/profile_{timestamp}.jpg`. Anon key saja. |
| **Firestore Persistence** | PASS | `photo_path` dan `photo_url` tersimpan di `users/{uid}`. |
| **Cleanup Foto Lama** | PASS | Storage file lama otomatis dihapus saat upload foto baru / delete. |
| **Fallback Inisial Nama** | PASS | Inisial 1-2 huruf kapital, styling Controlled Neo-Brutalism. |
| **Hapus Foto Profil** | PASS | Pengguna dapat menghapus foto dan kembali ke inisial nama. |
| **Zero Emojis** | PASS | Seluruh UI menggunakan ikon Material Rounded (`AppIcons.*`). |
| **Zero Regressions** | PASS | Seluruh 305 tests lulus 100%. |
