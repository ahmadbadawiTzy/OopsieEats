# LAPORAN AUDIT & SINKRONISASI DOKUMENTASI SISTEM NUTRIVIEW

**Proyek**: NutriView — Food Nutrition Recognition & Daily Tracking App  
**Status Audit**: SELESAI & 100% TERVERIFIKASI  
**Tanggal**: 6 November 2026  
**Auditor**: Senior Software Architect, Technical Writer, Flutter Engineer, & Documentation Auditor  
**Single Source of Truth**: Kode Sumber Aktual (`frontend/lib/`, `frontend/pubspec.yaml`, `firestore.rules`, `firestore.indexes.json`, `frontend/android/app/build.gradle.kts`)

---

## 1. Kondisi Dokumentasi Sebelum Diperbarui

Sebelum audit dan sinkronisasi ini dilakukan, kondisi dokumentasi NutriView memiliki kesenjangan (*divergence*) substansial dengan implementasi kode aktual:

1. **Peninggalan Dokumen Prototipe Awal (FastAPI + MySQL)**:
   Berkas `docs/prd.md` dan `docs/ai.md` (bertanggal 29 September 2026) mendeskripsikan arsitektur modular monolith berbasis server FastAPI (Python), basis data relasional MySQL, dan inferensi ML sisi server melalui library Ultralytics. Dokumen ini tidak mencerminkan keputusan migrasi penuh ke arsitektur **Serverless Firebase + On-Device TFLite (Flutter)** yang telah diimplementasikan sejak Oktober 2026.
2. **Klaim Dependensi Phantom "Firebase Cloud Storage"**:
   Dokumen `README.md` (root) dan `docs/deployment.md` masih mencantumkan bahwa NutriView menggunakan *Firebase Storage* (`firebase_storage` package) untuk aset media gambar dan aturan `storage:rules`. Padahal, pada kode aktual:
   - Paket `firebase_storage` **sama sekali tidak terpasang** di `pubspec.yaml`.
   - Repositori `AdminRepository` dan `ArticleRepository` mengelola media menggunakan URL web eksternal (HTTPS) yang disimpan di Cloud Firestore (`cms_media`).
   - Avatar profil pengguna digambar secara prosedural oleh Flutter (`AvatarCatalog`) tanpa unggahan berkas foto ke server.
3. **Ketidaksesuaian Sistem Peran (Role & Permissions)**:
   Dokumen `docs/deployment.md` menginstruksikan admin untuk mengatur `role: "super_admin"`. Padahal, aturan keamanan aktif `firestore.rules` (baris 20–25) secara ketat menerapkan **Strict 2-Role System** yang hanya mengenali `role == 'admin'` dan `role == 'user'`. Akun dengan `role: "super_admin"` justru akan ditolak oleh sistem keamanan Firestore.
4. **Placeholder Bawaan Template Flutter**:
   Berkas `frontend/README.md` masih berupa teks *boilerplate* bawaan `flutter create` ("A new Flutter project...") tanpa panduan teknis yang relevan.
5. **Jumlah Kasus Uji Tidak Akurat**:
   Dokumen lama mencatat 251 kasus uji, padahal suite pengujian telah berkembang menjadi **256 kasus uji** aktif.
6. **Ketiadaan Panduan Arsitektur & ML yang Mendalam**:
   Belum tersedia dokumen teknis terpisah yang merinci arsitektur dependensi, pipeline pra-pemrosesan isolate TFLite, formulasi gizi deterministik (Mifflin-St Jeor & Atwater), standar kode SOLID, dan metodologi pengujian kualitas perangkat lunak.

---

## 2. Daftar Dokumen yang Diperiksa

Audit menyeluruh memeriksa seluruh artefak dokumentasi di dalam repositori:

