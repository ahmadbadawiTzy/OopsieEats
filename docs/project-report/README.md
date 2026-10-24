# NutriView — Academic Project Implementation Report

Direktori ini berisi seluruh artefak dokumen laporan akademik implementasi proyek **NutriView: Food Nutrition Recognition & Daily Tracking App**.

---

## 1. Berkas Utama Dokumen Laporan

| Berkas | Format | Keterangan |
|---|---|---|
| [`project-implementation-report.docx`](project-implementation-report.docx) | Microsoft Word (.docx) | **Dokumen Final Utama**. Dapat diedit secara penuh, mengikuti standar format akademik (A4, Times New Roman, 1.5 spasi, Word Styles, tabel ber-header, diagram teknis resolusi tinggi). |
| [`project-implementation-report.pdf`](project-implementation-report.pdf) | Adobe PDF (.pdf) | **Hasil Render Ekspor**. Dokumen 50 halaman siap cetak/baca hasil konversi langsung dari LibreOffice Writer. |

---

## 2. Struktur Direktori Dokumentasi

```text
docs/project-report/
├── project-implementation-report.docx   # Dokumen Word final utama
├── project-implementation-report.pdf    # Dokumen PDF hasil render
├── README.md                            # Panduan penggunaan & pembaruan laporan
├── generate_diagrams.py                 # Skrip generator diagram teknis resolusi tinggi
├── generate_screen_illustrations.py     # Skrip generator ilustrasi layar antarmuka
├── generate_full_report.py              # Skrip kompilasi dokumen laporan lengkap
├── docx_styles.py                       # Modul helper styling & format dokumen Word
├── diagrams/                            # Koleksi diagram teknis sistem
│   ├── fig1_system_architecture.png     # Arsitektur Modular Monolith & Topologi
│   ├── fig2_use_case_diagram.png        # Diagram Use Case Sistem
│   ├── fig3_navigation_flow.png         # Diagram Alir Navigasi Pengguna
│   ├── fig4_ui_wireframes.png           # Galeri Wireframe Antarmuka
│   ├── fig5_database_erd.png            # ERD Basis Data (7 Tabel Relasional)
│   ├── fig6_scan_sequence_diagram.png   # Diagram Sekuensial Pindai & Catat Makan
│   └── fig7_nutrition_calc_flow.png     # Pipeline Formulasi Gizi & BMR/TDEE
├── screenshots/                         # Tangkapan layar & ilustrasi antarmuka
│   ├── screen_login.png                 # Antarmuka Layar Login
│   ├── screen_dashboard.png             # Antarmuka Layar Dashboard & Ring Kalori
│   ├── screen_detection_confirm.png     # Antarmuka Layar Konfirmasi Deteksi & Porsi
│   └── screen_meal_history.png          # Antarmuka Layar Riwayat Makan
└── appendices/                          # Data tambahan & catatan pengujian
```

---

## 3. Sistematika Dokumen Laporan (9 Bab Inti)

