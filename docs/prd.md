# Product Requirements Document — NutriView

> [!NOTE] **DOKUMEN HISTORIS (HISTORICAL DOCUMENTATION)**  
> Dokumen ini mencatat spesifikasi kebutuhan produk pada tahap perancangan awal (29 September 2026) saat sistem masih direncanakan menggunakan arsitektur client-server (FastAPI + MySQL).  
> Sejak Oktober 2026, NutriView telah bermigrasi penuh ke arsitektur **Serverless Firebase + On-Device Edge AI (Flutter & TFLite)**.  
> Untuk spesifikasi dan arsitektur aktif saat ini, silakan merujuk pada:
> - [`README.md`](../README.md) — Gambaran umum sistem dan panduan memulai.
> - [`docs/ARCHITECTURE.md`](ARCHITECTURE.md) — Arsitektur sistem aktif.
> - [`docs/DATABASE_AND_BACKEND.md`](DATABASE_AND_BACKEND.md) — Spesifikasi Cloud Firestore & Firebase Auth.
> - [`docs/MACHINE_LEARNING.md`](MACHINE_LEARNING.md) — Pipeline YOLO26n on-device.

## 1. Informasi Dokumen

| Atribut | Nilai |
|---|---|
| Nama produk | NutriView |
| Versi dokumen | 1.0.0 (MVP) |
| Tanggal | 2026-09-29 |
| Jenis proyek | Proyek perkuliahan (university-level) |
| Status | Siap diimplementasikan |
| Dokumen terkait | `ai.md` (spesifikasi rekayasa), `README.md` (panduan cepat) |

**Aturan otoritas dokumen**

- `prd.md` adalah sumber kebenaran untuk **apa** yang dibangun (perilaku produk, cakupan, kriteria penerimaan).
- `ai.md` adalah sumber kebenaran untuk **bagaimana** membangunnya (arsitektur, standar, aturan agen).
- Jika terdapat kontradiksi: perilaku produk mengikuti `prd.md`; keputusan teknis mengikuti `ai.md`. Kontradiksi harus dilaporkan dan diperbaiki, bukan diabaikan.

**Glosarium**

| Istilah | Arti |
|---|---|
| Deteksi | Prediksi kelas makanan beserta confidence dari model YOLO26n pada satu gambar |
| Confidence | Nilai 0–1 dari YOLO26n yang menunjukkan keyakinan model atas prediksi |
| Porsi | Berat makanan yang dikonsumsi dalam gram |
| Target harian | Kebutuhan kalori dan makronutrien per hari hasil perhitungan deterministik dari profil |
| Meal record | Satu catatan makan (mis. sarapan) yang berisi satu atau lebih item makanan |
| Meal item | Satu makanan beserta porsi dan nilai gizinya di dalam meal record |

---

## 2. Ikhtisar Produk

NutriView adalah aplikasi mobile yang membantu pengguna memahami asupan gizi harian dari makanan yang mereka konsumsi. Pengguna mengisi profil, sistem menghitung target gizi harian, lalu pengguna memotret atau mengunggah foto makanan. Sistem mendeteksi jenis makanan menggunakan YOLO26n, pengguna mengonfirmasi hasilnya dan memasukkan porsi dalam gram, kemudian sistem menghitung gizi secara deterministik dari basis data nutrisi dan menyimpannya sebagai catatan makan. Dashboard menampilkan progres harian terhadap target.

Sistem terdiri dari: aplikasi mobile (Flutter), REST API (FastAPI), computer vision (YOLO26n/Ultralytics), basis data nutrisi (MySQL), dan mesin perhitungan gizi deterministik.

## 3. Pernyataan Masalah

1. Mencatat asupan gizi secara manual (mencari makanan, mengetik, menghitung) melelahkan sehingga banyak orang berhenti mencatat.
2. Banyak orang tidak mengetahui kebutuhan kalori dan makronutrien hariannya.
3. Aplikasi pencatat gizi umum sering kurang relevan dengan makanan sehari-hari Indonesia.

## 4. Visi Produk

Membuat pencatatan asupan gizi semudah memotret makanan, dengan hasil yang transparan dan dapat dikoreksi pengguna, serta perhitungan gizi yang dapat diverifikasi (bukan hasil tebakan model).

## 5. Tujuan (Goals)

