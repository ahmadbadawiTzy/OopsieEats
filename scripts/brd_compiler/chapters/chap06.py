"""
Chapter 6: Pengembangan Mobile UI (Bab 6)
"""

from scripts.brd_compiler.builder import ChapterContent

def build_chapter_06():
    ch = ChapterContent(
        chapter_id="BAB_06",
        number_str="Bab 6",
        title="Pengembangan Mobile UI",
        subtitle="Sistem Desain Overkill Neo-Brutalism, Pohon Navigasi, Katalog 19 Wireframe Monokrom, dan State Management",
        filename="BAB_06_PENGEMBANGAN_MOBILE_UI"
    )

    # 6.1 Filosofi Desain
    ch.add_h2("6.1 Filosofi Desain: Overkill Neo-Brutalism Design System")
    ch.add_p(
        "OopsieEats menolak pendekatan desain minimalis konvensional (flat design / glassmorphism) yang cenderung homogen "
        "dan membosankan. Sebagai gantinya, aplikasi mengadopsi bahasa visual <strong>Overkill Neo-Brutalism</strong> "
        "yang terinspirasi oleh estetika desain brutalist fungsional dengan sentuhan modern berenergi tinggi."
    )
    ch.add_p(
        "Ciri khas filosofis Overkill Neo-Brutalism pada OopsieEats mencakup: "
        "(1) Garis batas tebal (Bold Outlines: 2.0px hingga 3.0px) berwarna hitam pekat (<code>#000000</code>), "
        "(2) Bayangan jatuh tanpa blur (Hard Drop Shadows: offset 4px hingga 6px tanpa radius penyebaran), "
        "(3) Latar belakang kanvas krem hangat (Warm Cream Canvas: <code>#FDFBF7</code>) yang ramah di mata, "
        "(4) Palet warna aksen primer kontras tinggi yang memberikan umpan balik visual seketika, dan "
        "(5) Tipografi tegas dengan hierarki pembobotan font tebal (Bold & Extra-Bold)."
    )

    # 6.2 Palet Warna, Tipografi & Spacing Tokens
    ch.add_h2("6.2 Palet Warna, Tipografi & Spacing Tokens")
    ch.add_p(
        "Seluruh elemen antarmuka dikendalikan oleh sistem token terpusat pada <code>lib/core/theme/neo_colors.dart</code> "
        "dan <code>neo_tokens.dart</code>:"
    )
    ch.add_table(
        caption="Tabel 6.1: Spesifikasi Token Desain Overkill Neo-Brutalism",
        headers=["Kategori Token", "Nama Variabel Token", "Nilai Heksadesimal / Dimensi", "Peran Semantik UI"],
        rows=[
            ["Warna Kanvas", "NeoColors.canvasBg", "#FDFBF7 (Warm Cream)", "Latar belakang utama seluruh layar aplikasi"],
            ["Warna Permukaan", "NeoColors.surfaceCard", "#FFFFFF (Pure White)", "Latar permukaan kartu, dialog, dan input text"],
            ["Warna Garis", "NeoColors.pureBlack", "#000000 (Pure Black)", "Border kontur 2.5px dan hard drop shadow"],
            ["Warna Primer", "NeoColors.electricYellow", "#FFE600 (Electric Yellow)", "Tombol tindakan utama (CTA) & highlight progres"],
            ["Warna Sekunder", "NeoColors.vibrantOrange", "#FF6B00 (Vibrant Orange)", "Kategori makan siang & lencana kalori tinggi"],
            ["Warna Aksen 1", "NeoColors.mintGreen", "#00E599 (Mint Green)", "Indikator protein, sukses, dan target tercapai"],
            ["Warna Aksen 2", "NeoColors.lavenderPurple", "#9D7BFF (Lavender Purple)", "Kategori makan malam & visualisasi makronutrien"],
            ["Warna Bahaya", "NeoColors.coralRed", "#FF3B30 (Coral Red)", "Peringatan bahaya, tombol hapus, kalori berlebih"],
            ["Border Width", "NeoTokens.borderBold", "2.5 px solid", "Ketebalan garis batas seluruh tombol dan kartu"],
            ["Drop Shadow", "NeoTokens.shadowHard", "Offset (4.0, 4.0), Blur 0.0", "Bayangan jatuh tegas retro-modern"],
            ["Border Radius", "NeoTokens.radiusNeo", "12.0 px rounded", "Kelengkungan sudut elemen struktural"]
        ]
    )

    # 6.3 Komponen Desain Reusable
    ch.add_h2("6.3 Komponen Desain Reusable (Design System Widgets)")
    ch.add_p(
        "Untuk mencegah duplikasi kode dan menjaga konsistensi tampilan, aplikasi membangun pustaka komponen mandiri:"
    )
    ch.add_list([
        "<strong>NeoButton</strong>: Komponen tombol interaktif dengan animasi penekanan (press animation) yang menggeser posisi tombol 2px ke bawah-kanan bersamaan dengan reduksi bayangan saat ditekan, memberikan efek taktil fisik yang memuaskan.",
        "<strong>NeoCard</strong>: Wadah informasi berbasis kartu putih dengan border hitam 2.5px dan hard shadow 4px, dilengkapi opsi header aksen warna warni untuk pengelompokan data.",
        "<strong>NeoInput</strong>: Bidang masukan teks dengan border kontras tinggi, label floating tebal, indikator fokus berwarna kuning elektrik, dan pesan galat validasi terintegrasi.",
        "<strong>NeoBottomNav</strong>: Bilah navigasi bawah mengambang (floating bar) dengan ikon kustom tebal dan indikator tab aktif berbingkai Neo-Brutalism.",
        "<strong>AvatarWidget</strong>: Komponen visual identitas pengguna yang menampilkan ilustrasi karakter pilihan dengan bingkai melingkar bergaris hitam ganda."
    ])

    # 6.4 Struktur Navigasi & Alur Layar
    ch.add_h2("6.4 Struktur Navigasi & Alur Layar (Bottom Navigation & Route Tree)")
    ch.add_p(
        "Pohon navigasi aplikasi OopsieEats dikendalikan oleh router deklaratif terpusat yang memetakan 19 layar "
        "ke dalam hierarki alur onboarding, autentikasi, dasbor utama, pemindai makanan, dan modul manajemen profil, "
        "sebagaimana dirinci pada Diagram 6:"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/navigation-flow.png",
        caption="Gambar 6.0: Diagram Alur Navigasi & Pohon Rute Layar Aplikasi (Navigation Flow)"
    )
    ch.add_p(
        "Siklus hidup transisi status antarmuka pengguna, evaluasi sesi, dan penguncian Complete Profile Guard "
        "dimodelkan secara formal melalui Diagram State Machine UML berikut:"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/uml-ui-state-machine.png",
        caption="Gambar 6.0b: Diagram State Machine UML — Siklus Hidup Antarmuka & Complete Profile Guard State Machine"
    )

    # 6.5 Desain & Spesifikasi 19 Layar Aplikasi
    ch.add_h2("6.5 Desain & Spesifikasi 19 Layar Aplikasi (Katalog Lengkap Wireframe Monokrom)")
    ch.add_p(
        "Berikut adalah katalog visual 19 layar aplikasi OopsieEats yang disajikan dalam format wireframe monokrom "
        "kontras tinggi standar rekayasa perangkat lunak internasional. Setiap wireframe diekstraksi 100% dari "
        "tangkapan layar aplikasi aktual (pixel-perfect) dengan bingkai perangkat mobile 1.5px tanpa teks banner internal:"
    )

    # Wireframe 1
    ch.add_h3("Layar 1: Onboarding Slide 1 (Track Nutrisi Instan)")
    ch.add_p(
        "Layar pembuka interaktif pertama yang menyambut pengguna baru dengan visualisasi ilustrasi piring makanan bernutrisi. "
        "Menjelaskan proposisi nilai utama OopsieEats dalam mengenali hidangan nusantara secara instan dengan bantuan AI."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/01_onboarding_slide1-wireframe.png",
        caption="Gambar 6.1: Wireframe Monokrom — Layar Onboarding Slide 1 (Pengenalan Deteksi AI)",
        is_wireframe=True
    )

    # Wireframe 2
    ch.add_h3("Layar 2: Onboarding Slide 2 (Kalkulasi Ilmiah Deterministik)")
    ch.add_p(
        "Slide edukasi kedua yang memaparkan keunggulan transparansi kalkulasi gizi berdasarkan formula ilmiah Mifflin-St Jeor "
        "dan basis data resmi Kementerian Kesehatan RI (TKPI 2020), menjamin estimasi kalori yang dapat dipertanggungjawabkan."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/02_onboarding_slide2-wireframe.png",
        caption="Gambar 6.2: Wireframe Monokrom — Layar Onboarding Slide 2 (Kalkulasi Nutrisi Ilmiah)",
        is_wireframe=True
    )

    # Wireframe 3
    ch.add_h3("Layar 3: Onboarding Slide 3 (Privasi & Kesiapan Akses)")
    ch.add_p(
        "Slide ketiga yang menekankan kedaulatan privasi visual (on-device processing) dan tombol aksi utama (CTA) 'Mulai Sekarang' "
        "yang membawa pengguna ke gerbang autentikasi akun."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/03_onboarding_slide3-wireframe.png",
        caption="Gambar 6.3: Wireframe Monokrom — Layar Onboarding Slide 3 (Kedaulatan Privasi & CTA Mulai)",
        is_wireframe=True
    )

    # Wireframe 4
    ch.add_h3("Layar 4: Splash Screen (Branding & Pemuatan Awal)")
    ch.add_p(
        "Layar pemuatan awal sistem yang menampilkan tipografi logo OopsieEats berkarakter Neo-Brutalism dengan bayangan tegas. "
        "Secara paralel mengeksekusi inisialisasi Firebase, pemeriksaan sesi terenkripsi, dan pengecekan kelengkapan profil."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/04_splash_screen-wireframe.png",
        caption="Gambar 6.4: Wireframe Monokrom — Layar Splash Screen (Inisialisasi Sistem)",
        is_wireframe=True
    )

    # Wireframe 5
    ch.add_h3("Layar 5: Register Screen (Pendaftaran Akun Baru)")
    ch.add_p(
        "Antarmuka registrasi akun yang memuat kolom masukan nama lengkap, email, kata sandi, konfirmasi kata sandi, "
        "tombol daftar Neo-Brutalism, serta pemisah opsi login pihak ketiga (Google Sign-In)."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/05_register_screen-wireframe.png",
        caption="Gambar 6.5: Wireframe Monokrom — Layar Pendaftaran Akun Baru (Register Screen)",
        is_wireframe=True
    )

    # Wireframe 6
    ch.add_h3("Layar 6: Complete Profile Screen (Guard Metrik Antropometri)")
    ch.add_p(
        "Layar wajib pengisian data antropometri (usia, jenis kelamin, tinggi badan, berat badan, dan frekuensi aktivitas fisik). "
        "Dilindungi oleh Complete Profile Guard sehingga tidak dapat dilewati sebelum seluruh masukan valid terverifikasi."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/06_complete_profile-wireframe.png",
        caption="Gambar 6.6: Wireframe Monokrom — Layar Lengkapi Profil Fisik (Complete Profile Screen)",
        is_wireframe=True
    )

    # Wireframe 7
    ch.add_h3("Layar 7: Login Screen (Gerbang Masuk Pengguna)")
    ch.add_p(
        "Formulir login bersih dengan dukungan masukan email/kata sandi, tombol pintas Google OAuth, opsi aktivasi biometrik, "
        "serta tautan pemulihan kata sandi 'Lupa Sandi?'."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/07_login_screen-wireframe.png",
        caption="Gambar 6.7: Wireframe Monokrom — Layar Masuk Akun (Login Screen)",
        is_wireframe=True
    )

    # Wireframe 8
    ch.add_h3("Layar 8: Dashboard / Home Screen (Pusat Kendali Nutrisi)")
    ch.add_p(
        "Layar beranda utama yang menyajikan Hero Calorie Dial interaktif (kalori terkonsumsi vs target harian), "
        "Bento Grid kartu ringkasan makronutrien (Karbohidrat, Protein, Lemak), daftar hidangan hari ini, dan bilah navigasi bawah."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/08_dashboard_home-wireframe.png",
        caption="Gambar 6.8: Wireframe Monokrom — Layar Beranda Utama (Dashboard / Home Screen)",
        is_wireframe=True
    )

    # Wireframe 9
    ch.add_h3("Layar 9: Scanner Viewfinder (Jendela Bidik Kamera)")
    ch.add_p(
        "Antarmuka kamera langsung berkecepatan tinggi dengan bingkai pemindai sudut kontras tinggi, tombol kendali lampu kilat (flash), "
        "tombol beralih ke galeri foto lokal, dan tombol rana (shutter button) berkarakter tebal."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/09_scanner_viewfinder-wireframe.png",
        caption="Gambar 6.9: Wireframe Monokrom — Jendela Bidik Kamera (Scanner Viewfinder Screen)",
        is_wireframe=True
    )

    # Wireframe 10
    ch.add_h3("Layar 10: Detection Confirmation Screen (Konfirmasi Deteksi AI)")
    ch.add_p(
        "Menampilkan foto yang baru saja diambil dengan hamparan kotak pembatas (bounding boxes) di sekitar makanan yang terdeteksi, "
        "nama hidangan teridentifikasi dari 29 kelas pangan, persentase tingkat keyakinan (confidence score), dan tombol konfirmasi."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/10_detection_confirmation-wireframe.png",
        caption="Gambar 6.10: Wireframe Monokrom — Layar Konfirmasi Hasil Deteksi (Detection Confirmation)",
        is_wireframe=True
    )

    # Wireframe 11
    ch.add_h3("Layar 11: Portion Input Screen (Penetapan Bobot Porsi)")
    ch.add_p(
        "Antarmuka penyesuaian porsi saji dalam satuan gram. Dilengkapi tombol cepat (1/2 porsi, 1 porsi standar, 1.5 porsi), "
        "slider bobot porsi, kalkulasi langsung nilai kalori dan makronutrien Atwater secara real-time, dan tombol simpan catatan makan."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/11_portion_input-wireframe.png",
        caption="Gambar 6.11: Wireframe Monokrom — Layar Penyesuaian Porsi Makan (Portion Input Screen)",
        is_wireframe=True
    )

    # Wireframe 12
    ch.add_h3("Layar 12: Meal History Screen (Linimasa Riwayat Makan)")
    ch.add_p(
        "Daftar kronologis riwayat makan harian pengguna yang dikelompokkan berdasarkan tanggal kalender dan kategori waktu "
        "(Sarapan, Makan Siang, Makan Malam, Camilan), dilengkapi thumbnail foto hidangan dan rekapitulasi kalori."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/12_meal_history-wireframe.png",
        caption="Gambar 6.12: Wireframe Monokrom — Layar Riwayat Makan Harian (Meal History Screen)",
        is_wireframe=True
    )

    # Wireframe 13
    ch.add_h3("Layar 13: Nutrition Analysis Screen (Grafik & Tren Gizi)")
    ch.add_p(
        "Layar analitik mendalam yang memvisualisasikan grafik tren asupan kalori mingguan, diagram lingkaran (pie chart) "
        "komposisi makronutrien, serta status kepatuhan terhadap Safe Calorie Floor."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/13_nutrition_analysis-wireframe.png",
        caption="Gambar 6.13: Wireframe Monokrom — Layar Analitik & Visualisasi Nutrisi (Nutrition Analysis)",
        is_wireframe=True
    )

    # Wireframe 14
    ch.add_h3("Layar 14: User Profile Screen (Manajemen Akun & Metrik)")
    ch.add_p(
        "Pusat pengelolaan identitas pengguna yang menampilkan kartu avatar, ringkasan target kalori, tombol pembaruan metrik fisik, "
        "tombol aktivasi biometrik, menu tentang aplikasi (About Screen), tombol keluar sesi (Logout), dan tombol hapus akun."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/14_user_profile-wireframe.png",
        caption="Gambar 6.14: Wireframe Monokrom — Layar Profil & Pengaturan Akun (User Profile Screen)",
        is_wireframe=True
    )

    # Wireframe 15
    ch.add_h3("Layar 15: Nutrition Articles Catalog (Katalog Literasi Gizi)")
    ch.add_p(
        "Katalog artikel edukasi kesehatan yang diterbitkan oleh administrator. Disusun dalam bentuk kartu interaktif "
        "berisikan gambar sampul, tag kategori, judul artikel, estimasi waktu baca, dan ringkasan singkat."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/15_nutrition_articles-wireframe.png",
        caption="Gambar 6.15: Wireframe Monokrom — Katalog Artikel Literasi Gizi (Nutrition Articles Screen)",
        is_wireframe=True
    )

    # Wireframe 16
    ch.add_h3("Layar 16: Article Detail Screen (Baca Lengkap Artikel)")
    ch.add_p(
        "Layar pembaca artikel yang merender format Markdown terstruktur dengan tipografi nyaman dibaca, pemisahan subjudul yang jelas, "
        "gambar pendukung, serta metadata penulis administrator."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/16_article_detail-wireframe.png",
        caption="Gambar 6.16: Wireframe Monokrom — Layar Detail Artikel Edukasi Gizi (Article Detail Screen)",
        is_wireframe=True
    )

    # Wireframe 17
    ch.add_h3("Layar 17: Avatar Selection Dialog (Modal Pemilihan Avatar)")
    ch.add_p(
        "Kotak dialog modal berbasis grid yang menyajikan katalog ilustrasi avatar personal. Pengguna dapat memilih karakter visual "
        "yang diinginkan dengan efek penyorotan bingkai kuning elektrik pada avatar yang aktif."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/17_avatar_dialog-wireframe.png",
        caption="Gambar 6.17: Wireframe Monokrom — Modal Pemilihan Karakter Avatar (Avatar Selection Dialog)",
        is_wireframe=True
    )

    # Wireframe 18
    ch.add_h3("Layar 18: Delete Account Confirmation Dialog (Modal Hapus Akun)")
    ch.add_p(
        "Dialog konfirmasi kritis beraksen merah koral yang memberikan peringatan tegas mengenai konsekuensi pemusnahan seluruh data "
        "riwayat makan dan foto secara permanen tanpa opsi pemulihan, mematuhi standar hak privasi UU PDP."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/18_delete_account_dialog-wireframe.png",
        caption="Gambar 6.18: Wireframe Monokrom — Dialog Konfirmasi Hapus Akun Permanen (Delete Account Dialog)",
        is_wireframe=True
    )

    # Wireframe 19
    ch.add_h3("Layar 19: Admin Dashboard Screen (Portal Manajemen CMS)")
    ch.add_p(
        "Antarmuka khusus pengelola sistem untuk memantau metrik ringkasan aplikasi, mengelola entri makanan pada katalog master "
        "TKPI 2020, memverifikasi formula Atwater, menyunting artikel edukasi, dan memeriksa log audit aktivitas."
    )
    ch.add_figure(
        path="docs/brd/wireframes/monochrome/19_admin_dashboard-wireframe.png",
        caption="Gambar 6.19: Wireframe Monokrom — Dasbor Administrasi & CMS Sistem (Admin Dashboard Screen)",
        is_wireframe=True
    )

    # 6.6 State Management dengan Provider
    ch.add_h2("6.6 State Management dengan Provider (Consumer, Selector & ChangeNotifier)")
    ch.add_p(
        "Manajemen status aplikasi mengandalkan pustaka <code>provider: ^6.1.2</code> yang dihubungkan melalui pola "
        "<code>MultiProvider</code> pada berkas <code>main.dart</code>. Untuk mencegah pembangunan ulang widget yang tidak "
        "perlu (unnecessary rebuilds), antarmuka menggunakan widget <code>Selector</code> yang secara granular hanya mendengarkan "
        "perubahan pada variabel nilai spesifik (misal: hanya mendengarkan <code>totalCalories</code> pada Hero Calorie Dial)."
    )

    # 6.7 Responsivitas & Adaptasi Berbagai Ukuran Layar
    ch.add_h2("6.7 Responsivitas & Adaptasi Berbagai Ukuran Layar")
    ch.add_p(
        "Antarmuka didesain adaptif terhadap berbagai rasio aspek layar ponsel pintar (16:9, 18:9, 20:9) hingga tablet. "
        "Semua kontainer utama dibungkus dalam <code>SingleChildScrollView</code> dengan <code>ClampingScrollPhysics</code> "
        "untuk mencegah overflow pada perangkat dengan faktor penskalaan teks (text scale factor) besar hingga 1.4x."
    )

    # 6.8 Aksesibilitas
    ch.add_h2("6.8 Aksesibilitas (Semantics, Color Contrast, Touch Targets)")
    ch.add_p(
        "Prinsip aksesibilitas ditegakkan secara ketat: rasio kontras warna teks hitam di atas kanvas krem melebihi 14:1 "
        "(jauh melampaui standar WCAG AAA 7:1), setiap tombol interaktif memiliki target sentuh minimum 48x48 dp, "
        "dan seluruh elemen grafis bermakna dibungkus widget <code>Semantics</code> dengan label pembaca layar yang deskriptif."
    )

    # 6.9 Animasi & Transisi Halus
    ch.add_h2("6.9 Animasi & Transisi Halus (Curves, Durasi, Haptic Feedback)")
    ch.add_p(
        "Meskipun mengusung gaya brutalist, pengalaman pengguna tetap dipertahankan luwes melalui kurva animasi <code>Curves.easeInOutCubic</code> "
        "dengan durasi transisi standar 250ms hingga 350ms. Interaksi penekanan tombol dilengkapi umpan balik getaran haptik halus "
        "(<code>HapticFeedback.lightImpact()</code>) untuk sensasi taktil yang nyata."
    )

    # 6.10 Pengujian Widget UI
    ch.add_h2("6.10 Pengujian Widget UI")
    ch.add_p(
        "Komponen antarmuka diuji melalui rangkaian Automated Widget Tests menggunakan <code>WidgetTester</code>. Pengujian memvalidasi "
        "rendering sempurna elemen kartu NeoCard, eksekusi callback pada NeoButton, responsivitas formulir CompleteProfileScreen, "
        "serta konsistensi tata letak Bento Grid tanpa satupun peringatan render overflow."
    )

    return ch
