# Checklist Listing Google Play Store — NutriView (`OopsieEats`)

Gunakan daftar periksa dan draf teks siap pakai berikut saat melengkapi **Store settings** dan **Main store listing** di Google Play Console.

---

## 1. Identitas & Kategori Store Listing

- **App Name (Maks. 30 karakter):** `OopsieEats: Pindai & Cek Gizi` *(29 karakter)* atau `OopsieEats` *(10 karakter)*
- **Default Language:** Bahasa Indonesia (`id-ID`)
- **App or Game:** App
- **Free or Paid:** Free
- **Category:** *Health & Fitness* (Kesehatan & Kebugaran)
- **Tags:** *Nutrition*, *Calorie Counter*, *Diet & Weight Management*, *Health & Fitness*
- **Contact Details (Store Listing):**
  - **Email (Wajib):** `ahmadbadawi.biu.si@gmail.com`
  - **Website (Opsional):** `https://nutriview-943cd.web.app`
  - **Privacy Policy URL:** `https://nutriview-943cd.web.app/privacy`

---

## 2. Draf Deskripsi Store Listing (Bahasa Indonesia — `id-ID`)

### Short Description (Maks. 80 karakter)
> `Kenali makananmu dari foto, cek kalori & gizi harian akurat berbasis TKPI.` *(74 karakter)*

### Full Description (Maks. 4.000 karakter)
```text
Kenali Makananmu, Pahami Gizinya bersama OopsieEats!

OopsieEats adalah aplikasi pendamping nutrisi harian yang membantu Anda mengenali jenis makanan melalui foto, menghitung estimasi kalori serta makronutrien (karbohidrat, protein, dan lemak), dan memantau target kebutuhan gizi harian secara praktis.

FITUR UTAMA OOPSIEEATS:

1. Pemindai Makanan Cerdas (On-Device AI)
Ambil foto makanan menggunakan kamera atau pilih dari galeri. Model Computer Vision berbasis TensorFlow Lite yang berjalan langsung di perangkat Anda mendeteksi makanan populer Indonesia dan internasional secara cepat serta menghitung estimasi kandungan gizinya sesuai porsi berat (gram).

2. Target Kalori & Makronutrien Personal
Hitung kebutuhan energi harian Anda secara otomatis berdasarkan usia (dari tanggal lahir), jenis kelamin, berat badan, tinggi badan, tingkat aktivitas fisik, dan tujuan kebugaran menggunakan rumus ilmiah Mifflin-St Jeor (BMR & TDEE). Setiap pembaruan biodata langsung menyinkronkan target kalori Anda di layar utama secara real-time.

3. Data Gizi Terverifikasi Berbasis TKPI
Informasi nilai gizi mengacu pada Tabel Komposisi Pangan Indonesia (TKPI) sehingga relevan dengan pola makan sehari-hari masyarakat Indonesia.

4. Catatan & Riwayat Makan Harian
Pantau asupan makan pagi, siang, malam, hingga camilan lengkap dengan foto makanan, rincian kalori, protein, karbohidrat, dan lemak dari hari ke hari.

5. Artikel & Edukasi Gizi Seimbang
Pelajari panduan gizi seimbang, tips pola makan sehat, dan wawasan nutrisi yang disajikan secara ringkas dan mudah dipahami.

6. Privasi & Kendali Penuh atas Data Anda
- Deteksi objek makanan diproses langsung di perangkat Anda (On-Device AI).
- Data profil dan riwayat makan diisolasi secara aman per akun pengguna melalui koneksi terenkripsi HTTPS/TLS.
- Dukungan kunci biometrik (Sidik Jari / Face Unlock) untuk keamanan sesi aplikasi.
- Kendali penuh untuk memperbarui biodata atau menghapus akun beserta seluruh data secara permanen kapan saja langsung dari dalam aplikasi.

Catatan Penting (Disclaimer Kesehatan):
OopsieEats dirancang sebagai alat bantu edukasi dan pencatatan nutrisi harian. Estimasi nilai kalori dan makronutrien bersifat informatif dan tidak menggantikan saran, diagnosis, atau perawatan medis profesional dari dokter maupun ahli gizi terdaftar.
```

---

## 3. Spesifikasi Aset Grafis Wajib di Google Play Console

Pastikan seluruh aset visual berikut telah disiapkan sebelum mempublikasikan listing:

| Aset Visual | Spesifikasi Teknis Google Play | Status Saat Ini | Catatan |
| :--- | :--- | :--- | :--- |
| **App Icon (Hi-Res)** | `512 x 512 px`, PNG 32-bit (dengan alpha), maks. 1 MB | `PASS` (Sumber tersedia di `frontend/assets/branding/app_icon_source.png`, pastikan diekspor tepat `512x512 px`) | Gunakan ikon resmi OopsieEats berlatar mint `#A8E6CF`. |
| **Feature Graphic** | `1024 x 500 px`, PNG 24-bit atau JPEG (tanpa alpha) | `NEEDS MANUAL ACTION` | Buat banner `1024x500` bergaya Neo-Brutalism dengan judul *"Kenali Makananmu, Pahami Gizinya"*. |
| **Phone Screenshots** | Minimal 2–8 tangkapan layar (`16:9` atau `9:16`), sisi pendek min. `320 px`, sisi panjang maks. `3840 px` (disarankan `1080 x 1920 px` atau `1080 x 2400 px`) | `NEEDS MANUAL ACTION` | Ambil screenshot asli dari aplikasi: (1) Onboarding, (2) Beranda & Ringkasan Kalori, (3) Pemindai Makanan AI, (4) Detail Hasil Gizi, (5) Riwayat Makan, (6) Profil & Biodata. |
| **7-inch & 10-inch Tablet Screenshots** | Minimal 1 screenshot per ukuran jika ingin masuk kategori *Designed for tablets* (opsional namun direkomendasikan) | `NEEDS MANUAL ACTION` | Ambil dari emulator tablet atau perangkat layar lebar. |
