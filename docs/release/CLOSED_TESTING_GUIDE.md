# Panduan Closed Testing Google Play (12 Testers / 14 Hari) — NutriView (`OopsieEats`)

Untuk akun developer personal Google Play yang dibuat setelah 13 November 2023, Google Play mewajibkan **Closed Testing** dengan minimal **12 tester yang melakukan opt-in selama 14 hari berturut-turut** sebelum tombol **Apply for production** dibuka.

Dokumen ini memandu langkah operasional dari persiapan sebelum unggah hingga pengajuan akses produksi.

---

## 1. Langkah Pra-Unggah (WAJIB Sebelum Tester Menguji Google Sign-In)

Ketika Anda mengunggah `.aab` ke Google Play Console dengan **Play App Signing** aktif:
1. Google Play memvalidasi `.aab` menggunakan **Upload Key** lokal Anda (`oopsieeats_upload`), lalu menandatangani ulang APK distribusi menggunakan **App Signing Key** milik Google Play.
2. Akibatnya, aplikasi yang diunduh oleh tester dari Play Store memiliki **SHA-1 dan SHA-256 yang berbeda** dari Upload Key lokal.
3. Agar **Google Sign-In** berfungsi pada perangkat tester:
   - Buka **Google Play Console → Test and release → Setup → App signing**.
   - Salin **SHA-1 certificate fingerprint** dan **SHA-256 certificate fingerprint** pada bagian **App signing key certificate**.
   - Buka **Firebase Console (`nutriview-943cd`) → Project settings → General → Your apps (`com.oopsieeats.app`)**.
   - Klik **Add fingerprint** dan tambahkan kedua fingerprint (SHA-1 & SHA-256) dari Google Play App Signing tersebut.
   - Unduh ulang `google-services.json` (opsional jika Web OAuth Client ID sudah terdaftar, namun sangat disarankan agar daftar `oauth_client` selalu sinkron).

---

## 2. Publikasi Halaman Web Kebijakan Privasi & Hapus Akun

Sebelum mengirimkan rilis Closed Testing untuk ditinjau Google:
1. Deploy halaman statis di direktori `public/` (`privacy.html` dan `delete-account.html`) ke Firebase Hosting:
   ```bash
   firebase deploy --only hosting,firestore:rules
   ```
2. Pastikan kedua URL berikut dapat diakses publik tanpa login (HTTP 200):
   - **Privacy Policy URL:** `https://nutriview-943cd.web.app/privacy`
   - **Delete Account URL:** `https://nutriview-943cd.web.app/delete-account`

---

## 3. Membuat Rilis Closed Testing di Google Play Console

1. Masuk ke **Google Play Console → Test and release → Testing → Closed testing**.
2. Pilih track **Alpha** (atau buat track baru, misalnya `closed-beta`).
3. Pada tab **Countries / regions**, tambahkan negara target (minimal **Indonesia**).
4. Pada tab **Testers**:
   - Buat **Email list** berisi minimal **15–20 alamat email akun Google aktif** (disarankan memiliki cadangan di atas batas minimum 12 tester untuk mengantisipasi tester yang keluar atau mencopot aplikasi).
   - Simpan perubahan, lalu salin tautan **Join on Android** atau **Join on the web** setelah rilis dipublikasikan.
5. Pada tab **Releases → Create new release**:
   - Unggah file `frontend/build/app/outputs/bundle/release/app-release.aab` (`versionCode: 2002`, `versionName: "1.0.0"`).
   - Isi **Release name**: `1.0.0 (2002)`
   - Isi **Release notes (id-ID)**:
     ```text
     <id-ID>
     Rilis perdana OopsieEats v1.0.0:
     - Pemindai makanan otomatis berbasis AI on-device (29 kategori pangan populer)
     - Perhitungan target kalori harian & makronutrien personal (BMR/TDEE)
     - Pencatatan riwayat makan harian & sinkronisasi real-time
     - Katalog pangan Tabel Komposisi Pangan Indonesia (TKPI) & artikel edukasi gizi
     </id-ID>
     ```
   - Klik **Next → Save and publish**.

---

## 4. Skenario Pengujian Wajib untuk Tester (Selama 14 Hari)

Bagikan daftar pengujian berikut kepada para tester agar aktivitas pengujian tercatat bermakna dan memvalidasi seluruh fitur utama:

| Hari | Fokus Pengujian | Langkah yang Dilakukan Tester | Hasil yang Diharapkan |
| :--- | :--- | :--- | :--- |
| **Hari 1–2** | Onboarding & Registrasi | Buka aplikasi pertama kali, geser 3 slide onboarding, daftar akun dengan Email/Password atau Google Sign-In, lalu isi formulir *Lengkapi Biodata*. | Masuk ke Beranda dengan target kalori harian sesuai biodata. |
| **Hari 3–5** | Pemindai Makanan AI & Input Porsi | Buka tab **Scan**, ambil foto makanan dari kamera atau pilih dari galeri, ubah berat porsi (gram), dan simpan ke riwayat makan. | Deteksi berjalan lancar tanpa freeze UI, ringkasan kalori di Beranda bertambah otomatis. |
| **Hari 6–8** | Sinkronisasi Biodata Real-Time | Buka **Profil → Kelola Biodata**, ubah berat/tinggi badan atau tingkat aktivitas, simpan, lalu kembali ke **Beranda**. | Target kalori dan sisa kalori di Beranda langsung berubah tanpa perlu restart aplikasi. |
| **Hari 9–11** | Riwayat Makanan & Artikel Gizi | Cek daftar riwayat makan per tanggal, lihat foto makanan tersimpan, hapus salah satu item makan, dan baca artikel di bagian Edukasi Gizi. | Foto tampil jelas, penghapusan item mengurangi kalori harian secara akurat. |
| **Hari 12–14** | Keamanan Biometrik, Foto Profil & Penghapusan Akun | Unggah/ganti foto profil, aktifkan kunci biometrik (jika perangkat mendukung), uji logout & login kembali, serta uji fitur *Hapus Akun & Data* menggunakan akun uji sekunder. | Seluruh alur berjalan bebas crash (0 ANR / 0 Unhandled Exception di Play Console Android Vitals). |

---

## 5. Mengajukan Akses Production (*Apply for Production*)

Setelah penghitung waktu 14 hari pada dasbor Google Play Console selesai dengan minimal 12 tester tetap opt-in:
1. Buka **Dashboard → Apply for production**.
2. Jawab kuesioner Google Play mengenai:
   - Bagaimana Anda merekrut tester dan mengumpulkan masukan (*feedback*).
   - Perubahan atau perbaikan apa yang Anda lakukan selama periode Closed Testing.
   - Bagaimana Anda menguji kualitas dan kesiapan aplikasi sebelum rilis publik.
3. Setelah disetujui, promosikan rilis dari track **Closed testing** ke **Production** (atau unggah `.aab` baru dengan `versionCode` lebih tinggi).
