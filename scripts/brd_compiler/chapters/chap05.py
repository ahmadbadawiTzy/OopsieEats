"""
Chapter 5: Integrasi Repositori dan Service (Bab 5)
"""

from scripts.brd_compiler.builder import ChapterContent

def build_chapter_05():
    ch = ChapterContent(
        chapter_id="BAB_05",
        number_str="Bab 5",
        title="Integrasi Repositori dan Service",
        subtitle="Abstraksi Repository Pattern, Layanan Eksternal, Strategi Cache Offline, dan Manajemen Kegagalan",
        filename="BAB_05_INTEGRASI_REPOSITORI_DAN_SERVICE"
    )

    # 5.1 Desain Arsitektur Repository Pattern
    ch.add_h2("5.1 Desain Arsitektur Repository Pattern")
    ch.add_p(
        "OopsieEats mengadopsi Repository Pattern untuk memisahkan domain logika bisnis (Business Logic Layer) dari "
        "detail implementasi sumber data (Data Source Layer). Setiap repositori bertindak sebagai fasad terpadu yang "
        "menyembunyikan kompleksitas komunikasi cloud, parsing JSON, dan caching lokal dari konsumsi antarmuka pengguna."
    )
    ch.add_table(
        caption="Tabel 5.1: Matriks Tanggung Jawab Lapisan Repositori dan Layanan",
        headers=["Nama Repositori / Service", "Sumber Data Terkait", "Tanggung Jawab Utama", "Kontrak Antarmuka (Interface)"],
        rows=[
            ["AuthRepository", "Firebase Auth, Firestore, FSS", "Registrasi, login, logout, sesi biometrik, hapus akun", "IAuthRepository"],
            ["MealRepository", "Cloud Firestore (users/{uid}/meals)", "CRUD catatan makan, kueri tanggal harian, agregasi kalori", "IMealRepository"],
            ["FoodRepository", "Firestore (foods), seed_foods.json", "Pencarian katalog pangan, fallback offline lokal, detail gizi", "IFoodRepository"],
            ["ProfileRepository", "Cloud Firestore (users/{uid})", "Pembaruan profil fisik, kalkulasi BMR, pemilihan avatar", "IProfileRepository"],
            ["AdminRepository", "Firestore (foods, articles, audit)", "Manajemen katalog CMS, validasi Atwater, audit log", "IAdminRepository"],
            ["SupabaseStorageService", "Supabase Storage API", "Kompresi citra 85%, upload privat, pembuatan Signed URLs", "IStorageService"],
            ["ApiClient", "FlutterSecureStorage Hardware", "Penyimpanan token JWT terenkripsi & pengelolaan sesi lokal", "IApiClient"]
        ]
    )
    ch.add_p(
        "Struktur kontrak antarmuka (interface), kelas repositori konkret, dan integrasi terhadap "
        "komponen State Management Provider digambarkan secara rinci melalui Diagram Kelas UML berikut:"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/uml-repository-class.png",
        caption="Gambar 5.2: Diagram Kelas UML — Arsitektur Repository Pattern & Kontrak Antarmuka Layanan"
    )

    # 5.2 AuthRepository & Layanan Sesi Pengguna
    ch.add_h2("5.2 AuthRepository & Layanan Sesi Pengguna")
    ch.add_p(
        "<code>AuthRepository</code> mengelola seluruh siklus hidup kredensial pengguna. Repositori ini menyediakan "
        "aliran stream <code>authStateChanges</code> yang dipantau oleh <code>AuthProvider</code> secara reaktif. "
        "Ketika status autentikasi berubah, repositori secara otomatis menyinkronkan token sesi ke dalam "
        "<code>FlutterSecureStorage</code> dan mengambil snapshot profil pengguna terbaru dari koleksi <code>users</code>."
    )

    # 5.3 MealRepository & Operasi CRUD Riwayat Makan
    ch.add_h2("5.3 MealRepository & Operasi CRUD Riwayat Makan")
    ch.add_p(
        "<code>MealRepository</code> menangani pencatatan asupan gizi harian. Operasi utama mencakup:"
    )
    ch.add_list([
        "<strong>createMeal()</strong>: Menyimpan entri makan baru ke <code>users/{uid}/meals</code> beserta daftar item hidangan terperinci, total kalori, dan jalur citra Supabase Storage.",
        "<strong>getMealsByDate(date)</strong>: Mengambil seluruh hidangan pada tanggal tertentu (format <code>YYYY-MM-DD</code>) terurut descending berdasarkan timestamp.",
        "<strong>getDailyAggregates(date)</strong>: Menghitung total akumulasi kalori, protein, karbohidrat, dan lemak untuk dibandingkan dengan target harian pengguna.",
        "<strong>deleteMeal(mealId, imagePath)</strong>: Menghapus dokumen catatan makan dan memicu penghapusan objek citra terkait pada Supabase Storage."
    ])

    # 5.4 FoodRepository & Strategi Cache/Fallback Lokal
    ch.add_h2("5.4 FoodRepository & Strategi Cache/Fallback Lokal (seed_foods.json)")
    ch.add_p(
        "Arsitektur penyimpanan offline, mekanisme cache berlapis, dan alur fallback lokal diilustrasikan secara detail pada Diagram 14:"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/offline-storage-cache.png",
        caption="Gambar 5.1: Arsitektur Penyimpanan & Mekanisme Cache Offline (Hardware KeyStore, SQLite, Asset Bundle)"
    )
    ch.add_p(
        "Jika perangkat berada dalam kondisi luring (tanpa koneksi internet) atau koleksi <code>foods</code> di Cloud Firestore "
        "belum terisi (cold-start), <code>FoodRepository</code> secara otomatis memuat bundel statis <code>assets/data/seed_foods.json</code> "
        "yang memuat data nutrisi resmi 29 kelas hidangan Indonesia berbasis standar TKPI 2020. Hal ini menjamin ketersediaan katalog "
        "100% tanpa pernah terjadi kondisi aplikasi terhenti (zero-failure guarantee)."
    )

    # 5.5 ProfileRepository & Sinkronisasi Metrik Fisik
    ch.add_h2("5.5 ProfileRepository & Sinkronisasi Metrik Fisik")
    ch.add_p(
        "<code>ProfileRepository</code> bertugas mengelola data antropometri pengguna. Ketika pengguna memperbarui berat badan "
        "atau tingkat aktivitas fisik pada <code>ProfileScreen</code>, repositori memanggil <code>NutritionCalculator</code> "
        "secara lokal untuk menghitung ulang BMR dan TDEE, kemudian melakukan sinkronisasi satu transaksi (atomic write) ke Firestore."
    )

    # 5.6 AdminRepository & Operasi CMS
    ch.add_h2("5.6 AdminRepository & Operasi CMS")
    ch.add_p(
        "<code>AdminRepository</code> memfasilitasi kebutuhan operasional pengelola sistem dengan protokol keamanan tinggi. "
        "Setiap panggilan mutasi data wajib melewati pemeriksaan peran (role check). Saat administrator menyimpan atau "
        "memperbarui data makanan, repositori secara otomatis menyisipkan entri ke koleksi <code>cms_audit_logs</code> "
        "dalam bentuk rekaman audit yang tidak dapat dihapus (immutable log)."
    )

    # 5.7 SupabaseStorageService (Kompresi & Signed URLs)
    ch.add_h2("5.7 SupabaseStorageService (Kompresi & Signed URLs)")
    ch.add_p(
        "Pengelolaan citra foto makanan dikonsolidasikan pada <code>SupabaseStorageService</code> dengan optimasi ganda:"
    )
    ch.add_list([
        "<strong>Kompresi Citra On-Device</strong>: Menggunakan pustaka <code>flutter_image_compress</code> untuk mereduksi resolusi maksimum ke 1080p dan kualitas JPEG 85%, menurunkan ukuran berkas rata-rata dari 4.5 MB menjadi di bawah 400 KB sebelum proses transmisi jaringan.",
        "<strong>Pembangkitan Signed URL Dinamis</strong>: Karena wadah <code>food-history-images</code> berstatus privat, tautan citra dimuat melalui metode <code>createSignedUrl(path, 3600)</code> yang menerbitkan token akses berbatas waktu 1 jam.",
        "<strong>Pemusnahan Berkas Bersih</strong>: Saat catatan makan dihapus, objek biner di Supabase Storage dimusnahkan secara langsung via <code>remove([path])</code> untuk menjaga kebersihan kapasitas penyimpanan."
    ])

    # 5.8 Error Handling, Custom Exceptions & Failure Mapping
    ch.add_h2("5.8 Error Handling, Custom Exceptions & Failure Mapping")
    ch.add_p(
        "Sistem menerapkan hierarki pengecualian khusus (Custom Exception Hierarchy) berbasis kelas abstrak <code>AppException</code>:"
    )
    ch.add_table(
        caption="Tabel 5.2: Taksonomi Custom Exception dan Penanganan Kesalahan",
        headers=["Kelas Exception", "Penyebab Kegagalan", "Penanganan di Lapisan Provider", "Respon Antarmuka (UI)"],
        rows=[
            ["AuthException", "Kredensial salah, token expired, sesi batal", "Reset state sesi, tawarkan login ulang", "Banner Neo-Brutalism peringatan merah"],
            ["NetworkException", "Koneksi internet timeout, DNS error", "Alihkan operasi ke cache lokal SQLite", "Snack bar indikator mode offline aktif"],
            ["StorageException", "Gagal upload gambar, kuota penuh", "Batalkan transaksi catatan makan", "Dialog penawaran coba lagi tanpa foto"],
            ["ValidationException", "Nilai input di luar batas rentang ilmiah", "Tolak pengiriman formulir", "Sorot field formulir berwarna oranye"],
            ["DatabaseException", "Firestore permission-denied / RLS error", "Catat log kegagalan, batalkan mutasi", "Notifikasi hak akses tidak mencukupi"]
        ]
    )

    # 5.9 Strategi Offline-First & Sinkronisasi Firestore SQLite Cache
    ch.add_h2("5.9 Strategi Offline-First & Sinkronisasi Firestore SQLite Cache")
    ch.add_p(
        "Dengan mengaktifkan persistensi luring bawaan Cloud Firestore, seluruh operasi baca dan tulis yang dilakukan "
        "saat perangkat tidak memiliki koneksi internet akan diarahkan ke basis data lokal SQLite terenkripsi. Ketika koneksi "
        "jaringan pulih, mesin sinkronisasi Firestore secara otomatis mengirimkan mutasi tertunda (pending mutations) "
        "ke cloud dengan strategi resolusi konflik Last-Write-Wins berbasis stempel waktu server (serverTimestamp)."
    )

    # 5.10 Pengujian Unit Repository (Mocking & Test Double)
    ch.add_h2("5.10 Pengujian Unit Repository (Mocking & Test Double)")
    ch.add_p(
        "Seluruh lapisan repositori diverifikasi secara ketat menggunakan teknik Mocking berbasis pustaka <code>mocktail</code>. "
        "Skenario pengujian mencakup penanganan kegagalan jaringan, validasi timeout 10 detik, mapping entitas JSON ke Dart Model, "
        "dan integritas fallback lokal <code>seed_foods.json</code>, menghasilkan cakupan pengujian unit repositori di atas 95%."
    )

    return ch
