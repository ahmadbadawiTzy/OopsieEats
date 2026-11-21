# BAB 2: Setup Lingkungan Pengembangan

**Spesifikasi Perangkat, Toolchain Flutter, Konfigurasi Android/iOS, Multi-Cloud, dan Struktur Repositori**

---

**Aplikasi:** OopsieEats (`com.oopsieeats.app`) | **Versi:** 1.0.0+2002  
**Penyusun:** Ahmad Badawi (NIM 20090015) — Universitas Bina Insani  
**Status:** Approved & Baselined | **Klasifikasi:** Confidential / Restricted

---


## 2.1 Prasyarat Perangkat Keras & Lunak

Untuk memastikan kelancaran kompilasi, eksekusi unit test, dan rendering simulator lokal, stasiun kerja pengembang (developer workstation) wajib memenuhi ambang batas spesifikasi minimum berikut:

**Tabel 2.1: Spesifikasi Minimum Workstation Rekayasa OopsieEats**

| Komponen Perangkat | Spesifikasi Minimum | Spesifikasi Rekomendasi Tim | Keterangan Kritis |
| --- | --- | --- | --- |
| Sistem Operasi | Ubuntu 22.04 LTS / macOS 13 Ventura / Windows 11 | Ubuntu 24.04 LTS / macOS 14 Sonoma | Dukungan POSIX shell & symlink native |
| Prosesor (CPU) | Intel Core i5 Gen 10 / AMD Ryzen 5 3600 (4-Core) | Apple Silicon M2 / Intel Core i7 13th Gen (8+ Core) | Dibutuhkan untuk parallel isolate testing |
| Memori Utama (RAM) | 16 GB DDR4 Dual-Channel | 32 GB DDR4/DDR5 Unified Memory | Kompilasi Gradle & emulator Android membutuhkan > 12 GB |
| Penyimpanan (Disk) | SSD NVMe 50 GB ruang kosong | SSD NVMe Gen4 100+ GB ruang kosong | Cache Gradle, CocoaPods, dan simulator build |
| Display & GPU | 1080p FHD, GPU terintegrasi Vulkan 1.1+ | 1440p QHD / 4K, Dedicated GPU 4GB VRAM | Akselerasi visual emulator dan antarmuka TFLite |


## 2.2 Konfigurasi Toolchain Flutter & Dart SDK

Lingkungan pengembangan OopsieEats dikunci secara ketat pada versi Flutter stable channel dengan dependensi Dart SDK modern:

- <strong>Flutter Channel & Version</strong>: Flutter 3.24.x stable channel dengan dukungan Material 3 dan engine Impeller.
- <strong>Dart SDK Constraint</strong>: Versi SDK dikunci pada rentang <code>sdk: ^3.13.4</code> pada berkas <code>pubspec.yaml</code> untuk menjamin ketersediaan fitur modern seperti pattern matching, class modifiers, dan <code>Isolate.run()</code>.
- <strong>Manajemen Dependensi Inti</strong>: Dependensi utama mencakup <code>provider: ^6.1.2</code> (state management), <code>tflite_flutter: ^0.10.4</code> (ML runtime), <code>firebase_core: ^3.6.0</code>, <code>cloud_firestore: ^5.4.4</code>, <code>supabase_flutter: ^2.8.0</code>, dan <code>flutter_secure_storage: ^9.2.2</code>.


## 2.3 Konfigurasi Android Build System (Gradle, NDK, SDK 36)

Konfigurasi Android Native pada berkas <code>android/app/build.gradle</code> dikonfigurasi secara presisi untuk memenuhi standar Google Play Store terbaru tahun 2026:

**Tabel 2.2: Parameter Kunci Build System Android OopsieEats**

