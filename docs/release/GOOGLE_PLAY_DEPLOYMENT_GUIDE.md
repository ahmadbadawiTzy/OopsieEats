# Panduan Lengkap Deployment Google Play Console — OopsieEats (NutriView)

**Versi Target:** `1.0.0+2002` (`versionName: "1.0.0"`, `versionCode: 2002`)  
**Package Name / Application ID:** `com.oopsieeats.app`  
**Target SDK:** Android 16 (API Level 36)  
**Keystore Alias:** `oopsieeats_upload`  
**Lokasi AAB Rilis:** `frontend/build/app/outputs/bundle/release/app-release.aab`  

Dokumen ini memandu langkah demi langkah proses deployment ke Google Play Console secara terstruktur dari pembuatan aplikasi hingga peluncuran produksi (*Production Rollout*).

---

## A. Create App (Membuat Aplikasi di Play Console)

| Field / Opsi | Nilai yang Harus Dimasukkan |
| :--- | :--- |
| **Lokasi Menu** | Google Play Console → **All apps** → Klik tombol biru **Create app** (kanan atas) |
| **App Name** | `OopsieEats` *(atau `OopsieEats: Pindai & Cek Gizi` maks. 30 karakter)* |
| **Default Language** | `Indonesian – id` (Bahasa Indonesia) |
| **App or Game** | Pilih **App** |
| **Free or Paid** | Pilih **Free** (Aplikasi gratis tanpa biaya unduh) |
| **Declarations** | Centang persetujuan: (1) Developer Program Policies, (2) US export laws |
| **Status Saat Ini** | `NEEDS MANUAL ACTION` (Harus dibuat langsung di Play Console oleh pemilik akun) |
| **Bukti Penyelesaian** | Dashboard aplikasi `OopsieEats` tampil di daftar aplikasi Play Console |

---

## B. App Integrity & Play App Signing

Google Play memisahkan dua jenis kunci kriptografi: **Upload Key** (milik Anda secara lokal) dan **App Signing Key** (dikelola Google Play untuk menandatangani APK yang didistribusikan ke pengguna).

### 1. Registrasi Upload Certificate ke Play Console
- **Lokasi Menu:** Play Console → Pilih aplikasi `OopsieEats` → Menu kiri: **Test and release** → **Setup** → **App signing**
- **Metode Signing:** Pilih **Use Google-generated key** (Play App Signing default).
- Saat mengunggah `app-release.aab` pertama kali, Play Console akan otomatis mengenali sertifikat upload Anda:
  - **Upload SHA-1:** `7F:2A:D7:60:53:9A:BE:8D:4C:CE:C0:EA:32:66:BD:DE:A8:A5:7A:D8`
  - **Upload SHA-256:** `B7:34:8D:DD:47:D5:33:C8:08:DD:15:1E:E2:39:56:9E:45:2B:1C:90:74:1D:BB:2A:06:8C:C7:9D:32:C6:BC:2C`

### 2. Sinkronisasi Kunci ke Firebase Console (KRITIKAL UNTUK GOOGLE SIGN-IN)
Setelah rilis pertama diunggah:
1. Buka **Play Console → Setup → App signing**.
2. Salin **SHA-1** dan **SHA-256** pada bagian **App signing key certificate**.
3. Buka **Firebase Console (`nutriview-943cd`) → Project Settings → General → Android App (`com.oopsieeats.app`)**.
4. Klik **Add fingerprint** dan masukkan:
   - SHA-1 milik *Upload Key* (`7F:2A:D7:60:53:9A:BE:8D:4C:CE:C0:EA:32:66:BD:DE:A8:A5:7A:D8`)
   - SHA-256 milik *Upload Key* (`B7:34:8D:DD:47:D5:33:C8:08:DD:15:1E:E2:39:56:9E:45:2B:1C:90:74:1D:BB:2A:06:8C:C7:9D:32:C6:BC:2C`)
   - SHA-1 milik *Play App Signing Key* (disalin dari Play Console)
   - SHA-256 milik *Play App Signing Key* (disalin dari Play Console)
