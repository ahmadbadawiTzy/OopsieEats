# NUTRIVIEW — FULL UX REDESIGN, FUNCTIONAL SCANNER, GAME-STYLE AVATARS & CREATOR PROFILE REPORT

**Tanggal:** 24 Oktober 2026  
**Status:** Sukses Terverifikasi (Build Release APK, 94/94 Test Passed, 0 Lints, Terpasang & Teruji di Device Fisik Android)  
**Target Platform:** Android (Device: Xiaomi Redmi 12 / Android 15)  

---

## 1. RINGKASAN EKSEKUTIF

Proyek antarmuka dan pengalaman pengguna (UX) NutriView telah ditingkatkan secara menyeluruh dengan mengadopsi prinsip **Controlled Overkill Neo-Brutalism**. Seluruh alur utama yang sebelumnya terasa pasif, terputus, atau artifisial kini telah menjadi alur fungsional dengan data riil, kalkulasi otomatis, dan identitas visual yang khas.

### 5 Pilar Implementasi Utama:
1. **Scanner Flow yang Fungsional & Transparan:**
   - Deteksi makanan langsung menampilkan rincian kalori & makronutrisi per 100g.
   - Peringatan transparan (*Unmapped Warning Chip*) jika suatu item memerlukan pencocokan manual.
   - Pada `PortionInputScreen`, kalkulasi kalori & makro (Protein, Karbohidrat, Lemak) diperbarui secara instan (*real-time reactive*) saat pengguna mengetik porsi atau memilih preset chip (`75g (1/2 Porsi)`, `150g (1 Porsi)`, `250g (Porsi Besar)`).
   - Ditambahkan kartu disclaimer jujur bahwa AI mengenali jenis hidangan dari visual, sedangkan porsi gram ditentukan oleh input pengguna.
2. **Beranda / Greeting yang Proporsional & Berorientasi Aksi:**
   - Header greeting disederhanakan menjadi panggilan personal yang ramah (*"Halo, Ahmad!"*).
   - Menghilangkan kesan dominan dan menjawab langsung: *"Apa yang bisa saya lakukan di NutriView sekarang?"* (memindai makanan harian, mengecek target kalori harian, atau membaca artikel gizi).
3. **Katalog Avatar Bergaya Karakter Game (Strictly No Photo Upload):**
   - Karakter game Neo-Brutalism berukuran 96dp diposisikan sebagai jangkar visual utama di tengah atas halaman Profil.
   - Menggantikan upload foto bebas dengan **Katalog 8 Karakter Game Vektor Unik** (`AvatarCatalog`): *Master Koki*, *Pelari Tangguh*, *Cyber Hero*, *Ahli Gizi*, *Pencinta Alam*, *Retro Biker*, *Zen Master*, dan *Penjelajah Bintang*.
   - Setiap karakter memiliki latar belakang warna neo yang kontras, outline tebal 2.5px, bayangan offset, dan atribut visual (topi, kacamata/visor, jaket/pakaian, ekspresi).
   - Pemilihan avatar tersimpan langsung ke Firestore dan tersinkronisasi otomatis ke header Beranda.
4. **Sistem Biodata & Perhitungan Usia Dinamis dari Tanggal Lahir (Full CRUD):**
   - Layar manajemen biodata terdedikasi (`BiodataScreen`) dengan navigasi langsung dari profil.
   - **Perhitungan Usia Dinamis (`AgeCalculator`):** Usia tidak lagi statis atau dihitung dari selisih tahun mentah. Sistem menghitung usia penuh berdasarkan tanggal lahir aktual, memperhitungkan bulan, hari, tahun kabisat (*leap years*), validasi tanggal di masa depan (*future dates*), serta batas rentang 5–120 tahun.
   - Badge usia (*"Usia: X thn"*) terpasang secara dinamis di samping DatePicker tanggal lahir.
   - **Full CRUD:** Pengguna dapat mengisi, melihat, memperbarui, dan menghapus biodata fisik (`deleteBiodata()`) dengan dialog konfirmasi aman yang tidak menghapus akun autentikasi Firebase maupun avatar pengguna.
5. **Layar "Tentang NutriView" & Profil Kreator (Ahmad Badawi):**
   - Layar terdedikasi `AboutScreen` (`/about`) yang dapat diakses dari halaman profil maupun tombol info di AppBar.
   - Memuat identitas aplikasi, versi `1.0.0+1`, serta 4 pilar nilai aplikasi (Pemindai Makanan Praktis, Data Gizi Terverifikasi TKPI, Kebutuhan Kalori Personal, dan Artikel & Panduan Gizi).
   - **Profil Kreator Ahmad Badawi:**
     - Nama: **Ahmad Badawi**
     - Peran: *Software Developer (Web · AI · Mobile)*
     - Bingkai foto profil dengan monogram fallback `AB` dan palet Neo-Brutalism kuning berbayang tegas.
     - Bio otentik: *"Saya adalah software developer yang tertarik membangun aplikasi dan pengalaman digital yang fungsional, interaktif, dan bermanfaat..."*
     - Tautan resmi terverifikasi dengan fitur salin satu ketukan (*tap-to-copy*) berumpan balik snackbar:
       - **GitHub:** `github.com/ahmadbadawiTzy`
       - **LinkedIn:** `linkedin.com/in/ahmad-badawi-b87274410`
       - **Instagram:** `@1hmdbdw_`

---

## 2. HASIL PENGUJIAN DAN VERIFIKASI KUALITAS