| Parameter Gradle | Nilai Konfigurasi | Lokasi Berkas | Alasan Arsitektural |
| --- | --- | --- | --- |
| applicationId | com.oopsieeats.app | android/app/build.gradle | Identitas unik paket aplikasi di Google Play Ecosystem |
| compileSdk | 36 (Android 15 Preview / QPR) | android/app/build.gradle | Kompatibilitas framework Android terbaru & API security |
| targetSdk | 36 | android/app/build.gradle | Kepatuhan kebijakan target API Google Play 2026 |
| minSdk | 23 (Android 6.0 Marshmallow) | android/app/build.gradle | Mencakup 99.2% populasi perangkat Android aktif global |
| versionCode | 2002 | android/app/build.gradle | Penomoran build rilis produksi stabil |
| versionName | 1.0.0 | android/app/build.gradle | Versi semantik rilis publik |
| Gradle Plugin | 8.3.2 | android/build.gradle | Dukungan kompilasi Kotlin 1.9+ & Java 17 bytecode |
| aaptOptions | noCompress 'tflite' | android/app/build.gradle | Mencegah kompresi berkas model AI best.tflite agar mmap langsung |


## 2.4 Konfigurasi iOS Build System (CocoaPods & Xcode)

Untuk platform Apple iOS, konfigurasi berkas <code>ios/Podfile</code> menetapkan platform minimum iOS 13.0 dengan aktivasi static linkage untuk menghindari konflik pustaka native TFLite C++:

- <strong>Target Minimum iOS</strong>: <code>platform :ios, '13.0'</code>
- <strong>Izin Akses Perangkat Keras (Info.plist)</strong>: <code>NSCameraUsageDescription</code> untuk pemindaian foto makanan dan <code>NSPhotoLibraryUsageDescription</code> untuk impor citra dari galeri foto.
- <strong>Biometric Privacy</strong>: <code>NSFaceIDUsageDescription</code> untuk autentikasi cepat pengguna via Face ID.
- <strong>Linkage Framework</strong>: Konfigurasi <code>use_frameworks! :linkage => :static</code> untuk menjamin kestabilan integrasi framework TensorFlow Lite native.


## 2.5 Konfigurasi Multi-Flavor & Environment Config (.env)

Aplikasi menerapkan pemisahan variabel konfigurasi lingkungan melalui paket <code>flutter_dotenv</code>. Berkas rahasia lingkungan disimpan pada jalur <code>assets/env/.env</code> yang diabaikan oleh kontrol versi Git demi keamanan kredensial:

**Tabel 2.3: Variabel Konfigurasi Lingkungan Aplikasi (.env)**

| Nama Kunci Variabel | Tipe Data | Tujuan Penggunaan | Tingkat Kerahasiaan |
| --- | --- | --- | --- |
| SUPABASE_URL | String (HTTPS URL) | Endpoint REST API instans Supabase ap-southeast-1 | Publik / Client Safe |
| SUPABASE_ANON_KEY | String (JWT Token) | Anon Key dengan pembatasan RLS level baris basis data | Publik / Client Safe |
| FIREBASE_PROJECT_ID | String | Identitas proyek cloud Google Firebase | Publik / Client Safe |
| APP_ENVIRONMENT | String (Enum) | Penanda lingkungan eksekusi (development / staging / production) | Internal |


## 2.6 Konfigurasi Firebase CLI & Proyek Cloud

Inisialisasi Firebase dilakukan melalui toolchain resmi FlutterFire CLI yang menghasilkan berkas konfigurasi terikat tipe <code>lib/firebase_options.dart</code>. Konfigurasi native platform Android dihubungkan melalui berkas <code>android/app/google-services.json</code> yang memetakan bundle ID <code>com.oopsieeats.app</code> terhadap proyek Cloud Firestore di zona Jakarta (<code>asia-southeast2</code>).


## 2.7 Konfigurasi Supabase CLI & Bucket Storage

Instans Supabase Storage dikonfigurasi melalui dasbor manajemen proyek dengan spesifikasi wadah penyimpanan:

- <strong>Nama Bucket</strong>: <code>food-history-images</code>
- <strong>Visibilitas</strong>: Privat (Private Object Storage) — objek tidak dapat diakses melalui tautan publik langsung tanpa autentikasi.
- <strong>Ukuran Maksimum Berkas</strong>: 5 MB per berkas citra.
- <strong>MIME Types yang Diizinkan</strong>: <code>image/jpeg</code>, <code>image/png</code>, <code>image/webp</code>.
- <strong>Mekanisme Akses Unduh</strong>: Pembangkitan URL bertanda tangan (Signed URLs) dengan masa kedaluwarsa 3600 detik (1 jam) via <code>createSignedUrl()</code>.