- **Status Saat Ini:** `NEEDS MANUAL ACTION` (Upload Key siap; Play App Signing Key tersedia setelah upload AAB pertama)
- **Bukti Penyelesaian:** 4 fingerprint terdaftar pada aplikasi `com.oopsieeats.app` di Firebase Console.

---

## C. Store Listing & Visual Assets

- **Lokasi Menu:** Play Console → Menu kiri: **Grow** → **Store presence** → **Main store listing**

| Komponen Metadata | Spesifikasi & Lokasi File Sumber | Konten / Data yang Dimasukkan | Status |
| :--- | :--- | :--- | :--- |
| **App Name** | Maks 30 karakter | `OopsieEats: Pindai & Cek Gizi` | Siap |
| **Short Description** | Maks 80 karakter | `Kenali makananmu dari foto, cek kalori & gizi harian akurat berbasis TKPI.` *(74 karakter)* | Siap |
| **Full Description** | Maks 4.000 karakter | Gunakan teks draf lengkap pada `docs/release/PLAY_STORE_LISTING_CHECKLIST.md` (bagian 2) | Siap |
| **App Icon** | 512 x 512 px, PNG 32-bit | `docs/branding/nutriview_playstore_512.png` *(512x512 RGBA)* | `PASS` (Tersedia) |
| **Feature Graphic** | 1024 x 500 px, PNG 24-bit/RGB | `docs/play_store_assets/final/feature_graphic_1024x500.png` *(1024x500 RGB)* | `PASS` (Tersedia) |
| **Phone Screenshots** | 1080 x 1920 px, 6 file PNG | `docs/play_store_assets/final/01_hero.png`<br>`docs/play_store_assets/final/02_ai_scanner.png`<br>`docs/play_store_assets/final/03_nutrition_analysis.png`<br>`docs/play_store_assets/final/04_meal_history.png`<br>`docs/play_store_assets/final/05_personal_profile.png`<br>`docs/play_store_assets/final/06_nutrition_articles.png` | `PASS` (Tersedia) |
| **Category** | Dropdown | **Health & Fitness** | Siap |
| **Contact Email** | Email aktif | `ahmadbadawi.biu.si@gmail.com` | Siap |
| **Privacy Policy URL** | URL HTTPS publik | `https://nutriview-943cd.web.app/privacy` | Siap |

---

## D. App Content & Policy Declarations

- **Lokasi Menu:** Play Console → Menu kiri paling bawah: **Policy and programs** → **App content**

Lengkapi seluruh formulir kebijakan berikut:

### 1. Data Safety Questionnaire
- **Does your app collect or share data?** → **Yes**
- **Is data encrypted in transit?** → **Yes** (HTTPS/TLS)
- **Do you provide a way to request account deletion?** → **Yes**
  - **Account Deletion URL:** `https://nutriview-943cd.web.app/delete-account`
- **Data types collected:**
  - *Personal info:* Name (`full_name`), Email (`email`), User IDs (`uid`), Other Info (Tanggal lahir / Usia, Jenis kelamin)
  - *Health and fitness:* Fitness info (Tinggi badan, berat badan, tingkat aktivitas fisik, riwayat asupan kalori/makronutrien harian)
  - *Photos and videos:* Photos (Foto makanan untuk riwayat makan & foto profil pengguna)
- **Data sharing:** No data is shared with third parties.
- **Data ephemeral:** Not ephemeral (Disimpan di Firestore & Supabase Storage privat pengguna).

### 2. Health Apps Declaration
- **Kategori:** *Nutrition and Weight Management* & *Fitness and Wellness*.
- **Pernyataan:** Aplikasi **bukan** perangkat medis (*Not a medical device*) dan tidak ditujukan untuk mendiagnosis, menyembuhkan, atau mencegah penyakit.

