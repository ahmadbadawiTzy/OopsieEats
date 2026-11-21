"""
Chapter 3: Implementasi Database dan CMS (Bab 3)
"""

from scripts.brd_compiler.builder import ChapterContent

def build_chapter_03():
    ch = ChapterContent(
        chapter_id="BAB_03",
        number_str="Bab 3",
        title="Implementasi Database dan CMS",
        subtitle="Struktur Skema Firestore, Kamus Data, Security Rules, Supabase Storage RLS, dan Portal Admin",
        filename="BAB_03_IMPLEMENTASI_DATABASE_DAN_CMS"
    )

    # 3.1 Skema Data Cloud Firestore
    ch.add_h2("3.1 Skema Data Cloud Firestore (Desain Koleksi & Subkoleksi)")
    ch.add_p(
        "OopsieEats mengadopsi model basis data berorientasi dokumen NoSQL Cloud Firestore dengan pendekatan pemisahan data "
        "privat pengguna dan data katalog publik/operasional. Relasi entitas sistem dipetakan pada Diagram Entity-Relationship (ERD):"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/database-erd.png",
        caption="Gambar 3.1: Diagram Relasi Entitas Basis Data (Entity Relationship Diagram — Cloud Firestore)"
    )
    ch.add_p(
        "Struktur fisik koleksi tingkat atas dan subkoleksi berhierarki diilustrasikan secara mendalam pada Diagram 11:"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/database-schema.png",
        caption="Gambar 3.2: Struktur Hirarki Koleksi Dokumen & Subkoleksi Cloud Firestore"
    )
    ch.add_p(
        "Hubungan antar-entitas data model pada tataran kode sumber Dart direpresentasikan secara rinci "
        "melalui Diagram Kelas UML (UML Class Diagram) berikut:"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/uml-firestore-models.png",
        caption="Gambar 3.3: Diagram Kelas UML — Model Entitas Domain & Entitas Dokumen Firestore"
    )
    ch.add_callout(
        "Desain subkoleksi users/{uid}/meals membatasi radius kueri riwayat makan hanya pada dokumen milik pengguna yang terautentikasi, "
        "secara inheren mencegah kebocoran data lintas akun (cross-user data leakage) pada level struktur partisi basis data."
    )

    # 3.2 Kamus Data Koleksi
    ch.add_h2("3.2 Kamus Data Koleksi (users, meals, foods, cms_articles, cms_audit_logs)")
    ch.add_p(
        "Setiap bidang data (field) pada dokumen Firestore memiliki tipe data terikat, batasan validasi, dan arti fungsional yang baku:"
    )
    ch.add_table(
        caption="Tabel 3.1: Kamus Data Dokumen Koleksi `users` (Jalur: /users/{uid})",
        headers=["Nama Field", "Tipe Data Firestore", "Aturan Validasi / Format", "Deskripsi Fungsional"],
        rows=[
            ["email", "string", "Valid email regex; unik", "Alamat surel terdaftar pengguna"],
            ["name", "string", "Min 2, max 100 karakter", "Nama lengkap pengguna"],
            ["role", "string", "Enum: 'user' | 'admin'", "Peran otorisasi pengguna dalam sistem"],
            ["isProfileComplete", "boolean", "true | false", "Penanda kepatuhan kelengkapan profil metrik fisik"],
            ["gender", "string", "Enum: 'male' | 'female'", "Jenis kelamin biologis untuk rumus Mifflin-St Jeor"],
            ["age", "number (int)", "Rentang: 10 - 120 tahun", "Usia biologis pengguna saat perhitungan profil"],
            ["height", "number (float)", "Rentang: 50 - 250 cm", "Tinggi badan pengguna dalam satuan centimeter"],
            ["weight", "number (float)", "Rentang: 20 - 300 kg", "Berat badan aktual pengguna dalam satuan kilogram"],
            ["activityLevel", "string", "Enum: sedentary/light/moderate/very_active", "Tingkat aktivitas fisik untuk pengali TDEE"],
            ["calorieTarget", "number (float)", "Nilai >= 1200 kcal", "Target batas asupan energi harian terhitung"],
            ["proteinTarget", "number (float)", "Satuan: gram", "Target gramasi protein harian"],
            ["carbTarget", "number (float)", "Satuan: gram", "Target gramasi karbohidrat harian"],
            ["fatTarget", "number (float)", "Satuan: gram", "Target gramasi lemak harian"],
            ["avatarId", "string", "Format: avatar_XX", "Pengenal grafis avatar yang dipilih pengguna"],
            ["createdAt", "timestamp", "serverTimestamp()", "Waktu pembuatan profil pertama kali"]
        ]
    )

    ch.add_table(
        caption="Tabel 3.2: Kamus Data Subkoleksi `meals` (Jalur: /users/{uid}/meals/{mealId})",
        headers=["Nama Field", "Tipe Data Firestore", "Aturan Validasi / Format", "Deskripsi Fungsional"],
        rows=[
            ["id", "string", "UUID v4 unik", "Pengenal unik dokumen catatan makan"],
            ["mealType", "string", "Enum: breakfast/lunch/dinner/snack", "Kategori waktu bersantap"],
            ["timestamp", "timestamp", "serverTimestamp()", "Waktu konsumsi makanan dicatat"],
            ["date", "string", "Format: YYYY-MM-DD", "Kunci pengindeksan tanggal kalender harian"],
            ["totalCalories", "number (float)", "Nilai >= 0 kkal", "Akumulasi kalori dari seluruh item hidangan"],
            ["totalCarbs", "number (float)", "Nilai >= 0 gram", "Akumulasi karbohidrat dari seluruh item"],
            ["totalProtein", "number (float)", "Nilai >= 0 gram", "Akumulasi protein dari seluruh item"],
            ["totalFat", "number (float)", "Nilai >= 0 gram", "Akumulasi lemak dari seluruh item"],
            ["imagePath", "string", "food-history-images/{uid}/{id}.jpg", "Jalur penyimpanan objek foto pada Supabase Storage"],
            ["items", "array of map", "Daftar objek pangan", "Detail pangan: {foodId, foodName, portionGrams, calories, carbs, protein, fat}"]
        ]
    )

    ch.add_table(
        caption="Tabel 3.3: Kamus Data Koleksi Master `foods` (Jalur: /foods/{foodId})",
        headers=["Nama Field", "Tipe Data Firestore", "Aturan Validasi / Format", "Deskripsi Fungsional"],
        rows=[
            ["id", "string", "Slug unik (misal: 'rendang_sapi')", "Kunci unik master hidangan kuliner"],
            ["name", "string", "Nama hidangan berbahasa Indonesia", "Nama resmi pangan (contoh: Rendang Daging Sapi)"],
            ["category", "string", "Makanan Utama / Sayur / Lauk / Camilan", "Klasifikasi kelompok hidangan"],
            ["servingSizeGrams", "number (float)", "Default: 100.0 g", "Bobot porsi basis perhitungan nutrisi"],
            ["caloriesPerServing", "number (float)", "Toleransi Atwater <= 30%", "Energi kalori standar per porsi saji"],
            ["proteinGrams", "number (float)", "Satuan: gram", "Kandungan protein per porsi saji"],
            ["carbsGrams", "number (float)", "Satuan: gram", "Kandungan karbohidrat per porsi saji"],
            ["fatGrams", "number (float)", "Satuan: gram", "Kandungan lemak per porsi saji"],
            ["tkpiCode", "string", "Format: TKPI-XXXX", "Kode referensi resmi Tabel Komposisi Pangan Indonesia"],
            ["updatedAt", "timestamp", "serverTimestamp()", "Waktu pemutakhiran terakhir oleh administrator"]
        ]
    )

    # 3.3 Indeks Komposit & Optimasi Kueri
    ch.add_h2("3.3 Indeks Komposit & Optimasi Kueri Firestore")
    ch.add_p(
        "Untuk mencegah latensi eksekusi kueri pada skala ribuan entri riwayat makan harian, Firestore dikonfigurasi "
        "dengan indeks komposit tunggal dan jamak:"
    )
    ch.add_list([
        "<strong>Indeks Riwayat Harian</strong>: Subkoleksi <code>users/{uid}/meals</code> dengan kombinasi bidang: <code>date</code> (ASCENDING) + <code>timestamp</code> (DESCENDING). Indeks ini mendukung kueri agregasi intake kalori harian seketika tanpa in-memory client sorting.",
        "<strong>Indeks Pencarian Katalog</strong>: Koleksi <code>foods</code> dengan pengurutan komposit: <code>category</code> (ASCENDING) + <code>name</code> (ASCENDING).",
        "<strong>Bounded Cache Persistence</strong>: Ukuran memori cache luring klien dibatasi maksimal 100 MB (104.857.600 byte) via parameter SDK <code>Settings(cacheSizeBytes: 104857600)</code> untuk mencegah memory bloat pada perangkat entry-level."
    ])

    # 3.4 Desain Keamanan Firestore Security Rules
    ch.add_h2("3.4 Desain Keamanan Firestore Security Rules")
    ch.add_p(
        "Keamanan akses basis data ditegakkan melalui aturan deklaratif <code>firestore.rules</code> yang mengimplementasikan "
        "Strict 2-Role System ('admin' dan 'user'). Pohon keputusan otorisasi diilustrasikan pada Diagram 13:"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/security-rules-rbac.png",
        caption="Gambar 3.4: Pohon Keputusan Otorisasi Berbasis Peran (RBAC) pada Firestore Security Rules"
    )
    ch.add_p(
        "Prinsip keamanan utama yang diterapkan pada aturan mencakup: "
        "(1) Isolasi subkoleksi pengguna di mana <code>request.auth.uid == userId</code>, "
        "(2) Pembacaan katalog pangan bersifat publik terautentikasi namun modifikasi eksklusif untuk role admin, "
        "(3) Log audit sistem bersifat kekal (immutable) di mana operasi update dan delete ditolak secara absolut."
    )

    # 3.5 Skema Supabase Storage & RLS Policy
    ch.add_h2("3.5 Skema Supabase Storage & RLS Policy")
    ch.add_p(
        "Penyimpanan berkas biner citra makanan pada bucket <code>food-history-images</code> dilindungi oleh Row Level Security "
        "(RLS) PostgreSQL Storage:"
    )
    ch.add_list([
        "<strong>Policy Unggah (INSERT)</strong>: Pengguna hanya diizinkan mengunggah objek citra jika segmen jalur pertama berkas cocok dengan UID akun pengguna yang mengirim token otorisasi: <code>(bucket_id = 'food-history-images' AND (storage.foldername(name))[1] = auth.uid())</code>.",
        "<strong>Policy Unduh (SELECT)</strong>: Pembacaan objek privat dibatasi pada pemilik objek atau melalui Signed URL bertanda tangan kriptografis dengan masa aktif terbatas.",
        "<strong>Policy Hapus (DELETE)</strong>: Pengguna hanya dapat menghapus foto dalam folder UID miliknya sendiri."
    ])

    # 3.6 Desain Content Management System (CMS) Admin
    ch.add_h2("3.6 Desain Content Management System (CMS) Admin")
    ch.add_p(
        "Portal CMS dirancang menyatu dalam aplikasi mobile untuk pengguna dengan klaim peran <code>role == 'admin'</code>. "
        "Dasbor CMS menyediakan antarmuka terpusat untuk: (1) Penambahan dan revisi nilai nutrisi pangan master, "
        "(2) Verifikasi formula Atwater otomatis, (3) Penerbitan artikel edukasi gizi masyarakat, dan (4) Pemantauan log aktivitas."
    )

    # 3.7 Manajemen Konten Edukasi Gizi
    ch.add_h2("3.7 Manajemen Konten Edukasi Gizi (Artikel)")
    ch.add_p(
        "Koleksi <code>cms_articles</code> menyimpan materi literasi gizi terstruktur. Setiap artikel memuat judul, "
        "ringkasan eksekutif, konten markdown lengkap, waktu baca estimasi (reading time), tautan gambar sampul eksternal, "
        "kategori, status terbit ('published' / 'draft'), serta identitas penulis administrator."
    )

    # 3.8 Manajemen Katalog Pangan
    ch.add_h2("3.8 Manajemen Katalog Pangan (TKPI 2020)")
    ch.add_p(
        "Modul manajemen pangan memungkinkan administrator mendaftarkan jenis kuliner baru ke dalam koleksi <code>foods</code>. "
        "Sistem secara otomatis menjalankan validasi konsistensi Atwater: nilai kalori total input dibandingkan dengan hasil kali "
        "<code>(4 * protein) + (4 * karbohidrat) + (9 * lemak)</code>. Jika simpangan melebihi toleransi wajar (30%), "
        "antarmuka memberikan peringatan ketidaksesuaian data gizi."
    )

    # 3.9 Log Audit & Pelacakan Aktivitas Admin
    ch.add_h2("3.9 Log Audit & Pelacakan Aktivitas Admin")
    ch.add_p(
        "Setiap mutasi data yang dilakukan oleh administrator (tambah hidangan, ubah artikel, hapus entri) dicatat secara "
        "otomatis ke koleksi <code>cms_audit_logs</code>. Dokumen log memuat <code>adminUid</code>, <code>adminEmail</code>, "
        "<code>action</code>, <code>targetCollection</code>, <code>targetDocumentId</code>, <code>timestamp</code>, dan snapshot data lama vs baru."
    )

    # 3.10 Strategi Backup & Disaster Recovery
    ch.add_h2("3.10 Strategi Backup & Disaster Recovery")
    ch.add_p(
        "Strategi pemulihan bencana sistem mengandalkan cadangan statis lokal <code>seed_foods.json</code> yang disematkan dalam bundle "
        "aplikasi sebagai fallback tanpa jaringan jika koneksi ke Cloud Firestore terputus, serta ekspor terjadwal berkala basis data "
        "Firestore ke Google Cloud Storage Bucket untuk pemulihan titik waktu (Point-in-Time Recovery)."
    )

    return ch
