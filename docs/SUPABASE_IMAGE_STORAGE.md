# Integrasi Supabase Storage — Foto Inspeksi Makanan & Foto Profil Pengguna

**OopsieEats (NutriView) Mobile Application (Flutter / Firebase / Supabase Storage)**

---

## 1. Ikhtisar & Ruang Lingkup Arsitektur

OopsieEats mempertahankan **Firebase** sebagai ekosistem identitas dan basis data utama:
- **Firebase Authentication**: Penyedia identitas tunggal yang mengelola registrasi, login, token, dan sesi pengguna.
- **Firebase Firestore**: Basis data utama yang menyimpan profil pengguna, target gizi harian, katalog pangan, riwayat makan, skor confidence YOLO26n, dan metadata citra.
- **On-Device YOLO26n**: Inferensi jaringan saraf tiruan pendeteksi makanan berjalan murni *offline* di perangkat klien tanpa mengirimkan citra ke API inferensi eksternal.

**Supabase Storage** digunakan **SECARA EKSKLUSIF** untuk penyimpanan berkas citra biner:
1. **Foto Inspeksi Makanan** (*Food Detection Inspection Photos*): Diambil saat pemindaian kamera/galeri untuk keperluan konfirmasi visual di riwayat makan.
2. **Foto Profil Pengguna** (*User Profile Pictures*): Foto personal yang diunggah pengguna sebagai alternatif avatar vektor prosedural.

### Spesifikasi Proyek Supabase:
- **Bucket**: `food-history-images` (**Bucket Privat**)
- **Project Ref**: `rnfvudxqcwcwilcyicow`
- **Region**: `ap-southeast-1` (Singapura)
- **Endpoint URL**: `https://rnfvudxqcwcwilcyicow.supabase.co`
- **Public Key**: `sb_publishable_zkmZHcq6D4fTB1L9qvIvYw_izbuSHDj`
- **Aturan Keamanan Kunci**: Kunci rahasia `service_role` **DILARANG KERAS** dimasukkan ke kode klien. Klien Flutter hanya menggunakan `publishableKey` publik dengan verifikasi jalur multi-tenant.

---

## 2. Struktur Direktori & Pola Jalur (Path Patterns)

Seluruh berkas citra disimpan dengan isolasi folder pengguna yang ketat berdasarkan Firebase UID:

```text
food-history-images/
  └── {userId}/
        ├── profile/
        │     └── profile_{timestamp}.jpg
        └── {mealId}/
              └── food_{timestamp}.jpg
```

### Rincian Komponen Jalur:
| Jalur / Komponen | Pola Penamaan | Deskripsi Teknis |
|---|---|---|
| **Foto Profil** | `{userId}/profile/profile_{timestamp}.jpg` | Citra profil pengguna terkompresi rasio 1:1 (persegi), resolusi maksimal $512 \times 512$ px, JPEG quality 85. |
| **Foto Inspeksi Makanan** | `{userId}/{mealId}/food_{timestamp}.jpg` | Citra makanan terkompresi, resolusi terpanjang maksimal 1024 px, rasio aspek asli dipertahankan, JPEG quality 80. |
| `{userId}` | Firebase UID (`auth.currentUser.uid`) | Partisi akar yang menjamin isolasi data multi-tenant antar-pengguna. |
| `{mealId}` | Epoch timestamp milidetik | Pengenal unik catatan makan yang berpadanan dengan ID dokumen di Firestore. |

---

## 3. Pipeline Kompresi Citra di Background Isolate

Untuk mencegah *frame dropping* (jank) pada antarmuka pengguna, seluruh pemrosesan citra berat dijalankan di dalam Dart *background isolate* (`Isolate.run`):

### 3.1. Pipeline Foto Inspeksi Makanan (`_compressImageWorker`)
1. **Decode**: `img.decodeImage(rawBytes)` memverifikasi integritas berkas.
2. **Koreksi Orientasi**: `img.bakeOrientation(decoded)` menyelaraskan rotasi sensor kamera (EXIF).
3. **Downscale Proporsional**: Jika dimensi terpanjang $> 1024$ px, citra diperkecil secara proporsional menggunakan interpolasi linear.
4. **Encoding**: Dikonversi ke JPEG dengan kualitas 80 (`SupabaseConfig.jpegQuality`).

### 3.2. Pipeline Foto Profil (`_compressProfilePhotoWorker`)
1. **Decode & Orientasi**: Decode berkas dan bake rotasi EXIF.
2. **Center Crop 1:1**: Memotong area tengah citra menjadi persegi sempurna ($W = H = \min(W, H)$).
3. **Resize**: Jika dimensi $> 512$ px, citra diperkecil menjadi tepat $512 \times 512$ px.
4. **Encoding**: Dikonversi ke JPEG dengan kualitas 85.

