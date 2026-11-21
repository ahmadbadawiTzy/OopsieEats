# Changelog Dokumentasi Proyek — OopsieEats (NutriView)

Seluruh riwayat pembaruan, sinkronisasi, dan rekonstruksi dokumentasi proyek dicatat dalam dokumen ini.

---

## [2.1.0] — 2026-11-13
### Audit & Rekonstruksi Menyeluruh Dokumentasi Sistem (Full Audit & Reconstruction)
- **Rekonstruksi Root `README.md`**:
  - Memutakhirkan branding aplikasi menjadi **OopsieEats** (`com.oopsieeats.app`), mencatat nama historis (*NutriView*).
  - Menggantikan diagram kotak ASCII lama dengan diagram Mermaid native yang profesional.
  - Memutakhirkan metrik test suite dari 348/256 menjadi **359 kasus uji aktif (100% lulus)** pada 42 berkas pengujian.
  - Menyelaraskan dependensi aktual: Flutter 3.x, Dart SDK `^3.13.4`, Target SDK 36.
- **Pembaruan `docs/ARCHITECTURE.md`**:
  - Mengintegrasikan arsitektur **Supabase Storage** (bucket privat `food-history-images` dengan RLS dan signed URLs).
  - Menambahkan dokumentasi alur *Complete Profile Guard* (`AppRoutes.completeProfile`) dan Onboarding interaktif 3 slide.
  - Memperbarui diagram arsitektur tingkat tinggi dan sequence diagrams dengan Mermaid native.
- **Pembaruan `docs/DATABASE_AND_BACKEND.md`**:
  - Memperbaiki klaim historis yang menyebut penyimpanan citra tidak digunakan; mengklarifikasi bahwa Firebase Cloud Storage memang tidak digunakan, melainkan menggunakan Supabase Storage.
  - Memutakhirkan skema dokumen `users/{userId}` dengan field aktual `is_profile_complete`, `photo_url`, `photo_path`, dan `avatar_preset`.
  - Memutakhirkan skema subkoleksi `users/{userId}/meals/{mealId}` dengan field objek `image` (`MealImageMetadata`).
- **Pembaruan `docs/SUPABASE_IMAGE_STORAGE.md`**:
  - Menambahkan spesifikasi alur unggah dan pembersihan foto profil pengguna (`uploadProfilePhoto`, `deleteProfilePhoto`) dengan auto-crop 1:1, downscale 512px, dan logging terstruktur (`ProfilePhotoLogger`).
- **Pembaruan `docs/TESTING_AND_QA.md`**:
  - Mengganti diagram piramida ASCII dengan diagram Mermaid native.
  - Memperluas inventaris berkas pengujian dari 32 berkas menjadi **42 berkas pengujian**.
  - Mencatat bukti eksekusi aktual: `flutter analyze` (0 issues) dan `flutter test` (359 test cases passed).
- **Pembaruan `docs/deployment.md`**:
  - Mengoreksi Application ID dari `com.nutriview.nutriview` menjadi `com.oopsieeats.app`.
  - Mengoreksi Android target SDK dari 34 menjadi 36 (Android 16), Java 17.
  - Menambahkan panduan skrip validasi rilis otomatis `./scripts/validate_release.sh` (12 gerbang pengujian).
  - Mengganti diagram ASCII dengan diagram Mermaid deployment architecture.
- **Pembuatan Koleksi Standalone Mermaid Diagrams (`docs/diagrams/`)**:
  - `system-context.mmd`
  - `application-architecture.mmd`
  - `folder-module-relationship.mmd`
  - `authentication-flow.mmd`
  - `data-flow.mmd`
  - `database-erd.mmd`
  - `ml-inference-pipeline.mmd`
  - `deployment-architecture.mmd`
  - `scan-sequence.mmd`
  - `account-deletion-sequence.mmd`
  - Seluruh 10 diagram divalidasi dengan 0 syntax error.
- **Pembuatan Portal Indeks `docs/README.md`**:
  - Menyediakan direktori navigasi satu pintu bagi developer baru dan tim engineering.

---

## [2.0.0] — 2026-11-06
### Sinkronisasi Pasca-Migrasi Firebase Serverless & On-Device TFLite
- Membersihkan referensi lama paket `firebase_storage` yang tidak terpasang di `pubspec.yaml`.
- Mengoreksi sistem peran pada dokumentasi menjadi **Strict 2-Role System** (`admin` dan `user`) sesuai `firestore.rules`.
- Menandai dokumen prototipe awal (`docs/prd.md`, `docs/ai.md`, `docs/CMS_IMPLEMENTATION_SPEC.md`) dengan status **DOKUMEN HISTORIS**.
- Menyusun dokumen arsitektur komprehensif: `docs/ARCHITECTURE.md`, `docs/DATABASE_AND_BACKEND.md`, `docs/MACHINE_LEARNING.md`, `docs/DEVELOPMENT_GUIDE.md`, dan `docs/TESTING_AND_QA.md`.

---

## [1.0.0] — 2026-09-29
### Rilis Dokumentasi Awal (Prototipe Monolith)
- Pembuatan PRD awal (`docs/prd.md`) dan spesifikasi rekayasa backend modular monolith (`docs/ai.md`) berbasis FastAPI, SQLAlchemy 2.0, dan MySQL.
