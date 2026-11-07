# LAPORAN REDESIGN RIWAYAT MAKAN (MEAL HISTORY) — NUTRIVIEW

**Proyek:** NutriView — Food Nutrition Recognition & Daily Tracking App  
**Tanggal:** 7 November 2026  
**Status Evaluasi:** **PASS** (100% Diverifikasi & Teruji)  
**Metodologi:** Controlled Neo-Brutalism & Multi-Screen Responsive Architecture  

---

## 1. Ringkasan Eksekutif

Laporan ini mendokumentasikan proses audit, identifikasi masalah, perancangan ulang (redesign), perbaikan layout, dan verifikasi menyeluruh untuk halaman **Riwayat Makan (Meal History Screen)** pada aplikasi NutriView.

Pekerjaan ini dilakukan untuk menyelesaikan permasalahan kritis yang terjadi pada rilis sebelumnya:
1. **RenderFlex Overflow Crash:** Baris metadata card riwayat makan mengalami *overflow 1.4 px* pada layar perangkat nyata (Xiaomi Redmi 12 / 360-390dp), menghasilkan garis kuning-hitam di UI.
2. **Ketiadaan Informasi Nama Makanan:** Card riwayat makan sebelumnya hanya menampilkan kategori waktu (misal: "SARAPAN") dan empat angka makronutrien tanpa memunculkan daftar makanan/hidangan yang dikonsumsi pengguna.
3. **Struktur Data Monolitik Tanpa Pengelompokan Tanggal:** Riwayat makan disajikan datar dalam satu list panjang tanpa pemisah tanggal yang jelas, menyulitkan pengguna mengevaluasi asupan harian mereka.
4. **Thumbnail Memori Unbounded:** Thumbnail gambar memuat foto resolusi tinggi kamera dari Supabase Storage tanpa batasan ukuran decode memori (`cacheWidth`/`cacheHeight`), berisiko memicu lonjakan memori (OOM).

Seluruh permasalahan di atas telah diperbaiki secara tuntas dengan mempertahankan identitas visual **Controlled Neo-Brutalism**, menerapkan **Zero-Emoji Policy**, dan mematuhi standar desain ketat NutriView (`AppIcons` Material Rounded, border 2px ink, offset shadow, typography scale).

---

## 2. Kondisi Sebelum Perubahan (Baseline)

| Elemen | Kondisi Lama | Dampak / Kerentanan | Status Awal |
|---|---|---|---|
| **Header Baris Card** | `Row(mainAxisAlignment: spaceBetween, children: [Container(badge), Row(time, chevron)])` tanpa `Flexible`/`Expanded` | Terjadi `RenderFlex overflowed by 1.4 pixels on the right` saat teks waktu atau badge panjang | **FAIL** |
| **Konten Makanan** | Hanya menampilkan `mealTypeLabel` ("SARAPAN") | Pengguna tidak tahu hidangan apa yang dicatat ("Nasi Putih", "Ayam", dll) | **FAIL** |
| **Hierarki Tanggal** | Monolithic `ListView.builder` tanpa pengelompokan | Tidak ada konteks asupan per hari; pengguna harus menghitung manual | **FAIL** |
| **Status Filter** | Hanya tombol kecil di AppBar | Pengguna tidak menyadari bahwa daftar sedang terfilter tanggal tertentu | **SUBOPTIMAL** |
| **Decode Gambar** | `Image.network(signedUrl)` tanpa `cacheWidth` | Foto kamera 12MP/4K didecode full resolution (~48MB per bitmap) di GPU RAM | **RISK** |

---

## 3. Akar Masalah (Root Cause Analysis)

1. **Unconstrained Horizontal Flex:**
   Pada baris `Row` header di `meal_history_screen.dart:220:29`, elemen `mealTypeLabel` (misal: "MAKAN SIANG") berada di sisi kiri dan `timeDisplay` (format `'d MMM yyyy, HH:mm'`, misal: "7 Nov 2026, 15:25") bersama icon jam dan icon panah kanan berada di sisi kanan. Di dalam card dengan padding horizontal 14px dan thumbnail 64px + margin 12px, sisa lebar horizontal hanya `252.7px`. Karena kedua sisi tidak memiliki constraint `Flexible(child: Text(..., overflow: TextOverflow.ellipsis))`, teks panjang meluap dan memicu exception Flutter RenderFlex.
2. **Abstraksi Tampilan yang Belum Lengkap:**
   Model `MealRecord` memiliki properti `items: List<MealItem>` yang berisi nama makanan lengkap (`item.foodName`), namun kode UI sebelumnya tidak memetakan `meal.items` ke dalam layout card.
3. **Flattening Data List View:**
   Provider mengembalikan array datar `List<MealRecord>`. Tidak adanya pemrosesan pengelompokan tanggal membuat UI tidak memiliki pemisah hari.

---

## 4. Solusi & Implementasi Redesign

