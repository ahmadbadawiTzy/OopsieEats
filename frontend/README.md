# OopsieEats — Frontend Mobile Package

Paket utama aplikasi mobile **OopsieEats: Food Nutrition Recognition & Daily Tracking App** (`package:oopsieeats`) yang dibangun menggunakan Flutter.

---

## 1. Ikhtisar Paket

Direktori ini berisi seluruh kode sumber antarmuka, logika bisnis (*state management*), abstraksi repositori data, dan pipeline inferensi model machine learning *on-device*.

### Ringkasan Teknis:
- **Framework**: Flutter (Dart SDK `^3.13.4`, paket `oopsieeats` v1.0.0+2002)
- **State Management**: `provider` (v6.1.2) dengan pola `ChangeNotifier`
- **Machine Learning**: `tflite_flutter` (v0.12.1) mengeksekusi `assets/models/best.tflite`
- **Cloud Backend**: `firebase_core` (v5.1.0), `firebase_auth` (v7.0.1), `cloud_firestore` (v7.1.0), `supabase_flutter` (v2.18.3)
- **Desain Antarmuka**: Overkill Neo-Brutalism Design System dengan Material Symbols

---

## 2. Struktur Direktori `lib/`

```text
lib/
├── main.dart               # Entrypoint aplikasi & inisialisasi MultiProvider
├── firebase_options.dart   # Konfigurasi platform Firebase
├── core/                   # Konfigurasi, tema, ML detector, & kalkulator gizi
├── data/                   # Model data (DTO), API client, dan Repositori
├── features/               # Modul fungsional (Auth, Dashboard, Scanner, Meals, Profile, Admin, Onboarding, Article, Splash)
└── shared/                 # Komponen UI pakai-ulang (Neo-Brutalism widgets)
```

---

## 3. Menjalankan Aplikasi

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

---

## 4. Dokumentasi Lengkap Proyek

Untuk dokumentasi arsitektur, basis data, pipeline kecerdasan buatan, dan panduan deployment yang komprehensif, silakan merujuk ke direktori dokumentasi utama:

- [README Utama Proyek](../README.md)
- [Arsitektur Sistem](../docs/ARCHITECTURE.md)
- [Basis Data & Layanan Cloud](../docs/DATABASE_AND_BACKEND.md)
- [Penyimpanan Media Supabase](../docs/SUPABASE_IMAGE_STORAGE.md)
- [Pipeline Machine Learning & Gizi](../docs/MACHINE_LEARNING.md)
- [Panduan Pengembangan & Konvensi](../docs/DEVELOPMENT_GUIDE.md)
- [Pengujian Kualitas & Hasil QA](../docs/TESTING_AND_QA.md)
- [Panduan Operasional & Deployment](../docs/deployment.md)
- [Laporan Audit Repositori](../docs/REPOSITORY_AUDIT_REPORT.md)
