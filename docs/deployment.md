# NutriView — Panduan Operasional & Deployment Firebase

Panduan komprehensif untuk instalasi, konfigurasi, *deployment* aturan keamanan, dan *build* rilis aplikasi NutriView menggunakan arsitektur **Serverless Firebase Spark Tier (Bebas Biaya $0)** dan **On-Device Computer Vision (TFLite)**.

---

## 1. Arsitektur Operasional & Topologi Serverless

NutriView beroperasi murni sebagai arsitektur *serverless* dan *offline-first*. Aplikasi tidak memerlukan server VPS, kontainer Docker, proses backend Python/Node.js, maupun database relasional mandiri.

```text
┌─────────────────────────────────────────────────────────────────┐
│                   PERANGKAT PENGGUNA (FLUTTER)                  │
│                                                                 │
│  ├── On-Device YOLO26n TFLite (best.tflite 9.4MB, Offline CPU)  │
│  ├── Offline Cache Firestore (Bounded Cache 100 MB)             │
│  ├── Fallback Data Lokal (assets/data/seed_foods.json)          │
│  └── Sesi Kredensial Lokal (FlutterSecureStorage)               │
└────────────────────────────────┬────────────────────────────────┘
                                 │
                                 │ HTTPS / TLS (Google Firebase SDK)
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│               FIREBASE SPARK PLAN (BEBAS BIAYA $0)              │
│                                                                 │
│  ├── Firebase Authentication                                    │
│  │   ├── Email / Password Provider                              │
│  │   └── Google Sign-In Provider (OAuth 2.0)                    │
│  │                                                              │
│  └── Cloud Firestore (NoSQL Document Store)                     │
│      ├── Multi-tenant Data: users/{uid}, users/{uid}/meals      │
│      ├── Katalog & CMS: foods, cms_articles, cms_categories,    │
│      │                  cms_announcements, cms_media            │
│      └── Audit Trail: cms_audit_logs (Immutable)                │
└─────────────────────────────────────────────────────────────────┘
```

> [!NOTE] **Bebas Ketergantungan Firebase Cloud Storage**  
> NutriView **tidak menggunakan Firebase Cloud Storage** (menghindari kewajiban upgrade ke paket Blaze berbayar). Seluruh aset media artikel CMS dikelola menggunakan URL gambar eksternal (HTTPS) yang tersimpan di koleksi `cms_media`, sementara avatar profil pengguna digambar secara deterministik langsung oleh aplikasi Flutter (`AvatarCatalog`).

---

## 2. Prasyarat Lingkungan Pengembangan (Prerequisites)

| Komponen | Versi Minimum | Catatan |
|---|---|---|
| **Flutter SDK** | `>= 3.24.0` (Dart SDK `>= 3.5.0`) | Channel `stable` |
| **Java Development Kit (JDK)** | OpenJDK 17 atau 21 | Sesuai target Android Gradle |
| **Android SDK** | API Level 34 (`compileSdk`), Min API 23 (`minSdk`) | Mendukung Android 6.0 s/d 14+ |
| **Node.js & npm** | Node `>= 18.0.0` | Untuk Firebase CLI |
| **Firebase CLI** | `firebase-tools >= 13.0.0` | Diinstal via `npm install -g firebase-tools` |
| **Python** (Opsional) | Python `>= 3.10` | Diperlukan jika menjalankan skrip migrasi data |

---

## 3. Langkah Konfigurasi & Inisialisasi Proyek

### 3.1. Kloning Repositori & Instalasi Dependensi
```bash
git clone https://github.com/ahmadbadawiTzy/NutriView.git
cd NutriView/frontend
flutter pub get
```

