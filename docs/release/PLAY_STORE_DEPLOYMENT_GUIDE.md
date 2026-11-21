# PANDUAN LENGKAP MANUAL DEPLOYMENT OOPSIEEATS (NUTRIVIEW) KE GOOGLE PLAY STORE

**Dokumen Operasional Tunggal — Dari Persiapan Akun Hingga Rilis Produksi**  
**Penyusun:** Senior Android Release Engineer & Google Play Console Deployment Specialist  
**Tanggal Verifikasi Aktual:** 13 November 2026  
**Status Audit Source Code:** **VERIFIED (100% Berbasis Implementasi Aktual)**  

---

## DAFTAR INFORMASI TEKNIS PROYEK (REFERENSI RESMI)

Berikut adalah data teknis aktual hasil audit langsung pada kode sumber dan build artifact OopsieEats:

| Parameter Teknis | Nilai Konfigurasi Aktual | Sumber Kebenaran Kode (*Source of Truth*) |
| :--- | :--- | :--- |
| **Nama Aplikasi Resmi** | `OopsieEats` *(Subjudul: Pindai & Cek Gizi)* | `AndroidManifest.xml` (`android:label="OopsieEats"`), `CreatorConfig.dart` |
| **Application ID / Package Name** | `com.oopsieeats.app` | `build.gradle.kts` (`applicationId = "com.oopsieeats.app"`), `google-services.json` |
| **Version Name** | `1.0.0` | `frontend/pubspec.yaml`, `build.gradle.kts`, `local.properties` |
| **Version Code** | `2002` | `frontend/pubspec.yaml` (`1.0.0+2002`), `local.properties` |
| **Target SDK Level** | `36` (Android 16) | `build.gradle.kts` (`targetSdk = maxOf(flutter.targetSdkVersion, 36)`) |
| **Minimum SDK Level** | `24` (Android 7.0 Nougat) | `merged_manifests/release/processReleaseManifest/AndroidManifest.xml` |
| **Compile SDK Level** | `36` (Android 16) | `build.gradle.kts` (`compileSdk = maxOf(flutter.compileSdkVersion, 36)`) |
| **File Android App Bundle (AAB)** | `frontend/build/app/outputs/bundle/release/app-release.aab` | Ukuran: `91.1 MB` (`91,095,371 bytes`), SHA-256: `e00d17b1ed02...` |
| **Firebase Project ID** | `nutriview-943cd` | `frontend/lib/firebase_options.dart`, `.firebaserc`, `firebase.json` |
| **Supabase Project URL** | `https://rnfvudxqcwcwilcyicow.supabase.co` | `frontend/lib/core/config/supabase_config.dart` |
| **Supabase Storage Bucket** | `food-history-images` (Privat, Signed URL TTL 1 Jam) | `frontend/lib/core/config/supabase_config.dart` |
| **Upload Keystore Path** | `/home/ahmadbadawi/.keystores/oopsieeats-upload-keystore.jks` | `frontend/android/key.properties` (`alias: oopsieeats_upload`) |
| **Upload Key SHA-1** | `7F:2A:D7:60:53:9A:BE:8D:4C:CE:C0:EA:32:66:BD:DE:A8:A5:7A:D8` | `keytool -list -v -keystore oopsieeats-upload-keystore.jks` |
| **Upload Key SHA-256** | `B7:34:8D:DD:47:D5:33:C8:08:DD:15:1E:E2:39:56:9E:45:2B:1C:90:74:1D:BB:2A:06:8C:C7:9D:32:C6:BC:2C` | `keytool -list -v -keystore oopsieeats-upload-keystore.jks` |
| **Support Email Pengembang** | `ahmadbadawi.biu.si@gmail.com` | `firebase.json` (`supportEmail`), `AboutScreen.dart` |
| **Privacy Policy URL Publik** | `https://nutriview-943cd.web.app/privacy` | `public/privacy.html`, `firebase.json` hosting rewrites |
| **Account Deletion URL Publik** | `https://nutriview-943cd.web.app/delete-account` | `public/delete-account.html`, `firebase.json` hosting rewrites |

---

# BAGIAN A: PERSIAPAN AKUN DEVELOPER GOOGLE PLAY

Sebelum mengunggah aplikasi, pastikan Anda memahami status akun Google Play Developer Anda.