| ID | Tujuan |
|---|---|
| G-01 | Pengguna dapat menghitung target gizi harian dari profilnya secara deterministik. |
| G-02 | Pengguna dapat mencatat makanan dari foto dengan bantuan deteksi YOLO26n dan konfirmasi manual. |
| G-03 | Nilai gizi dihitung dari data MySQL berdasarkan porsi gram, tanpa melibatkan model ML. |
| G-04 | Pengguna dapat melihat riwayat makan dan progres gizi harian terhadap target. |
| G-05 | Arsitektur tetap sederhana (modular monolith) dan sesuai skala proyek perkuliahan. |

## 6. Non-Goals

- Memberikan diagnosis, penilaian kesehatan, atau saran medis.
- Menebak porsi otomatis dari gambar.
- Mengenali seluruh makanan Indonesia (model hanya mendukung 10–20 kelas).
- Merekomendasikan makanan atau menyusun menu.
- Membangun platform skala besar atau infrastruktur terdistribusi.

## 7. Target Pengguna

Individu dewasa pengguna smartphone yang ingin memantau asupan kalori dan makronutrien harian dari makanan sehari-hari, tanpa memerlukan pengetahuan gizi mendalam. Platform utama: Android (Flutter). Bahasa antarmuka MVP: Bahasa Indonesia.

## 8. Persona Pengguna

| Persona | Deskripsi | Kebutuhan utama |
|---|---|---|
| **Rina, 21 tahun, mahasiswi** | Ingin menurunkan berat badan, makan di kantin kampus | Tahu target kalori harian dan mencatat makan dengan cepat |
| **Budi, 28 tahun, karyawan** | Ingin menambah massa otot, aktivitas sedang | Memantau protein harian terhadap target |
| **Sari, 35 tahun, ibu rumah tangga** | Ingin menjaga berat badan, memasak makanan rumahan | Pencatatan sederhana tanpa mengetik banyak, bisa koreksi manual |

## 9. User Stories

| ID | Sebagai pengguna, saya ingin… | Agar… | Fitur |
|---|---|---|---|
| US-01 | mendaftar dan login | data saya tersimpan aman dan pribadi | Autentikasi |
| US-02 | logout | sesi saya berakhir di perangkat ini | Autentikasi |
| US-03 | mengisi usia, jenis kelamin, berat, tinggi, aktivitas, dan tujuan | sistem mengetahui kebutuhan saya | Profil |
| US-04 | melihat target kalori, protein, karbohidrat, lemak harian | saya punya acuan asupan | Target |
| US-05 | memotret atau mengunggah foto makanan | makanan saya dikenali otomatis | Scanner |
| US-06 | mengonfirmasi, menghapus, mengoreksi, atau menambah makanan hasil deteksi | catatan saya akurat walau model salah | Konfirmasi |
| US-07 | memasukkan porsi dalam gram per makanan | perhitungan gizi sesuai yang saya makan | Porsi |
| US-08 | menyimpan catatan makan dengan nilai gizinya | asupan saya tercatat | Meal tracking |
| US-09 | melihat riwayat makan | saya dapat meninjau asupan sebelumnya | Meal tracking |
| US-10 | melihat progres harian terhadap target | saya tahu sisa kebutuhan hari ini | Dashboard |
| US-11 | mencari makanan secara manual | saya tetap bisa mencatat saat deteksi gagal | Konfirmasi |

## 10. User Journey

```text
1. Rina mendaftar → login.
2. Rina mengisi profil → sistem menampilkan target harian.
3. Saat makan siang, Rina memotret piringnya.
4. Sistem menampilkan hasil deteksi: nasi putih (0,91), ayam goreng (0,87).
5. Rina menghapus deteksi keliru, menambah "tempe goreng" secara manual.
6. Rina memasukkan porsi: nasi 250 g, ayam 100 g, tempe 50 g, memilih jenis makan "makan siang".
7. Rina menyimpan → sistem menghitung gizi dan menyimpan catatan makan.
8. Rina membuka dashboard → melihat progres kalori dan makronutrien hari ini.
```

## 11. Kebutuhan Fungsional