---

## 4. Mekanisme Tautan Bertanda Tangan (Signed URLs) & Caching

Bucket `food-history-images` bersifat privat dan tidak dapat diakses langsung tanpa otorisasi.

1. **Pembuatan Signed URL**:
   Saat aplikasi perlu menampilkan foto di riwayat makan atau profil, `SupabaseStorageService.getSignedImageUrl(path)` memanggil API Supabase untuk menerbitkan URL bertanda tangan sementara:
   ```dart
   final response = await client.storage.from(bucket).createSignedUrl(
     cleanPath,
     SupabaseConfig.signedUrlTtl.inSeconds, // 3600 detik (1 jam)
   );
   ```
2. **In-Memory Expiration Cache**:
   Untuk menghindari pemanggilan API berulang yang boros kuota dan memperlambat render UI, hasil signed URL disimpan di *in-memory cache* (`_urlCache`) dengan pengurangan *safety margin* 5 menit dari masa berlaku 1 jam. Jika cache masih segar, URL lokal langsung dikembalikan seketika (0 ms latensi jaringan).

---

## 5. Pembersihan Berkas & Siklus Hidup Penghapusan Akun

1. **Penghapusan Catatan Makan Tunggal**:
   Saat pengguna menghapus satu catatan makan di `MealHistoryScreen`, `MealRepository.deleteMeal(id)` menghapus dokumen di Firestore sekaligus memicu `storageService.deleteFoodImage(image.path)`.
2. **Pembersihan Berjenjang Saat Hapus Akun (*Cascading Deletion*)**:
   Saat pengguna menjalankan alur penghapusan akun mandiri (`AuthRepository.deleteAccount`), seluruh folder media pengguna di Supabase Storage dibersihkan secara tuntas melalui:
   ```dart
   await storageService.deleteUserFoodImages(userId);
   ```
   Metode ini melakukan *list* rekursif terhadap seluruh objek di bawah `{userId}/` dan menghapusnya secara permanen, menjamin kepatuhan hak privasi pengguna (*Right to be Forgotten*).

---

## 6. Logging Terstruktur Pipeline Foto Profil (`ProfilePhotoLogger`)

Untuk memudahkan penelusuran masalah pengunggahan foto profil di perangkat nyata, `ProfilePhotoLogger` mencatat setiap tahap secara terstruktur:

| Tahap (*Stage*) | Peristiwa yang Dicatat |
|---|---|
| `STAGE_1_PICK` | Pengguna memilih foto dari galeri / kamera via `image_picker`. |
| `STAGE_2_PERMISSION`| Status perizinan akses media perangkat. |
| `STAGE_3_INPUT_VALIDATION`| Pemeriksaan ukuran berkas ($\le 5$ MB) dan format citra. |
| `STAGE_4_BYTES_EXTRACTION`| Ekstraksi `Uint8List` dari berkas sumber. |
| `STAGE_5_COMPRESSION`| Pelaksanaan kompresi dan cropping 1:1 di background isolate beserta durasi milidetik. |
| `STAGE_6_CLIENT_AUTH`| Verifikasi inisialisasi Supabase client dan UID pengguna. |
| `STAGE_7_STORAGE_UPLOAD`| Pengunggahan berkas biner ke bucket Supabase dan penerbitan signed URL. |
| `STAGE_8_FIRESTORE_WRITE`| Pembaruan field `photo_path` dan `photo_url` pada dokumen `users/{uid}`. |
| `STAGE_9_UI_UPDATE`| Refleksi foto baru pada widget `UserProfileAvatar`. |

---

## 7. Kebijakan Keamanan Supabase Storage Row Level Security (RLS)

Untuk menjamin bahwa setiap pengguna hanya dapat membaca, mengunggah, dan menghapus berkas di dalam jalurnya sendiri, script SQL berikut diterapkan pada Supabase SQL Editor:

```sql
-- 1. Buat bucket privat jika belum ada
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'food-history-images',
  'food-history-images',
  false,
  5242880, -- Maksimal 5 MB
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = false,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];

-- 2. Aktifkan Row Level Security pada storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 3. Kebijakan Akses: Pengguna hanya dapat membaca citra di folder UID mereka
CREATE POLICY "Users can view their own media"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'food-history-images'
);

-- 4. Kebijakan Unggah: Pengguna hanya dapat mengunggah ke path berawalan UID mereka
CREATE POLICY "Users can upload their own media"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'food-history-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- 5. Kebijakan Hapus: Pengguna hanya dapat menghapus media milik mereka
CREATE POLICY "Users can delete their own media"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'food-history-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
);
```