| No | Lokasi Dokumen | Deskripsi / Topik |
|---|---|---|
| 1 | `README.md` (root) | Dokumentasi utama repositori |
| 2 | `frontend/README.md` | Dokumentasi paket mobile frontend |
| 3 | `docs/prd.md` | Product Requirements Document awal (29 Sep 2026) |
| 4 | `docs/ai.md` | Engineering Specification backend lama (29 Sep 2026) |
| 5 | `docs/CMS_IMPLEMENTATION_SPEC.md` | Spesifikasi awal CMS & perbandingan arsitektur |
| 6 | `docs/deployment.md` | Panduan operasional & rilis Firebase |
| 7 | `docs/reports/legacy_nutriview/FINAL_FIREBASE_MIGRATION_AND_ONDEVICE_YOLO_REPORT.md` | Laporan audit pembersihan Firebase Storage |
| 8 | `docs/reports/legacy_nutriview/FINAL_INTEGRATION_AND_RELEASE_READINESS_REPORT.md` | Laporan kesiapan rilis & integrasi |
| 9 | `docs/reports/legacy_nutriview/NUTRIVIEW_APP_SIZE_OPTIMIZATION_REPORT.md` | Laporan optimasi ukuran bundle aplikasi |
| 10 | `docs/reports/legacy_nutriview/NUTRIVIEW_CONSUMER_COPYWRITING_AND_ARTICLE_REDESIGN_REPORT.md` | Laporan desain ulang konten artikel |
| 11 | `docs/reports/legacy_nutriview/NUTRIVIEW_FULL_UX_REDESIGN_AVATARS_AND_CREATOR_REPORT.md` | Laporan UX avatar game & profil kreator |
| 12 | `docs/reports/legacy_nutriview/NUTRIVIEW_PRODUCTION_READINESS_REPORT.md` | Laporan kesiapan produksi |
| 13 | `docs/reports/legacy_nutriview/NUTRIVIEW_ROLE_AND_PERMISSION_AUDIT_REPORT.md` | Laporan audit role & otorisasi |
| 14 | `docs/reports/legacy_nutriview/NUTRIVIEW_SPLASH_AND_APP_ICON_REPORT.md` | Laporan aset splash & icon |
| 15 | `docs/reports/legacy_nutriview/NUTRIVIEW_VISUAL_OVERHAUL_V2_REPORT.md` | Laporan visual overhauls v2 |
| 16 | `docs/maintenance/GOOGLE_SIGN_IN_SKILL_MATRIX.md` | Matriks pemeliharaan Google Sign-In |
| 17 | `docs/maintenance/AUTH_RECOVERY_IMPLEMENTATION_REPORT.md` | Laporan pemulihan autentikasi |
| 18 | `docs/maintenance/DEAD_CODE_CLEANUP_REPORT.md` | Laporan pembersihan kode mati |
| 19 | `docs/maintenance/SKILL_EXECUTION_MATRIX.md` | Matriks eksekusi skill agen |
| 20 | `docs/performance/RELEASE_SIZE.md` | Ukuran rilis APK |
| 21 | `docs/performance/SCANNER_BENCHMARK.md` | Benchmark latensi scanner |
| 22 | `docs/performance/BASELINE.md` | Metrik baseline performa |
| 23 | `docs/performance/OPTIMIZATION_REPORT.md` | Laporan optimasi performa |
| 24 | `docs/project-report/README.md` | Panduan laporan akademik implementasi proyek |
| 25 | `docs/project-report/revision-notes.md` | Catatan revisi laporan akademik |

---

## 3. Daftar Dokumen yang Diperbarui & Dibuat

### A. Dokumen yang Diperbarui (Updated)
1. **`README.md` (root)**:
   - Menghapus seluruh referensi Firebase Cloud Storage dan paket `firebase_storage`.
   - Mengoreksi jumlah pengujian menjadi 256 kasus uji (100% lulus).
   - Menambahkan indeks tautan lengkap ke dokumen teknis di `docs/`.
   - Memutakhirkan topologi arsitektur sistem nirserver murni.
2. **`frontend/README.md`**:
   - Menulis ulang berkas dari *boilerplate* menjadi panduan teknis paket Flutter yang terintegrasi dengan dokumentasi root.
