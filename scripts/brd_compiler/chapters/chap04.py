"""
Chapter 4: Implementasi Autentikasi Firebase (Bab 4)
"""

from scripts.brd_compiler.builder import ChapterContent

def build_chapter_04():
    ch = ChapterContent(
        chapter_id="BAB_04",
        number_str="Bab 4",
        title="Implementasi Autentikasi Firebase",
        subtitle="Arsitektur Keamanan Identitas, Alur Sesi Kriptografis, Biometrik, Complete Profile Guard, dan Alur Hapus Akun",
        filename="BAB_04_IMPLEMENTASI_AUTENTIKASI_FIREBASE"
    )

    # 4.1 Arsitektur Autentikasi Firebase Auth
    ch.add_h2("4.1 Arsitektur Autentikasi Firebase Auth")
    ch.add_p(
        "OopsieEats mengintegrasikan Firebase Authentication sebagai lapisan gerbang verifikasi identitas pengguna berbasis "
        "standar industri OAuth 2.0 dan JSON Web Token (JWT). Alur pertukaran token dan validasi sesi kriptografis "
        "diilustrasikan pada Diagram 12:"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/token-security-flow.png",
        caption="Gambar 4.1: Alur Pertukaran Token Sesi Kriptografis dan Akses Data Terproteksi"
    )
    ch.add_p(
        "Klien aplikasi mobile melakukan negosiasi autentikasi langsung dengan server Google Identity Toolkit. Setelah kredensial "
        "divalidasi, Firebase menerbitkan ID Token (JWT) berumur 1 jam dan Refresh Token yang disimpan aman di hardware storage. "
        "Setiap panggilan kueri ke Cloud Firestore dan Supabase Storage membawa JWT ini untuk diverifikasi oleh mesin Security Rules."
    )

    # 4.2 Alur Registrasi Akun & Validasi Kredensial
    ch.add_h2("4.2 Alur Registrasi Akun & Validasi Kredensial")
    ch.add_p(
        "Pendaftaran akun baru menerapkan validasi berlapis di sisi klien (client-side form validation) dan sisi server:"
    )
    ch.add_table(
        caption="Tabel 4.1: Spesifikasi Aturan Validasi Formulir Pendaftaran Akun",
        headers=["Entri Formulir", "Kriteria Validasi", "Pesan Galat UI", "Tindakan Keamanan"],
        rows=[
            ["Nama Lengkap", "Min 2 huruf, alfabet & spasi, max 100 kar.", "Nama lengkap wajib diisi minimal 2 karakter", "Sanitasi karakter HTML/SQL injection"],
            ["Alamat Email", "Format RFC 5322 regex valid", "Masukkan format email yang valid", "Pengecekan keunikan akun di Firebase Auth"],
            ["Kata Sandi", "Min 6 karakter, kombinasi huruf & angka", "Kata sandi minimal 6 karakter kombinasi", "Hashing bcrypt/scrypt pada sisi server Google"],
            ["Konfirmasi Sandi", "Wajib identik dengan isian kata sandi", "Konfirmasi kata sandi tidak cocok", "Pencegahan typo sebelum pengiriman jaringan"]
        ]
    )

    # 4.3 Alur Login Email/Password & Google Sign-In
    ch.add_h2("4.3 Alur Login Email/Password & Google Sign-In")
    ch.add_p(
        "Sistem mendukung dua jalur masuk utama: (1) Kredensial Email dan Kata Sandi via <code>signInWithEmailAndPassword()</code>, "
        "dan (2) Google Sign-In berbasis alur satu sentuhan (One-Tap OAuth) via paket <code>google_sign_in</code>. "
        "Ketika pengguna masuk via Google, sistem secara otomatis mengekstrak <code>idToken</code> dan <code>accessToken</code>, "
        "membangkitkan kredensial <code>GoogleAuthProvider.credential()</code>, dan melakukan sinkronisasi profil pengguna ke Firestore."
    )

    # 4.4 Autentikasi Biometrik
    ch.add_h2("4.4 Autentikasi Biometrik (Fingerprint & Face ID via LocalAuth)")
    ch.add_p(
        "Untuk mempercepat akses tanpa memasukkan sandi berulang kali, aplikasi mengintegrasikan paket <code>local_auth</code> "
        "yang berkomunikasi dengan modul biometrik perangkat keras (Android BiometricPrompt dan iOS LocalAuthentication):"
    )
    ch.add_list([
        "<strong>Pengecekan Kapabilitas</strong>: Memanggil <code>isDeviceSupported()</code> dan <code>canCheckBiometrics</code> sebelum menampilkan opsi autentikasi biometrik.",
        "<strong>Kebijakan Sandi Cadangan</strong>: Jika pemindaian sidik jari atau wajah gagal 3 kali, pengguna diarahkan kembali ke alur input kata sandi akun standar.",
        "<strong>Penyimpanan Flag Status</strong>: Status preferensi aktivasi biometrik disimpan secara terenkripsi pada <code>FlutterSecureStorage</code>."
    ])

    # 4.5 Manajemen Sesi & Token Keamanan
    ch.add_h2("4.5 Manajemen Sesi & Token Keamanan (Hardware KeyStore/Keychain)")
    ch.add_p(
        "Kerahasiaan sesi pengguna dijamin melalui penyimpanan perangkat keras terisolasi:"
    )
    ch.add_table(
        caption="Tabel 4.2: Matriks Perlindungan Penyimpanan Kredensial Lokal Perangkat",
        headers=["Platform Mobile", "Mekanisme Hardware KeyStore", "Algoritma Kriptografi", "Cakupan Data Terlindungi"],
        rows=[
            ["Android", "Android KeyStore Provider & EncryptedSharedPreferences", "AES-256 GCM + RSA-2048", "Refresh tokens, Supabase JWT, preferensi biometrik"],
            ["iOS", "Apple Keychain Services (kSecAttrAccessible)", "Hardware Secure Enclave (AES-256)", "Credentials, auth session state, encrypted device keys"]
        ]
    )

    # 4.6 Alur Reset Sandi & Pemulihan Akun
    ch.add_h2("4.6 Alur Reset Sandi & Pemulihan Akun")
    ch.add_p(
        "Jika pengguna lupa kata sandi akun, fitur pemulihan mandiri memanggil <code>sendPasswordResetEmail()</code>. "
        "Firebase Auth akan mengirimkan surel berisikan tautan token kriptografis sekali pakai (One-Time Link) dengan masa "
        "berlaku 15 menit untuk memandu penyetelan ulang sandi baru secara aman di peramban terproteksi HTTPS."
    )

    # 4.7 Mekanisme Complete Profile Guard & State Enforcing
    ch.add_h2("4.7 Mekanisme Complete Profile Guard & State Enforcing")
    ch.add_p(
        "Salah satu integritas arsitektural terpenting dalam OopsieEats adalah penjaga kelengkapan profil (Complete Profile Guard). "
        "Aplikasi tidak mengizinkan pengguna mengakses Dashboard atau fitur pemindai makanan sebelum metrik fisik dasar diisi:"
    )
    ch.add_callout(
        "Jika dokumen pengguna pada /users/{uid} memiliki nilai isProfileComplete == false, Router dan AuthProvider "
        "secara deterministik mengunci navigasi dan mengarahkan pengguna ke CompleteProfileScreen. Hal ini menjamin seluruh formula "
        "BMR Mifflin-St Jeor memiliki input valid (usia, berat, tinggi, gender, aktivitas) sebelum kalkulasi nutrisi dijalankan."
    )

    # 4.8 Alur Hapus Akun & Hak Privasi Data
    ch.add_h2("4.8 Alur Hapus Akun & Hak Privasi Data (GDPR/UU PDP)")
    ch.add_p(
        "Sesuai mandat Undang-Undang Perlindungan Data Pribadi (UU PDP No. 27 Tahun 2022) dan standar GDPR global, "
        "OopsieEats menyediakan alur penghapusan akun mandiri tanpa friksi (Self-Service Data Erasure) yang diilustrasikan pada Diagram 9:"
    )
    ch.add_figure(
        path="docs/brd/diagrams/rendered/sequence-deletion.png",
        caption="Gambar 4.2: Diagram Sekuensial Penghapusan Akun & Pemusnahan Data Menyeluruh"
    )
    ch.add_p(
        "Ketika pengguna mengonfirmasi dialog hapus akun: "
        "(1) Seluruh foto makanan pada bucket <code>food-history-images/{uid}</code> dimusnahkan secara rekursif dari Supabase Storage, "
        "(2) Seluruh dokumen riwayat makan pada subkoleksi <code>users/{uid}/meals</code> dihapus, "
        "(3) Dokumen profil pengguna pada <code>users/{uid}</code> dihapus dari Firestore, "
        "(4) Kredensial akun dimusnahkan dari Firebase Authentication via <code>user.delete()</code>, "
        "(5) Seluruh cache lokal dan KeyStore dihapus bersih, dan pengguna dialihkan ke WelcomeScreen."
    )

    # 4.9 Penanganan Error Autentikasi & Edge Cases
    ch.add_h2("4.9 Penanganan Error Autentikasi & Edge Cases")
    ch.add_p(
        "Semua galat Firebase Auth dipetakan ke dalam pesan antarmuka berbahasa Indonesia yang bersahabat bagi pengguna:"
    )
    ch.add_table(
        caption="Tabel 4.3: Pemetaan Kode Galat Firebase Auth ke Pesan Bahasa Indonesia",
        headers=["Kode Galat Firebase", "Deskripsi Kegagalan", "Pesan UI yang Ditampilkan"],
        rows=[
            ["user-not-found", "Surel tidak terdaftar dalam sistem", "Akun dengan email tersebut tidak ditemukan. Silakan daftar terlebih dahulu."],
            ["wrong-password", "Kredensial kata sandi keliru", "Kata sandi yang Anda masukkan salah. Silakan coba lagi."],
            ["email-already-in-use", "Surel sudah digunakan oleh akun lain", "Email ini sudah terdaftar. Silakan masuk menggunakan akun Anda."],
            ["invalid-email", "Sintaks surel tidak sesuai format", "Format alamat email tidak valid."],
            ["network-request-failed", "Koneksi internet terputus saat request", "Koneksi internet bermasalah. Periksa jaringan Anda dan coba lagi."],
            ["user-disabled", "Akun diblokir oleh administrator", "Akun ini telah dinonaktifkan oleh administrator sistem."],
            ["requires-recent-login", "Sesi login sudah terlalu lama saat operasi kritis", "Demi keamanan, silakan keluar dan masuk kembali sebelum melanjutkan."]
        ]
    )

    # 4.10 Pengujian Keamanan Autentikasi
    ch.add_h2("4.10 Pengujian Keamanan Autentikasi")
    ch.add_p(
        "Keandalan modul autentikasi diverifikasi melalui automated test suite yang mencakup pengujian mock Firebase Auth, "
        "pengujian token expiry, pengujian bypass Complete Profile Guard, dan pengujian penghapusan akun beruntun, "
        "dengan tingkat kelulusan 100% pada seluruh skenario positif dan negatif."
    )

    return ch
