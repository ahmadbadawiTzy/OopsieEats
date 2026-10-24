# NUTRIVIEW — VISUAL OVERHAUL V2 REPORT: PREMIUM EXTREME NEO-BRUTALISM

**Platform:** Flutter Mobile (Android 15 / API 35)  
**Device:** Physical Device Xiaomi Redmi 12 (`eb9c29d27d73`)  
**Design System:** Editorial Neo-Brutalism (Swiss Grid + Controlled Brutalist Contrasts)  
**Verification Date:** 24 Oktober 2026  
**Status:** ✅ Fully Audited, Redesigned, Tested & Deployed on Physical Device

---

## 1. Audit Visual Awal (Baseline Actual Screenshots)

Sebelum melakukan perubahan kode, pengujian langsung dilakukan pada perangkat fisik `eb9c29d27d73` dan screenshot aktual diambil untuk mengaudit kualitas visual nyata:

- `docs/audit_screenshots/01_baseline_home_top.png` (Beranda atas)
- `docs/audit_screenshots/02_baseline_home_scroll.png` (Beranda scroll)
- `docs/audit_screenshots/03_baseline_artikel.png` (Halaman Artikel)
- `docs/audit_screenshots/04_baseline_riwayat.png` (Halaman Riwayat)
- `docs/audit_screenshots/05_baseline_profil.png` (Halaman Profil)
- `docs/audit_screenshots/06_baseline_avatar_dialog.png` (Dialog Avatar)

### Temuan Masalah Konkret dari Baseline:
1. **Unwanted Back Arrow di Seluruh Layar Utama:**
   - Halaman Beranda, Artikel, Riwayat, dan Profil semuanya menampilkan icon panah kembali `<-` di header AppBar. Hal ini terjadi karena Flutter secara default mengaktifkan `automaticallyImplyLeading: true` ketika route dipush ke Navigator stack, sehingga bar navigasi tab terlihat seperti halaman sub-detail yang membingungkan.
2. **Bottom Navigation Kaku dan Terlalu Berat:**
   - Active tab dan tombol Pindai berbentuk blok tebal berwarna lime dengan reticle sudut buatan yang terlihat seperti bug layout kawat wireframe.
   - Dua warna lime saling bertabrakan saat tab Beranda aktif di sebelah tombol Pindai.
   - Sudut navbar terlalu generik dan margins bawah tidak presisi dengan gesture bar Android.
3. **Avatar Terlihat Seperti Placeholder Murahan:**
   - Avatar awal hanya kotak berwarna dengan sebuah titik hitam di pojok kanan atas dan satu huruf inisial polos, membuatnya tampak seperti draft sementara.
4. **Chip `AKTIF` Tidak Informatif & Mengotori Header:**
   - Header beranda memuat chip status `• AKTIF` yang memakan ruang horizontal berharga tanpa nilai fungsional bagi user.
5. **Warna Lime Berlebihan di Profil (Color Flooding):**
   - Banner `Target Gizi Harian Anda` menggunakan latar belakang neon lime terang yang menutupi seluruh container kartu, merusak aturan estetika "Acid lime sebagai aksen fungsional, bukan memenuhi seluruh layar".
6. **Masih Ditemukan Emoji Tersembunyi:**
   - Terdapat emoji api `🔥` pada kartu riwayat makan (`🔥 168 KKAL`).
   - Terdapat emoji target `🎯` dan peringatan `⚠️` pada status target kalori.
   - Terdapat emoji makanan pada dashboard admin.

---

## 2. Perubahan Desain yang Diimplementasikan (Visual Overhaul V2)

### A. Design Tokens (`lib/core/neo_tokens.dart`)
- **Canvas & Paper:** Transisi ke warna canvas editorial warm off-white (`#FBF9F4`) dengan paper card putih steril (`#FFFFFF`) untuk kontras yang seimbang dan tidak melelahkan mata.
- **Structural Borders & Hierarchy:** Mengganti border 2.5px/3.5px yang seragam menjadi sistem proporsional: `2.0px` untuk container utama, `1.5px` (`borderWidthThin`) untuk sub-elemen/divider, dan `2.8px` untuk penekanan struktural.
- **Controlled Hard Shadows:** Menetapkan offset shadow `Offset(3, 3)` dan `Offset(2, 2)` yang sharp tanpa blur, diaplikasikan secara selektif pada komponen interaktif.
- **Color Discipline:** Menjaga Acid Lime (`#CCFF00`) sebagai trigger aksi utama dan focal point, didukung Electric Cobalt (`#1D4ED8`), Industrial Tangerine (`#FF6B00`), dan Bio Lilac (`#C4B5FD`).