| ID | Kebutuhan | Prioritas |
|---|---|---|
| FR-AUTH-01 | Pengguna dapat registrasi dengan email unik, kata sandi, dan nama lengkap. | Must |
| FR-AUTH-02 | Pengguna dapat login dengan email dan kata sandi dan menerima token akses. | Must |
| FR-AUTH-03 | Pengguna dapat logout; token yang di-logout tidak dapat dipakai lagi. | Must |
| FR-AUTH-04 | Seluruh endpoint selain registrasi, login, dan health check memerlukan autentikasi. | Must |
| FR-PROF-01 | Pengguna dapat melihat profilnya. | Must |
| FR-PROF-02 | Pengguna dapat membuat/memperbarui profil (usia, jenis kelamin, berat, tinggi, tingkat aktivitas, tujuan gizi). | Must |
| FR-TGT-01 | Sistem menghitung target harian kalori, protein, karbohidrat, lemak dari profil. | Must |
| FR-TGT-02 | Perhitungan target deterministik, terdokumentasi, dan tidak memakai model ML. | Must |
| FR-TGT-03 | Jika profil belum lengkap, sistem menolak dengan pesan yang jelas. | Must |
| FR-SCAN-01 | Pengguna dapat mengambil foto dengan kamera atau memilih dari galeri. | Must |
| FR-SCAN-02 | Aplikasi mengirim gambar ke backend; backend menjalankan YOLO26n dan mengembalikan daftar deteksi (makanan + confidence). | Must |
| FR-SCAN-03 | Gambar tidak disimpan permanen setelah inferensi. | Must |
| FR-SCAN-04 | Sistem menyediakan fallback manual jika tidak ada deteksi, confidence rendah, deteksi salah, atau kelas tidak didukung. | Must |
| FR-CONF-01 | Hasil deteksi tidak pernah otomatis menjadi catatan makan final; pengguna harus mengonfirmasi. | Must |
| FR-CONF-02 | Pengguna dapat menghapus deteksi, mengoreksi jenis makanan, dan menambah makanan secara manual. | Must |
| FR-PORT-01 | Pengguna memasukkan porsi dalam gram untuk setiap makanan terkonfirmasi. | Must |
| FR-NUT-01 | Gizi dihitung: `nutrisi_dikonsumsi = nutrisi_per_100g × porsi_gram / 100`. | Must |
| FR-NUT-02 | Nilai gizi per 100 g (kalori, protein, karbohidrat, lemak) disimpan di MySQL. | Must |
| FR-NUT-03 | YOLO26n tidak menghitung atau memengaruhi nilai gizi. | Must |
| FR-NUT-04 | Nilai gizi setiap item disimpan sebagai snapshot pada saat pencatatan. | Must |
| FR-MEAL-01 | Pengguna dapat menyimpan catatan makan (waktu, jenis makan, item, porsi). | Must |
| FR-MEAL-02 | Pengguna dapat melihat daftar riwayat makan miliknya, dengan filter tanggal. | Must |
| FR-MEAL-03 | Pengguna dapat melihat detail satu catatan makan. | Must |
| FR-MEAL-04 | Pengguna tidak dapat mengakses data milik pengguna lain. | Must |
| FR-DASH-01 | Dashboard harian menampilkan konsumsi/target untuk kalori, protein, karbohidrat, lemak. | Must |
| FR-DASH-02 | Dashboard menampilkan representasi visual sederhana progres (progress bar/indikator). | Must |
| FR-FOOD-01 | Pengguna dapat mencari dan melihat daftar makanan yang tersedia. | Must |
| FR-FOOD-02 | Pengguna dapat melihat detail makanan beserta gizi per 100 g. | Must |

## 12. Kebutuhan Non-Fungsional

| ID | Kategori | Kebutuhan |
|---|---|---|
| NFR-01 | Keamanan | Kata sandi di-hash; tidak ada kredensial di kode; validasi seluruh input; isolasi data antar pengguna; detail keamanan pada `ai.md` §11. |
| NFR-02 | Privasi | Foto makanan diproses sementara dan tidak disimpan; data pengguna hanya dapat diakses pemiliknya. |
| NFR-03 | Kinerja | Endpoint deteksi memproses gambar ≤ 5 MB dalam ≤ 5 detik (p95) pada mesin pengembangan tanpa GPU; endpoint non-ML merespons ≤ 500 ms (p95) pada beban satu pengguna. |
| NFR-04 | Keandalan | Kesalahan ditangani dengan format error konsisten; kegagalan model tidak menghentikan fitur pencatatan manual. |
| NFR-05 | Determinisme | Perhitungan target dan gizi menghasilkan keluaran identik untuk masukan identik. |
| NFR-06 | Kegunaan | Alur foto-hingga-simpan dapat diselesaikan dalam ≤ 6 layar; teks antarmuka Bahasa Indonesia; pesan error dapat dipahami awam. |
| NFR-07 | Portabilitas | Android sebagai platform utama; backend berjalan lokal (Python 3.11+, MySQL 8). |
| NFR-08 | Kemudahan pemeliharaan | Struktur modular, standar kode di `ai.md`, cakupan pengujian sesuai `ai.md` §17. |
| NFR-09 | Transparansi | Aplikasi menampilkan pernyataan bahwa hasil bersifat estimasi dan bukan saran medis. |
| NFR-10 | Keterbatasan model | Aplikasi/dokumen secara eksplisit menyatakan bahwa model hanya mengenali kelas terbatas. |

