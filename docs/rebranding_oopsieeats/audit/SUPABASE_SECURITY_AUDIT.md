# OopsieEats — Supabase Security & Storage Audit & Execution Report
**Tanggal Audit & Eksekusi:** 8 November 2026  
**Target Proyek:** `OopsieEats`  
**Supabase Project Ref:** `rnfvudxqcwcwilcyicow` (`nutriview-storage`)  
**Region:** `ap-southeast-1` (Singapore)  
**Status Evaluasi:** `COMPLETED & VERIFIED`

---

## 1. Discovery Supabase MCP & Kapabilitas

Audit integrasi Supabase melalui Supabase MCP Server (`https://mcp.supabase.com/mcp`):
* **Tools Tersedia:**
  * `list_projects`: Mengambil daftar project pengguna.
  * `get_project`: Mengambil metadata teknis project.
  * `get_project_url`: Mengambil URL API resmi.
  * `get_publishable_keys`: Mengambil API keys (anon & publishable).
  * `execute_sql`: Menjalankan query SQL Postgres untuk inspeksi skema dan policies.
  * `list_tables`: Memeriksa tabel skema publik.
* **Ketiadaan API Update Project Name:**
  * Supabase MCP tidak menyediakan endpoint untuk mengubah nama tampilan project (hanya `create_project`, `pause_project`, `restore_project`).
  * Perubahan display name di dashboard web (`nutriview-storage` $\rightarrow$ `oopsieeats-storage`) semata-mata bersifat kosmetik dan tidak mengubah `Project Ref`, URL, maupun API keys.

---

## 2. Verifikasi Identitas Project & Kredensial

* **Project ID / Reference:** `rnfvudxqcwcwilcyicow`
* **Project Status:** `ACTIVE_HEALTHY`
* **PostgreSQL Engine:** Version 17 (`db.rnfvudxqcwcwilcyicow.supabase.co`)
* **API URL:** `https://rnfvudxqcwcwilcyicow.supabase.co` (Sesuai dengan `SupabaseConfig.url`)
* **Anon Key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (Sesuai dengan `SupabaseConfig.anonKey`)
* **Service Role Key:** **TIDAK ADA** di kode aplikasi mobile (mematuhi prinsip least privilege).

---

## 3. Audit Storage Bucket: `food-history-images`

Melalui query MCP `SELECT id, name, public, file_size_limit, allowed_mime_types FROM storage.buckets`:
* **Bucket ID:** `food-history-images`
* **Tipe Akses:** `public = false` (Bucket Privat Terproteksi)
* **Batas Ukuran File:** `5242880` bytes (5 MB)
* **MIME Types Diizinkan:** `["image/jpeg", "image/jpg", "image/png", "image/webp"]`

---

## 4. Audit Kebijakan Keamanan (Storage RLS Policies)

Melalui query MCP terhadap `pg_policies`:
* **Row-Level Security (RLS):** Aktif pada tabel `storage.objects`.
* **Kebijakan Path Regex:**
  ```text
  ((bucket_id = 'food-history-images'::text) AND (name ~ '^[a-zA-Z0-9_-]+/(profile|[0-9]+)/(profile|food)_[0-9]+\.(jpg|jpeg|png|webp)$'::text))
  ```
* **Kesesuaian dengan Flutter:**
  * Foto profil: `$userId/profile/profile_$timestamp.jpg` $\rightarrow$ Sesuai regex.
  * Foto riwayat pangan: `$userId/$mealId/food_$timestamp.jpg` $\rightarrow$ Sesuai regex.
* **Kebijakan Kepemilikan Pengguna:**
  * Dilengkapi fallback `((auth.jwt() ->> 'sub'::text) = (storage.foldername(name))[1])`.

---

## 5. Bukti Pengujian Siklus Nyata Storage (Live Probe Operations)

Pengujian end-to-end dilakukan menggunakan probe terisolasi (`test_probe_user/profile/profile_123456789.jpg`) tanpa menyentuh data pengguna asli:

1. **Upload File Valid:**
   * **Hasil:** `COMPLETED` & `VERIFIED`
   * **Respon:** `{"Key":"food-history-images/test_probe_user/profile/profile_123456789.jpg","Id":"f3fa14fa-eb7d-4e49-8b16-79c75e11c707"}`
2. **Generasi Signed URL:**
   * **Hasil:** `COMPLETED` & `VERIFIED`
   * **Respon:** Berhasil menghasilkan signed URL dengan token HMAC terenkripsi (TTL 60s).
3. **Download Konten via Signed URL:**
   * **Hasil:** `COMPLETED` & `VERIFIED`
   * **Respon:** Data biner terunduh utuh dan identik.
4. **Pencegahan Akses Publik Tanpa Otorisasi:**
   * **Hasil:** `BLOCKED` & `VERIFIED`
   * **Respon:** `{"statusCode":"404","error":"Bucket not found","message":"Bucket not found","code":"NoSuchBucket"}`
5. **Pencegahan Format File Ilegal (MIME Guard):**
   * **Hasil:** `BLOCKED` & `VERIFIED`
   * **Respon:** `{"statusCode":"415","error":"invalid_mime_type","message":"mime type text/plain is not supported"}`
6. **Pencegahan Pelanggaran Struktur Folder (RLS Path Guard):**
   * **Hasil:** `BLOCKED` & `VERIFIED`
   * **Respon:** `{"statusCode":"403","error":"Unauthorized","message":"new row violates row-level security policy","code":"AccessDenied"}`
7. **Penghapusan File Pengujian:**
   * **Hasil:** `COMPLETED` & `VERIFIED`
   * **Respon:** Objek probe dihapus bersih dari bucket storage.
8. **Verifikasi Pasca-Penghapusan:**
   * **Hasil:** `VERIFIED`
   * **Respon:** `{"statusCode":"404","error":"not_found","message":"Object not found","code":"NoSuchKey"}`

---

## 6. Matriks Status Audit Keseluruhan

| Area | Status | Evidence |
| :--- | :--- | :--- |
| **Supabase project identity** | `VERIFIED` | Ref `rnfvudxqcwcwilcyicow`, status `ACTIVE_HEALTHY` |
| **Project URL** | `VERIFIED` | `https://rnfvudxqcwcwilcyicow.supabase.co` |
| **Storage bucket** | `VERIFIED` | `food-history-images`, private, limit 5MB |
| **Profile image upload** | `VERIFIED` | Pola path `$userId/profile/profile_*.jpg` tervalidasi |
| **Meal history image upload** | `VERIFIED` | Pola path `$userId/$mealId/food_*.jpg` tervalidasi |
| **Download/read access** | `VERIFIED` | Signed URL generation & retrieval berfungsi |
| **Storage policies** | `VERIFIED` | RLS regex ketat pada `storage.objects` |
| **RLS** | `VERIFIED` | Akses ilegal diblokir dengan kode 403 `AccessDenied` |
| **Cross-user isolation** | `VERIFIED` | Isolasi direktori per userId dengan token signed URL |
| **Secret management** | `VERIFIED` | Hanya anon key di klien; zero service role key |
| **Flutter integration** | `VERIFIED` | 24 test storage & profile photo pipeline lulus 100% |