### A. Controlled Neo-Brutalism Card Blueprint
Halaman dan card telah dirancang ulang dengan struktur terisolasi yang kokoh:
1. **Container Utama:** `NeoCard` dengan border hitam 2px (`NeoTokens.borderWidth`), sudut melengkung 10px (`NeoTokens.radiusMedium`), dan bayangan padat tanpa blur (`Offset(2, 2)`).
2. **Thumbnail Responsif (Kiri):** `NeoImageThumbnail` berukuran 64x64 (`size: 64` sesuai skala `avatarCanvas` design system), radius 6px, border 2px ink, dan placeholder fallback `AppIcons.restaurant`.
3. **Kolom Konten (Kanan - `Expanded`):**
   - **Baris 1 (Metadata):** 
     - Badge jenis waktu makan (`SARAPAN`, `MAKAN SIANG`, `MAKAN MALAM`, `CAMILAN`) dengan warna semantik:
       - Sarapan: `NeoTokens.lime` (`#CCFF00`)
       - Makan Siang: `NeoTokens.hazard` (`#FFD600`)
       - Makan Malam: `NeoTokens.lilac` (`#C4B5FD`)
       - Camilan: `NeoTokens.cyan` (`#06B6D4`)
     - Waktu konsumsi (`HH:mm`) dengan icon `AppIcons.accessTime` (size: `AppIcons.sizeMicro`), dilindungi dengan `Flexible` dan `overflow: TextOverflow.ellipsis` agar **mustahil terjadi overflow**.
     - `Spacer` fleksibel dan `AppIcons.chevronRight` (size: `AppIcons.sizeMedium`).
   - **Baris 2 (Daftar Makanan):**
     - Menampilkan nama hidangan dari `meal.items` (contoh: *"Nasi Merah Dada Ayam & Sayur Bayam"*).
     - Tipografi: 14px, weight 800, line height 1.25, `maxLines: 2`, `overflow: TextOverflow.ellipsis`.
   - **Baris 3 (4 Brutal Nutrition Stat Pills):**
     - `Wrap(spacing: 5, runSpacing: 5)` berisi:
       1. **Kalori:** `${kcal} kkal` (Background: `NeoTokens.lime`, Text: `NeoTokens.ink`)
       2. **Protein:** `P: ${protein}g` (Background: `NeoTokens.cobalt`, Text: `NeoTokens.paper`)
       3. **Karbohidrat:** `C: ${carbs}g` (Background: `NeoTokens.tangerine`, Text: `NeoTokens.ink`)
       4. **Lemak:** `F: ${fat}g` (Background: `NeoTokens.lilac`, Text: `NeoTokens.ink`)

### B. Pengelompokan Tanggal & Ringkasan Asupan Harian
- Data riwayat dikelompokkan otomatis berdasarkan `consumedDate` (`Map<String, List<MealRecord>>`).
- Setiap grup tanggal memiliki header elegan:
  - Indikator aksen vertikal `NeoTokens.cobalt`.
  - Format tanggal manusiawi Indonesia: `"HARI INI • 7 NOV 2026"`, `"KEMARIN • 6 NOV 2026"`, atau `"SABTU, 5 NOV 2026"`.
  - Badge total kalori hari tersebut (misal: `"1.450 KKAL"`), memberikan ringkasan instan kepada pengguna.
- Daftar digulirkan secara virtual melalui `ListView.builder` dengan tipe item tersegel (`_HistoryListItem`), menjaga framerate tetap di 60/120 FPS.

### C. Active Filter Banner & Interaktivitas
- Saat pengguna memilih filter tanggal melalui DatePicker, sebuah banner aksen `NeoTokens.hazard` muncul di bawah AppBar.
- Banner menampilkan tanggal filter aktif dan tombol aksi `RESET` dengan icon `AppIcons.clear` untuk mengembalikan tampilan ke seluruh riwayat dengan satu sentuhan.
- Dilengkapi `RefreshIndicator` untuk pull-to-refresh data terbaru.

---

## 5. File yang Dimodifikasi & Dibuat

1. `frontend/lib/features/meals/screens/meal_history_screen.dart`:
   - Penulisan ulang total implementasi UI Riwayat Makan (Controlled Neo-Brutalism, date grouping, food items display, overflow-proof metadata row).
2. `frontend/lib/shared/widgets/neo_image_thumbnail.dart`:
   - Penambahan optimasi decoding memori `cacheWidth` dan `cacheHeight` pada `Image.network`.
3. `frontend/test/meal_history_redesign_test.dart`:
   - Test suite baru berisi 7 skenario pengujian komprehensif (Empty State, Loading State, Populated State, Card Navigation, Active Filter Banner, dan Responsive Layout Guard pada 320px & 360px 1.4x scale).
4. `frontend/test/meal_history_image_widget_test.dart` & `frontend/test/supabase_storage_service_test.dart`:
   - Pembersihan import yang tidak digunakan untuk menjamin 0 lint warning.

---

## 6. Hasil Verifikasi & Pengujian

| Pengujian | Target | Hasil | Bukti Verifikasi |
|---|---|---|---|
| **Flutter Static Analysis** | `flutter analyze` | **PASS** | 0 error, 0 warning, 0 lint issue |
| **Design System Standards** | `test/design_system_standards_test.dart` | **PASS** | Memenuhi aturan ikon Material Rounded, skala font, dan iconScale |
| **Widget & State Tests** | `test/meal_history_redesign_test.dart` | **PASS** | 7/7 test lulus (Empty, Loading, Populated, Routing, Filter) |
| **Responsive Screen 320px** | Lebar layar sempit (iPhone SE 1st gen) | **PASS** | `tester.takeException() == null`, zero RenderFlex overflow |
| **Font Scaling 1.4x** | Aksesibilitas Android Large Text | **PASS** | Layout adaptif tanpa pemotongan atau overlap |
| **Full Regression Suite** | Seluruh unit & widget tests NutriView | **PASS** | **271/271 tests passed** tanpa regresi |

---

## 7. Kesimpulan
Halaman **Riwayat Makan NutriView** kini telah memiliki tampilan profesional, tangguh, responsif di seluruh variasi form factor mobile, menampilkan informasi makanan secara lengkap, dan sepenuhnya selaras dengan ekosistem visual Controlled Neo-Brutalism NutriView.