## 13. Spesifikasi Fitur

### 13.1 Autentikasi
- Registrasi: email (format valid, unik, tidak peka huruf besar/kecil), kata sandi minimal 8 karakter (maks. 128) berisi huruf dan angka, nama lengkap 1–100 karakter.
- Login berhasil mengembalikan token akses berumur terbatas. Login gagal memberi pesan generik ("Email atau kata sandi salah") tanpa membedakan penyebab.
- Logout mencabut token yang sedang dipakai.

### 13.2 Profil Pengguna

| Field | Aturan |
|---|---|
| Usia | Bilangan bulat 15–100 tahun |
| Jenis kelamin | `male` atau `female` (dipakai hanya untuk rumus BMR) |
| Berat | 20–300 kg |
| Tinggi | 100–250 cm |
| Tingkat aktivitas | `sedentary`, `light`, `moderate`, `active`, `very_active` |
| Tujuan gizi | `lose_weight`, `maintain_weight`, `gain_weight` |

Semua field wajib untuk profil lengkap.

### 13.3 Target Gizi Harian
Dihitung di backend; rumus rinci pada `ai.md` §13. Ringkasan: BMR (Mifflin-St Jeor) × faktor aktivitas = TDEE; kalori target = TDEE disesuaikan tujuan; protein berdasarkan gram per kg berat badan; lemak 25% kalori; karbohidrat = sisa kalori. Hasil bersifat estimasi umum, bukan preskripsi medis.

### 13.4 Food Scanner
- Format gambar: JPEG, PNG, WebP; ukuran maksimum 5 MB.
- Hasil deteksi berupa daftar makanan unik (satu entri per kelas, confidence tertinggi) yang dipetakan ke tabel `foods`.
- Deteksi dengan confidence di bawah ambang "rendah" tetap ditampilkan dengan penanda "perlu dicek" agar pengguna dapat memutuskan.
- Jika tidak ada deteksi, aplikasi menampilkan pesan dan langsung menawarkan penambahan makanan manual.
- Kelas model yang tidak terpetakan ke `foods` diabaikan oleh backend.

### 13.5 Konfirmasi Deteksi
Layar konfirmasi menampilkan setiap deteksi dengan aksi: **pertahankan**, **hapus**, **ganti makanan** (pencarian dari `foods`). Tombol **tambah makanan manual** selalu tersedia. Pengguna tidak dapat melanjutkan bila daftar item kosong.

### 13.6 Input Porsi
Satuan gram. Nilai > 0 dan ≤ 5000. Setiap item wajib memiliki porsi. Nilai awal kosong (tidak diisi otomatis dari tebakan sistem).

### 13.7 Perhitungan Gizi
Dilakukan backend saat catatan makan dibuat. Klien tidak mengirim nilai gizi. Aplikasi menampilkan hasil perhitungan setelah catatan tersimpan (tidak ada pratinjau gizi sebelum simpan pada MVP, agar logika bisnis tidak duplikat di UI).

### 13.8 Meal Tracking
Catatan makan berisi: pengguna, waktu konsumsi, jenis makan (`breakfast`, `lunch`, `dinner`, `snack`), 1–20 item (makanan, porsi gram, gizi snapshot, sumber item: `detected` / `corrected` / `manual`), dan total gizi.

### 13.9 Dashboard Harian
Untuk tanggal terpilih (default: hari ini): konsumsi vs target dan persentase untuk kalori, protein, karbohidrat, lemak; jumlah catatan makan. Persentase dapat melebihi 100%; UI membatasi panjang bar secara visual.

## 14. Alur Pengguna

```text
Register → Login → Isi Profil → Lihat Target Harian
                                     │
                                     ▼
                               Dashboard Harian ◄───────────────┐
                                     │                          │
                                     ▼                          │
                          Ambil / Unggah Foto                   │
                                     │                          │
                                     ▼                          │
                             Deteksi YOLO26n (backend)             │
                                     │                          │
                                     ▼                          │
                        Konfirmasi Deteksi (koreksi/hapus/tambah)
                                     │                          │
                                     ▼                          │
                              Input Porsi (gram)                │
                                     │                          │
                                     ▼                          │
                  Simpan → Hitung Gizi (backend) → Meal Record ─┘
```

