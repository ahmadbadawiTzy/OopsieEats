# Kepatuhan Kebijakan Google Play Store — NutriView (`OopsieEats`)

Dokumen ini memetakan kesiapan teknis dan kepatuhan kebijakan Google Play Store untuk **OopsieEats (`com.oopsieeats.app`)**, termasuk panduan pengisian formulir **Data Safety**, **App Content**, **Target Audience**, **Health Apps Declaration**, dan **Account Deletion**.

---

## 1. Matriks Status Kepatuhan Google Play

| Area Kepatuhan | Status | Bukti Teknis / Lokasi Implementasi |
| :--- | :--- | :--- |
| **Format Paket Rilis (`.aab`)** | `PASS` | `frontend/build/app/outputs/bundle/release/app-release.aab` |
| **Target API Level (Android 15/16)** | `PASS` | `targetSdkVersion = 36` (Android 16) dan `compileSdk = 36` di `frontend/android/app/build.gradle.kts` |
| **Kompatibilitas 16 KB Page Size** | `PASS` | Seluruh pustaka `.so` (`arm64-v8a` & `x86_64`) memiliki ELF `LOAD` alignment `0x4000` (16 KB) atau `0x10000` (64 KB); `useLegacyPackaging = false` |
| **Prinsip Izin Minimum (*Least Privilege*)** | `PASS` | Hanya mendeklarasikan `INTERNET`, `CAMERA` (`required="false"`), `USE_BIOMETRIC`, `ACCESS_NETWORK_STATE`. Izin warisan `READ_PHONE_STATE` dan `READ/WRITE_EXTERNAL_STORAGE` dari pustaka transitif dihapus eksplisit dengan `tools:node="remove"` |
| **Keamanan Jaringan (HTTPS/TLS)** | `PASS` | `usesCleartextTraffic="false"` dan `network_security_config.xml` menolak trafik HTTP cleartext pada build rilis |
| **Penghapusan Akun & Data (In-App)** | `PASS` | Tersedia di *Profil → Hapus Akun & Data* (`AuthRepository.deleteAccount`), menghapus dokumen `users/{uid}`, subkoleksi `meals`, `profiles/{uid}`, objek foto di Supabase Storage, kredensial Firebase Auth, dan `FlutterSecureStorage` |
| **Penghapusan Akun & Data (Web Luar Aplikasi)** | `PASS` | Tersedia di `public/delete-account.html` (`https://nutriview-943cd.web.app/delete-account`) |
| **Kebijakan Privasi (Web & In-App)** | `PASS` | Tersedia di `public/privacy.html` (`https://nutriview-943cd.web.app/privacy`) dan dapat diakses dari layar *Tentang OopsieEats* (`AboutScreen`) |
| **Isolasi Data Pengguna Multi-Tenant** | `PASS` | `firestore.rules` menerapkan isolasi `isOwner(userId)` dengan pencegahan eskalasi peran (`data.role == prev.role`) dan validasi skema ketat |
| **Pengisian Formulir Google Play Console** | `NEEDS MANUAL ACTION` | Harus diisi secara manual oleh pemilik akun di Google Play Console sesuai panduan pada Bagian 2–6 di bawah ini |

---

## 2. Audit Izin Android (*Permissions Justification*)

Berikut adalah daftar lengkap izin yang ada pada *merged release* `AndroidManifest.xml`:

| Permission | Tujuan Penggunaan | Wajib / Opsional | Deklarasi Khusus Play Console |
| :--- | :--- | :--- | :--- |
| `android.permission.INTERNET` | Autentikasi Firebase Auth, sinkronisasi Firestore, dan pengunduhan/pengunggahan foto riwayat makanan via HTTPS. | Wajib | Tidak memerlukan deklarasi khusus. |
| `android.permission.ACCESS_NETWORK_STATE` | Memeriksa status konektivitas jaringan sebelum melakukan sinkronisasi cloud. | Wajib | Tidak memerlukan deklarasi khusus. |
| `android.permission.CAMERA` | Mengambil foto makanan untuk dipindai dengan model TFLite on-device atau mengambil foto profil pengguna. `<uses-feature android:name="android.hardware.camera" android:required="false"/>` memastikan perangkat tanpa kamera tetap kompatibel. | Opsional (*Runtime Permission*) | Tidak memerlukan deklarasi izin sensitif berisiko tinggi. |
| `android.permission.USE_BIOMETRIC` / `USE_FINGERPRINT` | Membuka kunci sesi aplikasi secara lokal menggunakan sidik jari atau pengenalan wajah perangkat melalui `local_auth`. | Opsional | Biometrik diproses oleh OS Android (*Keystore/BiometricPrompt*), tidak pernah meninggalkan perangkat. |

