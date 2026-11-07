# NutriView

NutriView adalah aplikasi pelacak nutrisi makanan *mobile* berbasis **Flutter** dengan kemampuan **Computer Vision On-Device (YOLO26n TFLite)** dan arsitektur nirserver (**Firebase Serverless**).

Pengguna mengatur profil fisik pribadi, memperoleh target kalori dan makronutrien harian secara deterministik menggunakan persamaan Mifflin-St Jeor, serta mencatat makanan dengan memotret hidangan mereka. Model neural network terkuantisasi **YOLO26n TensorFlow Lite (~9.4 MB)** mengidentifikasi 29 kelas makanan langsung pada perangkat pengguna tanpa memerlukan koneksi internet aktif. Pengguna mengonfirmasi porsi gram, dan metrik nutrisi dihitung secara deterministik dengan validasi konsistensi faktor energi Atwater sebelum disinkronkan ke Cloud Firestore dengan dukungan persistensi *offline* penuh.

> **Pernyataan Penyangkalan (Disclaimer)**: Nilai gizi dan rekomendasi yang disajikan oleh NutriView merupakan estimasi algoritmik untuk pemantauan kesehatan umum dan **tidak dapat menggantikan saran medis, diagnosis klinis, atau konsultasi ahli gizi profesional**.

---

## Ringkasan Arsitektur Sistem

NutriView mengimplementasikan arsitektur *edge-AI mobile* nirserver (*serverless*):

```text
┌────────────────────────────────────────────────────────────────────────┐
│                      APLIKASI FLUTTER (CLIENT MOBILE)                  │
│                                                                        │
│   ┌─────────────────────┐               ┌───────────────────────────┐  │
│   │ On-Device YOLO26n   │               │   Nutrition Engine        │  │
│   │ TFLite [1,3,640,640]│               │   Mifflin-St Jeor +       │  │
│   │ (best.tflite 9.4MB) │               │   Atwater Validation      │  │
│   └──────────┬──────────┘               └─────────────┬─────────────┘  │
│              │                                        │                │
│              ▼                                        ▼                │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │       Data Repositories & Local Persistent Cache (Offline)      │  │
│   │ (FoodRepository, MealRepository, ProfileRepo, AuthRepo, Client) │  │
│   └────────────────────────────────┬────────────────────────────────┘  │
└────────────────────────────────────┼───────────────────────────────────┘
                                     │ Direct Firebase SDK (HTTPS / TLS)
                                     ▼ (Firestore Rules & Strict 2-Role RBAC)
┌────────────────────────────────────────────────────────────────────────┐
│                   LAYANAN CLOUD FIREBASE (SPARK PLAN $0)               │
│                                                                        │
│   ┌─────────────────────────────────┐   ┌──────────────────────────┐   │
│   │ Firebase Authentication         │   │ Cloud Firestore          │   │
│   │ (Email/Password, Google Sign-In,│   │ (Multi-tenant Meals,     │   │
│   │  Biometric Session Fallback)    │   │  Foods Catalog, CMS,     │   │
│   │                                 │   │  Immutable Audit Logs)   │   │
│   └─────────────────────────────────┘   └──────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────┘
```

### Karakteristik Utama Arsitektur:
1. **100% On-Device Food Inference**: Model YOLO26n (9.4 MB) dieksekusi secara lokal via C++ runtime `tflite_flutter` pada *background isolate* tanpa latensi transmisi jaringan, menjamin privasi visual pengguna.
2. **Serverless Spark Plan ($0/bulan)**: Beroperasi murni pada layanan terkelola Firebase (Authentication dan Cloud Firestore) tanpa memerlukan server VPS, kontainer Docker, proses backend mandiri, ataupun bucket Cloud Storage berbayar.
3. **Isolasi Data & Keamanan Multi-Tenant**: Catatan makan privat pengguna disimpan di bawah `users/{uid}/meals/{mealId}`, dilindungi secara ketat oleh deklaratif `firestore.rules` dengan sistem peran biner terverifikasi (`admin` dan `user`).
4. **Desain Visual Overkill Neo-Brutalism**: Antarmuka ekspresif dengan batas hitam tebal (`2.0` / `3.0`), bayangan pejal tanpa blur (*hard shadow*), skala spasi integer terukur, dan ikon Material Symbols (`rounded`).
5. **Karakter Avatar Game Vektor**: Karakter profil digambar secara prosedural oleh kode Flutter (`AvatarCatalog`) tanpa mewajibkan pengguna mengunggah foto ke cloud.

---

## Fitur Utama Aplikasi

- **Deteksi Makanan On-Device**: Pengenalan citra instan menggunakan model terkuantisasi YOLO26n yang mengenali 29 jenis makanan populer Indonesia.
- **Autentikasi Multi-Metode**: Login via Email/Password, Google Sign-In (OAuth 2.0), autentikasi biometrik lokal (sidik jari/wajah), dan penyimpanan sesi terenkripsi (`FlutterSecureStorage`).
- **Mesin Gizi Deterministik**: Perhitungan BMR dan TDEE berbasis formula Mifflin-St Jeor, penyesuaian target kalori aman (*calorie floor*), dan validasi energi Atwater $((4 \times P) + (4 \times C) + (9 \times F))$.
- **Dashboard Nutrisi Interaktif**: Pelacakan progres kalori harian dinamis, bento grid makronutrien (Protein, Karbohidrat, Lemak), dan daftar asupan makanan terkini.
- **Ketahanan Offline Penuh**: Dukungan persistensi Firestore 100 MB dan *fallback* katalog pangan lokal via `seed_foods.json`.
- **Portal Administrasi & CMS Terintegrasi**: Manajemen katalog pangan, artikel edukasi gizi berbasis gambar URL eksternal, pengumuman publik, dan log audit yang bersifat permanen (*immutable*).