**Alur alternatif**

| Kondisi | Perilaku |
|---|---|
| Profil belum lengkap | Dashboard/target mengarahkan pengguna ke layar profil |
| Tidak ada deteksi | Pesan informatif + pencarian makanan manual |
| Confidence rendah | Deteksi ditandai "perlu dicek" |
| Makanan tidak didukung model | Pengguna menambahkan makanan manual dari `foods` |
| Makanan tidak ada di `foods` | Tidak didukung MVP; pengguna memilih makanan terdekat |
| Gambar tidak valid/terlalu besar | Pesan error jelas; pengguna dapat memilih gambar lain atau input manual |
| Token kedaluwarsa | Pengguna diarahkan kembali ke layar login |

## 15. Kebutuhan Data

| Entitas | Atribut utama | Catatan |
|---|---|---|
| Pengguna | email, hash kata sandi, nama lengkap | Kata sandi tidak pernah disimpan polos |
| Profil | usia, jenis kelamin, berat, tinggi, aktivitas, tujuan | Satu profil per pengguna |
| Makanan | nama, kelas YOLO26n (opsional) | Kelas YOLO26n terisi untuk makanan yang dapat dideteksi |
| Gizi makanan | kalori, protein, karbohidrat, lemak per 100 g, sumber data | Satu baris per makanan |
| Meal record | pengguna, waktu, tanggal lokal, jenis makan, total gizi | |
| Meal item | makanan, porsi gram, gizi snapshot, sumber, confidence deteksi (opsional) | |

**Sumber data gizi.** Nilai gizi harus bersumber dari referensi yang dapat ditelusuri (utamanya Tabel Komposisi Pangan Indonesia/TKPI Kemenkes RI atau label gizi produk) dan dicatat pada kolom `source`. Nilai tidak boleh dikarang. Pengisian seed data adalah tugas manusia (tim proyek); agen AI hanya membuat struktur dan berkas seed dengan data yang telah disediakan.

**Dataset citra.** Dikumpulkan/dianotasi oleh tim (atau dari dataset publik dengan lisensi yang jelas); pelatihan dilakukan di `ml/` (dapat memakai Google Colab). Dataset tidak dimasukkan ke repositori.

**Retensi.** Foto tidak disimpan. Data akun dan catatan makan disimpan sampai proyek dihentikan (tidak ada fitur hapus akun pada MVP).

## 16. Cakupan MVP

Autentikasi (registrasi, login, logout) · profil · target gizi harian · scanner makanan (kamera/galeri + YOLO26n) · konfirmasi deteksi · input porsi gram · perhitungan gizi · meal tracking (buat, daftar, detail) · dashboard harian · daftar/pencarian makanan · fallback manual.

Model YOLO26n mendukung **10–20 kelas makanan** (jumlah final bergantung pada kualitas dan ketersediaan dataset). Daftar kandidat: nasi putih, nasi goreng, ayam goreng, ikan goreng, telur dadar, telur rebus, tempe goreng, tahu goreng, perkedel, sate ayam, rendang, gado-gado, bakso, mie goreng, sayur bening.

## 17. Di Luar Cakupan (Out of Scope)

MVP **tidak** mencakup:

- Estimasi porsi otomatis dari gambar
- Diagnosis medis dan pengobatan medis yang dipersonalisasi
- Chatbot AI dan LLM
- Mesin rekomendasi makanan, optimasi belanja bahan makanan
- OR-Tools dan model rekomendasi Food.com
- Pelatihan/pembinaan gizi real-time
- Integrasi wearable dan IoT
- Fitur media sosial
- Microservices dan infrastruktur terdistribusi
- Edit/hapus catatan makan, reset kata sandi, verifikasi email, hapus akun, mode offline, multi-bahasa

## 18. Kriteria Penerimaan