3. **`docs/deployment.md`**:
   - Menghapus instruksi pembuatan bucket Cloud Storage for Firebase dan deploy `storage:rules`.
   - Mengoreksi role bootstrap administrator pertama dari `"super_admin"` menjadi persis `"admin"`.
   - Mendokumentasikan konfigurasi kompilasi Android menggunakan **Gradle Kotlin DSL (`build.gradle.kts`)**, AAPT `noCompress("tflite")`, dan ProGuard minification.
4. **`docs/prd.md`**:
   - Menambahkan banner status resmi sebagai **Dokumen Historis** dengan navigasi ke arsitektur aktif.
5. **`docs/ai.md`**:
   - Menambahkan banner status resmi sebagai **Dokumen Historis** rekayasa backend lama (FastAPI + MySQL).
6. **`docs/CMS_IMPLEMENTATION_SPEC.md`**:
   - Menambahkan banner status resmi sebagai **Dokumen Historis** perancangan awal CMS.

### B. Dokumen Spesifikasi Baru yang Dibuat (Created)
1. **`docs/ARCHITECTURE.md`**:
   - Spesifikasi menyeluruh arsitektur Serverless Edge-AI.
   - Tanggung jawab per layer (Presentation, Logic/Provider, Repository, Core/ML).
   - Diagram arsitektur sistem dan diagram sekuensial (Scan-to-Meal flow, Target calculation flow) berbasis Mermaid.
2. **`docs/DATABASE_AND_BACKEND.md`**:
   - Dokumentasi lengkap Cloud Firestore & Firebase Auth.
   - Skema JSON detail untuk `users`, `meals`, `foods`, `cms_articles`, `cms_categories`, `cms_announcements`, `cms_audit_logs`, dan `cms_media`.
   - Aturan keamanan deklaratif `firestore.rules` dan indeks komposit `firestore.indexes.json`.
   - Mekanisme persistensi offline (bounded cache 100 MB) dan local fallback `seed_foods.json`.
3. **`docs/MACHINE_LEARNING.md`**:
   - Spesifikasi teknis model on-device YOLO26n TFLite (`best.tflite`, 9.4 MB) dan 29 kelas makanan.
   - Alur pra-pemrosesan citra di Dart background isolate (`Isolate.run`), penanganan orientasi EXIF, dan normalisasi tensor Float32 $[1, 3, 640, 640]$.
   - Algoritma pasca-pemrosesan, array hoisting, dan Non-Maximum Suppression (IoU 0.45).
   - Formulasi gizi deterministik: Mifflin-St Jeor (BMR), TDEE, makronutrien, dan validasi Atwater factor.
   - Jaminan eksekusi 100% offline dan privasi data visual.
4. **`docs/DEVELOPMENT_GUIDE.md`**:
   - Konvensi penamaan kode Dart, struktur kelas, dan kepatuhan `flutter_lints`.
   - Implementasi prinsip SOLID & OOP pada arsitektur NutriView.
   - Standar sistem desain visual **Overkill Neo-Brutalism** (`neo_tokens.dart`) dan katalog avatar game vektor (`AvatarCatalog`).
   - Hierarki penanganan kesalahan terpusat (`ApiException`).
   - Konfigurasi profil pengembang terpusat (`creator_config.dart`).
5. **`docs/TESTING_AND_QA.md`**:
   - Piramida pengujian dan inventaris lengkap 32 berkas uji di `frontend/test/`.
   - Bukti eksekusi faktual: `flutter analyze` (0 issues) dan `flutter test` (256/256 passed).
   - Tolak ukur benchmark scanner (latensi 150–400ms, 0 frame dropping pada UI thread).
6. **`docs/DOCUMENTATION_AUDIT_REPORT.md`**:
   - Laporan audit formal dan ringkasan komparasi sebelum/sesudah audit.

---

## 4. Daftar Dokumen yang Dipertahankan sebagai Historis

Dokumen-dokumen berikut dipertahankan dalam repositori karena memiliki nilai riwayat keputusan arsitektur (*architectural history*) dan konteks akademik, dengan penambahan banner penjelas yang tegas:

