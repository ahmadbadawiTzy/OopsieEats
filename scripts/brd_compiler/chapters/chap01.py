"""
Chapter 1: Pendahuluan dan Desain Sistem (Bab 1)
"""

from scripts.brd_compiler.builder import ChapterContent

def build_chapter_01():
    ch = ChapterContent(
        chapter_id="BAB_01",
        number_str="Bab 1",
        title="Pendahuluan dan Desain Sistem",
        subtitle="Perencanaan Proyek, Pernyataan Masalah, Ruang Lingkup, Arsitektur Sistem, dan Matriks Stakeholder",
        filename="BAB_01_PENDAHULUAN_DAN_DESAIN_SISTEM"
    )

    # 1.1 Latar Belakang & Pernyataan Masalah
    ch.add_h2("1.1 Latar Belakang & Pernyataan Masalah")
    ch.add_p(
        "Kebutuhan masyarakat modern terhadap pemantauan asupan gizi harian terus meningkat seiring tingginya prevalensi "
        "penyakit degeneratif seperti diabetes melitus, obesitas, dan hipertensi yang dipicu oleh pola makan tidak seimbang. "
        "Meskipun berbagai aplikasi pelacak kalori telah beredar di pasar global, sebagian besar memiliki friksi adopsi yang "
        "sangat tinggi: pengguna diwajibkan mencari nama hidangan secara tekstual satu per satu dari ribuan entri, memperkirakan "
        "ukuran porsi tanpa acuan standar lokal, serta menghadapi ketergantungan konstan pada koneksi internet berbayar."
    )
    ch.add_p(
        "Berdasarkan survei empiris perilaku pengguna aplikasi kesehatan, lebih dari 68% pengguna menghentikan pencatatan "
        "nutrisi dalam kurun waktu 14 hari pertama semata-mata karena beban kognitif (cognitive overhead) dalam memasukkan data "
        "secara manual. Selain itu, sebagian besar aplikasi komersial mengadopsi basis data kuliner barat yang tidak mengakomodasi "
        "kekayaan dan variasi komposisi kuliner nusantara, seperti rawon, rendang, gado-gado, soto ayam, dan tempe bacem."
    )
    ch.add_p(
        "Aplikasi <strong>OopsieEats</strong> (dengan identitas paket resmi <code>com.oopsieeats.app</code>, versi <code>1.0.0+2002</code>, "
        "yang berevolusi dari basis riset arsitektur NutriView) dikembangkan untuk memecahkan dilema tersebut. OopsieEats "
        "menggabungkan teknologi Computer Vision mutakhir berbasis on-device Deep Learning (YOLOv8 TFLite) dengan kerangka "
        "kerja nutrisi ilmiah Tabel Komposisi Pangan Indonesia (TKPI 2020) dari Kementerian Kesehatan Republik Indonesia, "
        "memungkinkan identifikasi hidangan secara instan, luring (offline), dan akurat tanpa mengorbankan privasi data visual pengguna."
    )

    # 1.2 Tujuan Proyek & Indikator Keberhasilan (KPI)
    ch.add_h2("1.2 Tujuan Proyek & Indikator Keberhasilan (KPI)")
    ch.add_p(
        "Pengembangan OopsieEats diarahkan pada pencapaian serangkaian sasaran strategis rekayasa perangkat lunak dan bisnis "
        "yang terukur melalui Key Performance Indicators (KPI) kuantitatif:"
    )
    ch.add_table(
        caption="Tabel 1.1: Matriks Sasaran Proyek dan Indikator Keberhasilan (KPI)",
        headers=["No", "Sasaran Strategis", "Indikator Keberhasilan (KPI)", "Metode Verifikasi", "Target Capaian"],
        rows=[
            ["1", "Pencatatan Nutrisi Cepat & Ergonomis", "Durasi pencatatan makan dari pemindaian hingga penyimpanan", "Benchmark pengujian UX", "< 15 detik per sesi"],
            ["2", "Inferensi Kecerdasan Buatan On-Device", "Latensi deteksi objek pangan pada perangkat mobile", "Stopwatch Isolate.run", "< 300 ms (rata-rata 180ms)"],
            ["3", "Ketahanan Tanpa Jaringan (Offline-First)", "Fungsionalitas klasifikasi makanan & kalkulasi gizi saat luring", "Uji regresi mode pesawat", "100% fitur inti beroperasi"],
            ["4", "Presisi Perhitungan Energi", "Konsistensi formula Mifflin-St Jeor & verifikasi makro Atwater", "Automated Unit Test (42 berkas)", "359 pengujian lulus 100%"],
            ["5", "Keamanan & Kedaulatan Privasi Data", "Enkripsi kredensial & perlindungan hak hapus data (UU PDP)", "Security Audit Rule & Keychain", "0 kebocoran kredensial"],
            ["6", "Kualitas Kode Sumber & Pemeliharaan", "Analisis statis Dart linter & pemisahan arsitektur", "flutter analyze CLI", "0 lint warnings / errors"]
        ]
    )

    # 1.3 Ruang Lingkup Proyek
    ch.add_h2("1.3 Ruang Lingkup Proyek (In-Scope vs Out-of-Scope)")
    ch.add_p(
        "Untuk memastikan ketepatan jadwal rilis, keandalan fungsional, dan integritas arsitektural, ruang lingkup proyek "
        "dibatasi secara ketat menjadi aspek In-Scope dan Out-of-Scope:"
    )
    ch.add_table(
        caption="Tabel 1.2: Batasan Ruang Lingkup Fungsional Proyek OopsieEats",
        headers=["Kategori Ruang Lingkup", "Deskripsi Fitur / Modul", "Status Batasan"],
        rows=[
            ["In-Scope", "Deteksi visual otomatis 29 kelas hidangan Indonesia via TFLite (best.tflite, 9.4 MB)", "Diimplementasikan Penuh"],
            ["In-Scope", "Kalkulasi target BMR, TDEE, kalori, dan makronutrien deterministik (Mifflin-St Jeor)", "Diimplementasikan Penuh"],
            ["In-Scope", "Antarmuka Overkill Neo-Brutalism (19 layar terintegrasi, border tebal, hard shadow)", "Diimplementasikan Penuh"],
            ["In-Scope", "Manajemen sesi autentikasi (Email/Password, Google OAuth, Biometrik Fingerprint/Face ID)", "Diimplementasikan Penuh"],
            ["In-Scope", "Persistensi ganda: Cloud Firestore (asia-southeast2) dan Supabase Storage (signed URLs)", "Diimplementasikan Penuh"],
            ["In-Scope", "Mekanisme Complete Profile Guard & Alur Hapus Akun Permanen (Self-Service Privacy)", "Diimplementasikan Penuh"],
            ["In-Scope", "Portal Content Management System (CMS) Admin untuk katalog pangan dan artikel edukasi", "Diimplementasikan Penuh"],
            ["Out-of-Scope", "Integrasi perangkat keras wearable pihak ketiga (Apple HealthKit / Google Fit API)", "Rilis Masa Depan (v2.0)"],
            ["Out-of-Scope", "Konsultasi tele-nutrisi real-time tatap muka langsung dengan dokter spesialis gizi", "Di Luar Fokus Produk"],
            ["Out-of-Scope", "Sistem pembayaran langganan in-app purchase (seluruh fitur aplikasi 100% gratis)", "Kebijakan Non-Komersial"]
        ]
    )

    # 1.4 Identifikasi Pemangku Kepentingan (Stakeholder Analysis)
    ch.add_h2("1.4 Identifikasi Pemangku Kepentingan (Stakeholder Analysis)")
    ch.add_p(
        "Analisis pemangku kepentingan mengidentifikasi pihak-pihak internal dan eksternal yang memiliki kepentingan, "
        "pengaruh, dan ekspektasi langsung terhadap siklus hidup perangkat lunak OopsieEats:"
    )
    ch.add_table(
        caption="Tabel 1.3: Matriks Analisis Pemangku Kepentingan Proyek",
        headers=["Stakeholder", "Peran & Kategori", "Kepentingan Utama", "Tingkat Pengaruh", "Strategi Keterlibatan"],
        rows=[
            ["Pengguna Akhir (User)", "Pengguna Mobile Eksternal", "Pencatatan makan cepat, estimasi gizi akurat, privasi terjamin", "Tinggi", "Uji usabilitas, umpan balik langsung, analitik anonim"],
            ["Administrator Sistem", "Operator Bisnis Internal", "Pengelolaan katalog makanan, kurasi artikel gizi, audit log", "Sedang", "Antarmuka CMS terproteksi, dokumentasi panduan admin"],
            ["Lead Architect & Dev", "Tim Teknis Internal", "Integritas clean architecture, performa isolate, 0 lint issue", "Tinggi", "Code review harian, CI/CD automated test suite"],
            ["Auditor Akademis / QA", "Evaluator Independen", "Kepatuhan spesifikasi teknis, bukti pengujian, transparansi kode", "Tinggi", "Laporan BRD komprehensif, trace matrix pengujian"],
            ["Penyedia Cloud (Google/Supa)", "Infrastruktur Eksternal", "Stabilitas kuota Spark/Free tier, kepatuhan batas egress data", "Rendah", "Caching agresif, kompresi gambar, bounded 100MB cache"]
        ]
    )

    # 1.5 Profil & Segmentasi Pengguna
    ch.add_h2("1.5 Profil & Segmentasi Pengguna (Target Audience & Personas)")
    ch.add_p(
        "Target audiens OopsieEats dikelompokkan ke dalam 3 persona representatif untuk memandu keputusan desain interaksi:"
    )
    ch.add_list([
        "<strong>Persona 1: Rian (24 th, Mahasiswa / Junior Professional)</strong> — Memiliki target kebugaran menurunkan persentase lemak tubuh (fat loss). Membutuhkan pencatatan makan super cepat di sela kesibukan kampus tanpa repot menimbang gramasi secara manual. Mengutamakan tampilan modern, interaktif, dan non-konvensional.",
        "<strong>Persona 2: Siti (38 th, Ibu Rumah Tangga & Penggiat Diet Keluarga)</strong> — Mengelola pola makan harian keluarga dengan menu kuliner nusantara rumahan. Membutuhkan estimasi kalori masakan lokal Indonesia dan panduan artikel gizi praktis yang mudah dipahami.",
        "<strong>Persona 3: Hendra (52 th, Pasien Pra-Diabetes / Pengontrol Glukosa)</strong> — Memerlukan pemantauan ketat terhadap asupan karbohidrat dan kalori harian sesuai anjuran medis. Membutuhkan indikator visual kontras tinggi (Neo-Brutalism) yang mudah dibaca pada layar perangkat."
    ])

    # 1.6 Asumsi Proyek & Batasan Sistem
    ch.add_h2("1.6 Asumsi Proyek & Batasan Sistem")
    ch.add_p(
        "Operasional dan kinerja arsitektur sistem didasarkan pada asumsi teknis serta batasan lingkungan berikut:"
    )
    ch.add_list([
        "<strong>Kompatibilitas Sistem Operasi</strong>: Aplikasi berjalan minimal pada Android API level 23 (Android 6.0 Marshmallow) hingga Android 14+ (Target SDK 36), serta iOS 13.0 ke atas.",
        "<strong>Kamera & Perangkat Keras</strong>: Perangkat diasumsikan memiliki modul kamera belakang dengan autofocus minimal 5 MP untuk menghasilkan citra makanan yang memadai.",
        "<strong>Privasi Gambar Visual</strong>: Foto makanan yang diambil melalui fitur pemindai diproses secara komputasi lokal pada memori perangkat; tidak ada gambar mentah yang dikirim ke cloud AI eksternal, menjamin kedaulatan privasi visual.",
        "<strong>Batas Kuota Cloud Gratis ($0 Budget)</strong>: Arsitektur cloud memanfaatkan Firebase Spark Plan dan Supabase Free Tier secara efisien melalui bounded cache 100 MB dan kompresi JPEG 85%."
    ])

    # 1.7 Analisis Kesenjangan Proses Bisnis
    ch.add_h2("1.7 Analisis Kesenjangan Proses Bisnis (As-Is vs To-Be Process)")
    ch.add_p(
        "Transformasi proses bisnis pencatatan makanan dari alur konvensional (As-Is) menjadi alur modern otomatis (To-Be) "
        "diilustrasikan secara sistematis pada Diagram 2:"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/business-process-as-is-to-be.png",
        caption="Gambar 1.1: Diagram Proses Bisnis Pencatatan Nutrisi (As-Is vs To-Be Process)"
    )
    ch.add_p(
        "Pada proses As-Is, pengguna harus melalui 7 tahapan manual yang memakan waktu rata-rata 3 hingga 5 menit per hidangan, "
        "yang menyebabkan tingkat kelelahan mental tinggi. Pada proses To-Be OopsieEats, tahapan dipangkas menjadi 3 langkah "
        "intuitif: Ambil Foto -> Konfirmasi Hasil Deteksi AI -> Simpan Catatan Makan, dengan total durasi di bawah 15 detik."
    )

    # 1.8 Arsitektur Sistem Konseptual & Konteks Sistem
    ch.add_h2("1.8 Arsitektur Sistem Konseptual & Konteks Sistem")
    ch.add_p(
        "Konteks sistem tingkat tinggi dan interaksi batas eksternal aplikasi digambarkan pada Diagram 1:"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/system-context.png",
        caption="Gambar 1.2: Diagram Konteks Sistem Tingkat Tinggi (C4 Context Diagram)"
    )
    ch.add_p(
        "Struktur internal aplikasi dirancang menggunakan arsitektur modular berlapis (Layered & Modular Clean Architecture) "
        "yang memisahkan tanggung jawab antarmuka, logika bisnis, komputasi terisolasi, repositori data, dan infrastruktur persistensi, "
        "sebagaimana dirinci pada Diagram 3:"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/architecture.png",
        caption="Gambar 1.3: Arsitektur Berlapis Aplikasi Mobile OopsieEats (Presentation, State, Core, Data, Infra)"
    )
    ch.add_callout(
        "Pemisahan komputasi inferensi kecerdasan buatan ke dalam Background Isolate (Isolate.run) merupakan kunci utama "
        "stabilitas performa aplikasi, menjamin 0ms UI freezing pada thread utama antarmuka saat model memproses citra 640x640."
    )

    # 1.9 Topologi Deployment & Infrastruktur Cloud
    ch.add_h2("1.9 Topologi Deployment & Infrastruktur Cloud")
    ch.add_p(
        "Infrastruktur produksi OopsieEats mendistribusikan beban komputasi dan penyimpanan ke dua penyedia cloud global "
        "dengan pusat data regional Asia Tenggara, meminimalkan latensi jaringan dan memaksimalkan ketersediaan layanan:"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/deployment-topology.png",
        caption="Gambar 1.4: Diagram Topologi Deployment Multi-Cloud (Firebase asia-southeast2 & Supabase ap-southeast-1)"
    )
    ch.add_table(
        caption="Tabel 1.4: Spesifikasi Komponen Infrastruktur Cloud",
        headers=["Komponen Cloud", "Penyedia Layanan", "Region Data Center", "Protokol Komunikasi", "Fungsi Utama"],
        rows=[
            ["Firebase Auth", "Google Cloud", "Global Edge Network", "HTTPS / OAuth 2.0 / JWT", "Manajemen identitas akun, sesi Google, dan token kredensial"],
            ["Cloud Firestore", "Google Cloud", "asia-southeast2 (Jakarta)", "gRPC / TLS 1.3 Streaming", "Basis data NoSQL profil pengguna, catatan riwayat makan, CMS"],
            ["Supabase Storage", "Supabase Inc.", "ap-southeast-1 (Singapura)", "REST API / Signed URLs", "Penyimpanan objek privat foto makanan terkompresi (food-history-images)"],
            ["On-Device TFLite", "Perangkat Keras Klien", "Lokal (CPU/GPU/NPU Mobile)", "C++ TFLite Runtime Native", "Inferensi model deteksi makanan YOLOv8 tanpa transmisi data"]
        ]
    )

    # 1.10 Diagram Use Case & Matriks Aktor-Sistem
    ch.add_h2("1.10 Diagram Use Case & Matriks Aktor-Sistem")
    ch.add_p(
        "Interaksi fungsional antara pengguna (User), pengelola (Admin), dan subsistem eksternal dipetakan secara formal "
        "pada Diagram 5:"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/use-case.png",
        caption="Gambar 1.5: Diagram Use Case Sistem (Interaksi Pengguna Reguler & Administrator)"
    )
    ch.add_table(
        caption="Tabel 1.5: Matriks Aktor dan Kebutuhan Fungsional Sistem",
        headers=["Kode Use Case", "Nama Fungsionalitas", "Aktor Utama", "Kondisi Awal (Pre-condition)", "Kondisi Akhir (Post-condition)"],
        rows=[
            ["UC-01", "Registrasi Akun Baru", "Pengguna Baru", "Pengguna belum memiliki akun aktif", "Akun terbuat di Firebase Auth, profil terinisialisasi"],
            ["UC-02", "Login Multi-Metode", "Pengguna Terdaftar", "Akun terdaftar di sistem", "Token sesi tersimpan di KeyStore/Keychain"],
            ["UC-03", "Lengkapi Profil Fisik", "Pengguna Baru", "Status isProfileComplete bernilai false", "BMR & target kalori dihitung, akses beranda terbuka"],
            ["UC-04", "Pindai Makanan Kamera", "Pengguna Aktif", "Izin akses kamera diberikan", "Kotak pembatas hidangan & 29 label pangan terdeteksi"],
            ["UC-05", "Simpan Catatan Makan", "Pengguna Aktif", "Porsi terkonfirmasi dalam gram", "Foto diunggah ke Supabase, entri tersimpan di Firestore"],
            ["UC-06", "Hapus Catatan Makan", "Pengguna Aktif", "Catatan makan tercatat di koleksi", "Foto terhapus dari bucket, dokumen dihapus dari subkoleksi"],
            ["UC-07", "Hapus Akun Permanen", "Pengguna Aktif", "Pengguna mengonfirmasi modal hapus", "Seluruh data riwayat, profil, dan objek foto dimusnahkan"],
            ["UC-08", "Kelola Katalog CMS", "Administrator", "Kredensial memiliki role 'admin'", "Katalog pangan terbarukan, audit log tercatat immutable"]
        ]
    )

    # 1.11 Glosarium Istilah & Akronim Teknis
    ch.add_h2("1.11 Glosarium Istilah & Akronim Teknis")
    ch.add_p(
        "Untuk mencegah ambiguitas pemahaman lintas divisi rekayasa dan bisnis, istilah teknis didefinisikan sebagai berikut:"
    )
    ch.add_table(
        caption="Tabel 1.6: Glosarium Istilah dan Definisi Standar Teknis",
        headers=["Istilah / Akronim", "Kepanjangan", "Definisi Arsitektural dalam OopsieEats"],
        rows=[
            ["BMR", "Basal Metabolic Rate", "Jumlah energi minimum yang dibakar tubuh saat istirahat, dihitung via persamaan Mifflin-St Jeor."],
            ["TDEE", "Total Daily Energy Expenditure", "Total pengeluaran energi harian dengan mengalikan BMR terhadap faktor aktivitas fisik."],
            ["TKPI", "Tabel Komposisi Pangan Indonesia", "Standar komposisi kimiawi pangan resmi Kemenkes RI 2020 yang memuat data energi makronutrien."],
            ["Atwater Factor", "Sistem Faktor Spesifik Atwater", "Standar konversi energi makronutrien: 4 kkal/g protein, 4 kkal/g karbohidrat, 9 kkal/g lemak."],
            ["YOLO", "You Only Look Once", "Arsitektur jaringan saraf konvolusi deteksi objek real-time fase tunggal (single-stage detector)."],
            ["TFLite", "TensorFlow Lite", "Format runtime model pembelajaran mendalam berbobot ringan untuk eksekusi on-device mobile."],
            ["Isolate", "Dart Isolate", "Model konkurensi berbasis memori terisolasi pada Dart yang berjalan independen tanpa blocking thread UI."],
            ["Neo-Brutalism", "Overkill Neo-Brutalism", "Gaya desain UI dengan garis tepi tebal (2-3px hitam), hard drop shadow tanpa blur, dan warna kontras."],
            ["RLS", "Row Level Security", "Mekanisme kebijakan keamanan basis data PostgreSQL/Supabase yang membatasi hak akses baris/objek."]
        ]
    )

    # 1.12 Struktur Tim & Matriks Tanggung Jawab (RACI)
    ch.add_h2("1.12 Struktur Tim & Matriks Tanggung Jawab (RACI)")
    ch.add_p(
        "Alokasi tanggung jawab tim rekayasa perangkat lunak diklasifikasikan menggunakan matriks RACI (Responsible, "
        "Accountable, Consulted, Informed):"
    )
    ch.add_table(
        caption="Tabel 1.7: Matriks Penugasan Tanggung Jawab Rekayasa (RACI)",
        headers=["Area Proyek / Deliverable", "Software Architect", "Mobile Developer", "ML Engineer", "QA Specialist"],
        rows=[
            ["Arsitektur Sistem & Data Model", "Accountable (A)", "Responsible (R)", "Consulted (C)", "Informed (I)"],
            ["Pipeline Inferensi YOLO TFLite", "Consulted (C)", "Responsible (R)", "Accountable (A)", "Informed (I)"],
            ["Antarmuka Mobile Neo-Brutalism", "Consulted (C)", "Accountable (A)", "Informed (I)", "Consulted (C)"],
            ["Integrasi Firebase & Supabase", "Accountable (A)", "Responsible (R)", "Informed (I)", "Consulted (C)"],
            ["Pengujian Otomatis & Analisis Statis", "Consulted (C)", "Responsible (R)", "Consulted (C)", "Accountable (A)"],
            ["Dokumentasi Spesifikasi BRD", "Accountable (A)", "Responsible (R)", "Responsible (R)", "Responsible (R)"]
        ]
    )

    return ch