| ID | Kriteria (Given / When / Then) | FR |
|---|---|---|
| AC-01 | Given email belum terdaftar, when registrasi dengan data valid, then akun dibuat dan kata sandi tersimpan sebagai hash. | FR-AUTH-01 |
| AC-02 | Given email sudah terdaftar, when registrasi ulang, then ditolak dengan error konflik. | FR-AUTH-01 |
| AC-03 | Given kredensial benar, when login, then token akses diterima; given kredensial salah, then 401 dengan pesan generik. | FR-AUTH-02 |
| AC-04 | Given token valid, when logout, then token tersebut ditolak pada permintaan berikutnya. | FR-AUTH-03 |
| AC-05 | Given tanpa token, when memanggil endpoint terlindungi, then 401. | FR-AUTH-04 |
| AC-06 | Given data profil di luar rentang, when disimpan, then ditolak dengan 422 dan pesan per field. | FR-PROF-02 |
| AC-07 | Given profil lengkap, when meminta target, then kalori, protein, karbohidrat, lemak sesuai rumus `ai.md` §13 (contoh uji terdokumentasi). | FR-TGT-01/02 |
| AC-08 | Given profil belum ada, when meminta target, then error `PROFILE_INCOMPLETE`. | FR-TGT-03 |
| AC-09 | Given foto JPEG valid berisi makanan yang didukung, when dikirim, then respons berisi deteksi (makanan, confidence). | FR-SCAN-02 |
| AC-10 | Given file bukan gambar/format tak didukung/melebihi 5 MB, when dikirim, then ditolak dan tidak diproses YOLO26n. | FR-SCAN-02 |
| AC-11 | Given gambar tanpa makanan dikenali, when dikirim, then respons 200 dengan daftar kosong dan aplikasi menawarkan input manual. | FR-SCAN-04 |
| AC-12 | Given hasil deteksi, when pengguna belum menekan simpan, then tidak ada meal record yang dibuat. | FR-CONF-01 |
| AC-13 | Given hasil deteksi, when pengguna menghapus, mengganti, atau menambah item, then daftar akhir mengikuti pilihan pengguna. | FR-CONF-02 |
| AC-14 | Given porsi ≤ 0 atau > 5000, when disimpan, then ditolak dengan 422. | FR-PORT-01 |
| AC-15 | Given nasi putih 250 g dengan gizi per 100 g tertentu, when catatan disimpan, then nilai gizi = nilai per 100 g × 250 / 100 (dibulatkan sesuai `ai.md` §13). | FR-NUT-01 |
| AC-16 | Given data gizi makanan diubah setelah pencatatan, when catatan lama dibuka, then nilai gizi lama tidak berubah. | FR-NUT-04 |
| AC-17 | Given pengguna A, when mengakses meal milik pengguna B, then 404. | FR-MEAL-04 |
| AC-18 | Given beberapa catatan makan pada satu tanggal, when membuka dashboard tanggal itu, then konsumsi = jumlah seluruh item pada tanggal tersebut dan progres tampil visual. | FR-DASH-01/02 |
| AC-19 | Given pencarian nama makanan, when memanggil daftar makanan, then hasil terfilter dan berhalaman. | FR-FOOD-01 |
| AC-20 | Given kegagalan internal, when respons dikirim, then klien menerima pesan aman tanpa stack trace. | NFR-01/04 |

## 19. Pertimbangan Masa Depan

Ide berikut **tidak boleh** memengaruhi arsitektur MVP kecuali ada persyaratan eksplisit di masa depan: edit/hapus catatan makan; pratinjau gizi sebelum simpan; satuan porsi rumah tangga (piring, sendok); penambahan kelas makanan dan retraining model; tren mingguan; ekspor data; reset kata sandi; dukungan iOS dan multi-bahasa.

## 20. Metrik Keberhasilan

Seluruh metrik dapat diukur oleh tim proyek tanpa data bisnis.

| ID | Metrik | Target | Cara pengukuran |
|---|---|---|---|
| M-01 | Akurasi model pada set validasi | mAP@0.5 ≥ 0,70 | Laporan evaluasi Ultralytics |
| M-02 | Perhitungan gizi dan target | 100% unit test lulus | Hasil pytest |
| M-03 | Cakupan pengujian layanan backend | ≥ 70% | Laporan coverage |
| M-04 | Alur utama end-to-end (login → scan → konfirmasi → porsi → simpan → dashboard) | Berhasil pada perangkat/emulator Android | Uji manual + widget/integration test |
| M-05 | Latensi endpoint deteksi | ≤ 5 detik (p95) pada 20 gambar uji | Skrip/pengukuran manual |
| M-06 | Uji kegunaan dengan ≥ 5 responden mahasiswa | ≥ 80% menyelesaikan alur foto-hingga-simpan tanpa bantuan dalam ≤ 3 menit | Observasi |
| M-07 | Kepatuhan cakupan | 100% FR "Must" memenuhi kriteria penerimaan terkait | Checklist AC |
