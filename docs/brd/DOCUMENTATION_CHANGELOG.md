# Documentation Changelog — OopsieEats BRD Reconstruction
**Tanggal Rilis**: 13 November 2026 | **Versi Dokumentasi**: 2.1.0 (Professional Redesign + Dedicated Cover Pages & UML Per Chapter)

---

## 1. Ringkasan Rekonstruksi Total
Dokumentasi Business Requirements Document (BRD) telah direkonstruksi 100% dari kondisi monolitik usang menjadi suite dokumen rekayasa modular bertaraf enterprise.

### Perubahan Utama:
1. **Halaman Sampul Resmi per Bab (Dedicated Cover Pages)**:
   - Setiap bab (Bab 1 s.d. Lampiran) serta Master Index kini memiliki Halaman Sampul Depan Resmi (Halaman 1) dengan tata letak institusional profesional, judul bab, metadata dokumen, dan bebas running header/footer.
   - Konten bab dimulai pada Halaman 2 lengkap dengan running header, divider line, running footer, dan penomoran dinamis `Halaman X dari Y`.
2. **Cakupan Diagram UML di Seluruh Bab (100% UML Coverage)**:
   - Setiap bab memiliki minimal satu diagram teknis/UML native Mermaid:
     - Bab 1: System Context, Business Process, Architecture, Deployment, Use Case
     - Bab 2: UML Component Diagram (Build & Toolchain)
     - Bab 3: Database ERD, Schema Hierarchy, UML Class Diagram (Domain Models), RBAC Decision Tree
     - Bab 4: Token Security Flow, Sequence Diagram (Account Deletion UU PDP)
     - Bab 5: Offline Storage Cache, UML Class Diagram (Repository Pattern & Services)
     - Bab 6: Navigation Flow, UML State Machine Diagram (UI Lifecycle & Profile Guard) + 19 Wireframes Monokrom
     - Bab 7: Sequence Diagram (CV Meal Logging & AI Pipeline)
     - Bab 8: UML Sequence Diagram (Nutrition Calculation & Safe Calorie Floor)
     - Bab 9: UML Activity Diagram (System Lifecycle & QA)
     - Lampiran: UML Package & Traceability Diagram (Clean Architecture Layers)
3. **Pemisahan Dokumen Berdasarkan Bab (Modular Chapter Separation)**:
   - Setiap bab diterbitkan menjadi berkas mandiri `.docx` dan `.pdf` di dalam `docs/brd/chapters/`.
   - Penerbitan Master Index terpadu (`BRD_MASTER_INDEX.docx` & `.pdf`) dengan daftar isi bertitik (*dot leaders*) dan jumlah halaman akurat.
4. **Koleksi Wireframe Nyata Monokrom (19 Layar)**:
   - Mengambil 19 tangkapan layar resolusi asli (1080x2400) dari widget aplikasi nyata.
   - Mengonversi menjadi wireframe monokrom kontras tinggi dengan garis tepi perangkat 1.5px dan **tanpa judul/teks banner di dalam gambar**. Seluruh keterangan diletakkan sebagai caption formal `Gambar 6.X`.
5. **Standarisasi 20 Diagram Native Mermaid**:
   - Seluruh 20 diagram teknis memiliki berkas sumber native `.mmd` di `docs/brd/diagrams/mermaid/`.
   - Dirender menjadi gambar PNG resolusi tinggi dengan *auto-cropping* di `docs/brd/diagrams/rendered/`.
6. **Penyelarasan Fakta Implementasi Aktual (Single Source of Truth)**:
   - Nama aplikasi: **OopsieEats** (`com.oopsieeats.app`), versi `1.0.0+2002`, Target SDK 36, compileSdk 36, minSdk 23.
   - Hasil pengujian: **359 automated tests lulus 100%** pada 42 berkas pengujian (sebelumnya tercatat 256).
   - Analisis statis: **0 issues** pada `flutter analyze --fatal-infos`.
   - Penyimpanan gambar: **Supabase Storage** (`food-history-images` private bucket dengan Signed URLs 3600s TTL).
   - Model Machine Learning: **best.tflite (9.4 MB)** YOLOv8 Nano Float32, 29 kelas pangan TKPI 2020.
   - Keamanan: Complete Profile Guard, Strict 2-Role RBAC, dan Alur Hapus Akun mandiri sesuai UU PDP 2022.
