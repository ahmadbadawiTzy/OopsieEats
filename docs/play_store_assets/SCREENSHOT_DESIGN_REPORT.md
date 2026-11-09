# OOPSIEEATS — GOOGLE PLAY STORE SCREENSHOTS & PROMOTIONAL VISUAL DESIGN REPORT

**Target Platform:** Google Play Store (Android)  
**Deliverable Set:** 6 Promotional Screenshots (9:16 Portrait, 1080 × 1920 px) + Campaign Overview Poster  
**Design System:** Overkill Neo-Brutalism Design System  
**Device Environment:** Authentic Physical Hardware — Xiaomi Redmi 12 (`23053RN02A`, Android 15 / API 35)  
**Status:** Production Ready (Release Candidate 1)  

---

## 1. EXECUTIVE SUMMARY & DESIGN DIRECTION

Aplikasi **OopsieEats** mengusung filosofi desain **Overkill Neo-Brutalism**: visual berani, percaya diri, kontras tinggi, border hitam tegas, hard offset drop shadows tanpa blur, dan aksen warna bervoltase tinggi (Acid Lime, Hazard Yellow, Deep Cobalt, Mint Cyan, Tangerine, Bio Lilac, dan Emerald Green).

Untuk peluncuran di Google Play Store, screenshot promosi dirancang bukan sekadar tempelan tangkapan layar biasa, melainkan sebuah **kampanye peluncuran editorial modern** yang memadukan estetika teknologi kekinian dan gaya hidup sehat:
- **Hero-First Narrative:** Menyajikan nilai guna aplikasi secara bertahap mulai dari pemantauan kalori harian, pemindaian AI on-device, rincian makronutrien gramasi akurat, jurnal visual riwayat makan, personalisasi BMR/TDEE berbasis formula ilmiah Mifflin-St Jeor, hingga edukasi gizi berbasis bukti medis.
- **100% Authentic Application UI:** Seluruh tangkapan layar diambil langsung dari aplikasi Flutter OopsieEats yang berjalan aktif di perangkat fisik Redmi 12 melalui koneksi ADB native, memastikan nol manipulasi atau mockup rekayasa non-fungsional.
- **Enterprise-Grade Privacy Sanitization:** Seluruh data pribadi pengguna fisik (nama asli, email akun, avatar) telah disanitasi secara deterministik pada level piksel menggunakan branding resmi OopsieEats.

---

## 2. SELECTED SCREENS & NARRATIVE SEQUENCE

| Slide | Nama File | Fitur Utama | Headline & Subtitle | Aksen Visual & Stiker |
| :---: | :--- | :--- | :--- | :--- |
| **01** | `01_hero.png` | **Real-Time Calorie & Macro Dashboard** | **Pantau Kalori, Bangun Pola Sehat**<br>Dashboard gizi interaktif real-time. Hitung target harianmu dengan presisi dan visual yang menyenangkan. | **Acid Lime (`#CCFF00`)**<br>✦ `REAL-TIME SYNC` (Lightning) |
| **02** | `02_ai_scanner.png` | **Instant AI Food Scanner (YOLO & TKPI)** | **Pindai Makanan Dalam Hitungan Detik**<br>Model AI on-device cepat & akurat tanpa internet. Didukung ribuan data gizi resmi Kemenkes RI (TKPI). | **Hazard Yellow (`#FFD600`)**<br>✦ `100% OFFLINE AI` (Bolt) |
| **03** | `03_nutrition_analysis.png` | **Macro & Portion Breakdown** | **Pahami Setiap Asupan Nutrisi**<br>Analisis otomatis kalori, protein, karbohidrat, dan lemak lengkap dengan estimasi berat per porsi. | **Mint Cyan (`#06B6D4`)**<br>✦ `PORTION ANALYSIS` (Target) |
| **04** | `04_meal_history.png` | **Daily Visual Food Journal** | **Catatan Makan Lengkap & Teratur**<br>Dokumentasikan perjalanan makan harianmu dengan kartu foto makanan, waktu makan, dan total kalori. | **Bio Lilac (`#C4B5FD`)**<br>✦ `TIMELINE HARIAN` (Bolt) |
| **05** | `05_personal_profile.png` | **Deterministic Science (BMR/TDEE)** | **Dihitung Khusus Sesuai Tubuhmu**<br>Kalkulasi BMR & TDEE ilmiah rumus Mifflin-St Jeor berbasis usia, berat, tinggi, dan intensitas fisik. | **Industrial Tangerine (`#FF6B00`)**<br>✦ `MIFFLIN-ST JEOR` (Target) |
| **06** | `06_nutrition_articles.png` | **Curated Evidence-Based Knowledge** | **Wawasan Gizi & Panduan Pola Hidup**<br>Kurasi artikel kesehatan berbasis bukti medis dari ahli gizi tepercaya untuk gaya hidup yang seimbang. | **Emerald Green (`#16A34A`)**<br>✦ `EVIDENCE-BASED` (Star) |