1. **`docs/prd.md`**: Menyimpan rekam jejak kebutuhan fungsional awal MVP sebelum migrasi platform.
2. **`docs/ai.md`**: Menyimpan spesifikasi teknis arsitektur modular monolith terdahulu.
3. **`docs/CMS_IMPLEMENTATION_SPEC.md`**: Menyimpan perbandingan analitis antara berbagai pendekatan CMS.
4. **`docs/project-report/README.md` & `revision-notes.md`**: Menyimpan dokumentasi laporan akademik perkuliahan.
5. **Laporan Audit Fase Tertentu** (`docs/reports/legacy_nutriview/FINAL_FIREBASE_MIGRATION_AND_ONDEVICE_YOLO_REPORT.md`, `docs/reports/legacy_nutriview/NUTRIVIEW_ROLE_AND_PERMISSION_AUDIT_REPORT.md`, dll.): Dipertahankan sebagai catatan verifikasi *milestone*.

---

## 5. Ringkasan Informasi yang Sebelumnya Tidak Akurat

| Topik | Klaim Dokumentasi Lama | Fakta Implementasi Kode Aktual |
|---|---|---|
| **Layanan Media & Storage** | Menggunakan Firebase Cloud Storage (`firebase_storage`) untuk berkas media artikel dan avatar pengguna. | **Tidak menggunakan Firebase Storage sama sekali**. Paket tidak terpasang di `pubspec.yaml`. Media artikel menggunakan URL eksternal di Firestore, dan avatar pengguna digambar via `CustomPainter` (`AvatarCatalog`). |
| **Sistem Peran (RBAC)** | `docs/deployment.md` menyebutkan role `super_admin` untuk akun bootstrap. | `firestore.rules` menerapkan **Strict 2-Role System** (`admin` dan `user`). Nilai role wajib persis `"admin"`. |
| **Kuantitas Kasus Uji** | Dokumentasi lama menyebutkan 251 test cases. | Suite pengujian aktual memiliki **256 test cases** yang semuanya lulus 100%. |
| **Konfigurasi Build Android** | Menyebutkan konfigurasi Groovy `build.gradle`. | Android menggunakan **Kotlin DSL (`build.gradle.kts`)** dengan konfigurasi ProGuard dan `aaptOptions { noCompress("tflite") }`. |
| **Arsitektur Backend** | `docs/ai.md` dan `docs/prd.md` menyebutkan server FastAPI dan database MySQL. | Seluruh backend beroperasi nirserver (*serverless*) melalui Firebase Authentication dan Cloud Firestore. |

---

## 6. Bukti Kesesuaian Dokumentasi dengan Source Code

Semua informasi dalam dokumentasi yang diperbarui telah diverifikasi langsung terhadap kode sumber:

1. **Model Machine Learning**:
   - Lokasi berkas diverifikasi di `frontend/assets/models/best.tflite` (ukuran biner 9,856,521 bytes).
   - Label diverifikasi di `frontend/assets/models/classes.txt` (tepat 29 baris kelas makanan).
   - Deklarasi asset diverifikasi di `frontend/pubspec.yaml` (baris 32–37).
2. **Pipeline Inferensi & Pra-Pemrosesan**:
   - Verifikasi isolasi Dart pada `frontend/lib/core/ml/yolo_detector_io.dart` (baris 228: `Isolate.run(() => _preprocessImage(imageBytes))`).
   - Verifikasi dimensi tensor: Input `[1, 3, 640, 640]` Float32, Output `[1, 33, 8400]` Float32.
   - Verifikasi NMS IoU threshold: `0.45` (baris 203).
3. **Aturan Keamanan Database**:
   - Verifikasi pada `firestore.rules`: Fungsi `isAdmin()` (baris 20–25) mengecek `getUserData().role == 'admin' && getUserData().is_active == true`.
   - Verifikasi pencegahan eskalasi hak akses pada registrasi (baris 34–36: `request.resource.data.role == 'user'`).