### 3.2. Konfigurasi Proyek Firebase Console
1. Buka [Firebase Console](https://console.firebase.google.com/) dan buat proyek baru (contoh: `nutriview-app`).
2. Masuk ke menu **Build** > **Authentication**:
   - Aktifkan provider **Email/Password**.
   - Aktifkan provider **Google** (masukkan nama aplikasi dan email dukungan).
3. Masuk ke menu **Build** > **Firestore Database**:
   - Klik **Create Database** dalam mode **Production**.
   - Pilih region server (disarankan `asia-southeast2` Jakarta untuk latensi optimal di Indonesia).
4. Catat Project ID Firebase Anda.

### 3.3. Mengunduh Konfigurasi Kredensial Platform
- **Android**:
  1. Daftarkan aplikasi Android dengan package name `com.nutriview.nutriview`.
  2. Tambahkan fingerprint sertifikat SHA-1 debug dan release ke Firebase Console (wajib untuk Google Sign-In).
  3. Unduh berkas `google-services.json` dan letakkan di:
     ```text
     frontend/android/app/google-services.json
     ```
- **Flutter Options**:
  Pastikan konfigurasi di `frontend/lib/firebase_options.dart` telah disesuaikan dengan Project ID Anda, atau buat ulang menggunakan FlutterFire CLI:
  ```bash
  cd frontend
  flutterfire configure
  ```

---

## 4. Deployment Aturan Keamanan & Indeks Database

Deploy aturan keamanan deklaratif (`firestore.rules`) dan indeks komposit (`firestore.indexes.json`) langsung dari root repositori:

```bash
# Login ke Firebase CLI jika belum
firebase login

# Set proyek aktif
firebase use <YOUR_PROJECT_ID>

# Deploy rules dan indexes (TANPA storage rules)
firebase deploy --only firestore:rules,firestore:indexes
```

Hasil verifikasi deployment:
- `✔ firestore: released rules firestore.rules to cloud.firestore`
- `✔ firestore: deployed indexes in firestore.indexes.json successfully`

---

## 5. Migrasi & Seeding Data Master Awal

Tersedia dua opsi untuk memuat katalog makanan awal dan artikel panduan gizi:

### Opsi A: Otomatis via Aplikasi (Offline-First)
Aplikasi secara bawaan menyertakan data offline di `frontend/assets/data/seed_foods.json`. Saat aplikasi dijalankan pertama kali tanpa koneksi database, repositori `FoodRepository` secara otomatis memuat 29 item pangan lokal dari asset bundel.

### Opsi B: Seeding Manual via Skrip Python ke Firestore
Jika ingin mengisi koleksi cloud Firestore secara langsung:
```bash
cd /path/to/NutriView

# Set kredensial service account
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account.json"
export GCLOUD_PROJECT="<YOUR_PROJECT_ID>"

# Jalankan skrip migrasi
python scripts/migrate_to_firestore.py
```
Skrip akan mengunggah:
- 29 item katalog makanan ke koleksi `foods`.
- Kategori artikel ke koleksi `cms_categories`.
- Artikel panduan gizi ke koleksi `cms_articles`.
- Pengumuman selamat datang ke koleksi `cms_announcements`.
- Log inisialisasi sistem ke koleksi `cms_audit_logs`.

---

## 6. Provisi Akun Administrator Pertama (Bootstrap Admin)

Sistem hak akses NutriView menerapkan **Strict 2-Role System** (`user` dan `admin`). Security rules secara ketat melarang pendaftaran publik dengan status admin (*anti-privilege escalation*).

Untuk membuat akun administrator pertama:

1. **Registrasi Akun Biasa**:
   Daftarkan akun melalui form registrasi aplikasi mobile atau lewat menu **Firebase Console** > **Authentication** > **Add user**.
2. **Salin UID Pengguna**:
   Buka Firebase Authentication di Console, salin **User UID** dari akun tersebut (misalnya `aBcDeF123456789...`).
3. **Elevasi Hak Akses di Firestore**:
   Buka **Firestore Database** > buka koleksi `users` > cari dokumen dengan ID sesuai UID di atas (`users/{UID}`).
4. **Perbarui Atribut**:
   Ubah field berikut pada dokumen:
   ```json
   {
     "role": "admin",
     "is_active": true
   }
   ```
   > [!WARNING] **Gunakan Tepat Nilai `"admin"`**  
   > Jangan menggunakan `"super_admin"`, `"dietitian"`, atau `"editor"`. Sistem evaluasi keamanan `firestore.rules` baris 20–25 secara ketat hanya memvalidasi `getUserData().role == 'admin'`.

5. Akun tersebut kini dapat masuk ke Panel Admin (`/admin/dashboard`) dan mengelola katalog makanan, artikel CMS, media, serta akun pengguna.

---

## 7. Kompilasi & Rilis Aplikasi Android

Konfigurasi Android NutriView menggunakan **Gradle Kotlin DSL (`build.gradle.kts`)** dengan integrasi ProGuard/R8 dan optimasi asset TFLite.

### 7.1. Konfigurasi Optimasi Asset TFLite
Pada `frontend/android/app/build.gradle.kts`, model TFLite dikecualikan dari kompresi agar dapat di-*memory-map* langsung oleh runtime C++ TFLite tanpa overhead dekompresi RAM:
```kotlin
aaptOptions {
    noCompress("tflite")
}
```

### 7.2. Konfigurasi Signing Key Rilis (Opsional)
Untuk rilis ke Google Play Store, buat berkas `frontend/android/key.properties`:
```properties
storePassword=keystore_password
keyPassword=key_password
keyAlias=key_alias
storeFile=../app/release.keystore
```
Jika berkas `key.properties` tidak ditemukan, build Gradle secara otomatis *fallback* menggunakan konfigurasi debug signing untuk kemudahan pengujian internal.

### 7.3. Perintah Build APK Rilis
```bash
cd frontend
flutter build apk --release
```
Berkas APK hasil kompilasi berlokasi di:
```text
frontend/build/app/outputs/flutter-apk/app-release.apk
```

### 7.4. Perintah Build Android App Bundle (AAB)
Untuk publikasi resmi di Google Play Store:
```bash
cd frontend
flutter build appbundle --release
```
Berkas App Bundle berlokasi di:
```text
frontend/build/app/outputs/bundle/release/app-release.aab
```

---

## 8. Verifikasi Kualitas & Diagnostik Operasional

Sebelum mendistribusikan rilis, jalankan pengujian lengkap berikut di direktori `frontend`:

```bash
# 1. Analisis Statis Kode (Harus 0 issues)
flutter analyze

# 2. Eksekusi Seluruh Suite Pengujian (256 test cases)
flutter test
```

### Troubleshooting Umum

| Masalah | Penyebab | Solusi |
|---|---|---|
| **Google Sign-In Error 10 / 12500** | SHA-1 certificate fingerprint belum didaftarkan di Firebase Console. | Jalankan `./gradlew signingReport` di `frontend/android`, salin SHA-1 ke Firebase Project Settings > General > Android apps, lalu perbarui `google-services.json`. |
| **Model TFLite Gagal Dimuat** | Model tidak terbawa di asset atau nama file salah. | Periksa `frontend/pubspec.yaml` bagian `assets: - assets/models/` dan pastikan file `frontend/assets/models/best.tflite` tersedia. |
| **Izin Akses Admin Ditolak (403)** | Dokumen `users/{uid}` belum diset `role: "admin"` atau `is_active: false`. | Periksa dokumen pengguna di Firestore dan pastikan nilainya persis `"role": "admin"` dan `"is_active": true`. |
| **Peringatan Kuota Firestore** | Query scanning koleksi tanpa filter tanggal. | Repositori telah dioptimasi dengan query berbasis `consumed_date` (`where('consumed_date', isEqualTo: ...)`), menghemat hingga 95% operasi baca database harian. |
