"""
Chapter 10 / Lampiran: Checklist dan Referensi Teknis
"""

from scripts.brd_compiler.builder import ChapterContent

def build_chapter_lampiran():
    ch = ChapterContent(
        chapter_id="LAMPIRAN",
        number_str="Lampiran",
        title="Checklist dan Referensi Teknis",
        subtitle="Matriks Kepatuhan Audit, Kebutuhan FR/NFR, Katalog 29 Pangan TKPI 2020, dan Referensi Industri",
        filename="LAMPIRAN_CHECKLIST_DAN_REFERENSI"
    )

    # Lampiran A
    ch.add_h2("Lampiran A: Checklist Kepatuhan BRD & Audit Bukti Implementasi")
    ch.add_p(
        "Tabel berikut mengaitkan setiap klaim spesifikasi kebutuhan bisnis secara langsung terhadap artefak kode sumber "
        "riil dan berkas uji otomatis di dalam repositori, menegakkan prinsip Single Source of Truth:"
    )
    ch.add_table(
        caption="Tabel A.1: Matriks Ketertelusuran Bukti Implementasi (Traceability Matrix)",
        headers=["Klaim Kebutuhan", "Komponen Kode Sumber Aktual", "Berkas Pengujian Otomatis", "Status Audit"],
        rows=[
            ["Model YOLO On-Device 9.4 MB", "assets/models/best.tflite & lib/data/services/yolo_detector.dart", "test/unit/services/yolo_isolate_processor_test.dart", "VERIFIED (100%)"],
            ["Formula Mifflin-St Jeor & Floor", "lib/core/utils/nutrition_calculator.dart", "test/unit/utils/nutrition_calculator_test.dart", "VERIFIED (100%)"],
            ["Complete Profile Guard", "lib/presentation/screens/auth/complete_profile_screen.dart", "test/unit/providers/auth_provider_test.dart", "VERIFIED (100%)"],
            ["Alur Hapus Akun Permanen", "lib/data/repositories/auth_repository.dart (deleteAccount)", "test/unit/repositories/auth_repository_test.dart", "VERIFIED (100%)"],
            ["19 Wireframe Layar Monokrom", "lib/presentation/screens/ (seluruh 19 layar implementasi)", "test/widget/ (seluruh uji widget UI)", "VERIFIED (100%)"],
            ["14 Diagram Native Mermaid", "docs/brd/diagrams/mermaid/ & diagrams/rendered/", "scripts/render_all_mermaid.py (14 berkas PNG)", "VERIFIED (100%)"],
            ["Supabase Private Signed URLs", "lib/data/services/supabase_storage_service.dart", "test/unit/services/supabase_storage_service_test.dart", "VERIFIED (100%)"],
            ["359 Tests Passed 100%", "42 berkas pengujian otomatis di direktori test/", "flutter test runner (eksekusi terminal)", "VERIFIED (100%)"]
        ]
    )
    ch.add_p(
        "Keterkaitan struktural modular antara package lapisan Clean Architecture, modul pengujian jaminan kualitas, "
        "dan infrastruktur backend cloud divisualisasikan pada Diagram Paket UML berikut:"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/uml-system-traceability.png",
        caption="Gambar L.1: Diagram Paket UML — Arsitektur Berlapis Clean Architecture & Matriks Ketertelusuran Pengujian"
    )

    # Lampiran B
    ch.add_h2("Lampiran B: Matriks Kebutuhan Fungsional (FR) & Non-Fungsional (NFR)")
    ch.add_p(
        "Katalog lengkap seluruh kebutuhan fungsional (Functional Requirements) dan non-fungsional (Non-Functional Requirements):"
    )
    ch.add_table(
        caption="Tabel B.1: Matriks Kebutuhan Fungsional (FR-01 s/d FR-08)",
        headers=["ID Kebutuhan", "Nama Spesifikasi", "Kriteria Keberhasilan (Acceptance Criteria)", "Prioritas"],
        rows=[
            ["FR-01", "Registrasi & Login Multi-Metode", "Mendukung email/password, Google Sign-In, dan biometrik sidik jari/wajah", "Tinggi (Must Have)"],
            ["FR-02", "Profil Fisik & Target Nutrisi", "Menghitung BMR dan TDEE secara otomatis serta membatasi Safe Calorie Floor", "Tinggi (Must Have)"],
            ["FR-03", "Deteksi Makanan Visual AI", "Mengklasifikasikan 29 hidangan nusantara via TFLite on-device < 300 ms", "Tinggi (Must Have)"],
            ["FR-04", "Konfirmasi & Bobot Porsi", "Menampilkan kotak pembatas dan slider porsi gram dengan hitung gizi Atwater", "Tinggi (Must Have)"],
            ["FR-05", "Pencatatan Riwayat Makan", "Menyimpan ke users/{uid}/meals dan mengunggah foto ke Supabase Storage", "Tinggi (Must Have)"],
            ["FR-06", "Dashboard Nutrisi Harian", "Visualisasi Hero Calorie Dial dan Bento Grid kartu makronutrien", "Tinggi (Must Have)"],
            ["FR-07", "Katalog Pangan & Fallback", "Pencarian master makanan dengan fallback offline seed_foods.json", "Tinggi (Must Have)"],
            ["FR-08", "Portal Admin & Log Audit", "Pengelolaan katalog makanan, artikel edukasi gizi, dan pencatatan audit immutable", "Sedang (Should Have)"]
        ]
    )

    ch.add_table(
        caption="Tabel B.2: Matriks Kebutuhan Non-Fungsional (NFR-01 s/d NFR-06)",
        headers=["ID Kebutuhan", "Atribut Kualitas", "Metrik Kuantitatif / Standar", "Tingkat Kritis"],
        rows=[
            ["NFR-01", "Security & RBAC", "Strict 2-Role System ('admin' dan 'user') dengan penegakan di Firestore Security Rules", "Kritis (Blocker)"],
            ["NFR-02", "Performance & Latency", "Latensi inferensi model AI di bawah 300 ms dengan 0 ms UI frame drop (Isolate.run)", "Tinggi (Critical)"],
            ["NFR-03", "Offline Availability", "Dukungan operasional luring 100% untuk deteksi makanan dan katalog lokal", "Tinggi (Critical)"],
            ["NFR-04", "Maintainability", "0 issues pada flutter analyze --fatal-infos dan kepatuhan Clean Architecture", "Tinggi (Critical)"],
            ["NFR-05", "Design Usability", "Kontras warna rasio > 14:1, target sentuh min 48x48 dp, estetika Overkill Neo-Brutalism", "Tinggi (Critical)"],
            ["NFR-06", "Reliability & Test", "359 automated test cases lulus 100% tanpa kegagalan atau test skip", "Kritis (Blocker)"]
        ]
    )

    # Lampiran C
    ch.add_h2("Lampiran C: Daftar Lengkap 29 Kelas Pangan Indonesia (TKPI 2020)")
    ch.add_p(
        "Katalog komprehensif 29 hidangan kuliner nusantara yang didukung oleh model pembelajaran mendalam OopsieEats "
        "beserta nilai energi standar basis per 100 gram saji menurut Tabel Komposisi Pangan Indonesia (TKPI 2020):"
    )
    ch.add_table(
        caption="Tabel C.1: Basis Data 29 Kelas Pangan Indonesia (TKPI 2020 per 100g Saji)",
        headers=["No", "Nama Hidangan", "Label Prediksi", "Energi (kkal)", "Protein (g)", "Karbohidrat (g)", "Lemak (g)"],
        rows=[
            ["1", "Ayam Goreng", "ayam_goreng", "260.0", "28.0", "0.0", "15.0"],
            ["2", "Bakso Sapi", "bakso", "202.0", "12.0", "18.0", "9.0"],
            ["3", "Batagor Bandung", "batagor", "290.0", "8.0", "32.0", "14.5"],
            ["4", "Bihun Goreng", "bihun", "192.0", "4.0", "35.0", "4.2"],
            ["5", "Capcay Kuah", "capcay", "85.0", "3.5", "11.0", "3.0"],
            ["6", "Gado-Gado", "gado_gado", "135.0", "6.2", "14.8", "6.1"],
            ["7", "Ikan Goreng", "ikan_goreng", "195.0", "22.0", "2.0", "11.0"],
            ["8", "Martabak Manis", "martabak_manis", "275.0", "6.0", "45.0", "8.5"],
            ["9", "Martabak Telur", "martabak_telur", "240.0", "11.5", "18.0", "13.5"],
            ["10", "Mie Goreng", "mie_goreng", "220.0", "5.0", "38.0", "6.0"],
            ["11", "Nasi Goreng", "nasi_goreng", "168.0", "4.5", "28.0", "4.5"],
            ["12", "Nasi Putih", "nasi_putih", "130.0", "2.4", "28.6", "0.2"],
            ["13", "Pempek Palembang", "pempek", "175.0", "8.5", "26.0", "4.0"],
            ["14", "Rawon Sapi", "rawon", "115.0", "13.5", "3.0", "5.5"],
            ["15", "Rendang Sapi", "rendang", "195.0", "18.5", "4.5", "11.5"],
            ["16", "Roti Bakar", "roti_bakar", "285.0", "7.0", "48.0", "7.5"],
            ["17", "Sate Ayam", "sate_ayam", "215.0", "20.0", "8.0", "11.5"],
            ["18", "Sate Kambing", "sate_kambing", "230.0", "22.5", "6.0", "13.0"],
            ["19", "Sayur Asem", "sayur_asem", "45.0", "1.8", "8.5", "0.5"],
            ["20", "Soto Ayam", "soto_ayam", "105.0", "10.0", "6.5", "4.5"],
            ["21", "Tahu Goreng", "tahu_goreng", "115.0", "9.5", "2.5", "7.5"],
            ["22", "Telur Balado", "telur_balado", "175.0", "12.0", "3.5", "12.5"],
            ["23", "Telur Dadar", "telur_dadar", "190.0", "13.0", "1.5", "15.0"],
            ["24", "Telur Mata Sapi", "telur_mata_sapi", "185.0", "12.5", "0.8", "14.5"],
            ["25", "Tempe Bacem", "tempe_bacem", "165.0", "14.0", "15.5", "5.5"],
            ["26", "Tempe Goreng", "tempe_goreng", "195.0", "15.0", "11.0", "10.5"],
            ["27", "Terang Bulan", "terang_bulan", "280.0", "5.5", "46.0", "9.0"],
            ["28", "Tumis Kangkung", "tumis_kangkung", "68.0", "2.5", "6.0", "3.8"],
            ["29", "Udang Goreng", "udang_goreng", "210.0", "21.0", "6.0", "11.0"]
        ]
    )

    # Lampiran D
    ch.add_h2("Lampiran D: Standar Formula Matematika Gizi (Mifflin-St Jeor & Atwater)")
    ch.add_p(
        "Persamaan matematika resmi yang diterapkan secara deterministik pada modul <code>NutritionCalculator</code>:"
    )
    ch.add_list([
        "<strong>BMR Pria</strong>: <code>BMR = 10 * weight(kg) + 6.25 * height(cm) - 5 * age(th) + 5</code>",
        "<strong>BMR Wanita</strong>: <code>BMR = 10 * weight(kg) + 6.25 * height(cm) - 5 * age(th) - 161</code>",
        "<strong>TDEE</strong>: <code>TDEE = BMR * ActivityMultiplier (1.20 | 1.375 | 1.55 | 1.725)</code>",
        "<strong>Safe Calorie Floor</strong>: <code>calorieTarget = max(TDEE - deficit, gender == 'male' ? 1500.0 : 1200.0)</code>",
        "<strong>Energi Atwater Spesifik</strong>: <code>Kalori = (4 * Protein_g) + (4 * Karbohidrat_g) + (9 * Lemak_g)</code>"
    ])

    # Lampiran E
    ch.add_h2("Lampiran E: Daftar API & Endpoint Supabase/Firebase")
    ch.add_p(
        "Daftar interaksi jaringan resmi antara klien aplikasi mobile OopsieEats dengan layanan cloud nirserver:"
    )
    ch.add_table(
        caption="Tabel E.1: Pemetaan Endpoint dan Protokol Komunikasi Cloud",
        headers=["Layanan Cloud", "Metode Protokol", "Jalur Sumber Daya (Resource Path)", "Fungsi Operasional"],
        rows=[
            ["Firebase Auth", "HTTPS / REST", "identitytoolkit.googleapis.com/v1/accounts", "Registrasi, login email/password, pertukaran token"],
            ["Cloud Firestore", "gRPC over TLS 1.3", "firestore.googleapis.com/.../documents/users/{uid}", "Sinkronisasi profil pengguna & pembacaan status guard"],
            ["Cloud Firestore", "gRPC over TLS 1.3", "firestore.googleapis.com/.../users/{uid}/meals", "Aliran data reaktif (snapshot stream) riwayat makan harian"],
            ["Cloud Firestore", "gRPC over TLS 1.3", "firestore.googleapis.com/.../documents/foods", "Kueri katalog master pangan (read-only terautentikasi)"],
            ["Supabase Storage", "HTTPS / POST", "{SUPABASE_URL}/storage/v1/object/food-history-images", "Unggah citra terkompresi dengan token JWT pemilik"],
            ["Supabase Storage", "HTTPS / POST", "{SUPABASE_URL}/storage/v1/object/sign/food-history-images", "Pembangkitan Signed URL privat berbatas waktu 3600 detik"],
            ["Supabase Storage", "HTTPS / DELETE", "{SUPABASE_URL}/storage/v1/object/food-history-images", "Pemusnahan berkas foto saat catatan makan/akun dihapus"]
        ]
    )

    # Lampiran F
    ch.add_h2("Lampiran F: Referensi Kepustakaan & Standar Industri")
    ch.add_p(
        "Landasan teoretis dan metodologi rekayasa perangkat lunak dalam penyusunan dokumen BRD ini merujuk pada standar ilmiah:"
    )
    ch.add_list([
        "1. Kementerian Kesehatan Republik Indonesia. (2020). <em>Tabel Komposisi Pangan Indonesia (TKPI)</em>. Direktorat Gizi Masyarakat, Jakarta.",
        "2. Mifflin, M. D., St Jeor, S. T., et al. (1990). <em>A new predictive equation for resting energy expenditure in healthy individuals</em>. The American Journal of Clinical Nutrition, 51(2), 241-247.",
        "3. Merrill, A. L., & Watt, B. K. (1973). <em>Energy value of foods: basis and derivation</em>. Agriculture Handbook No. 74, Agricultural Research Service, USDA.",
        "4. Jocher, G., et al. (2023). <em>Ultralytics YOLOv8 Architecture and Real-Time Object Detection</em>. Ultralytics Inc.",
        "5. Martin, R. C. (2017). <em>Clean Architecture: A Craftsman's Guide to Software Structure and Design</em>. Prentice Hall.",
        "6. Bizzotto, A. (2024). <em>Flutter Production Readiness and Release Engineering Checklist</em>. CodeWithAndrea Publishing.",
        "7. Undang-Undang Republik Indonesia No. 27 Tahun 2022 tentang <em>Pelindungan Data Pribadi (UU PDP)</em>. Lembaran Negara RI Tahun 2022 No. 196.",
        "8. European Parliament. (2016). <em>General Data Protection Regulation (GDPR) Regulation (EU) 2016/679</em>. Official Journal of the European Union."
    ])

    return ch