## 2.8 Struktur Direktori Proyek (Clean Architecture & Modular)

Tata letak direktori proyek OopsieEats merefleksikan prinsip Clean Architecture dengan pemisahan keprihatinan yang tegas:

**Tabel 2.4: Peta Struktur Direktori dan Tanggung Jawab Modul**

| Jalur Direktori | Fokus Arsitektur | Deskripsi Tanggung Jawab & Berkas Kunci |
| --- | --- | --- |
| frontend/lib/core/ | Core & Shared | Konstanta aplikasi, utilitas tanggal/umur, helper kalkulator, dan token tema |
| frontend/lib/core/theme/ | Design System | Definisi token Neo-Brutalism (NeoColors, NeoTokens, AppTheme) |
| frontend/lib/data/models/ | Data Entities | Kelas transfer data JSON (User, MealRecord, FoodItem, CMSArticle) |
| frontend/lib/data/repositories/ | Data Access Layer | Abstraksi akses basis data (AuthRepo, MealRepo, FoodRepo, AdminRepo) |
| frontend/lib/data/services/ | External Gateways | Layanan teknis pihak ketiga (SupabaseStorageService, BiometricService) |
| frontend/lib/logic/providers/ | State Management | Pengelola status aplikasi berbasis ChangeNotifier (Auth, Dashboard, Scan, Profile) |
| frontend/lib/presentation/screens/ | UI Views | 19 layar aplikasi (Auth, Dashboard, Scanner, MealHistory, Profile, Admin) |
| frontend/lib/presentation/widgets/ | Reusable Widgets | Komponen Neo-Brutalism modular (NeoButton, NeoCard, NeoBottomNav) |
| frontend/assets/models/ | ML Artifacts | Bobot model on-device best.tflite (9.4 MB) & label pangan 29 kelas |
| frontend/test/ | Automated Tests | 359 unit, widget, dan security tests terdistribusi pada 42 berkas pengujian |

Keterkaitan arsitektur antara stasiun kerja pengembang, toolchain Flutter/Dart, dependensi platform Android/iOS, kredensial lokal, dan sistem cloud dipetakan secara formal pada Diagram Komponen UML berikut:


![Gambar 2.1: Diagram Komponen UML — Arsitektur Toolchain & Lingkungan Kompilasi Multi-Platform](docs/brd/diagrams/rendered/uml-build-toolchain.png)
*Gambar 2.1: Diagram Komponen UML — Arsitektur Toolchain & Lingkungan Kompilasi Multi-Platform*


## 2.9 Panduan Setup Developer Baru (Onboarding & Runbook)

Langkah onboarding mandiri untuk pengembang baru yang bergabung ke dalam repositori OopsieEats:

1. 1. Klon repositori lokal: <code>git clone https://github.com/oopsieeats/oopsieeats.git</code>
2. 2. Pindah ke direktori frontend: <code>cd frontend</code>
3. 3. Pasang seluruh dependensi: <code>flutter pub get</code>
4. 4. Salin template variabel lingkungan: <code>cp assets/env/.env.example assets/env/.env</code> dan isi kredensial pengujian
5. 5. Jalankan verifikasi integritas kode sumber: <code>flutter analyze</code> (harus menghasilkan 0 issues)
6. 6. Jalankan seluruh rangkaian uji otomatis: <code>flutter test</code> (harus 359 tests passed 100%)
7. 7. Jalankan aplikasi pada perangkat atau simulator: <code>flutter run</code>


## 2.10 Standar Kontribusi & Git Workflow

Seluruh komit pada repositori wajib mematuhi standar Conventional Commits (misal: <code>feat:</code>, <code>fix:</code>, <code>docs:</code>, <code>test:</code>, <code>refactor:</code>). Penggabungan kode ke cabang utama (<code>main</code>) mensyaratkan lulus uji otomatis CI (GitHub Actions) dan peninjauan kode minimal oleh 1 orang Senior Software Architect.