---

## Teknologi yang Digunakan (Tech Stack)

- **Framework**: Flutter (Dart SDK `^3.13.4`, kompatibel dengan Flutter 3.24+)
- **Computer Vision & ML**: TensorFlow Lite (`tflite_flutter` v0.12.1), custom YOLO26n model (`best.tflite`)
- **Autentikasi**: `firebase_auth` (v7.0.1), `google_sign_in` (v7.2.0), `local_auth` (v3.0.2), `flutter_secure_storage` (v9.2.2)
- **Basis Data Cloud**: `cloud_firestore` (v7.1.0), `firebase_core` (v5.1.0)
- **Manajemen Status**: `provider` (v6.1.2) dengan arsitektur Repository Pattern
- **Pemrosesan Citra**: `image` (v4.12.0) untuk rotasi EXIF dan transformasi tensor matriks

---

## Dokumentasi Teknis Lengkap

NutriView menyediakan dokumentasi arsitektur dan teknis mendalam yang terbagi dalam direktori `docs/`:

| Dokumen | Topik Pembahasan |
|---|---|
| [**Arsitektur Sistem**](docs/ARCHITECTURE.md) | Diagram arsitektur detail, diagram sekuensial, tanggung jawab per layer, dan alur navigasi |
| [**Basis Data & Backend**](docs/DATABASE_AND_BACKEND.md) | Skema koleksi Firestore, Security Rules RBAC biner, indeks komposit, dan mekanisme persistensi offline |
| [**Machine Learning & Formulasi Gizi**](docs/MACHINE_LEARNING.md) | Pipeline inferensi YOLO26n on-device, pra-pemrosesan isolate, NMS, rumus Mifflin-St Jeor, dan faktor Atwater |
| [**Panduan Pengembangan**](docs/DEVELOPMENT_GUIDE.md) | Konvensi kode Dart, implementasi prinsip SOLID, sistem desain Neo-Brutalism, dan hierarki error |
| [**Pengujian Kualitas & QA**](docs/TESTING_AND_QA.md) | Piramida pengujian, inventaris 32 berkas uji, hasil eksekusi 256 test cases (100% lulus), dan tolak ukur benchmark |
| [**Panduan Operasional & Deployment**](docs/deployment.md) | Konfigurasi Firebase CLI, bootstrap admin pertama, build APK/AAB rilis, dan ProGuard |
| [**Laporan Audit Dokumentasi**](docs/DOCUMENTATION_AUDIT_REPORT.md) | Laporan menyeluruh hasil audit dokumentasi, penyesuaian historis, dan bukti verifikasi |

---

## Panduan Memulai Cepat (Getting Started)

### 1. Kloning Repositori
```bash
git clone https://github.com/ahmadbadawiTzy/NutriView.git
cd NutriView/frontend
```

### 2. Instalasi Dependensi
```bash
flutter pub get
```

### 3. Model Machine Learning
Model inferensi dan daftar label telah terbundel langsung di dalam repositori:
- Model Weights: `frontend/assets/models/best.tflite` (9.4 MB)
- Label Map: `frontend/assets/models/classes.txt` (29 kelas makanan)

### 4. Konfigurasi Kredensial Firebase
- Letakkan berkas `google-services.json` pada direktori:
  ```text
  frontend/android/app/google-services.json
  ```
- Deploy Security Rules dan Indeks Firestore ke proyek Firebase Anda:
  ```bash
  firebase deploy --only firestore:rules,firestore:indexes
  ```

---

## Verifikasi Kualitas & Pengujian

### Analisis Statis Kode
```bash
cd frontend
flutter analyze
```
*Hasil aktual: **No issues found!** (0 error, 0 warning).*

### Eksekusi Seluruh Test Suite
```bash
cd frontend
flutter test
```
*Hasil aktual: **256 test cases passed (100% pass rate)** meliputi validasi formula Mifflin-St Jeor, Atwater factor, stabilitas isolasi TFLite, autentikasi biometrik, responsivitas antarmuka, dan RBAC biner.*

---

## Kompilasi Rilis Android

### Android Release APK
```bash
cd frontend
flutter build apk --release
```
Berkas keluaran: `frontend/build/app/outputs/flutter-apk/app-release.apk`.

### Android App Bundle (AAB)
```bash
cd frontend
flutter build appbundle --release
```
Berkas keluaran: `frontend/build/app/outputs/bundle/release/app-release.aab`.

---

## Hak Cipta & Referensi

- **Penyusun & Pengembang**: Ahmad Badawi ([GitHub](https://github.com/ahmadbadawiTzy) · [LinkedIn](https://www.linkedin.com/in/ahmad-badawi-b87274410))
- **Data Acuan Komposisi Pangan**: Tabel Komposisi Pangan Indonesia (TKPI 2020), Kementerian Kesehatan Republik Indonesia.
- **Model Vision AI**: Arsitektur kustom YOLO26n terkuantisasi TFLite dilatih pada dataset 29 pangan Indonesia.
- **Tipografi & Ikon**: Inter font & Material Symbols (`rounded`).
