# NUTRIVIEW — LAPORAN OVERHAUL COPYWRITING CONSUMER-FIRST & REDESIGN KONTROL NEO-BRUTALISM

Dokumen ini merangkum perbaikan menyeluruh antarmuka NutriView: eliminasi seluruh jargon kecerdasan buatan (AI/YOLO26n/TFLite/telemetri sci-fi), transisi ke copywriting berorientasi konsumen (*consumer-first*), serta redesign terstruktur pada halaman **Artikel Nutrisi** dengan prinsip **Controlled Neo-Brutalism**.

---

## 1. Ringkasan Eksekutif

| Aspek | Kondisi Sebelumnya (Developer / Tech Demo) | Kondisi Baru (Consumer Product / Controlled Neo-Brutalism) |
|---|---|---|
| **Tone of Voice** | Berorientasi laboratorium & model AI (`YOLO26n`, `INFERENSI`, `OPTICAL_INPUT`, `NV // PROTOKOL GIZI`) | Berorientasi manfaat pengguna nyata (*"Pindai Makanan"*, *"Catatan Gizi Harian"*, privasi transparan) |
| **Header Artikel** | Berjejal badge teknis (`EDUKASI`, `${n} ARTIKEL`) yang mempersempit hierarki visual | Bersih, tegas, profesional: Judul tunggal `Artikel Nutrisi` |
| **Search Bar Artikel** | Sempit (44dp), terhimpit badge, teks terpotong, padding kecil | Luas (54dp), membentang selebar konten (padding 16dp), nyaman disentuh, dilengkapi tombol reset instan |
| **Kategori Artikel** | Huruf kapital penuh kaku (`GIZI SEIMBANG`) | Title Case ramah & elegan (`Semua`, `Gizi Seimbang`, `Hidrasi`, `Tips Sehat`) |
| **Banner Fallback** | Kode sistem monospaced (`NV.EDUKASI // PANDUAN`) | Kartu panduan bernuansa hangat (*"Panduan Gizi & Nutrisi"*) |
| **Empty & Error States** | Pesan singkat tanpa solusi ramah | Pesan consumer terstruktur dengan tombol reset pencarian & refresh data |
| **Analisis & Tes** | - | 0 warning/lint issue (`flutter analyze`), 77/77 tests passed (100%) |

---

## 2. Pemetaan Komprehensif Copywriting: Before vs. After

### A. Dashboard & Beranda
| Lokasi / Komponen | Teks Lama | Teks Baru | Alasan Perubahan |
|---|---|---|---|
| `dashboard_screen.dart` | `NUTRIVIEW // PROTOKOL GIZI` | `CATATAN GIZI HARIAN` | Menggantikan terminologi protokol militer/lab dengan fungsi esensial aplikasi konsumer. |
| `dashboard_hero_section.dart` | `NV // PROTOKOL GIZI` | `CATATAN GIZI` | Mengurangi visual noise kode sandi internal. |
| `scan_cta_card.dart` (Badge Atas) | `[02] ON-DEVICE AI DETECTOR` | `PINDAI MAKANAN` | Pengguna tidak perlu memikirkan nomor komponen perangkat keras/AI. |
| `scan_cta_card.dart` (Pill Kanan) | `YOLO26N` | `FOTO` | Mengeliminasi nama arsitektur model AI yang membingungkan konsumen awam. |
| `scan_cta_card.dart` (Judul Utama) | `SCAN YOUR MEAL` | `PINDAI MAKANAN` | Bahasa Indonesia lugas, seragam dengan branding lokal. |
| `scan_cta_card.dart` (Deskripsi) | `Arahkan kamera ke piring Anda. Model YOLO26n mendeteksi porsi secara instan.` | `Kenali makanan dari foto dan catat nutrisinya secara instan.` | Menjelaskan *benefit* konkret (kenali makanan & catat nutrisi), bukan teknis model. |

### B. Kamera Pemindai Makanan (`scanner_screen.dart`)
| Lokasi / Komponen | Teks Lama | Teks Baru | Alasan Perubahan |
|---|---|---|---|
| App Bar Title | `[LAB-01] OPTICAL_INPUT` | `PINDAI MAKANAN` | Standar navigasi aplikasi modern, bukan label eksperimen lab. |
| Processing Overlay (Judul) | `MEMPROSES CITRA MAKANAN` | `Mengidentifikasi Makanan...` | Kalimat interaktif yang lebih manusiawi saat loading. |
| Processing Overlay (Subteks) | `Menjalankan inferensi YOLO26n on-device...` | `Menganalisis foto langsung di perangkat...` | Menjelaskan proses lokal tanpa menyebutkan kode AI biner. |
| Processing Overlay (Footer) | `FOTO PRIVAT · DIHAPUS SETELAH INFERENSI` | `FOTO LANGSUNG DIPROSES DI PERANGKAT · PRIVASI TERJAGA` | Memberikan jaminan keamanan & privasi data dengan bahasa positif. |
| Viewfinder Guide (Atas) | `ARAHKAN KAMERA KE MAKANAN` | `Arahkan kamera ke makanan` | Title/Sentence case bersih, tidak berteriak (ALL-CAPS). |
| Viewfinder Guide (Bawah) | `INPUT_RES: 640x640 // MODEL: yolo26n.pt` | `Posisikan makanan di dalam bingkai agar mudah dikenali` | Mengganti string debug/telemetri dengan panduan praktis pengambilan foto. |

