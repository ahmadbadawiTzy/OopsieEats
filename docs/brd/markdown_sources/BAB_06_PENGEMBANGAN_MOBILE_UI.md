# BAB 6: Pengembangan Mobile UI

**Sistem Desain Overkill Neo-Brutalism, Pohon Navigasi, Katalog 19 Wireframe Monokrom, dan State Management**

---

**Aplikasi:** OopsieEats (`com.oopsieeats.app`) | **Versi:** 1.0.0+2002  
**Penyusun:** Ahmad Badawi (NIM 20090015) — Universitas Bina Insani  
**Status:** Approved & Baselined | **Klasifikasi:** Confidential / Restricted

---


## 6.1 Filosofi Desain: Overkill Neo-Brutalism Design System

OopsieEats menolak pendekatan desain minimalis konvensional (flat design / glassmorphism) yang cenderung homogen dan membosankan. Sebagai gantinya, aplikasi mengadopsi bahasa visual <strong>Overkill Neo-Brutalism</strong> yang terinspirasi oleh estetika desain brutalist fungsional dengan sentuhan modern berenergi tinggi.

Ciri khas filosofis Overkill Neo-Brutalism pada OopsieEats mencakup: (1) Garis batas tebal (Bold Outlines: 2.0px hingga 3.0px) berwarna hitam pekat (<code>#000000</code>), (2) Bayangan jatuh tanpa blur (Hard Drop Shadows: offset 4px hingga 6px tanpa radius penyebaran), (3) Latar belakang kanvas krem hangat (Warm Cream Canvas: <code>#FDFBF7</code>) yang ramah di mata, (4) Palet warna aksen primer kontras tinggi yang memberikan umpan balik visual seketika, dan (5) Tipografi tegas dengan hierarki pembobotan font tebal (Bold & Extra-Bold).


## 6.2 Palet Warna, Tipografi & Spacing Tokens

Seluruh elemen antarmuka dikendalikan oleh sistem token terpusat pada <code>lib/core/theme/neo_colors.dart</code> dan <code>neo_tokens.dart</code>:

**Tabel 6.1: Spesifikasi Token Desain Overkill Neo-Brutalism**

| Kategori Token | Nama Variabel Token | Nilai Heksadesimal / Dimensi | Peran Semantik UI |
| --- | --- | --- | --- |
| Warna Kanvas | NeoColors.canvasBg | #FDFBF7 (Warm Cream) | Latar belakang utama seluruh layar aplikasi |
| Warna Permukaan | NeoColors.surfaceCard | #FFFFFF (Pure White) | Latar permukaan kartu, dialog, dan input text |
| Warna Garis | NeoColors.pureBlack | #000000 (Pure Black) | Border kontur 2.5px dan hard drop shadow |
| Warna Primer | NeoColors.electricYellow | #FFE600 (Electric Yellow) | Tombol tindakan utama (CTA) & highlight progres |
| Warna Sekunder | NeoColors.vibrantOrange | #FF6B00 (Vibrant Orange) | Kategori makan siang & lencana kalori tinggi |
| Warna Aksen 1 | NeoColors.mintGreen | #00E599 (Mint Green) | Indikator protein, sukses, dan target tercapai |
| Warna Aksen 2 | NeoColors.lavenderPurple | #9D7BFF (Lavender Purple) | Kategori makan malam & visualisasi makronutrien |
| Warna Bahaya | NeoColors.coralRed | #FF3B30 (Coral Red) | Peringatan bahaya, tombol hapus, kalori berlebih |
| Border Width | NeoTokens.borderBold | 2.5 px solid | Ketebalan garis batas seluruh tombol dan kartu |
| Drop Shadow | NeoTokens.shadowHard | Offset (4.0, 4.0), Blur 0.0 | Bayangan jatuh tegas retro-modern |
| Border Radius | NeoTokens.radiusNeo | 12.0 px rounded | Kelengkungan sudut elemen struktural |


## 6.3 Komponen Desain Reusable (Design System Widgets)

Untuk mencegah duplikasi kode dan menjaga konsistensi tampilan, aplikasi membangun pustaka komponen mandiri:

- <strong>NeoButton</strong>: Komponen tombol interaktif dengan animasi penekanan (press animation) yang menggeser posisi tombol 2px ke bawah-kanan bersamaan dengan reduksi bayangan saat ditekan, memberikan efek taktil fisik yang memuaskan.
- <strong>NeoCard</strong>: Wadah informasi berbasis kartu putih dengan border hitam 2.5px dan hard shadow 4px, dilengkapi opsi header aksen warna warni untuk pengelompokan data.
- <strong>NeoInput</strong>: Bidang masukan teks dengan border kontras tinggi, label floating tebal, indikator fokus berwarna kuning elektrik, dan pesan galat validasi terintegrasi.
- <strong>NeoBottomNav</strong>: Bilah navigasi bawah mengambang (floating bar) dengan ikon kustom tebal dan indikator tab aktif berbingkai Neo-Brutalism.
- <strong>AvatarWidget</strong>: Komponen visual identitas pengguna yang menampilkan ilustrasi karakter pilihan dengan bingkai melingkar bergaris hitam ganda.


## 6.4 Struktur Navigasi & Alur Layar (Bottom Navigation & Route Tree)

Pohon navigasi aplikasi OopsieEats dikendalikan oleh router deklaratif terpusat yang memetakan 19 layar ke dalam hierarki alur onboarding, autentikasi, dasbor utama, pemindai makanan, dan modul manajemen profil, sebagaimana dirinci pada Diagram 6:


![Gambar 6.0: Diagram Alur Navigasi & Pohon Rute Layar Aplikasi (Navigation Flow)](docs/brd/diagrams/rendered/navigation-flow.png)
*Gambar 6.0: Diagram Alur Navigasi & Pohon Rute Layar Aplikasi (Navigation Flow)*

Siklus hidup transisi status antarmuka pengguna, evaluasi sesi, dan penguncian Complete Profile Guard dimodelkan secara formal melalui Diagram State Machine UML berikut:


![Gambar 6.0b: Diagram State Machine UML — Siklus Hidup Antarmuka & Complete Profile Guard State Machine](docs/brd/diagrams/rendered/uml-ui-state-machine.png)
*Gambar 6.0b: Diagram State Machine UML — Siklus Hidup Antarmuka & Complete Profile Guard State Machine*


## 6.5 Desain & Spesifikasi 19 Layar Aplikasi (Katalog Lengkap Wireframe Monokrom)

Berikut adalah katalog visual 19 layar aplikasi OopsieEats yang disajikan dalam format wireframe monokrom kontras tinggi standar rekayasa perangkat lunak internasional. Setiap wireframe diekstraksi 100% dari tangkapan layar aplikasi aktual (pixel-perfect) dengan bingkai perangkat mobile 1.5px tanpa teks banner internal:


### Layar 1: Onboarding Slide 1 (Track Nutrisi Instan)

Layar pembuka interaktif pertama yang menyambut pengguna baru dengan visualisasi ilustrasi piring makanan bernutrisi. Menjelaskan proposisi nilai utama OopsieEats dalam mengenali hidangan nusantara secara instan dengan bantuan AI.


![Gambar 6.1: Wireframe Monokrom — Layar Onboarding Slide 1 (Pengenalan Deteksi AI)](docs/brd/wireframes/monochrome/01_onboarding_slide1-wireframe.png)
*Gambar 6.1: Wireframe Monokrom — Layar Onboarding Slide 1 (Pengenalan Deteksi AI)*


### Layar 2: Onboarding Slide 2 (Kalkulasi Ilmiah Deterministik)

Slide edukasi kedua yang memaparkan keunggulan transparansi kalkulasi gizi berdasarkan formula ilmiah Mifflin-St Jeor dan basis data resmi Kementerian Kesehatan RI (TKPI 2020), menjamin estimasi kalori yang dapat dipertanggungjawabkan.


![Gambar 6.2: Wireframe Monokrom — Layar Onboarding Slide 2 (Kalkulasi Nutrisi Ilmiah)](docs/brd/wireframes/monochrome/02_onboarding_slide2-wireframe.png)
*Gambar 6.2: Wireframe Monokrom — Layar Onboarding Slide 2 (Kalkulasi Nutrisi Ilmiah)*


### Layar 3: Onboarding Slide 3 (Privasi & Kesiapan Akses)

Slide ketiga yang menekankan kedaulatan privasi visual (on-device processing) dan tombol aksi utama (CTA) 'Mulai Sekarang' yang membawa pengguna ke gerbang autentikasi akun.


![Gambar 6.3: Wireframe Monokrom — Layar Onboarding Slide 3 (Kedaulatan Privasi & CTA Mulai)](docs/brd/wireframes/monochrome/03_onboarding_slide3-wireframe.png)
*Gambar 6.3: Wireframe Monokrom — Layar Onboarding Slide 3 (Kedaulatan Privasi & CTA Mulai)*


### Layar 4: Splash Screen (Branding & Pemuatan Awal)

Layar pemuatan awal sistem yang menampilkan tipografi logo OopsieEats berkarakter Neo-Brutalism dengan bayangan tegas. Secara paralel mengeksekusi inisialisasi Firebase, pemeriksaan sesi terenkripsi, dan pengecekan kelengkapan profil.


![Gambar 6.4: Wireframe Monokrom — Layar Splash Screen (Inisialisasi Sistem)](docs/brd/wireframes/monochrome/04_splash_screen-wireframe.png)
*Gambar 6.4: Wireframe Monokrom — Layar Splash Screen (Inisialisasi Sistem)*


### Layar 5: Register Screen (Pendaftaran Akun Baru)

Antarmuka registrasi akun yang memuat kolom masukan nama lengkap, email, kata sandi, konfirmasi kata sandi, tombol daftar Neo-Brutalism, serta pemisah opsi login pihak ketiga (Google Sign-In).


![Gambar 6.5: Wireframe Monokrom — Layar Pendaftaran Akun Baru (Register Screen)](docs/brd/wireframes/monochrome/05_register_screen-wireframe.png)
*Gambar 6.5: Wireframe Monokrom — Layar Pendaftaran Akun Baru (Register Screen)*


### Layar 6: Complete Profile Screen (Guard Metrik Antropometri)

Layar wajib pengisian data antropometri (usia, jenis kelamin, tinggi badan, berat badan, dan frekuensi aktivitas fisik). Dilindungi oleh Complete Profile Guard sehingga tidak dapat dilewati sebelum seluruh masukan valid terverifikasi.


![Gambar 6.6: Wireframe Monokrom — Layar Lengkapi Profil Fisik (Complete Profile Screen)](docs/brd/wireframes/monochrome/06_complete_profile-wireframe.png)
*Gambar 6.6: Wireframe Monokrom — Layar Lengkapi Profil Fisik (Complete Profile Screen)*


### Layar 7: Login Screen (Gerbang Masuk Pengguna)

Formulir login bersih dengan dukungan masukan email/kata sandi, tombol pintas Google OAuth, opsi aktivasi biometrik, serta tautan pemulihan kata sandi 'Lupa Sandi?'.


![Gambar 6.7: Wireframe Monokrom — Layar Masuk Akun (Login Screen)](docs/brd/wireframes/monochrome/07_login_screen-wireframe.png)
*Gambar 6.7: Wireframe Monokrom — Layar Masuk Akun (Login Screen)*


### Layar 8: Dashboard / Home Screen (Pusat Kendali Nutrisi)

Layar beranda utama yang menyajikan Hero Calorie Dial interaktif (kalori terkonsumsi vs target harian), Bento Grid kartu ringkasan makronutrien (Karbohidrat, Protein, Lemak), daftar hidangan hari ini, dan bilah navigasi bawah.


![Gambar 6.8: Wireframe Monokrom — Layar Beranda Utama (Dashboard / Home Screen)](docs/brd/wireframes/monochrome/08_dashboard_home-wireframe.png)
*Gambar 6.8: Wireframe Monokrom — Layar Beranda Utama (Dashboard / Home Screen)*


### Layar 9: Scanner Viewfinder (Jendela Bidik Kamera)

Antarmuka kamera langsung berkecepatan tinggi dengan bingkai pemindai sudut kontras tinggi, tombol kendali lampu kilat (flash), tombol beralih ke galeri foto lokal, dan tombol rana (shutter button) berkarakter tebal.


![Gambar 6.9: Wireframe Monokrom — Jendela Bidik Kamera (Scanner Viewfinder Screen)](docs/brd/wireframes/monochrome/09_scanner_viewfinder-wireframe.png)
*Gambar 6.9: Wireframe Monokrom — Jendela Bidik Kamera (Scanner Viewfinder Screen)*


### Layar 10: Detection Confirmation Screen (Konfirmasi Deteksi AI)

Menampilkan foto yang baru saja diambil dengan hamparan kotak pembatas (bounding boxes) di sekitar makanan yang terdeteksi, nama hidangan teridentifikasi dari 29 kelas pangan, persentase tingkat keyakinan (confidence score), dan tombol konfirmasi.


![Gambar 6.10: Wireframe Monokrom — Layar Konfirmasi Hasil Deteksi (Detection Confirmation)](docs/brd/wireframes/monochrome/10_detection_confirmation-wireframe.png)
*Gambar 6.10: Wireframe Monokrom — Layar Konfirmasi Hasil Deteksi (Detection Confirmation)*


### Layar 11: Portion Input Screen (Penetapan Bobot Porsi)

Antarmuka penyesuaian porsi saji dalam satuan gram. Dilengkapi tombol cepat (1/2 porsi, 1 porsi standar, 1.5 porsi), slider bobot porsi, kalkulasi langsung nilai kalori dan makronutrien Atwater secara real-time, dan tombol simpan catatan makan.


![Gambar 6.11: Wireframe Monokrom — Layar Penyesuaian Porsi Makan (Portion Input Screen)](docs/brd/wireframes/monochrome/11_portion_input-wireframe.png)
*Gambar 6.11: Wireframe Monokrom — Layar Penyesuaian Porsi Makan (Portion Input Screen)*


### Layar 12: Meal History Screen (Linimasa Riwayat Makan)

Daftar kronologis riwayat makan harian pengguna yang dikelompokkan berdasarkan tanggal kalender dan kategori waktu (Sarapan, Makan Siang, Makan Malam, Camilan), dilengkapi thumbnail foto hidangan dan rekapitulasi kalori.


![Gambar 6.12: Wireframe Monokrom — Layar Riwayat Makan Harian (Meal History Screen)](docs/brd/wireframes/monochrome/12_meal_history-wireframe.png)
*Gambar 6.12: Wireframe Monokrom — Layar Riwayat Makan Harian (Meal History Screen)*


### Layar 13: Nutrition Analysis Screen (Grafik & Tren Gizi)

Layar analitik mendalam yang memvisualisasikan grafik tren asupan kalori mingguan, diagram lingkaran (pie chart) komposisi makronutrien, serta status kepatuhan terhadap Safe Calorie Floor.


![Gambar 6.13: Wireframe Monokrom — Layar Analitik & Visualisasi Nutrisi (Nutrition Analysis)](docs/brd/wireframes/monochrome/13_nutrition_analysis-wireframe.png)
*Gambar 6.13: Wireframe Monokrom — Layar Analitik & Visualisasi Nutrisi (Nutrition Analysis)*


### Layar 14: User Profile Screen (Manajemen Akun & Metrik)

Pusat pengelolaan identitas pengguna yang menampilkan kartu avatar, ringkasan target kalori, tombol pembaruan metrik fisik, tombol aktivasi biometrik, menu tentang aplikasi (About Screen), tombol keluar sesi (Logout), dan tombol hapus akun.


![Gambar 6.14: Wireframe Monokrom — Layar Profil & Pengaturan Akun (User Profile Screen)](docs/brd/wireframes/monochrome/14_user_profile-wireframe.png)
*Gambar 6.14: Wireframe Monokrom — Layar Profil & Pengaturan Akun (User Profile Screen)*


### Layar 15: Nutrition Articles Catalog (Katalog Literasi Gizi)

Katalog artikel edukasi kesehatan yang diterbitkan oleh administrator. Disusun dalam bentuk kartu interaktif berisikan gambar sampul, tag kategori, judul artikel, estimasi waktu baca, dan ringkasan singkat.


![Gambar 6.15: Wireframe Monokrom — Katalog Artikel Literasi Gizi (Nutrition Articles Screen)](docs/brd/wireframes/monochrome/15_nutrition_articles-wireframe.png)
*Gambar 6.15: Wireframe Monokrom — Katalog Artikel Literasi Gizi (Nutrition Articles Screen)*


### Layar 16: Article Detail Screen (Baca Lengkap Artikel)

Layar pembaca artikel yang merender format Markdown terstruktur dengan tipografi nyaman dibaca, pemisahan subjudul yang jelas, gambar pendukung, serta metadata penulis administrator.


![Gambar 6.16: Wireframe Monokrom — Layar Detail Artikel Edukasi Gizi (Article Detail Screen)](docs/brd/wireframes/monochrome/16_article_detail-wireframe.png)
*Gambar 6.16: Wireframe Monokrom — Layar Detail Artikel Edukasi Gizi (Article Detail Screen)*


### Layar 17: Avatar Selection Dialog (Modal Pemilihan Avatar)

Kotak dialog modal berbasis grid yang menyajikan katalog ilustrasi avatar personal. Pengguna dapat memilih karakter visual yang diinginkan dengan efek penyorotan bingkai kuning elektrik pada avatar yang aktif.


![Gambar 6.17: Wireframe Monokrom — Modal Pemilihan Karakter Avatar (Avatar Selection Dialog)](docs/brd/wireframes/monochrome/17_avatar_dialog-wireframe.png)
*Gambar 6.17: Wireframe Monokrom — Modal Pemilihan Karakter Avatar (Avatar Selection Dialog)*


### Layar 18: Delete Account Confirmation Dialog (Modal Hapus Akun)

Dialog konfirmasi kritis beraksen merah koral yang memberikan peringatan tegas mengenai konsekuensi pemusnahan seluruh data riwayat makan dan foto secara permanen tanpa opsi pemulihan, mematuhi standar hak privasi UU PDP.


![Gambar 6.18: Wireframe Monokrom — Dialog Konfirmasi Hapus Akun Permanen (Delete Account Dialog)](docs/brd/wireframes/monochrome/18_delete_account_dialog-wireframe.png)
*Gambar 6.18: Wireframe Monokrom — Dialog Konfirmasi Hapus Akun Permanen (Delete Account Dialog)*


### Layar 19: Admin Dashboard Screen (Portal Manajemen CMS)

Antarmuka khusus pengelola sistem untuk memantau metrik ringkasan aplikasi, mengelola entri makanan pada katalog master TKPI 2020, memverifikasi formula Atwater, menyunting artikel edukasi, dan memeriksa log audit aktivitas.


![Gambar 6.19: Wireframe Monokrom — Dasbor Administrasi & CMS Sistem (Admin Dashboard Screen)](docs/brd/wireframes/monochrome/19_admin_dashboard-wireframe.png)
*Gambar 6.19: Wireframe Monokrom — Dasbor Administrasi & CMS Sistem (Admin Dashboard Screen)*


## 6.6 State Management dengan Provider (Consumer, Selector & ChangeNotifier)

Manajemen status aplikasi mengandalkan pustaka <code>provider: ^6.1.2</code> yang dihubungkan melalui pola <code>MultiProvider</code> pada berkas <code>main.dart</code>. Untuk mencegah pembangunan ulang widget yang tidak perlu (unnecessary rebuilds), antarmuka menggunakan widget <code>Selector</code> yang secara granular hanya mendengarkan perubahan pada variabel nilai spesifik (misal: hanya mendengarkan <code>totalCalories</code> pada Hero Calorie Dial).


## 6.7 Responsivitas & Adaptasi Berbagai Ukuran Layar

Antarmuka didesain adaptif terhadap berbagai rasio aspek layar ponsel pintar (16:9, 18:9, 20:9) hingga tablet. Semua kontainer utama dibungkus dalam <code>SingleChildScrollView</code> dengan <code>ClampingScrollPhysics</code> untuk mencegah overflow pada perangkat dengan faktor penskalaan teks (text scale factor) besar hingga 1.4x.


## 6.8 Aksesibilitas (Semantics, Color Contrast, Touch Targets)

Prinsip aksesibilitas ditegakkan secara ketat: rasio kontras warna teks hitam di atas kanvas krem melebihi 14:1 (jauh melampaui standar WCAG AAA 7:1), setiap tombol interaktif memiliki target sentuh minimum 48x48 dp, dan seluruh elemen grafis bermakna dibungkus widget <code>Semantics</code> dengan label pembaca layar yang deskriptif.


## 6.9 Animasi & Transisi Halus (Curves, Durasi, Haptic Feedback)

Meskipun mengusung gaya brutalist, pengalaman pengguna tetap dipertahankan luwes melalui kurva animasi <code>Curves.easeInOutCubic</code> dengan durasi transisi standar 250ms hingga 350ms. Interaksi penekanan tombol dilengkapi umpan balik getaran haptik halus (<code>HapticFeedback.lightImpact()</code>) untuk sensasi taktil yang nyata.


## 6.10 Pengujian Widget UI

Komponen antarmuka diuji melalui rangkaian Automated Widget Tests menggunakan <code>WidgetTester</code>. Pengujian memvalidasi rendering sempurna elemen kartu NeoCard, eksekusi callback pada NeoButton, responsivitas formulir CompleteProfileScreen, serta konsistensi tata letak Bento Grid tanpa satupun peringatan render overflow.
