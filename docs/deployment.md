# NutriView — Firebase Deployment & Operations Guide

Panduan lengkap untuk melakukan konfigurasi, *deployment*, dan pemeliharaan arsitektur Serverless NutriView menggunakan Firebase Spark Tier (Bebas Biaya Server) dan On-Device AI inference.

---

## 1. Arsitektur & Topologi Serverless

NutriView tidak lagi memerlukan server VPS, kontainer Docker, proses daemon FastAPI, atau database MySQL server. Arsitektur beroperasi secara *serverless* dan *offline-first*:

```text
[ Perangkat Mobile / Pengguna ]
             │
             ├── On-Device YOLO26n TFLite (best.tflite 9.4MB, Offline CPU/GPU)
             ├── Offline Cache Firestore (Local SQLite / IndexedDB)
             │
             ▼ HTTPS / Direct SDK (Google TLS)
┌──────────────────────────────────────────────────┐
│             Firebase Spark Tier (Cloud)          │
│                                                  │
│   ├── Firebase Authentication (Email/Password)   │
│   ├── Cloud Firestore (Multi-tenant Document DB) │
│   └── Cloud Storage for Firebase (Media Assets)  │
└──────────────────────────────────────────────────┘
```

---

## 2. Langkah Deployment Proyek Firebase

### 2.1. Persiapan Proyek di Firebase Console
1. Buka [Firebase Console](https://console.firebase.google.com/).
2. Buat proyek baru dengan nama proyek Anda (misal `nutriview-app`).
3. Pada menu **Build** > **Authentication**:
   - Aktifkan provider **Email/Password**.
4. Pada menu **Build** > **Firestore Database**:
   - Buat database baru dalam mode produksi.
   - Pilih lokasi server (disarankan `asia-southeast2` Jakarta untuk latensi terendah di Indonesia).
5. Pada menu **Build** > **Storage**:
   - Aktifkan Cloud Storage for Firebase.

### 2.2. Menghubungkan Aplikasi Flutter
Jalankan konfigurasi FlutterFire CLI di direktori `frontend`:
```bash
cd frontend
flutterfire configure
```
Atau unduh berkas `google-services.json` dari Firebase Console dan tempatkan pada:
```text
frontend/android/app/google-services.json
```

### 2.3. Melakukan Deploy Aturan Keamanan (Security Rules)
Deploy aturan keamanan deklaratif dan indeks Firestore langsung dari root repositori:
```bash
firebase deploy --only firestore:rules,storage:rules,firestore:indexes
```

### 2.4. Melakukan Seed Data Awal ke Firestore
Jalankan skrip migrasi idempotem dengan kredensial service account admin:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
export GCLOUD_PROJECT="nutriview-app"
python scripts/migrate_to_firestore.py
```
Skrip ini akan mengunggah:
- 29 katalog makanan dari `frontend/assets/data/seed_foods.json` ke koleksi `foods`.
- Kategori artikel ke `cms_categories`.
- Artikel panduan gizi ke `cms_articles`.
- Pengumuman selamat datang ke `cms_announcements`.
- Log audit inisialisasi ke `cms_audit_logs`.

---

## 3. Bootstrap Akun Super Admin Pertama

Karena Security Rules melarang pengguna aplikasi menaikkan hak akses (*role*) secara mandiri:
1. Daftarkan akun Anda melalui aplikasi NutriView (atau lewat Firebase Console > Authentication > Add User).
2. Salin **User UID** akun tersebut di tab Authentication.
3. Buka **Firestore Database** > koleksi `users` > buka dokumen dengan nama UID Anda (`users/{UID}`).
4. Ubah nilai field:
   - `role`: `"super_admin"`
   - `is_active`: `true`
5. Akun Anda kini resmi memiliki status `super_admin` dan dapat mengakses seluruh menu manajemen di Panel Admin (`/admin/login`).

---

## 4. Kompilasi & Rilis Aplikasi Android

Untuk merilis berkas APK siap pakai bagi pengguna:
```bash
cd frontend
flutter build apk --release
```
Berkas APK hasil kompilasi berlokasi di:
```text
frontend/build/app/outputs/flutter-apk/app-release.apk
```
Fitur on-device YOLO26n (`best.tflite`) telah dibundel otomatis dan siap dijalankan tanpa internet pada target perangkat yang didukung.