> **Catatan Penting Photo Picker:** Aplikasi menggunakan `image_picker` dengan dukungan *Android Photo Picker* tanpa meminta izin `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, atau `READ_EXTERNAL_STORAGE`.

---

## 3. Panduan Pengisian Formulir *Data Safety* (Google Play Console)

Gunakan jawaban berikut saat mengisi formulir **App Content → Data Safety** di Google Play Console agar 100% akurat terhadap perilaku kode sumber:

### 3.1 Pertanyaan Umum Data Safety
1. **Does your app collect or share any of the required user data types?** → **Yes**
2. **Is all of the user data collected by your app encrypted in transit?** → **Yes** (Seluruh komunikasi ke Firebase & Supabase menggunakan HTTPS/TLS).
3. **Do you provide a way for users to request that their data is deleted?** → **Yes**
   - **Delete Account URL:** `https://nutriview-943cd.web.app/delete-account`

### 3.2 Rincian Kategori Data yang Dikumpulkan

| Kategori Google Play | Sub-Tipe Data | Dikumpulkan (*Collected*) | Dibagikan (*Shared*) | Diproses Sementara (*Ephemeral*) | Wajib / Opsional | Tujuan (*Purpose*) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Personal info** | **Name** (`full_name`, nama panggilan) | Yes | No | No | Required | App functionality, Account management |
| **Personal info** | **Email address** (`email`) | Yes | No | No | Required | App functionality, Account management |
| **Personal info** | **User IDs** (Firebase Auth `uid`) | Yes | No | No | Required | App functionality, Account management, Fraud prevention & security |
| **Personal info** | **Other info** (Tanggal lahir / usia, jenis kelamin) | Yes | No | No | Required | App functionality (perhitungan BMR/TDEE & target kalori harian) |
| **Health and fitness** | **Fitness info** (Tinggi badan, berat badan, tingkat aktivitas fisik, riwayat asupan kalori & makronutrien harian) | Yes | No | No | Required | App functionality (pencatatan gizi & kalkulasi kebutuhan kalori harian) |
| **Photos and videos** | **Photos** (Foto makanan pada riwayat makan & foto profil pengguna) | Yes | No | No | Optional | App functionality (pemindaian makanan on-device & tampilan riwayat makan pribadi) |

> **Catatan Data yang TIDAK Dikumpulkan:**
> - **Location (Approximate / Precise):** Tidak dikumpulkan.
> - **Contacts / Calendar / SMS / Call logs / Microphone:** Tidak dikumpulkan.
> - **Financial Info:** Tidak dikumpulkan.
> - **Device or other IDs / Advertising ID:** Tidak dikumpulkan dan aplikasi tidak memuat SDK iklan.

---

## 4. Deklarasi Aplikasi Kesehatan (*Health Apps Declaration*)

Pada bagian **App Content → Health apps** di Google Play Console, pilih kategori yang sesuai dengan fungsi NutriView / OopsieEats:
- **Kategori:** *Nutrition and Weight Management* dan/atau *Fitness and Wellness* (Pelacakan asupan makanan, estimasi kalori/makronutrien berdasarkan Tabel Komposisi Pangan Indonesia, dan perhitungan kebutuhan kalori harian BMR/TDEE).
- **Pernyataan Perangkat Medis:** Aplikasi **bukan** perangkat medis (*Not a medical device*) dan tidak memberikan diagnosis medis.

---

## 5. Target Audiens, Rating Konten (IARC), Iklan & Akses Pengujian

1. **Ads Declaration:** Pilih **No, my app does not contain ads**.
2. **Target Audience and Content:** Pilih kelompok usia **18 and over** (atau **13–15, 16–17, 18 and over**). Pastikan memilih **No** pada pertanyaan apakah aplikasi secara tidak sengaja menarik perhatian anak-anak (*Appeal to children*).
3. **Content Rating (IARC):** Kategori *Utility, Productivity, Communication, or Other* / *Health & Fitness* — tidak mengandung kekerasan, konten seksual, perjudian, atau transaksi uang nyata.
4. **App Access (Kredensial untuk Reviewer Google Play):**
   Karena aplikasi memerlukan login untuk mengakses fitur utama (pemindai makanan, kalkulator kalori, dan riwayat makanan), Anda **WAJIB** memilih **"All or some functionality in my app is restricted"** pada bagian **App Content → App access** dan menyediakan akun uji coba (*test account*) email & password yang sudah memiliki biodata lengkap untuk tim peninjau Google Play.