4. **Formulasi Gizi Deterministik**:
   - Verifikasi pada `frontend/lib/core/nutrition_calculator.dart`: Formula BMR Mifflin-St Jeor (baris 45–50), alokasi protein per kg (baris 12–16), alokasi lemak 25% kalori (baris 70), dan validasi Atwater (baris 102–126).
5. **Konfigurasi Platform Android**:
   - Verifikasi pada `frontend/android/app/build.gradle.kts`: `minSdk = maxOf(flutter.minSdkVersion, 23)`, `compileOptions { sourceCompatibility = JavaVersion.VERSION_17 }`, `aaptOptions { noCompress("tflite") }`.

---

## 7. Temuan Implementasi untuk Perbaikan Terpisah (Future Tasks)

Sesuai aturan kerja (*aturan dokumentasi, bukan refactoring*), kode aplikasi tidak dimodifikasi. Namun, berikut adalah temuan kode yang dicatat untuk diperbaiki pada siklus rekayasa berikutnya:

1. **Parameter Sisa `dynamic storage` pada Konstruktor**:
   Pada `frontend/lib/features/admin/data/admin_repository.dart` (baris 17) dan `frontend/lib/data/api_client.dart` (baris 14–15), terdapat parameter konstruktor sisa (`dynamic storage`, `dynamic client`, `String? baseUrl`) yang tidak lagi digunakan setelah migrasi dari Firebase Storage/HTTP Client. Parameter ini aman untuk dibersihkan pada refactor berikutnya.
2. **Peringatan Versi Dependensi Outdated**:
   Pemeriksaan `flutter pub outdated` mendeteksi bahwa beberapa paket dependensi memiliki versi rilis yang lebih baru (misal: `flutter_secure_storage 9.2.4` vs `11.2.0`, `intl 0.19.0` vs `0.20.3`). Pembaruan dependensi sebaiknya dilakukan pada tiket pemeliharaan terpisah dengan verifikasi regresi penuh.
3. **Penyempurnaan Pesan Kesalahan pada Layar Scanner**:
   Ketika gambar yang dipindai tidak menghasilkan deteksi objek di atas ambang batas 0.15, antarmuka dapat menyajikan pesan panduan pencahayaan yang lebih kontekstual bagi pengguna awam.

---

## 8. Hasil Verifikasi Sistem

Pemeriksaan otomatis dijalankan pada direktori `frontend`:

```bash
# 1. Analisis Statis Kode
flutter analyze
```
**Output**:
```text
Analyzing frontend...
No issues found! (ran in 6.8s)
```

```bash
# 2. Eksekusi Seluruh Suite Pengujian
flutter test
```
**Output**:
```text
00:39 +256: All tests passed!
```

- **Integritas Link**: Seluruh path berkas dan tautan antar-dokumen Markdown telah diperiksa dan mengarah pada berkas yang valid.
- **Kerahasiaan Kredensial**: Tidak ada API key sensitif, token akses, ataupun private service account key yang terpapar pada dokumentasi.

---

## 9. Tabel Ringkasan Audit Dokumen