---

## 3. OVERKILL NEO-BRUTALISM DESIGN SYSTEM TOKENS

### A. Typography
- **Headlines (Display):** `Fira Sans Heavy` (52 pt, tracking -0.5, line-height 1.15). Memberikan kesan editorial bold dan percaya diri.
- **Header Chips & Badges:** `Fira Sans Bold` (21 pt, all-caps, tracking +1.0).
- **Supporting Copy:** `Fira Sans Book / Regular` (23 pt, color `#4A4A4A`, line-height 1.25) dengan kontras keterbacaan tinggi di atas latar terang.
- **Floating Stickers:** `Fira Sans Bold` (23 pt) dengan ikon vektor geometris murni (Star, Bolt, Target).

### B. Color Palette
```
Canvas Backgrounds:
  - Slide 01: Warm Editorial Off-White  #FBF9F4
  - Slide 02: Soft Pale Lime            #F4FCE6
  - Slide 03: Soft Pale Cyan / Sky      #EEF8FB
  - Slide 04: Soft Bio Lilac Tint       #F5F0FF
  - Slide 05: Soft Warm Creamsicle      #FFF5EE
  - Slide 06: Soft Fresh Mint           #EBF9F2

Brand Accent Matrix:
  - Inks & Borders: Pitch Black        #111111 (Solid 6px chassis, 3px chips)
  - Hero Voltage: Acid Lime             #CCFF00
  - Highlights: Hazard Yellow           #FFD600
  - Nutrition Protein: Deep Cobalt      #1D4ED8
  - Nutrition Carbs: Tangerine          #FF6B00
  - Nutrition Fat: Bio Lilac            #C4B5FD
  - Nutrition Water/Cam: Mint Cyan      #06B6D4
  - Wellness/Health: Emerald Green      #16A34A
```

### C. Structural Framing & Drop Shadows
- **Chassis Border:** 6px solid `#111111`.
- **Chassis Hard Shadow:** `Offset(10, 10)` solid `#111111` tanpa Gaussian blur (prinsip otentik Neo-Brutalism).
- **Chassis Body:** Titanium Graphite Deep Slate (`#161618`) yang menonjolkan layar aplikasi dengan elegan.
- **Corner Radii:** Outer Chassis = 50px, Inner Screen = 34px, Chips & Stickers = 8–10px.

---

## 4. PHYSICAL DEVICE & CAPTURE ENVIRONMENT

Tangkapan layar diproduksi langsung dari perangkat fisik pengembang untuk menjamin integritas rendering shader Skia/Impeller, font native, dan data dinamis:
- **Device Model:** Xiaomi Redmi 12 (`23053RN02A` / Serial `eb9c29d27d73`)
- **Operating System:** Android 15 (VanillaIceCream / SDK 35)
- **Screen Resolution:** 1080 × 2460 px (Screen Density: 440 dpi)
- **Capture Protocol:** ADB Framebuffer Pipeline (`adb exec-out screencap -p`)
- **Flutter Environment:** Flutter 3.29.3 (Channel stable), Dart 3.7.2

---

## 5. PRIVACY SANITIZATION AUDIT

Privasi pengguna fisik disanitasi secara ketat dan menyeluruh pada level grafis sebelum komposit final:

1. **Slide 01 (`01_hero.png`):**
   - **Avatar Asli:** Avatar default dengan inisial "AB" ditutup total (`X: 90-220, Y: 395-525`) dan digantikan oleh Neo-Brutalist badge "OE" (OopsieEats) berwarna Acid Lime dengan border hitam 5px.
   - **Nama Asli:** Teks "Halo, Ahmad Badawi" dibersihkan secara presisi dan digantikan oleh "Halo, Sahabat Sehat!" menggunakan `Fira Sans Bold` 44pt dengan baseline dan warna `#111111` yang identik dengan tema asli.
2. **Slide 05 (`05_personal_profile.png`):**
   - **Email Akun:** Email pribadi `abadawibadawi000@gmail.com` pada pill akun disanitasi menjadi `user@oopsieeats.app`.
   - **Nama Lengkap:** Input field `Ahmad Badawi` disanitasi menjadi `Pengguna OopsieEats`.
3. **Slide 06 (`06_nutrition_articles.png`):**
   - **Brand Author:** Label "Tim Gizi NutriView" diperbarui secara konsisten menjadi "Tim Gizi OopsieEats" sesuai identitas merek baru.
