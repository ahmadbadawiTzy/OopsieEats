# OopsieEats (NutriView) — Panduan Operasional & Deployment

Panduan komprehensif untuk instalasi, konfigurasi, *deployment* aturan keamanan, dan *build* rilis aplikasi **OopsieEats** (`com.oopsieeats.app`, nama historis: *NutriView*) menggunakan arsitektur **Serverless Firebase Spark Tier (Bebas Biaya $0)**, **Supabase Storage**, dan **On-Device Computer Vision (TFLite)**.

---

## 1. Arsitektur Operasional & Topologi Serverless

OopsieEats beroperasi murni sebagai arsitektur *serverless* dan *offline-first*. Aplikasi tidak memerlukan server VPS, kontainer Docker, proses backend Python/Node.js, maupun database relasional mandiri:

```mermaid
flowchart TB
    subgraph Client ["Perangkat Pengguna (Aplikasi Flutter)"]
        FlutterApp["OopsieEats Mobile (com.oopsieeats.app)\n• On-Device YOLO26n (best.tflite ~9.4 MB)\n• Offline Cache Firestore (100 MB Limit)\n• Fallback Data Lokal (seed_foods.json)\n• Sesi Kredensial Lokal (FlutterSecureStorage)"]
    end

    subgraph FirebaseCloud ["Google Firebase (Spark Tier Bebas Biaya $0)"]
        FBAuth["Firebase Authentication\n• Email/Password Provider\n• Google Sign-In Provider (OAuth 2.0)"]
        Firestore["Cloud Firestore (NoSQL Document Store)\n• Multi-tenant Data: users/{uid}, meals\n• Katalog & CMS: foods, cms_articles\n• Audit Trail: cms_audit_logs (Immutable)"]
        FBHosting["Firebase Hosting\n• Kebijakan Privasi (/privacy)\n• Halaman Hapus Akun (/delete-account)"]
    end

    subgraph SupabaseCloud ["Supabase Storage (Private Media Tier)"]
        SupabaseBucket["Supabase Private Bucket: food-history-images\n• Foto Riwayat Makan: {uid}/{mealId}/food_{ts}.jpg\n• Foto Profil Pengguna: {uid}/profile/profile_{ts}.jpg\n• Signed URL Generator (1 Jam TTL)"]
    end

    FlutterApp <-->|HTTPS / TLS (Firebase SDK)| FBAuth
    FlutterApp <-->|HTTPS / TLS (Firebase SDK)| Firestore
    FlutterApp <-->|HTTPS / TLS (Supabase SDK)| SupabaseBucket
    FlutterApp -.->|Tautan Legal Google Play| FBHosting

    classDef client fill:#E8F1FF,stroke:#2B6CB0,stroke-width:2px,color:#1A365D;
    classDef firebase fill:#FFF2E8,stroke:#DD6B20,stroke-width:2px,color:#7B341E;
    classDef supabase fill:#E6FFFA,stroke:#2C7A7B,stroke-width:2px,color:#1D4044;

    class FlutterApp client;
    class FBAuth,Firestore,FBHosting firebase;
    class SupabaseBucket supabase;
```

---

## 2. Prasyarat Lingkungan Pengembangan (Prerequisites)

| Komponen | Versi Teruji | Catatan |
|---|---|---|
| **Flutter SDK** | `>= 3.24.0` (Dart SDK `>= 3.13.4`) | Channel `stable` |
| **Java Development Kit (JDK)** | OpenJDK 17 (`JavaVersion.VERSION_17`) | Diperlukan oleh Gradle Android 8+ |
| **Android SDK** | `compileSdk = 36`, `targetSdk = 36`, `minSdk = 23` | Kepatuhan Google Play target API 36 (Android 16) |
| **Node.js & npm** | Node `>= 18.0.0` | Diperlukan untuk Firebase CLI |
| **Firebase CLI** | `firebase-tools >= 13.0.0` | Diinstal via `npm install -g firebase-tools` |
| **Bash & Linux Tooling** | Bash 5+, `jarsigner`, `zip/unzip` | Untuk skrip validasi rilis `./scripts/validate_release.sh` |

---

## 3. Langkah Konfigurasi & Inisialisasi Proyek

### 3.1. Kloning Repositori & Instalasi Dependensi
```bash
git clone https://github.com/ahmadbadawiTzy/OopsieEats.git OopsieEats
cd OopsieEats/frontend
flutter pub get
```

