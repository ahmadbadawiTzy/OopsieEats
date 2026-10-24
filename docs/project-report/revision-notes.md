# Catatan Revisi Redesain Diagram Teknis — NutriView Project Implementation Report

**Tanggal:** 16 Oktober 2026  
**Peran:** Senior Software Architect, Technical Illustrator & Academic Document Designer  
**Dokumen Target:**
- DOCX: `docs/project-report/project-implementation-report.docx`
- PDF: `docs/project-report/project-implementation-report.pdf`
- Backup: `docs/project-report/project-implementation-report-backup.docx`
- Generator: `docs/project-report/diagrams/redesign_diagrams.py`
- Direktori Render: `docs/project-report/diagrams/rendered/`

---

## 1. Ringkasan Eksekutif & Karakteristik Desain Baru

Revisi ini berfokus pada peningkatan mutu visual, konsistensi teknis, keterbacaan, dan estetika akademik seluruh diagram teknis di dalam laporan implementasi proyek NutriView tanpa mengubah arsitektur aktual atau kode aplikasi.

Karakteristik desain yang diterapkan:
1. **Palet Warna Terkendali & Konsisten:**
   - Utama: NutriView Forest Green (`#166534`, `#14532D`) untuk aksen aplikasi.
   - Struktur: Dark Slate (`#1E293B`, `#334155`) untuk kontras tinggi dan formalitas akademis.
   - Latar Komponen: Neutral Grays (`#FFFFFF`, `#F8FAFC`, `#F1F5F9`).
   - Batas/Garis: Slate Grays (`#CBD5E1`, `#94A3B8`).
   - Semantik: Ochre (`#D97706`) untuk ML, Crimson (`#DC2626`) untuk Decision/Logout, Deep Cyan (`#0284C7`) untuk REST API.
2. **Eliminasi Judul Duplikat:** Menghapus judul diagram besar di dalam gambar yang menduplikasi caption Word.
3. **Penyempurnaan Penataan Ruang (Zero Overlaps & Zero Collisions):** Margin aman, padding teks cukup, orthogonal routing.
4. **Resolusi Tinggi:** 250 DPI untuk publikasi cetak dan digital.

## 2. Rincian Perbaikan Tiap Diagram

### Gambar 1.1: Arsitektur Tingkat Tinggi & Topologi Sistem (Modular Monolith)
- **File:** `fig1_system_architecture.png` (Halaman 12 Laporan PDF)
- **Perbaikan:**
  - Menata 3 kolom modular monolith: Mobile Client ($x=2..25$), Backend Application ($x=35..71$), dan Database ($x=83..98$).
  - Menambah celah bebas selebar 10–12 unit antar-layer, badge `REST API` dan `SQLAlchemy` memiliki clearance 2.2 unit tanpa bertabrakan.
  - Memecah teks API Gateway menjadi 2 baris bersih: *"API Gateway & Route Handlers (/api/v1/\*)"* dan *"JWT Authentication & Exception Interceptors"*.
  - Menempatkan modul CV YOLO26n dalam subsistem in-process terpisah beraksen amber.

### Gambar 1.2: Diagram Use Case Aplikasi NutriView
- **File:** `fig2_use_case_diagram.png` (Halaman 13 Laporan PDF)
- **Perbaikan:**
  - Menggantikan garis asosiasi menyebar dengan *Association Bus* vertikal ($x=20$) yang rapi dari aktor.
  - Memperlebar elips use case ($rx=14.5$ dan $rx=13$) sehingga teks use case primer (UC-01 s.d. UC-06) dan sekunder (UC-07 s.d. UC-09) memiliki padding lapang.
  - Memberikan jarak 12.5 unit antara use case primer dan sekunder untuk relasi `<<include>>` dan `<<extend>>`.

### Gambar 1.3: Diagram Alir Navigasi Pengguna (Application Navigation Flowchart)
- **File:** `fig3_navigation_flow.png` (Halaman 13 Laporan PDF)
- **Perbaikan:**
  - Menyeimbangkan proporsi kanvas menjadi $10.8 \times 6.2$ inci.
  - Alur logis dari Auth Gate $\rightarrow$ Decision [Token Valid?] $\rightarrow$ Login (jika Tidak) atau Dashboard (jika Ya).
  - Menggunakan tulang punggung vertikal ($x=71$) untuk mencabangkan navigasi ke 3 hub: Scanner, Riwayat, dan Profil.
  - Garis return *Simpan & Refresh* dialirkan melengkung melewati bagian atas (*over-the-top* pada $y=61.5$) langsung ke Dashboard, menjamin nol perpotongan kotak.
  - Garis logout merah dialirkan secara ortogonal di bagian bawah langsung menuju Layar Login.

### Gambar 1.4: Wireframe UI
- **File:** `fig4_ui_wireframes.png` (Hal 14): 4 layar, teks rapi, preview porsi bebas tumpang tindih.

### Gambar 1.5: Database ERD
- **File:** `fig5_database_erd.png` (Hal 15): 7 entitas relasional, z-order rapi, non-crossing badges.

### Gambar 5.1: Sequence Diagram
- **File:** `fig6_scan_sequence_diagram.png` (Hal 28): 5 lifeline, 14 langkah, background teks anti-tabrakan.

### Gambar 8.1: Nutrition Calculation Flow
- **File:** `fig7_nutrition_calc_flo