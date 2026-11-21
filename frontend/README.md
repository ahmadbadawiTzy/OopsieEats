# OopsieEats — Frontend Mobile Package

Paket utama aplikasi mobile **OopsieEats: Food Nutrition Recognition & Daily Tracking App** (`package:oopsieeats`, Application ID `com.oopsieeats.app`), dibangun menggunakan Flutter.

---

## 1. Ikhtisar Paket

Direktori ini berisi seluruh kode sumber antarmuka, logika bisnis (*state management*), abstraksi repositori data, dan pipeline inferensi model machine learning *on-device*.

### Ringkasan Teknis:
- **Framework**: Flutter (Channel Stable)
- **Dart SDK**: `^3.13.4`
- **Application ID / Package**: `com.oopsieeats.app`
- **Versi Aplikasi**: `1.0.0+2002`
- **Target Android SDK**: `compileSdk = 36`, `targetSdk = 36`, `minSdk = 23`
- **State Management**: `provider` (v6.1.2) dengan pola `ChangeNotifier`
- **Machine Learning**: `tflite_flutter` (v0.12.1) mengeksekusi `assets/models/best.tflite` (~9.4 MB)
- **Cloud Backend**: `firebase_core` (v5.1.0), `firebase_auth` (v7.0.1), `cloud_firestore` (v7.1.0), `supabase_flutter` (v2.18.3)
- **Desain Antarmuka**: Overkill Neo-Brutalism Design System dengan token tebal dan hard shadow

---

## 2. Struktur Direktori `lib/`

```text
lib/
├── main.dart               # Entrypoint aplikasi, dependency injection, & route guards
├── firebase_options.dart   # Konfigurasi platform Firebase
├── core/                   # Konfigurasi, tema, ML detector, & kalkulator gizi
│   ├── config.dart             # Konfigurasi nama aplikasi & disclaimer
│   ├── config/creator_config.dart # Data profil kreator & link legal
│   ├── config/supabase_config.dart# Konfigurasi bucket Supabase Storage
│   ├── error_handler.dart      # Hierarki exception (ApiException)
│   ├── nutrition_calculator.dart # Formulasi Mifflin-St Jeor & Atwater
│   ├── age_calculator.dart     # Kalkulasi umur dinamis dari birth_date
│   ├── routes.dart             # Konstanta rute navigasi aplikasi
│   ├── theme.dart              # Tema terang dan gelap
│   ├── neo_tokens.dart         # Token warna & border Neo-Brutalism
│   └── ml/                     # Detektor YOLO (io, stub, export)
├── data/                   # Model data (DTO), API client, repositori, layanan
│   ├── api_client.dart         # Penyimpanan sesi lokal (FlutterSecureStorage)
│   ├── models/                 # DTO Model (User, Profile, Food, Meal, Article, Dashboard)
│   ├── repositories/           # Repositori (Auth, Profile, Food, Meal, Dashboard, Article)
│   └── services/               # Layanan (BiometricService, SupabaseStorageService)
├── features/               # Modul fungsional
│   ├── admin/                  # Dashboard CMS manajemen katalog, artikel, audit, & user
│   ├── article/                # Tampilan daftar dan detail artikel edukasi gizi
│   ├── auth/                   # Layar Login, Registrasi, Modal Biometrik & Reset Sandi
│   ├── dashboard/              # Layar dashboard utama, bento grid makro, hero kalori
│   ├── meals/                  # Layar riwayat makan dan rincian detail makanan
│   ├── onboarding/             # Layar onboarding interaktif 3 slide
│   ├── profile/                # Layar profil, form biodata terpadu, dan tentang kreator
│   ├── scanner/                # Layar kamera scanner, konfirmasi deteksi, & input porsi
│   └── splash/                 # Layar pembuka aplikasi dengan animasi badge
└── shared/                 # Komponen UI pakai-ulang (Neo-Brutalism widgets & avatar)
```

---

## 3. Menjalankan & Menguji Aplikasi

### Instalasi Dependensi:
```bash
flutter pub get
```

### Menjalankan di Perangkat / Emulator:
```bash
flutter run
```

### Menjalankan Analisis Statis Kode:
```bash
flutter analyze
```

### Menjalankan Seluruh Unit & Widget Tests:
```bash
flutter test
```
*Status Terverifikasi*: **359 tests passed (100% lulus)** pada 42 berkas pengujian.

---

## 4. Build Rilis Android App Bundle

Proses kompilasi rilis menggunakan proteksi penandatanganan rilis via `android/key.properties`:

```bash
flutter build appbundle --release --obfuscate --split-debug-info=../symbols/android
```

---

## 5. Dokumentasi Lengkap Proyek

Untuk dokumentasi teknis menyeluruh, arsitektur, basis data, pipeline kecerdasan buatan, dan panduan deployment, silakan merujuk ke direktori dokumentasi utama:

- [README Utama Proyek](../README.md)
- [Portal Indeks Dokumentasi](../docs/README.md)
- [Arsitektur Sistem](../docs/ARCHITECTURE.md)
- [Basis Data & Layanan Cloud](../docs/DATABASE_AND_BACKEND.md)
- [Penyimpanan Media Supabase](../docs/SUPABASE_IMAGE_STORAGE.md)
- [Pipeline Machine Learning & Gizi](../docs/MACHINE_LEARNING.md)
- [Panduan Pengembangan & Konvensi](../docs/DEVELOPMENT_GUIDE.md)
- [Pengujian Kualitas & Hasil QA](../docs/TESTING_AND_QA.md)
- [Panduan Operasional & Deployment](../docs/deployment.md)
- [Koleksi Diagram Mermaid](../docs/diagrams/)