### 3. App Access (Kredensial Pengujian Reviewer Google)
- **Pilihan:** **"All or some functionality in my app is restricted"**
- **Instruksi untuk Reviewer Google Play:**
  - Tambahkan 1 set kredensial akun uji coba aktif:
    - *Email:* Sediakan akun uji (misal: `reviewer.nutriview@gmail.com`)
    - *Password:* Masukkan password akun uji tersebut
    - *Instructions:* "Sign in using Email & Password. Biodata is pre-filled with normal physical metrics. Access Home, Scan tab, and Meal History to test food scanning and calorie calculation."

### 4. Ads Declaration
- Pilih **No, my app does not contain ads**.

### 5. Content Rating (IARC)
- Mulai kuesioner baru → Kategori *Utility, Productivity, Communication, or Other*.
- Jawab seluruh pertanyaan terkait kekerasan, seksualitas, bahasa kasar, dan perjudian dengan **No**.
- Rating yang diharapkan: **PEGI 3** / **Everyone**.

### 6. Target Audience
- Pilih kelompok usia **18 and over** (atau **13+**).
- **Appeal to children:** Pilih **No**.

### 7. Government Apps
- Pilih **No, this app does not represent a government entity**.

---

## E. Testing (Internal Testing & Closed Testing)

### Track 1: Internal Testing (Distribusi Instan)
- **Lokasi Menu:** Play Console → **Test and release** → **Testing** → **Internal testing**
- **Tujuan:** Pengujian kilat tanpa menunggu proses tinjauan Google (*review-free instant distribution*).
- **Langkah:**
  1. Klik **Create new release**.
  2. Unggah `frontend/build/app/outputs/bundle/release/app-release.aab`.
  3. Release name: `1.0.0 (2002)`.
  4. Simpan dan klik **Review release** → **Start rollout to Internal testing**.
  5. Pada tab **Testers**, buat email list berisi email tester Anda sendiri, lalu bagikan link *Join on Android*.

### Track 2: Closed Testing (Syarat 12 Testers / 14 Hari untuk Akun Personal)
- **Lokasi Menu:** Play Console → **Test and release** → **Testing** → **Closed testing**
- **Langkah:**
  1. Pilih track **Alpha** (atau buat track Closed Testing baru).
  2. Tambahkan negara target: **Indonesia**.
  3. Pada tab **Testers**, tambahkan email list berisi minimal **15–20 tester** aktif (disarankan lebih dari batas minimum 12).
  4. Promosikan rilis dari Internal Testing atau unggah AAB `app-release.aab`.
  5. Kirim rilis untuk ditinjau oleh tim Google Play (*In review* ~1-3 hari kerja).
  6. Setelah rilis disetujui, bagikan tautan **Join on Android** kepada para tester.
  7. Pastikan minimal 12 tester melakukan opt-in dan memasang aplikasi selama **14 hari berturut-turut**.

---

## F. Production Rollout (Peluncuran Publik)

Setelah syarat Closed Testing terpenuhi dan tombol **Apply for production** disetujui:
1. **Lokasi Menu:** Play Console → **Test and release** → **Production**
2. Klik **Create new release**.
3. Promosikan rilis yang terbukti stabil dari Closed Testing (atau unggah AAB baru jika ada perbaikan bug).
4. Masukkan **Release notes (id-ID)**:
   ```text
   <id-ID>
   Rilis perdana OopsieEats v1.0.0:
   - Pemindai makanan otomatis berbasis AI on-device (29 kategori pangan populer)
   - Perhitungan target kalori harian & makronutrien personal (BMR/TDEE)
   - Pencatatan riwayat makan harian & sinkronisasi real-time
   - Katalog pangan Tabel Komposisi Pangan Indonesia (TKPI) & artikel edukasi gizi
   </id-ID>
   ```
5. Pilih persentase peluncuran bertahap (*Staged Rollout*): Disarankan mulai dari **20%** pengguna pada hari pertama, lalu pantau Android Vitals selama 24 jam sebelum dinaikkan ke **50%** dan **100%**.
6. Klik **Review release** → **Start rollout to Production**.
7. Pantau menu **Quality → Android Vitals** (Crash rate < 1.09%, ANR rate < 0.47%).
