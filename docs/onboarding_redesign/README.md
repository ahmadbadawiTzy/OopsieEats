# NutriView — Onboarding Redesign (Extreme Neo-Brutalism)

> **Status:** Tahap 1 (aset + HTML prototype) dan Tahap 2 (implementasi Flutter native, audit project, `flutter analyze`, `flutter test`, integrasi FTUE) **selesai dan terverifikasi 100%**.
> Lihat `IMPLEMENTATION_REPORT.md` untuk dokumentasi arsitektur dan laporan verifikasi lengkap.

## Isi folder

```
docs/onboarding_redesign/
├─ onboarding_preview.html          # prototype (satu file, font & foto sudah di-embed)
├─ FLUTTER_HANDOFF.md               # prompt Tahap 2 untuk dijalankan di folder project
├─ assets/
│  ├─ photos/
│  │  ├─ onboarding_1_sticker.png   # slide 1: foto memegang piring (cocok dengan "Kenali Isi Piringmu!")
│  │  ├─ onboarding_2_sticker.png   # slide 2: foto menghadap depan
│  │  └─ onboarding_3_sticker.png   # slide 3: foto tersenyum (nuansa optimis)
│  └─ food/                         # 14 ilustrasi makanan, PNG transparan + SVG sumber
└─ screenshots_html_prototype/      # screenshot prototype 390×844 (BUKAN screenshot Flutter)
```

## Foto pengguna

- Sumber: 3 foto asli. Piksel wajah, rambut, baju, pose, dan tangan **tidak diubah** (tanpa regenerasi, tanpa face enhancement, tanpa koreksi warna).
- Yang dilakukan: hapus background (`rembg`, model `u2net_human_seg`), buang lampu gantung / ventilasi di latar foto 1–2 yang menempel di rambut, pertahankan piring di foto 3 (bagian dari pose; mask-nya dikembalikan manual), lalu tambah outline putih die-cut mengikuti siluet + garis hitam tebal.
- Hard black offset shadow **tidak dibake** ke PNG: ditambahkan saat render (`drop-shadow(x y 0 #000)` di HTML; `BoxShadow`/`ColorFiltered` di Flutter) supaya mudah diatur.
- Sisi yang terpotong oleh frame foto (kiri/kanan/bawah) sengaja tidak diberi outline. Letakkan PNG rata dengan tepi bawah area ilustrasi, tertutup kartu teks bergerigi.

## Ilustrasi makanan

Dibuat sebagai vektor (SVG) bergaya stylized dengan outline hitam tebal, gradient, dan highlight, lalu diekspor ke PNG transparan (`assets/food/*.png`) agar Flutter cukup memakai `Image.asset` tanpa dependency baru.
Isi: nasi goreng (+ versi tanpa piring), sate, bakso, pisang goreng, klepon, martabak, ayam goreng, rendang, semangka, mangga, cabai, tomat, wortel.

Catatan jujur: ini bukan render 3D fotorealistis. Kalau mau kualitas 3D premium seperti brief, ganti file di `assets/food/` dengan aset 3D dari ilustrator/generator pilihanmu (nama file dan rasio sama, lihat bagian "Mengganti aset").

## Struktur HTML prototype

| Bagian | Fungsi |
|---|---|
| `:root` tokens | `--nv-green`, `--nv-mint`, `--nv-yellow`, `--nv-orange`, `--nv-cream`, `--nv-black`. **Samakan dengan design token project** sebelum implementasi Flutter. |
| `<svg><defs>` | Library ilustrasi makanan (`<symbol>`), ikon panah/centang/bintang |
| `.stage` | Kanvas portrait 9:16 (tanpa frame HP). Semua ukuran memakai `cqw` (persentase lebar stage) supaya skala proporsional |
| `.track` > `.slide.s1/.s2/.s3` | 3 slide; tiap slide = `.art` (ilustrasi) + `.card` (teks, tepi kertas sobek) |
| `.footer` | Pagination (`.dots`) + tombol `.cta` yang berubah dari bulat (Next) menjadi lebar penuh "Mulai Sekarang" di slide 3 |
| `.skip` | Tombol Skip (disembunyikan di slide terakhir) |
| `.dev` | Panel preview rasio (9:16, 9:19.5, 9:20, layar pendek). Bukan bagian desain |

Interaksi: tombol Next, swipe/drag kiri-kanan (ambang 18% lebar, resistensi di ujung), klik titik pagination, tombol panah keyboard. Skip dan "Mulai Sekarang" hanya menampilkan toast sebagai placeholder navigasi.

## Rencana struktur widget Flutter (belum diimplementasi)

```
OnboardingScreen            // Scaffold + SafeArea, PageController, state index
├─ PageView(children: 3 × OnboardingSlide)
│  └─ OnboardingSlide
│     ├─ OnboardingArt      // Stack: bentuk latar, makanan (Positioned+Transform.rotate), foto sticker
│     └─ TornPaperCard      // CustomClipper untuk tepi sobek + headline (RichText + highlight) + deskripsi
├─ Skip button (hilang di slide 3)
└─ OnboardingControls       // dots + Next / "Mulai Sekarang"
```

## Alur carousel

1. Slide 1 *Food Discovery* → "Kenali Isi Piringmu!"
2. Slide 2 *Nutrition Awareness* → "Setiap Gigitan Punya Arti!"
3. Slide 3 *Healthy Habits* → "Mulai dari Piringmu, Ubah Kebiasaanmu!" + CTA "Mulai Sekarang"

Skip dan CTA harus memakai mekanisme penyimpanan status onboarding dan routing yang sudah ada di project (tidak diubah oleh redesign ini).

## Mengganti aset onboarding

- **Foto:** timpa `assets/photos/onboarding_N_sticker.png` (PNG RGBA, rasio ± 749×989 untuk slide 1, 576×797 untuk slide 2–3). Di HTML foto di-embed base64; jalankan ulang skrip build atau ganti `src` di `<img>`.
- **Makanan:** timpa file di `assets/food/` dengan nama sama. Daftarkan folder di `pubspec.yaml` pada Tahap 2.
- **Warna:** ubah variabel `--nv-*` di HTML (dan token Flutter).

## Hasil pengujian (HTML prototype)

| Uji | Hasil |
|---|---|
| Error konsol / exception JS | 0 |
| Tombol Next (slide 1 → 2) | Lulus |
| Swipe kiri (2 → 3) dan kanan (3 → 2) | Lulus |
| Drag kecil (< ambang) tidak pindah slide | Lulus |
| Drag melewati ujung pertama | Tertahan di slide 1 |
| Skip | Memicu aksi selesai; tersembunyi di slide 3 |
| Tombol terakhir berlabel "Mulai Sekarang" | Lulus |
| Navigasi keyboard ← → | Lulus |
| Layout pada 9:16, 9:19.5, 9:20 dan layar pendek | Tanpa overflow/tabrakan pada pemeriksaan visual |

## Hasil pengujian (Flutter)

| Perintah | Hasil |
|---|---|
| `flutter analyze` | **Lulus 100% (0 issues found)** |
| `flutter test test/onboarding_test.dart` | **Lulus 100% (14/14 tests passed)** |
| `flutter test test/splash_screen_test.dart` | **Lulus 100% (7/7 tests passed)** |
| `flutter test test/design_system_standards_test.dart` | **Lulus 100% (7/7 tests passed)** |
| `flutter test` (Full Project Suite) | **Lulus 100% (333/333 tests passed, 0 failed)** |
| Uji Responsivitas (360x800, 390x844, 393x873, 412x915, 430x932) | **Lulus (Zero RenderFlex overflow)** |