### A. Static Analysis (`flutter analyze`)
```bash
$ flutter analyze
Analyzing frontend...
No issues found! (ran in 3.6s)
```
- **0 errors**, **0 warnings**, **0 lints**.
- Seluruh unused import telah dibersihkan.
- Token `cobaltBlue` dan `electricLime` telah terdefinisi secara aman di `NeoTokens`.

### B. Unit & Widget Test Suite (`flutter test`)
```bash
$ flutter test
00:12 +94: All tests passed!
```
- **94/94 test lulus (100% pass rate)** meliputi:
  - `test/age_calculator_test.dart` (8 tests): kalkulasi usia akurat, boundary leap year, batas usia 5–120 tahun, future date validation, dan format tanggal Indonesia.
  - `test/avatar_catalog_test.dart` (5 tests): integritas 8 karakter katalog, keunikan ID, penanganan ID fallback, backward-compatibility mapping.
  - `test/biodata_and_about_test.dart` (3 tests): verifikasi tampilan AboutScreen, profil Ahmad Badawi, copy link to clipboard, dan dynamic age badge pada BiodataScreen.
  - `test/floating_navbar_and_avatar_test.dart` (6 tests).
  - `test/overkill_neobrutalism_dashboard_test.dart` (10 tests).
  - `test/user_navigation_and_article_test.dart` (7 tests).

### C. Build Release & Device Testing
- **Release APK:** `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (37.6 MB dengan obfuscation dan debug-symbols split).
- **Perangkat Uji:** Xiaomi Redmi 12 (Android 15, USB ADB ID `eb9c29d27d73`).
- **Status Instalasi & Runtime:** Sukses terpasang dan seluruh transisi antar layar berjalan mulus pada 60/90 fps.

---

## 3. DOKUMENTASI VISUAL PERANGKAT AKTUAL

### A. Dashboard Utama (Sinkronisasi Avatar Header)
![Beranda NutriView](/home/ahmadbadawi/.gemini/antigravity/brain/53c3f479-ecf7-4e8a-8a28-f4ec026298fb/device_dashboard_updated_avatar.png)
- Header kiri atas menampilkan avatar karakter game Neo-Brutalism yang dipilih pengguna.
- Greeting proporsional dan headline yang berfokus pada aksi harian.

### B. Halaman Profil Terpusat (Centered Game Avatar)
![Profil Pengguna](/home/ahmadbadawi/.gemini/antigravity/brain/53c3f479-ecf7-4e8a-8a28-f4ec026298fb/device_profile_after_biodata.png)
- Avatar 96dp berkarakter game di tengah atas dengan tombol "Pilih Karakter Avatar".
- Kartu metrik fisik ringkas (Usia, Gender, Tinggi, Berat).
- Tombol aksi "Kelola Biodata" dan menu "Tentang NutriView & Pembuat".

### C. Katalog Avatar Game (Interactive Modal Bottom Sheet)
![Katalog Avatar Game](/home/ahmadbadawi/.gemini/antigravity/brain/53c3f479-ecf7-4e8a-8a28-f4ec026298fb/device_avatar_modal.png)
- Preview dinamis di bagian atas dengan nama karakter, badge pilihan, peran, dan detail atribut visual.
- Grid 8 karakter game Neo-Brutalism dengan high-contrast background dan aksen bold.

### D. Manajemen Biodata & Kalkulator Usia Dinamis
![Kelola Biodata](/home/ahmadbadawi/.gemini/antigravity/brain/53c3f479-ecf7-4e8a-8a28-f4ec026298fb/device_biodata_date_updated.png)
- Form input Neo-Brutalism dengan DatePicker tanggal lahir.
- Chip kuning dinamis `"Usia: 20 thn"` yang langsung bereaksi saat tanggal lahir dipilih.
- Aksi "Simpan Perubahan Biodata" dan opsi "Hapus Biodata Fisik".

### E. Dialog Konfirmasi Hapus Biodata (Keamanan Akun Terjaga)
![Dialog Hapus Biodata](/home/ahmadbadawi/.gemini/antigravity/brain/53c3f479-ecf7-4e8a-8a28-f4ec026298fb/device_delete_biodata_dialog.png)
- Pesan peringatan eksplisit: menghapus biodata hanya mereset parameter fisik dan target gizi; sesi login akun dan avatar tetap aman.

### F. Layar Tentang Aplikasi & Profil Kreator (Ahmad Badawi)
![Tentang NutriView & Profil Ahmad Badawi](/home/ahmadbadawi/.gemini/antigravity/brain/53c3f479-ecf7-4e8a-8a28-f4ec026298fb/device_about_creator_scrolled.png)
- Identitas aplikasi, versi release `1.0.0+1`, dan pilar nilai utama.
- Kartu Profil Pengembang **Ahmad Badawi** dengan keahlian Web · AI · Mobile.
- Tautan terverifikasi GitHub, LinkedIn, dan Instagram dengan feedback copy to clipboard.

---

## 4. KESIMPULAN

Pembaruan arsitektur dan antarmuka NutriView ini berhasil menyelesaikan seluruh poin audit UX:
1. Alur scanner kini menyajikan nilai riil dengan umpan balik visual instan.
2. Halaman profil memiliki hierarki visual yang solid berkat avatar karakter game terpusat.
3. Biodata kini memiliki perhitungan usia matematis yang valid dari tanggal lahir dan mendukung siklus CRUD lengkap.
4. Profil Ahmad Badawi sebagai pencipta NutriView ditampilkan secara profesional, otentik, dan menyatu dengan bahasa desain Neo-Brutalism.