4. **Status Bar Telepon (Semua Slide):**
   - Indikator status bar bawaan (kecepatan internet `0,08 KB/d`, baterai `88%`, ikon hening) digantikan oleh status bar promosi standar yang bersih: waktu **09:41**, sinyal **5G**, **WiFi** penuh, dan indikator **Baterai 100%**.

---

## 6. DEVICE MOCKUP & ASPECT RATIO ENGINEERING

Layar fisik Redmi 12 memiliki rasio aspek ~20.5:9 (1080 × 2460 px), sedangkan kanvas Google Play Store mensyaratkan rasio potret 9:16 (1080 × 1920 px).

Pendekatan komposit yang diterapkan:
- **Mockup Width:** 860 px (Outer Bezel: 16 px, Inner Screen: 828 px).
- **Scale Factor:** 828 / 1080 = **0.7666**.
- **Display Window:** Menampilkan tinggi konten hingga ~2060 px dari screenshot asli, mencakup 100% seluruh kartu esensial (App Bar, Greetings, Ringkasan Kalori, Makronutrien, Foto Makanan, dan Formulir Biometrik).
- **Graceful Chassis Bleed:** Sasis ponsel diletakkan mulai dari `Y = 395 px` dan memanjang hingga tepi bawah kanvas, memberikan ruang bernapas 395 px di bagian atas untuk tipografi editorial tanpa meremas atau memotong komponen aplikasi penting.

---

## 7. ASSET INVENTORY & SPECIFICATIONS

| File | Dimensi | Format | Ukuran | Status Google Play |
| :--- | :---: | :---: | :---: | :---: |
| `docs/play_store_assets/final/01_hero.png` | 1080 × 1920 | PNG | 309.1 KB | **Memenuhi Syarat (Pass)** |
| `docs/play_store_assets/final/02_ai_scanner.png` | 1080 × 1920 | PNG | 287.5 KB | **Memenuhi Syarat (Pass)** |
| `docs/play_store_assets/final/03_nutrition_analysis.png` | 1080 × 1920 | PNG | 779.3 KB | **Memenuhi Syarat (Pass)** |
| `docs/play_store_assets/final/04_meal_history.png` | 1080 × 1920 | PNG | 167.4 KB | **Memenuhi Syarat (Pass)** |
| `docs/play_store_assets/final/05_personal_profile.png` | 1080 × 1920 | PNG | 228.1 KB | **Memenuhi Syarat (Pass)** |
| `docs/play_store_assets/final/06_nutrition_articles.png` | 1080 × 1920 | PNG | 189.2 KB | **Memenuhi Syarat (Pass)** |
| `docs/play_store_assets/preview/campaign_overview.png` | 2460 × 2860 | PNG | 1.38 MB | **Campaign Master Deck** |

---

## 8. GOOGLE PLAY STORE CONSOLE COMPLIANCE CHECKLIST

- [x] **Format File:** Format PNG lossless 24-bit RGB.
- [x] **Dimensi Minimum & Maksimum:** Tepat 1080 × 1920 px (antara 320 px hingga 3840 px).
- [x] **Rasio Aspek:** Tepat 9:16 (Google Play Portrait Recommendation).
- [x] **Batas Ukuran File:** Seluruh file < 800 KB (Jauh di bawah batas 8 MB Google Play).
- [x] **Kejujuran Representasi (Authenticity):** Menggunakan tangkapan layar antarmuka aplikasi nyata, bukan grafis render 3D konseptual yang menyesatkan.
- [x] **Keterbacaan Teks (Readability):** Kontras rasio teks headline (`#111111`) di atas latar terang (`#FBF9F4`) melebihi 15:1 (Standar WCAG AAA).
- [x] **Nol Data Pribadi Terbuka:** Tidak ada email pribadi, nomor telepon, atau identitas privat yang terekspos.

---

## 9. REPRODUCIBILITY & AUTOMATION

Seluruh visual set ini dapat diproduksi ulang secara otomatis kapan saja menggunakan skrip Python yang telah disediakan di repository:

```bash
# Eksekusi generator dari root project
python3 docs/play_store_assets/generate_play_store_screenshots.py
```

Skrip ini secara otomatis:
1. Membaca 6 screenshot mentah dari `docs/play_store_assets/raw/`.
2. Menerapkan sanitasi privasi dan peremajaan status bar 09:41.
3. Menyusun sasis mockup smartphone neo-brutalist dengan hard shadow.
4. Merender 6 file PNG resolusi 1080 × 1920 px ke folder `final/`.
5. Merender campaign overview poster 2460 × 2860 px ke folder `preview/`.