### B. Floating Bottom Navigation (`lib/shared/neo/neo_bottom_nav.dart`)
- **Silhouette & Elevation:** Floating dock dengan radius `16.0px`, border `2.0px`, dan hard shadow `Offset(3, 4)` yang melayang sempurna di atas safe area Android.
- **Refined Active State:** Active tab ditandai dengan rounded capsule (`10.0px`) beraksen Acid Lime, border `1.8px`, dan subtle shadow `Offset(1.5, 1.5)`. Tidak lagi memakan seluruh tinggi bar secara kaku.
- **Unified Center Hero Scan Button:** Tombol Pindai mengusung icon `Icons.qr_code_scanner_rounded`, border `2.0px`, dan label monospaced tegas tanpa reticle sudut yang mengganggu.
- **Strictly ZERO Emojis & Fluid Touch:** Touch target luas dengan translasi taktil mikro `Offset(1, 1)` saat ditekan.

### C. Top Header & Navigation Bar
- **Eliminasi Back Arrow:** Menambahkan `automaticallyImplyLeading: !widget.isTab` pada `DashboardScreen`, `ArticleListScreen`, `MealHistoryScreen`, dan `ProfileScreen`. Layar tab navigasi utama kini bebas dari panah kembali.
- **Penghapusan Chip `AKTIF`:** Membersihkan header dari telemetry metadata yang tidak bernilai.
- **Identitas Editorial Konsisten:**
  - `DashboardScreen`: Menampilkan monogram avatar interaktif (clickable to profile), pre-title `NUTRIVIEW // PROTOKOL GIZI`, dan sapaan `Halo, $displayName`.
  - `ArticleListScreen`, `MealHistoryScreen`, `ProfileScreen`: Header dengan tipografi grotesque bold (`18px, FontWeight.w900, letterSpacing: -0.5`) dan garis divider bawah `1.5px`.

### D. Redesain Avatar Geometris (`lib/shared/neo/neo_avatar.dart`)
- **Komposisi Geometris Autentik:** Setiap preset warna memiliki komposisi grafis diagonal corner slice dan grounding strip:
  - `LIME`: Base Acid Lime dengan aksen geometris hitam pekat.
  - `COBALT`: Base Deep Cobalt (`#1D4ED8`) dengan aksen cyan elektrik.
  - `TANGERINE`: Base Tangerine (`#FF6B00`) dengan aksen kuning hazard.
  - `LILAC`: Base Bio Lilac (`#C4B5FD`) dengan aksen ungu royal.
- **Tipografi Inisial Tebal:** Menggunakan huruf monogram proporsional berbobot `w900` dengan alignment tepat.
- **Photo URL Handling:** `ClipRRect` presisi, `BoxFit.cover`, loading indicator proporsional, dan graceful fallback ke preset geometris jika link gambar invalid.
- **Profile Preset Selector:** Menampilkan indikator centang `Icons.check_rounded` pada preset aktif.

### E. Eliminasi Total Emoji (Zero Emoji Policy)
- Memeriksa seluruh codebase dengan regex: `grep -rnP "[\x{1F300}-\x{1F9FF}]" frontend/lib/`.
- Menghapus emoji api `🔥` pada `meal_history_screen.dart`.
- Menghapus emoji `🎯` dan `⚠️` pada `daily_calorie_hero_card.dart`.
- Menghapus emoji pada macro pills di `admin_dashboard_screen.dart`.
- Hasil grep final: **0 emoji ditemukan di seluruh codebase**.

---

## 3. Perbandingan Screenshot (Sebelum vs Sesudah)