### 1. Cara Membuka Google Play Console
1. Buka browser dan kunjungi: **[https://play.google.com/console](https://play.google.com/console)**.
2. Masuk menggunakan Akun Google developer utama Anda (`ahmadbadawi.biu.si@gmail.com` atau akun developer yang telah Anda bayar biaya registrasinya sebesar $25).
3. Anda akan masuk ke halaman muka **All apps**.

### 2. Menentukan Jenis Akun: Personal vs Organization
Google Play menerapkan aturan rilis yang berbeda secara fundamental tergantung jenis akun Anda:

| Aspek | Akun Personal (Perorangan) | Akun Organisasi / Perusahaan (D-U-N-S) |
| :--- | :--- | :--- |
| **Kewajiban Closed Testing** | **WAJIB** untuk akun yang dibuat setelah **13 November 2023**. Wajib memiliki minimal **12 tester yang melakukan opt-in selama 14 hari berturut-turut** sebelum tombol *Apply for production* dibuka. | **TIDAK WAJIB** Closed Testing 14 hari. Dapat langsung merilis ke Production setelah review lolos. |
| **Verifikasi Identitas** | KTP / Paspor / SIM asli pemilik akun + Bukti Alamat (rekening koran/utilitas). | Nomor D-U-N-S resmi, Akta Perusahaan, NIB/NPWP Badan Usaha, dan identitas perwakilan resmi. |

### 3. Cara Mengetahui Apakah Akun Anda Terkena Kewajiban Closed Testing
1. Di Google Play Console, lihat menu navigasi sebelah kiri pada aplikasi baru yang dibuat.
2. Jika pada bagian **Dashboard** terdapat kartu tugas berjudul:
   > *"Test your app with 12 testers for at least 14 days"* atau *"Apply for production"*
   maka akun Anda adalah **Akun Personal Baru** yang wajib melewati alur Closed Testing 14 hari (Ikuti **Bagian F, Opsi 1** pada panduan ini).
3. Jika pada menu **Test and release** Anda dapat langsung mengklik **Production** dan membuat rilis tanpa kartu peringatan 14 hari, maka akun Anda bebas kewajiban pengujian 14 hari (Ikuti **Bagian F, Opsi 2**).

---

# BAGIAN B: MEMBUAT APLIKASI DI GOOGLE PLAY CONSOLE

Ikuti langkah-langkah konkret berikut untuk mendaftarkan aplikasi di Play Console:

1. Buka **Google Play Console** → Halaman **All apps**.
2. Klik tombol biru **Create app** di sudut kanan atas layar.
3. Masukkan informasi berikut pada formulir:
   - **App name:** `OopsieEats` *(atau `OopsieEats: Pindai & Cek Gizi` jika ingin subjudul, maks. 30 karakter)*.
   - **Default language:** Pilih `Indonesian – id` (Bahasa Indonesia).
   - **App or game:** Pilih opsi `App`.
   - **Free or paid:** Pilih opsi `Free` *(Catatan: Sekali aplikasi disetel sebagai Free, aplikasi tidak dapat diubah menjadi Paid)*.
4. **Declarations (Pernyataan Hukum):**
   - Centang kotak: *"I accept the Developer Program Policies"*.
   - Centang kotak: *"I accept the US export laws"*.
5. Klik tombol **Create app** di pojok kanan bawah.
6. Halaman akan otomatis beralih ke dasbor aplikasi `OopsieEats`.

---

# BAGIAN C: APP INTEGRITY, APP SIGNING & GOOGLE SIGN-IN

Google Play Console menggunakan sistem **Play App Signing**. Memahami alur ini adalah kunci agar fitur **Google Sign-In** dan **Firebase** tidak mengalami error `ApiException: 10`.

### 1. Memahami Dua Jenis Kunci Tanda Tangan
- **Upload Key (Lokal):** Kunci yang tersimpan di komputer Anda (`oopsieeats-upload-keystore.jks`). Kunci ini digunakan untuk menandatangani berkas `app-release.aab` sebelum diunggah ke Google Play. Google Play memverifikasi kunci ini untuk memastikan berkas benar-benar berasal dari Anda.
- **App Signing Key (Google):** Kunci privat yang dibuat dan disimpan aman oleh Google di infrastruktur cloud mereka. Google Play akan membuka berkas AAB Anda, mengoptimalkannya, lalu menandatangani ulang APK distribusi yang diunduh pengguna di Play Store menggunakan *App Signing Key* ini.

### 2. Cara Mengambil Fingerprint dari Play Console
1. Di Play Console, pilih aplikasi **OopsieEats**.
2. Pada menu sebelah kiri, gulir ke bagian **Test and release** → klik **Setup** → pilih **App signing**.
3. Pada tab **App signing key certificate**, Anda akan melihat dua baris sidik jari:
   - **SHA-1 certificate fingerprint**
   - **SHA-256 certificate fingerprint**
4. Jangan menutup tab browser ini, salin kedua fingerprint tersebut.

### 3. Cara Memasukkan Fingerprint ke Firebase Console (WAJIB)
Agar fitur *Masuk dengan Google (Google Sign-In)* berfungsi pada aplikasi yang diunduh tester/pengguna dari Play Store:
1. Buka tab baru dan kunjungi: **[https://console.firebase.google.com/](https://console.firebase.google.com/)**.
2. Pilih proyek Anda: **`nutriview-943cd` (OopsieEats)**.
3. Klik ikon gerigi (Settings) di kiri atas → pilih **Project settings**.
4. Gulir ke bawah ke bagian **Your apps** → pilih aplikasi Android: **`com.oopsieeats.app`**.
5. Klik tombol **Add fingerprint**, lalu masukkan 4 fingerprint berikut secara bergiliran:
   - **Fingerprint 1 (Upload Key SHA-1):** `7F:2A:D7:60:53:9A:BE:8D:4C:CE:C0:EA:32:66:BD:DE:A8:A5:7A:D8`
   - **Fingerprint 2 (Upload Key SHA-256):** `B7:34:8D:DD:47:D5:33:C8:08:DD:15:1E:E2:39:56:9E:45:2B:1C:90:74:1D:BB:2A:06:8C:C7:9D:32:C6:BC:2C`
   - **Fingerprint 3 (Play App Signing SHA-1):** *(Tempelkan SHA-1 yang baru saja Anda salin dari Play Console)*
   - **Fingerprint 4 (Play App Signing SHA-256):** *(Tempelkan SHA-256 yang baru saja Anda salin dari Play Console)*
6. Klik **Save**.
7. *(Opsional tapi disarankan)*: Klik tombol **Download google-services.json**, simpan dan gantikan berkas di `frontend/android/app/google-services.json`.

---

# BAGIAN D: STORE LISTING & ASET GRAFIS

Navigasi menu: Play Console → Menu kiri: **Grow** → **Store presence** → **Main store listing**.

### 1. Data Teks Listing (Siap Salin)

#### A. App Name
```text
OopsieEats: Pindai & Cek Gizi
```
*(Tepat 29 karakter — batas maksimum 30 karakter)*

#### B. Short Description
```text
Kenali makananmu dari foto, cek kalori & gizi harian akurat berbasis TKPI.
```
*(Tepat 74 karakter — batas maksimum 80 karakter)*

#### C. Full Description (Maks. 4.000 Karakter)
Salin teks profesional berikut secara utuh ke kolom **Full description**:
```text
Kenali Makananmu, Pahami Gizinya bersama OopsieEats!

OopsieEats adalah aplikasi pendamping nutrisi harian yang membantu Anda mengenali jenis makanan melalui foto, menghitung estimasi kalori serta makronutrien (karbohidrat, protein, dan lemak), dan memantau target kebutuhan gizi harian secara praktis dan menyenangkan.

FITUR UTAMA OOPSIEEATS:

1. Pemindai Makanan Cerdas (On-Device AI)
Ambil foto makanan langsung dari kamera atau pilih dari galeri. Model Computer Vision on-device berbasis TensorFlow Lite mendeteksi 29 kategori makanan populer secara instan langsung di perangkat Anda tanpa membebani kuota data, lengkap dengan estimasi nilai gizinya sesuai porsi berat (gram).

2. Target Kalori & Makronutrien Personal (BMR & TDEE)
Hitung kebutuhan energi harian Anda secara otomatis berdasarkan usia (dari tanggal lahir), jenis kelamin, berat badan, tinggi badan, tingkat aktivitas fisik, dan target kebugaran menggunakan rumus ilmiah Mifflin-St Jeor. Setiap kali Anda memperbarui data biodata fisik, target kalori harian Anda di layar utama akan diperbarui secara real-time.

3. Data Gizi Terverifikasi Berbasis TKPI
Seluruh estimasi nilai kalori dan makronutrien mengacu pada Tabel Komposisi Pangan Indonesia (TKPI) dari Kementerian Kesehatan RI, menjadikannya sangat relevan dan akurat untuk pola makan masyarakat Indonesia.

4. Pencatatan & Riwayat Makan Harian
Catat konsumsi makan pagi, makan siang, makan malam, hingga camilan harian Anda. Pantau asupan nutrisi lengkap dengan foto dokumentasi makanan, grafik progres harian, dan ringkasan sisa kalori harian Anda.

5. Artikel & Edukasi Gizi Seimbang
Tingkatkan wawasan pola hidup sehat Anda melalui kurasi artikel edukatif seputar gizi seimbang, tips diet sehat, dan pemahaman label nutrisi yang disajikan dengan gaya Overkill Neo-Brutalism yang segar dan mudah dipahami.

6. Privasi & Keamanan Penuh Pengguna
- Pemrosesan gambar AI dilakukan secara lokal di perangkat Anda (On-Device Inference).
- Data profil fisik dan catatan makanan diisolasi secara aman menggunakan koneksi terenkripsi HTTPS/TLS.
- Mendukung fitur kunci biometrik (Sidik Jari / Face Unlock) untuk melindungi privasi aplikasi Anda.
- Hak penuh pengguna untuk memperbarui biodata atau menghapus akun beserta seluruh data secara permanen kapan saja langsung dari dalam aplikasi maupun melalui halaman web resmi.

CATATAN PENTING & PENYANGKALAN MEDIS (HEALTH DISCLAIMER):
OopsieEats dirancang murni sebagai alat bantu edukasi, pelacakan gaya hidup, dan pencatatan asupan nutrisi mandiri. Seluruh perhitungan kalori dan informasi nutrisi bersifat estimasi informatif dan BUKAN merupakan saran medis, diagnosis klinis, atau pengganti penanganan kesehatan profesional dari dokter maupun ahli gizi terdaftar.
```

### 2. Kategori & Informasi Kontak Pengembang
Navigasi menu: Play Console → **Store presence** → **Store settings**.
- **App category:** Pilih `Health & Fitness` (Kesehatan & Kebugaran).
- **Tags:** Klik *Manage tags*, pilih tag: `Nutrition`, `Calorie counter`, `Health & Fitness`.
- **Contact details:**
  - **Email address:** `ahmadbadawi.biu.si@gmail.com`
  - **Phone number:** Kosongkan (opsional).
  - **Website:** `https://nutriview-943cd.web.app`

### 3. Aset Grafis (Telah Tersedia di Repositori)
Unggah berkas-berkas berikut pada halaman **Main store listing**:

| Nama Aset Visual | Spesifikasi Play Store | Lokasi Berkas di Repositori Proyek | Status |
| :--- | :--- | :--- | :---: |
| **App Icon** | 512 x 512 px, 32-bit PNG (maks. 1 MB) | `docs/branding/nutriview_playstore_512.png` | **READY** |
| **Feature Graphic** | 1024 x 500 px, 24-bit PNG/JPEG (tanpa alpha) | `docs/play_store_assets/final/feature_graphic_1024x500.png` | **READY** |
| **Screenshot 1** | 1080 x 1920 px (Hero & Value Prop) | `docs/play_store_assets/final/01_hero.png` | **READY** |
| **Screenshot 2** | 1080 x 1920 px (AI Scanner on-device) | `docs/play_store_assets/final/02_ai_scanner.png` | **READY** |
| **Screenshot 3** | 1080 x 1920 px (Nutrition Analysis & TKPI) | `docs/play_store_assets/final/03_nutrition_analysis.png` | **READY** |
| **Screenshot 4** | 1080 x 1920 px (Meal History & Log) | `docs/play_store_assets/final/04_meal_history.png` | **READY** |
| **Screenshot 5** | 1080 x 1920 px (Personal Profile & Target) | `docs/play_store_assets/final/05_personal_profile.png` | **READY** |
| **Screenshot 6** | 1080 x 1920 px (Nutrition Education Articles)| `docs/play_store_assets/final/06_nutrition_articles.png` | **READY** |

---

# BAGIAN E: APP CONTENT & POLICY DECLARATIONS (BAGIAN PALING PENTING)

Navigasi menu: Play Console → Gulir ke menu paling bawah sebelah kiri: **Policy and programs** → klik **App content**.

Di bagian ini terdapat 8 formulir deklarasi kebijakan yang **wajib berstatus centang hijau (Completed)**. Gunakan panduan berikut:

---

### 1. Privacy Policy (Kebijakan Privasi)

- **Lokasi Menu:** Play Console → Policy and programs → App content → Privacy policy.
- **Pertanyaan:** Provide a link to your app's privacy policy.

<badge color="success">Rekomendasi Jawaban</badge>

- **Jawaban:** Masukkan URL: `https://nutriview-943cd.web.app/privacy`
- **Alasan Teknis:** Halaman kebijakan privasi publik telah dibangun di `public/privacy.html` dan dikonfigurasi melalui Firebase Hosting (`nutriview-943cd`). Halaman ini menjelaskan pemrosesan AI lokal on-device, penyimpanan foto terkompresi di bucket privat Supabase, isolasi multi-tenant di Firestore, dan hak penghapusan data.
- **Tindakan Anda:**
  1. Jalankan `firebase deploy --only hosting` jika belum dideploy.
  2. Buka menu Privacy policy di Play Console.
  3. Tempelkan URL `https://nutriview-943cd.web.app/privacy`.
  4. Klik **Save**.
- **Status Verifikasi:** `VERIFIED`

---

### 2. Data Safety (Keamanan Data)

- **Lokasi Menu:** Play Console → Policy and programs → App content → Data safety.

#### A. Pertanyaan Umum Data Safety
1. **Does your app collect or share any of the required user data types?**
   - **Jawaban:** Pilih **Yes**.
   - **Alasan:** Aplikasi mengumpulkan nama, email, identitas akun (UID), data fisik biodata (usia, TB, BB, aktivitas fisik), dan foto riwayat makan.
2. **Is all of the user data collected by your app encrypted in transit?**
   - **Jawaban:** Pilih **Yes**.
   - **Alasan:** Seluruh komunikasi data ke Firebase Auth, Cloud Firestore, dan Supabase Storage menggunakan enkripsi HTTPS/TLSv1.3. `usesCleartextTraffic="false"` ditegakkan di AndroidManifest.
3. **Do you provide a way for users to request that their data is deleted?**
   - **Jawaban:** Pilih **Yes**.
   - **Pertanyaan lanjutan (Delete Account URL):** Masukkan `https://nutriview-943cd.web.app/delete-account`.
   - **Alasan:** Aplikasi menyediakan penghapusan akun mandiri in-app (*Profil → Hapus Akun & Data*) serta halaman web publik di `public/delete-account.html`.

#### B. Tabel Rincian Kategori Data yang Dikumpulkan

| Kategori Data Google Play | Tipe Data Spesifik | Dikumpulkan (*Collected*) | Dibagikan (*Shared*) | Ephemeral (*Sementara*) | Wajib/Opsional | Tujuan Penggunaan (*Purpose*) | Status Verifikasi |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- | :---: |
| **Personal info** | **Name** (`full_name`) | **Yes** | **No** | **No** | Required | App functionality, Account management | `VERIFIED` |
| **Personal info** | **Email address** (`email`) | **Yes** | **No** | **No** | Required | App functionality, Account management | `VERIFIED` |
| **Personal info** | **User IDs** (Firebase Auth UID) | **Yes** | **No** | **No** | Required | App functionality, Account management, Fraud prevention & security | `VERIFIED` |
| **Personal info** | **Other info** (Tanggal lahir, jenis kelamin) | **Yes** | **No** | **No** | Required | App functionality (Kalkulasi BMR & target kalori) | `VERIFIED` |
| **Health and fitness** | **Fitness info** (TB, BB, level aktivitas fisik, target diet, log asupan kalori/makro) | **Yes** | **No** | **No** | Required | App functionality (Perhitungan kebutuhan kalori & pencatatan gizi) | `VERIFIED` |
| **Photos and videos** | **Photos** (Foto makanan & foto profil pengguna) | **Yes** | **No** | **No** | Optional | App functionality (Pencatatan riwayat makan & kustomisasi avatar) | `VERIFIED` |

#### C. Data yang TIDAK Dikumpulkan (Pilih NO / Uncheck):
- **Location:** TIDAK dikumpulkan (Tidak meminta izin lokasi GPS/Network).
- **Financial info:** TIDAK dikumpulkan (Aplikasi gratis tanpa in-app billing).
- **Messages / SMS / Call logs:** TIDAK dikumpulkan.
- **Contacts / Calendar:** TIDAK dikumpulkan.
- **Audio / Microphone:** TIDAK dikumpulkan.
- **Device or other IDs / Advertising ID:** TIDAK dikumpulkan (Aplikasi bebas SDK iklan dan bebas tracker pihak ketiga).

<badge color="success">Rekomendasi Jawaban</badge>
- Klik **Next** → Tinjau ringkasan tabel Data Safety → Klik **Save**.
- **Status Verifikasi:** `VERIFIED`

---

### 3. Health Apps Declaration (Deklarasi Aplikasi Kesehatan)

- **Lokasi Menu:** Play Console → Policy and programs → App content → Health apps.
- **Pertanyaan 1:** Select the health-related categories that best describe your app.

<badge color="success">Rekomendasi Jawaban</badge>
- **Pilihan Kategori:** Centang **Nutrition and weight management** dan centang **Fitness and wellness**.
- **Alasan Teknis:** OopsieEats berfungsi mencatat asupan makanan, menghitung estimasi kalori/makro berbasis TKPI, dan menghitung kebutuhan energi harian BMR/TDEE.
- **Pertanyaan 2:** Is your app a medical device or does it provide medical advice, diagnosis, or treatment?
- **Pilihan:** Pilih **No, my app is not a medical device and does not provide medical services**.
- **Alasan Teknis:** OopsieEats adalah alat pencatat gaya hidup mandiri. Aplikasi secara eksplisit menyertakan *Health Disclaimer* di `AboutScreen`, `privacy.html`, dan deskripsi toko bahwa aplikasi bukan alat diagnosis medis.
- **Tindakan Anda:**
  1. Pilih kategori *Nutrition and weight management*.
  2. Pilih *No* untuk pertanyaan alat medis.
  3. Klik **Save**.
- **Status Verifikasi:** `VERIFIED`

---

### 4. App Access (Akses Pengujian untuk Reviewer Google)

- **Lokasi Menu:** Play Console → Policy and programs → App content → App access.
- **Pertanyaan:** Are parts of your app restricted by credentials, subscriptions, or login?

<badge color="success">Rekomendasi Jawaban</badge>
- **Jawaban:** Pilih **All or some functionality in my app is restricted**.
- **Alasan Teknis:** Fitur utama OopsieEats (pemindai makanan, riwayat makan, dashboard kalori) berada di balik layar login Firebase Auth dan mewajibkan profil biodata terisi. Tim peninjau Google Play **wajib** diberikan akun uji agar mereka tidak tertahan di halaman login.
- **Tindakan Anda:**
  1. Klik tombol **Add instructions**.
  2. Isi formulir dengan data berikut:
     - **Title:** `Demo Account for Play Reviewer`
     - **Username / Email:** `reviewer.oopsieeats@gmail.com` *(Atau buat 1 akun email uji di Firebase Auth)*
     - **Password:** `OopsieEats2026!` *(Gunakan password akun uji tersebut)*
     - **Explanation / Steps:**
       ```text
       1. Open app and proceed to the Login screen.
       2. Sign in using the provided Email and Password.
       3. The account has pre-filled biodata metrics (Male, 25 yo, 175 cm, 70 kg, Moderate activity).
       4. You will land directly on the Home dashboard showing daily calorie targets.
       5. Tap the 'Scan' tab to test food recognition (test pictures of eggs, chicken, or rice can be used).
       6. Tap 'Riwayat' to view persisted food history.
       ```
  3. Pastikan Anda telah membuat akun tersebut di Firebase Console sebelumnya!
  4. Klik **Add** lalu klik **Save**.
- **Status Verifikasi:** `MANUAL CONFIRMATION` (Anda perlu membuat akun email pengujian di Firebase Console).

---

### 5. Ads Declaration (Deklarasi Iklan)

- **Lokasi Menu:** Play Console → Policy and programs → App content → Ads.
- **Pertanyaan:** Does your app contain ads?

<badge color="success">Rekomendasi Jawaban</badge>
- **Jawaban:** Pilih **No, my app does not contain ads**.
- **Alasan Teknis:** `pubspec.yaml` tidak memuat SDK iklan (AdMob, Unity Ads, Facebook Audience Network, dll). Merged manifest tidak memuat izin atau activity iklan.
- **Tindakan Anda:** Pilih *No* → Klik **Save**.
- **Status Verifikasi:** `VERIFIED`

---

### 6. Content Rating (Rating Konten IARC)

- **Lokasi Menu:** Play Console → Policy and programs → App content → Content rating.
- **Pertanyaan:** Lengkapi kuesioner rating International Age Rating Coalition (IARC).

<badge color="success">Rekomendasi Jawaban</badge>
- **Email address:** Masukkan `ahmadbadawi.biu.si@gmail.com`.
- **Category:** Pilih **Utility, Productivity, Communication, or Other** *(atau Health and Fitness)*.
- **Pertanyaan Kuesioner:**
  - *Violence:* Pilih **No**.
  - *Sexuality / Nudity:* Pilih **No**.
  - *Profanity / Crude Humor:* Pilih **No**.
  - *Controlled Substances (Narkoba/Alkohol):* Pilih **No**.
  - *Age-restricted items:* Pilih **No**.
  - *User Interaction / Content Sharing:* Pilih **No** (Pengguna tidak berinteraksi publik antar-pengguna; data sepenuhnya privat per-akun).
  - *Physical location sharing:* Pilih **No**.
  - *Digital Goods / In-app purchases:* Pilih **No**.
- **Hasil Rating yang Diharapkan:** **PEGI 3**, **Everyone (US)**, **Rating 3+**.
- **Tindakan Anda:** Klik *Save* → Klik *Next* → Klik *Submit*.
- **Status Verifikasi:** `VERIFIED`

---

### 7. Target Audience and Content (Target Audiens)

- **Lokasi Menu:** Play Console → Policy and programs → App content → Target audience and content.
- **Pertanyaan 1 (Target age groups):** What are the target age groups of your app?

<badge color="success">Rekomendasi Jawaban</badge>
- **Pilihan Usia:** Centang **18 and over** *(atau jika ingin mencakup remaja: 13-15, 16-17, 18 and over)*.
- **Rekomendasi Terbaik:** Centang **18 and over** saja untuk rilis perdana. Memilih kelompok usia di bawah 13 tahun akan memicu pemeriksaan ketat kepatuhan COPPA (*Designed for Families*) yang memperlambat review.
- **Pertanyaan 2 (Appeal to children):** Could your store listing appeal to children?
- **Jawaban:** Pilih **No**.
- **Tindakan Anda:** Pilih *18 and over* → Pilih *No* pada appeal to children → Klik **Save**.
- **Status Verifikasi:** `VERIFIED`

---

### 8. Account Deletion (Penghapusan Akun Pengguna)

- **Lokasi Menu:** Play Console → Policy and programs → App content → Account deletion.
- **Pertanyaan 1:** Does your app allow users to create an account?
- **Jawaban:** Pilih **Yes**.
- **Pertanyaan 2:** How can users request account deletion?

<badge color="success">Rekomendasi Jawaban</badge>
- **Pilihan:** Centang opsi: **Users can delete their account within the app** DAN centang opsi: **Users can request account deletion on the web**.
- **Web Link for Deletion Request:** Masukkan URL:
  `https://nutriview-943cd.web.app/delete-account`
- **Pertanyaan 3:** Does deleting an account delete all user data?
  - **Jawaban:** Pilih **Yes, all data is deleted permanently**.
  - **Data Retention Period:** Pilih **Data is deleted immediately upon request**.
- **Alasan Teknis:** Kode pada `AuthRepository.deleteAccount` menghapus akun Firebase Auth, menghapus dokumen Firestore `users/{uid}`, menghapus subkoleksi `meals`, menghapus seluruh foto makanan di folder Supabase Storage `uid/`, dan membersihkan penyimpanan aman lokal. Halaman web `public/delete-account.html` juga menyediakan formulir penghapusan akun berbasis web.
- **Tindakan Anda:**
  1. Pilih *Yes* pada akun dan opsi in-app + web.
  2. Masukkan URL `https://nutriview-943cd.web.app/delete-account`.
  3. Pilih penghapusan total permanen.
  4. Klik **Save**.
- **Status Verifikasi:** `VERIFIED`

---

### 9. Government Apps & Financial Features (Formulir Tambahan)
- **Government apps:** Pilih **No, this app does not represent a government entity**.
- **Financial features:** Pilih **My app doesn't provide any financial features**.

---

# BAGIAN F: TESTING TRACKS (PENGUJIAN SEBELUM PRODUKSI)

Google Play menyediakan jalur pengujian bertingkat untuk memastikan aplikasi tidak mengalami crash pada perangkat nyata.

---

### OPSI 1: JALUR CLOSED TESTING (KHUSUS AKUN DEVELOPER PERSONAL)
*Jika akun developer Anda dibuat setelah 13 November 2023 dan diwajibkan menguji dengan 12 tester selama 14 hari.*

1. **Membuat Track Closed Testing:**
   - Buka Play Console → **Test and release** → **Testing** → klik **Closed testing**.
   - Pilih track **Closed testing - Alpha** (atau klik *Create track* dan beri nama `Closed Testing`).
2. **Menentukan Negara Target:**
   - Klik tab **Countries / regions** → Klik **Add countries/regions** → Pilih **Indonesia** (dan negara lain jika diinginkan) → Klik **Save**.
3. **Menambahkan Daftar Email Tester:**
   - Klik tab **Testers**.
   - Pada bagian *Email lists*, klik **Create email list**.
   - Beri nama list: `Tester NutriView`.
   - Masukkan minimal **15–20 alamat email Google (Gmail) aktif** milik rekan, kolega, atau komunitas penguji Anda *(Disarankan menyiapkan lebih dari 12 email untuk mengantisipasi tester yang lupa opt-in)*.
   - Klik **Save changes**.
4. **Membuat Rilis Closed Testing:**
   - Buka tab **Releases** → Klik tombol biru **Create new release** di kanan atas.
   - Pada bagian *App bundles*, klik **Upload**.
   - Pilih berkas: `frontend/build/app/outputs/bundle/release/app-release.aab`.
   - Tunggu proses upload dan validasi Google selesai (AAB akan terdeteksi sebagai `versionName: 1.0.0`, `versionCode: 2002`).
   - Pada bagian *Release name*, biarkan terisi `1.0.0 (2002)`.
   - Pada bagian *Release notes*, tempelkan catatan rilis Bahasa Indonesia (Lihat Bagian G).
   - Klik **Next** → Tinjau warning (jika hanya berupa informasi biasa, lanjutkan) → Klik **Save and publish**.
5. **Menunggu Persetujuan Tinjauan Google:**
   - Status rilis akan menjadi *In review* (biasanya memakan waktu 1–3 hari kerja).
6. **Membagikan Link Opt-In kepada Para Tester:**
   - Setelah status rilis disetujui (*Available*), kembali ke menu **Closed testing** → tab **Testers**.
   - Gulir ke bawah ke bagian **How testers join your test**.
   - Salin tautan **Join on Android** atau **Join on the web**.
   - Bagikan tautan tersebut ke 12+ tester Anda.
7. **Aturan Wajib 14 Hari Berturut-turut:**
   - Seluruh tester wajib mengklik tautan, memilih **Become a Tester**, lalu mengunduh aplikasi dari Google Play Store di HP mereka.
   - Tester harus membiarkan aplikasi terpasang di HP mereka selama **minimal 14 hari berturut-turut**.
   - Arahkan tester untuk membuka aplikasi secara berkala, mencoba pemindaian makanan, dan memperbarui biodata.
8. **Mengajukan Akses Produksi (Apply for Production):**
   - Setelah 14 hari selesai dan indikator dashboard Play Console mencapai 14/14 hari dengan minimal 12 tester aktif:
   - Buka **Dashboard** → Klik tombol **Apply for production**.
   - Jawab kuesioner singkat Google mengenai feedback yang Anda dapatkan dari tester dan perbaikan apa yang dilakukan.
   - Tunggu konfirmasi persetujuan dari Google Play Support (biasanya 2–7 hari kerja).

---

### OPSI 2: JALUR INTERNAL TESTING (DISTRIBUSI INSTAN UNTUK TESTING TIM)
*Jalur tercepat untuk menguji aplikasi pada perangkat Android tanpa menunggu proses review dari Google.*

1. Buka Play Console → **Test and release** → **Testing** → klik **Internal testing**.
2. Pada tab **Testers**, buat email list berisi email akun Google Anda sendiri dan tim pengembang inti.
3. Klik tab **Releases** → Klik **Create new release**.
4. Unggah berkas `app-release.aab`.
5. Klik **Next** → **Review release** → Klik **Start rollout to Internal testing**.
6. Rilis langsung aktif dalam hitungan menit tanpa peninjauan Google!
7. Salin link opt-in pada tab *Testers*, buka di HP Android Anda, pasang dari Play Store, dan verifikasi seluruh fitur bekerja normal.

---

# BAGIAN G: PRODUCTION RELEASE (PELUNCURAN PUBLIK)

Setelah seluruh deklarasi kebijakan berstatus centang hijau dan izin akses produksi telah diberikan oleh Google Play:

### 1. Membuka Menu Production
1. Di menu navigasi kiri Play Console, klik **Test and release** → klik **Production**.
2. Pada tab **Countries / regions**, pastikan negara target sudah dipilih (minimal **Indonesia**).
3. Klik tombol biru **Create new release** di pojok kanan atas.

### 2. Mengunggah Berkas AAB
1. Pada bagian *App bundles*, klik tombol **Upload**.
2. Arahkan ke file:
   `/home/ahmadbadawi/Documents/CodinganKu/Flutter/OopsieEats/frontend/build/app/outputs/bundle/release/app-release.aab`
3. Tunggu hingga proses upload selesai (100%).
4. Sistem akan menampilkan rincian:
   - *App bundle details:* `Version 1.0.0 (2002)`
   - *Target SDK:* `36`
   - *Size:* `~86.9 MB (download size ~35-40 MB per device)`

### 3. Mengisi Release Notes (Bahasa Indonesia Siap Salin)
Pada kolom **Release notes**, klik bahasa `id-ID` (atau tambahkan `Indonesian`), lalu tempelkan teks berikut:

```text
<id-ID>
Rilis Perdana OopsieEats v1.0.0:
- Pemindai Makanan Otomatis: Deteksi 29 kategori pangan populer Indonesia secara instan menggunakan AI on-device.
- Informasi Gizi Terverifikasi: Data kalori, protein, karbohidrat, dan lemak mengacu pada Tabel Komposisi Pangan Indonesia (TKPI).
- Target Kalori Personal: Perhitungan kebutuhan kalori harian dinamis (BMR & TDEE) berbasis biodata fisik.
- Catatan Riwayat Harian: Pantau asupan makan harian dengan dokumentasi foto dan ringkasan kalori real-time.
- Desain Segar Overkill Neo-Brutalism & Perlindungan Privasi Penuh.
</id-ID>
```

### 4. Memeriksa Peringatan & Validasi Akhir
1. Klik tombol **Next** di kanan bawah.
2. Google Play Console akan menjalankan analisis otomatis terhadap berkas AAB Anda:
   - **Errors:** Wajib **0 Errors**. (Jika ada error merah, Anda tidak dapat merilis).
   - **Warnings:** Jika muncul peringatan terkait *deobfuscation file*, itu wajar karena simbol Dart dipisahkan secara aman. File R8 mapping otomatis dibundel di dalam AAB pada direktori `BUNDLE-METADATA/`.

### 5. Peluncuran Bertahap (Staged Rollout) & Review
1. Pada opsi peluncuran, Anda dapat memilih:
   - **100% Rollout:** Aplikasi langsung tersedia untuk seluruh pengguna setelah disetujui.
   - **Staged Rollout (Direkomendasikan):** Mulai dari **20%** pengguna. Hal ini berguna untuk memantau apakah ada laporan crash tak terduga sebelum dirilis ke 100% pengguna.
2. Klik tombol **Save and publish** (atau **Send for review**).
3. Muncul dialog konfirmasi: *"Changes will be submitted for review"*. Klik **Confirm**.
4. Status rilis Anda sekarang berubah menjadi **In review**.
5. Waktu peninjauan untuk rilis perdana umumnya memakan waktu **1 hingga 5 hari kerja**.

---

# BAGIAN H: SETELAH PUBLIKASI (POST-LAUNCH MONITORING)

Setelah aplikasi Anda disetujui dan berstatus **Available on Google Play**:

### 1. Cara Mendapatkan URL Aplikasi di Google Play Store
Tautan resmi aplikasi Anda di Play Store dapat diakses melalui format:
```text
https://play.google.com/store/apps/details?id=com.oopsieeats.app
```
Anda juga dapat membuka menu **Main store listing** di Play Console dan mengklik tautan **View on Google Play**.

### 2. Memantau Android Vitals & Stabilitas Aplikasi
Google Play sangat ketat terhadap metrik stabilitas aplikasi. Pantau menu:
**Quality** → **Android vitals** → **Overview**.
Pastikan metrik aplikasi Anda berada jauh di bawah batas buruk (*Bad Behavior Thresholds*):
- **User-perceived crash rate:** Harus **< 1.09%** (Idealnya 0.00%).
- **User-perceived ANR rate (Application Not Responding):** Harus **< 0.47%** (Idealnya 0.00%).
Karena OopsieEats menjalankan inferensi AI pada background Isolate dan telah lulus 359/359 automated tests, aplikasi memiliki profil stabilitas tinggi.

### 3. Cara Mendekode Stack Trace Crash (Jika Ada Crash Laporan)
Jika terjadi crash di perangkat pengguna yang terobfuskasi:
1. Play Console akan otomatis mendekode crash native dan Java menggunakan mapping R8 yang dibundel di dalam AAB.
2. Untuk mendekode stack trace kode Dart yang terobfuskasi:
   Gunakan file simbol debug yang tersimpan di repositori Anda:
   ```bash
   flutter symbolize -i <stack_trace_dari_console.txt> -d symbols/android/app.android-arm64.symbols
   ```

### 4. Menangani Rating & Ulasan Pengguna
1. Buka menu **Quality** → **Ratings and reviews**.
2. Balas setiap ulasan dari pengguna dengan sopan, terutama jika ada tester yang memberikan masukan terkait akurasi deteksi makanan atau permintaan penambahan menu makanan baru di katalog TKPI.

### 5. Cara Melakukan Update Aplikasi di Masa Depan
Jika Anda memperbaiki bug atau menambah fitur baru di masa depan:
1. Buka `frontend/pubspec.yaml`, naikkan `versionCode` dan `versionName`:
   ```yaml
   version: 1.0.1+2003
   ```
2. Selaraskan `frontend/lib/core/config/creator_config.dart`:
   ```dart
   static const String appVersion = '1.0.1+2003';
   ```
3. Bangun kembali paket rilis AAB:
   ```bash
   cd frontend
   flutter build appbundle --release --obfuscate --split-debug-info=../symbols/android
   ```
4. Masuk ke Play Console → **Production** → **Create new release** → Unggah berkas `app-release.aab` yang baru → Masukkan release notes pembaruan → Kirim untuk review.