### C. Konfirmasi Hasil Deteksi (`detection_confirmation_screen.dart`)
| Lokasi / Komponen | Teks Lama | Teks Baru | Alasan Perubahan |
|---|---|---|---|
| Ringkasan Deteksi | `Total Deteksi: X objek makanan` | `Ditemukan X makanan dari foto` | Bahasa percakapan ramah dan bersahabat. |
| State Kosong | `Tidak Ada Makanan Terdeteksi` | `Makanan Belum Teridentifikasi` | Tidak menyalahkan pengguna; menyarankan untuk mencoba foto ulang atau cari manual. |

### D. Halaman Artikel Nutrisi (`article_list_screen.dart` & `article_detail_screen.dart`)
| Lokasi / Komponen | Teks Lama | Teks Baru | Alasan Perubahan |
|---|---|---|---|
| Top Header | `EDUKASI` chip + `${n} ARTIKEL` | Dihilangkan; Judul tunggal `Artikel Nutrisi` | Menghilangkan distraksi visual, memberi ruang bernapas di area atas. |
| Search Bar Hint | `Cari artikel...` (kotak 44dp terhimpit) | `Cari artikel nutrisi...` (kotak 54dp penuh) | Touch target luas sesuai rekomendasi WCAG & Material 3, hint deskriptif. |
| Kategori Filter | `SEMUA`, `GIZI SEIMBANG`, `HIDRASI` | `Semua`, `Gizi Seimbang`, `Hidrasi`, `Tips Sehat` | Lebih mudah dibaca (scannability tinggi) dibanding all-caps. |
| CTA Kartu Artikel | `BACA` | `Baca Artikel` | Call-to-action eksplisit dan intuitif. |
| Fallback Banner | `NV.EDUKASI // PANDUAN` | `Panduan Gizi & Nutrisi` | Menghilangkan format sintaks pemrograman/terminal. |
| Empty Search State | Pesan generik tanpa tombol reset | *"Artikel Tidak Ditemukan: Maaf, tidak ada artikel yang cocok dengan kata kunci..."* + Tombol **Lihat Semua Artikel** | Memberikan jalan keluar instan bagi pengguna (*graceful recovery*). |

---

## 3. Redesign Halaman Artikel Nutrisi (Controlled Neo-Brutalism)

Pembaruan halaman Artikel Nutrisi menerapkan panduan `flutter-ai-ui-skill`:

1. **Struktur Spasial & Touch Target**:
   - Search bar diperlebar hingga mengisi seluruh lebar kontainer konten (`16dp` horizontal padding).
   - Tinggi search box ditingkatkan menjadi `54dp` dengan radius border `14dp`, border solid 2px `#1A1A1A`, dan offset shadow `2px 2px`.
   - Ikon pencarian dan ikon clear (`X`) memiliki ukuran yang nyaman untuk sentuhan jari (`48dp` touch box).
2. **Kategori Filter Horisontal**:
   - Menggunakan `ListView.separated` horizontal dengan `ScrollPhysics` kenyal.
   - Pill kategori aktif menggunakan warna aksen Mint Green (`#A8E6CF`) dengan shadow `2px 2px`, sementara pill inaktif menggunakan warna putih gading dengan border halus.
3. **Kartu Artikel (NeoCard)**:
   - Header thumbnail kartu artikel menampilkan pill kategori dan waktu baca (`3 mnt baca`).
   - Judul artikel menggunakan bobot font tegas (`FontWeight.w800`) dengan *line-height* proporsional.
   - Ringkasan artikel dibatasi 2 baris teks abu-abu tua kontras tinggi.
   - Tombol `Baca Artikel` di kanan bawah kartu dilengkapi ikon panah (`Icons.arrow_forward_rounded`).

---

## 4. Verifikasi Teknis & Kualitas Kode

- **Static Analysis (`flutter analyze`)**:
  - Dijalankan pada seluruh direktori `frontend/`.
  - Hasil: **0 issues found!**
- **Unit & Widget Testing (`flutter test`)**:
  - Seluruh rangkaian pengujian (77 unit & widget tests) lolos 100%.
  - Mencakup pengujian spesifik `overkill_neobrutalism_dashboard_test.dart` dan `user_navigation_and_article_test.dart`.
  - Tidak ada lagi referensi ke teks usang seperti `YOLO26N`, `AI DETECTOR`, atau `[LAB-01]`.