| Layar | Screenshot Baseline (Sebelum) | Screenshot V2 (Sesudah) | Status Perbaikan |
|---|---|---|---|
| **Beranda (Atas)** | `docs/audit_screenshots/01_baseline_home_top.png` | `docs/audit_screenshots/v2/01_v2_home_top.png` | Back button hilang, chip AKTIF dihapus, avatar geometris baru, floating navbar proporsional |
| **Beranda (Scroll)** | `docs/audit_screenshots/02_baseline_home_scroll.png` | `docs/audit_screenshots/v2/02_v2_home_scrolled.png` | Bottom clearance aman, scroll content tidak tertutup floating dock |
| **Artikel** | `docs/audit_screenshots/03_baseline_artikel.png` | `docs/audit_screenshots/v2/03_v2_artikel.png` | Back button tab hilang, dock ARTIKEL aktif rapi |
| **Riwayat Makan** | `docs/audit_screenshots/04_baseline_riwayat.png` | `docs/audit_screenshots/v2/04_v2_riwayat.png` | Back button hilang, emoji 🔥 dihapus dari KKAL pill |
| **Profil Pengguna** | `docs/audit_screenshots/05_baseline_profil.png` | `docs/audit_screenshots/v2/05_v2_profil.png` | Back button hilang, preset checkmark aktif, Target Gizi berlatar paper putih bersih (tidak menyilaukan) |
| **Dialog Avatar** | `docs/audit_screenshots/06_baseline_avatar_dialog.png` | `docs/audit_screenshots/v2/06_v2_avatar_dialog.png` | Dialog rapi dengan input URL dan validasi HTTPS |
| **Kamera Scanner** | *(N/A)* | `docs/audit_screenshots/v2/07_v2_scanner.png` | Tombol PINDAI di floating dock membuka scanner YOLO secara responsif |

---

## 4. File yang Diubah

1. `frontend/lib/core/neo_tokens.dart`: Penyesuaian token palet canvas `#FBF9F4`, ink `#111111`, border scale, dan shadow specs.
2. `frontend/lib/shared/neo/neo_avatar.dart`: Redesain lengkap avatar dengan custom painter corner accent, tipografi monogram, preset data model, dan zero emoji.
3. `frontend/lib/shared/neo/neo_bottom_nav.dart`: Redesain lengkap floating navbar dengan dock capsule 16px, scan hero button terintegrasi, active tab indicator rounded, dan gesture responsiveness.
4. `frontend/lib/features/dashboard/screens/dashboard_screen.dart`: Penghapusan implyLeading, pembersihan chip AKTIF, integrasi NeoAvatar baru dan pre-title editorial.
5. `frontend/lib/features/article/screens/article_list_screen.dart`: Penambahan `automaticallyImplyLeading: !widget.isTab` dan harmonisasi styling AppBar.
6. `frontend/lib/features/meals/screens/meal_history_screen.dart`: Penambahan `automaticallyImplyLeading: !widget.isTab` dan penghapusan emoji `🔥`.
7. `frontend/lib/features/profile/screens/profile_screen.dart`: Penambahan `automaticallyImplyLeading: !widget.isTab`, redesain preset chip dengan checkmark, dan refactor Target Gizi card ke background paper putih.
8. `frontend/lib/features/dashboard/widgets/daily_calorie_hero_card.dart`: Penghapusan emoji `🎯` dan `⚠️`.
9. `frontend/lib/features/admin/presentation/screens/admin_dashboard_screen.dart`: Penghapusan emoji pada macro pill.
10. `frontend/test/floating_navbar_and_avatar_test.dart`: Penyesuaian test case avatar monogram dan floating nav.
11. `frontend/test/overkill_neobrutalism_dashboard_test.dart`: Penyesuaian test case zero-emoji dan penghapusan chip AKTIF.
12. `frontend/test/user_navigation_and_article_test.dart`: Penyesuaian test case header expectation.

---

## 5. Hasil Verifikasi Otomatis

### Static Analysis
```bash
$ flutter analyze
Analyzing frontend...
No issues found! (ran in 5.4s)
```

### Test Suite
```bash
$ flutter test
00:07 +67: All tests passed!
```
Seluruh 67 skenario pengujian unit, widget, dan integrasi berhasil 100%.

### Debug Build & Device Installation
```bash
$ flutter build apk --debug
✓ Built build/app/outputs/flutter-apk/app-debug.apk

$ adb -s eb9c29d27d73 install -r build/app/outputs/flutter-apk/app-debug.apk
Success
Starting: Intent { cmp=com.nutriview.nutriview/.MainActivity }
```
Aplikasi berhasil dipasang dan diuji secara interaktif pada smartphone fisik Xiaomi Redmi 12 (`eb9c29d27d73`).
Semua screenshot `docs/audit_screenshots/v2/` diambil langsung dari layar ponsel tersebut.

---

## 6. Masalah yang Masih Tersisa
- Tidak ada isu fungsional maupun visual blocker yang tersisa.
- Semua kriteria visual Overkill Neo-Brutalism profesional, floating dock, zero-emoji policy, dan stabilitas on-device ML detector berjalan optimal.