Dokumen laporan disusun sistematis mengikuti kaidah akademik resmi:
- **Sampul Laporan Profesional**: Identitas penyusun (Ahmad Badawi, S1 Sistem Informasi, Universitas Bina Insani, 2026), judul proyek, dan disclaimer akademik.
- **Petunjuk Penggunaan Laporan & Daftar Isi Otomatis**
- **Daftar Gambar & Daftar Tabel**
- **BAB 1 — Project Planning and System Design**: Latar belakang, rumusan masalah, ruang lingkup, kebutuhan fungsional & non-fungsional, arsitektur sistem, use case, navigation flow, wireframe, ERD, dan spesifikasi API.
- **BAB 2 — Development Environment Setup**: Prasyarat sistem, struktur repositori, konfigurasi backend Python, konfigurasi mobile Flutter, variabel lingkungan (.env), migrasi Alembic, inisialisasi master data nutrisi (foods.csv), bobot model YOLO26n, serta prosedur eksekusi dan verifikasi diagnostik.
- **BAB 3 — Database and Data Management Implementation**: Perancangan skema relasional 7 tabel (`users`, `profiles`, `foods`, `food_nutrition`, `meal_records`, `meal_items`, `revoked_tokens`), kolom, tipe data, foreign keys, check constraints, migrasi Alembic, dan data access layer SQLAlchemy 2.0.
- **BAB 4 — Authentication and Authorization Implementation**: Autentikasi stateless JWT, hashing kata sandi Argon2id, registrasi/login, penyimpanan aman flutter_secure_storage, proteksi rute FastAPI, serta penanganan token kedaluwarsa/logout.
- **BAB 5 — API and Service Integration**: Pola arsitektur REST Client-Service-Repository, serialisasi JSON (snake_case vs camelCase), kontrak endpoint `/api/v1`, format penanganan error RFC 7807, dan pengujian integrasi.
- **BAB 6 — Application Interface and Core Feature Development**: Sistem desain UI Material 3, alur navigasi bottom bar, implementasi layar login, dashboard progres kalori, kartu makronutrien, scanner kamera/galeri, konfirmasi deteksi YOLO, masukan porsi gram, riwayat makan, serta manajemen state Provider.
- **BAB 7 — Specialized Feature: Computer Vision & Food Detection**: Arsitektur YOLO26n (best.pt, 29 kelas makanan Indonesia), YOLOInferenceService, validasi citra & proteksi decompression bomb, deteksi multiobjek, ambang batas keyakinan (confidence threshold 0.15/0.50), serta graceful degradation (HTTP 503 saat model tidak tersedia).
- **BAB 8 — Data Processing, Analytics, or Business Logic**: Formulasi deterministik BMR Mifflin-St Jeor, faktor aktivitas fisik (TDEE), penyesuaian target kalori & batas bawah aman (calorie floor 1500 kcal pria / 1200 kcal wanita), distribusi makronutrien, algoritma kalkulasi porsi gram, dan presisi numerik Decimal ROUND_HALF_UP.
- **BAB 9 — Testing, Optimization, and Deployment**: Piramida pengujian, hasil pengujian unit nutrisi (5 kasus uji benchmark, 100% lulus), pengujian unit computer vision (19 kasus uji, 100% lulus), pengujian validasi citra (4 kasus uji, 100% lulus), analisis diagnostik kendala basis data host, pengujian keamanan, optimasi performa, prosedur build APK rilis, matriks ketercapaian kebutuhan vs implementasi, serta rekomendasi pengembangan.
- **Bagian Akhir**: Checklist bukti implementasi, daftar referensi format IEEE (12 sumber resmi), Lampiran A (Kamus Data Skema DB), Lampiran B (Kontrak REST API Lengkap), Lampiran C (Daftar 29 Kelas Makanan YOLO26n & Nilai Acuan Gizi), Lampiran D (Log Eksekusi Pengujian Sistem), dan Glosarium Istilah Teknis.

---

## 4. Cara Memperbarui Dokumen & Daftar Isi

1. **Memperbarui Dokumen Word (.docx)**:
   - Jika terdapat penyesuaian teks atau kode sumber, modifikasi berkas generator `generate_full_report.py`.
   - Jalankan kompilasi ulang dengan perintah:
     ```bash
     python3 docs/project-report/generate_full_report.py
     ```
2. **Memperbarui Daftar Isi pada Microsoft Word**:
   - Buka berkas `project-implementation-report.docx` di Microsoft Word atau LibreOffice Writer.
   - Klik kanan pada tabel Daftar Isi.
   - Pilih menu **Update Field** -> **Update entire table** (Perbarui seluruh tabel).
3. **Mengekspor Ulang ke Format PDF**:
   - Jalankan perintah konversi headless LibreOffice:
     ```bash
     libreoffice --headless --convert-to pdf docs/project-report/project-implementation-report.docx --outdir docs/project-report/
     ```

---

## 5. Daftar Bukti yang Masih Perlu Dilengkapi (Pending Implementation Evidence)

Sebagaimana dicatat secara transparan pada Bab 2.10 dan Bab 9.5:
1. **Pengujian Integrasi Database Lokal (MySQL)**:
   - Status: *Pending Execution / Tertunda*.
   - Penyebab: Partisi root host (`/dev/nvme0n1p6`) terisi 100% (hanya tersisa 56 MB), menyebabkan daemon mysqld gagal berjalan (`Errno 111 Connection refused`).
   - Tindakan Rekomendasi: Bersihkan ruang disk pada workstation, nyalakan service MySQL (`sudo systemctl start mysql`), jalankan migrasi `alembic upgrade head`, dan eksekusi `pytest backend/tests/integration`.
2. **Pengujian Kompilasi Flutter Test & Build Release APK**:
   - Status: *Pending Execution / Tertunda*.
   - Penyebab: Kompiler Flutter mengembalikan error OS 28 (*No space left on device*) saat mencoba menulis artefak intermediate `.dill`.
   - Tindakan Rekomendasi: Sediakan ruang kosong minimal 2-3 GB, lalu jalankan `flutter test` dan `flutter build apk --release`.
3. **Tangkapan Layar Perangkat Fisik (Physical Device Testing)**:
   - Status: *Mockup Design Illustration*.
   - Gambar yang disertakan saat ini adalah ilustrasi desain antarmuka resolusi tinggi berlabel desain, siap digantikan dengan tangkapan layar emulator/perangkat fisik setelah proses build APK diselesaikan.