### 3.2. Konfigurasi Proyek Firebase Console
1. Buka [Firebase Console](https://console.firebase.google.com/) dan pastikan project aktif sesuai (default: `nutriview-943cd`).
2. Masuk ke menu **Build** > **Authentication**:
   - Aktifkan provider **Email/Password**.
   - Aktifkan provider **Google** (masukkan nama aplikasi `OopsieEats` dan email dukungan `ahmadbadawi.biu.si@gmail.com`).
3. Masuk ke menu **Build** > **Firestore Database**:
   - Pastikan database berada dalam mode **Production**.
4. Daftarkan aplikasi Android dengan package name resmi:
   ```text
   com.oopsieeats.app
   ```
5. Tambahkan fingerprint SHA-1 debug dan SHA-1 release ke Firebase Console (wajib untuk Google Sign-In).
6. Unduh berkas `google-services.json` dan letakkan di:
   ```text
   frontend/android/app/google-services.json
   ```

### 3.3. Konfigurasi Kredensial Supabase Storage
Supabase Storage digunakan secara eksklusif untuk bucket privat `food-history-images`. Kredensial publik diteruskan saat menjalankan aplikasi atau build:
```bash
--dart-define=SUPABASE_URL=https://rnfvudxqcwcwilcyicow.supabase.co \
--dart-define=SUPABASE_ANON_KEY=sb_publishable_zkmZHcq6D4fTB1L9qvIvYw_izbuSHDj
```

---

## 4. Deployment Aturan Keamanan & Indeks Database

Deploy aturan keamanan deklaratif (`firestore.rules`), indeks komposit (`firestore.indexes.json`), dan hosting langsung dari root direktori repositori:

```bash
# 1. Login ke Firebase CLI jika belum
firebase login

# 2. Pastikan project target aktif
firebase use nutriview-943cd

# 3. Deploy Firestore Rules
firebase deploy --only firestore:rules

# 4. Deploy Firestore Composite Indexes
firebase deploy --only firestore:indexes

# 5. Deploy Halaman Web Legal (Privacy Policy & Delete Account)
firebase deploy --only hosting
```

---

## 5. Provisi Akun Administrator Pertama (Bootstrap)

Aturan keamanan `firestore.rules` menerapkan **Strict 2-Role System** (`admin` dan `user`). Akun admin tidak dapat dibuat melalui formulir registrasi publik klien untuk mencegah eskalasi peran (*anti-privilege escalation*).

### Langkah Menjadikan Akun Sebagai Admin:
1. Daftarkan akun baru secara normal melalui aplikasi atau Firebase Console Authentication.
2. Buka **Firestore Database** di Firebase Console.
3. Masuk ke dokumen pengguna di koleksi `users/{userId}`.
4. Ubah nilai field:
   - `role`: dari `"user"` menjadi `"admin"` (huruf kecil persis).
   - `is_active`: pastikan bernilai `true`.
5. Simpan perubahan. Akun tersebut kini memiliki hak akses penuh ke panel CMS admin (`AppRoutes.adminDashboard`).

> [!WARNING] **Larangan Penggunaan Role Lain**  
> Dilarang menggunakan nama role seperti `"super_admin"`, `"dietitian"`, atau `"editor"`. Sistem keamanan Firestore akan menolak akses untuk nilai role selain persis `"admin"`.

---

## 6. Build Rilis Android App Bundle (`.aab`) & Kepatuhan Google Play

### 6.1. Konfigurasi Upload Keystore
Sistem build Gradle (`frontend/android/app/build.gradle.kts`) menerapkan proteksi *fail-fast*. Jika `key.properties` tidak tersedia atau kosong, build rilis akan langsung dibatalkan (*fail-fast*) dan **tidak akan pernah** melakukan fallback ke debug signing key.

Buat berkas `frontend/android/key.properties` (berkas ini diabaikan oleh `.gitignore`):
```properties
storeFile=/path/to/oopsieeats-upload-keystore.jks
storePassword=PASSWORD_KEYSTORE_ANDA
keyAlias=oopsieeats_upload
keyPassword=PASSWORD_KEY_ANDA
```

### 6.2. Perintah Kompilasi Rilis Terobfuskasi
Jalankan perintah berikut dari direktori `frontend/`:
```bash
cd frontend
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release --obfuscate --split-debug-info=../symbols/android
```

### 6.3. Verifikasi Otomatis 12-Tahap (`validate_release.sh`)
Dari root repositori, jalankan:
```bash
./scripts/validate_release.sh
```
Skrip akan secara otomatis memverifikasi:
1. Resolusi Dependensi (`flutter pub get`)
2. Analisis Statis Kode (`flutter analyze` — 0 issues)
3. Test Suite Otomatis (359 test cases passed)
4. Keberadaan Artefak `app-release.aab`
5. Pemetaan R8 ProGuard (`mapping.txt`) & Dart Debug Symbols
6. Keselarasan Package Identifier (`com.oopsieeats.app`)
7. Kepatuhan Target SDK 36 (Android 16)
8. Keaslian Tanda Tangan Kriptografi Release via `jarsigner`
9. Audit Kebocoran Secret & Keystore di Git
10. Audit Izin Minimal Manifest (penghapusan izin implisit kamera/penyimpanan)
11. Keselarasan Halaman ELF 16 KB pada Pustaka Native ARM64/x86_64
12. Audit Ketersediaan Aset Legal & Halaman Web Penghapusan Akun