| Dokumen | Kondisi Awal | Tindakan yang Diambil | Status Akhir |
|---|---|---|---|
| `README.md` (root) | Terdapat referensi lama ke Firebase Storage dan data pengujian tidak mutakhir (251 test). | Diperbarui: Hapus ketergantungan storage, mutakhirkan 256 test cases, tautkan indeks dokumentasi lengkap. | **ACCURATE** |
| `frontend/README.md` | Berupa placeholder default bawaan template `flutter create`. | Diperbarui: Tulis ulang sebagai panduan paket frontend yang fungsional dan terhubung ke docs root. | **ACCURATE** |
| `docs/deployment.md` | Mencantumkan Firebase Storage dan role bootstrap yang salah (`super_admin`). | Diperbarui: Hapus storage, sesuaikan role ke `admin`, dokumentasikan Gradle Kotlin DSL & APK/AAB rilis. | **ACCURATE** |
| `docs/ARCHITECTURE.md` | Belum tersedia dokumen arsitektur komprehensif pasca-migrasi. | Dibuat baru: Dokumentasikan arsitektur Serverless Edge-AI, diagram Mermaid, tanggung jawab layer. | **ACCURATE** |
| `docs/DATABASE_AND_BACKEND.md`| Belum tersedia spesifikasi basis data terpusat pasca-migrasi. | Dibuat baru: Dokumentasikan skema Firestore, rules RBAC biner, indeks komposit, persistensi offline. | **ACCURATE** |
| `docs/MACHINE_LEARNING.md` | Belum tersedia dokumentasi pipeline deteksi dan formulasi gizi terpadu. | Dibuat baru: Dokumentasikan TFLite isolate pipeline, NMS, Mifflin-St Jeor, Atwater, dan 29 kelas makanan. | **ACCURATE** |
| `docs/DEVELOPMENT_GUIDE.md` | Belum tersedia panduan konvensi developer dan sistem desain. | Dibuat baru: Dokumentasikan standar kode Dart, prinsip SOLID, Neo-Brutalism tokens, dan penanganan error. | **ACCURATE** |
| `docs/TESTING_AND_QA.md` | Belum tersedia dokumentasi QA dan inventarisasi pengujian terperinci. | Dibuat baru: Dokumentasikan 32 berkas uji, hasil verifikasi faktual (256 lulus), dan benchmark scanner. | **ACCURATE** |
| `docs/prd.md` | Spesifikasi produk awal berbasis arsitektur lama (FastAPI + MySQL). | Dipertahankan dengan penambahan banner peringatan dokumen historis dan tautan ke docs aktif. | **HISTORICAL** |
| `docs/ai.md` | Spesifikasi rekayasa backend lama (FastAPI + MySQL). | Dipertahankan dengan penambahan banner peringatan dokumen historis dan tautan ke docs aktif. | **HISTORICAL** |
| `docs/CMS_IMPLEMENTATION_SPEC.md` | Spesifikasi perancangan awal CMS berbasis REST/Docker. | Dipertahankan dengan penambahan banner peringatan dokumen historis RFC. | **HISTORICAL** |
| `docs/reports/legacy_nutriview/FINAL_FIREBASE_MIGRATION_AND_ONDEVICE_YOLO_REPORT.md` | Laporan migrasi penghapusan Firebase Storage (24 Okt 2026). | Dipertahankan sebagai bukti audit migrasi milestone historis. | **ACCURATE** |
| `docs/reports/legacy_nutriview/NUTRIVIEW_ROLE_AND_PERMISSION_AUDIT_REPORT.md` | Laporan audit role dan pemisahan profesi. | Dipertahankan sebagai bukti audit sistem otorisasi. | **ACCURATE** |
| `docs/project-report/*` | Berkas laporan akademik perkuliahan. | Dipertahankan sebagai dokumen pelaporan akademik resmi. | **HISTORICAL** |

---

## 10. Kesimpulan & Status Penyelesaian (Definition of Done)

Proses audit dan sinkronisasi dokumentasi NutriView dinyatakan **SELESAI (COMPLETE)**:
- [x] Dokumentasi 100% mencerminkan kondisi kode aktual NutriView.
- [x] Seluruh klaim fitur didukung oleh bukti implementasi kode sumber.
- [x] Pipeline Computer Vision YOLO26n dan formulasi gizi dijelaskan secara matematis dan faktual.
- [x] Tidak ada dependensi usang (Firebase Storage, FastAPI, MySQL) yang didokumentasikan sebagai aktif.
- [x] Dokumen lama diberi penandaan historis secara transparan tanpa merusak riwayat proyek.
- [x] Tidak ada perubahan yang dilakukan pada kode sumber aplikasi (`git diff` di luar dokumentasi adalah nihil).
- [x] Analisis statis (`flutter analyze`) dan seluruh pengujian (`flutter test`) terkonfirmasi lulus 100%.
- [x] Tidak ada commit atau push otomatis yang dieksekusi.
