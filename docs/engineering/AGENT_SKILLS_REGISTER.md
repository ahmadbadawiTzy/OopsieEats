# AGENT SKILLS REGISTER — NUTRIVIEW PRODUCTION READINESS

Dokumen ini mencatat seluruh Agent Skills yang ditemukan, dievaluasi, dan diinstal ke dalam workspace NutriView (`.agents/skills/`) untuk mendukung inisiatif kesiapan rilis Google Play Store, rekayasa performa, audit kepatuhan, dan pengerasan keamanan.

---

## 1. Metodologi Penemuan dan Evaluasi Skill

Pencarian dilakukan menggunakan ekosistem terbuka **Skills CLI (`npx skills find`)** dari Vercel Labs, official Flutter plugin ecosystem, Google/Android developer ecosystem, dan security researchers bereputasi (Trail of Bits, Snyk, Affaan).

### Kriteria Evaluasi:
- **Reputasi Publisher**: Pengembang resmi atau kontributor terverifikasi di komunitas AI Agent & Mobile Engineering.
- **Popularitas & Instalasi**: Diutamakan skill dengan adopsi luas dan rekam jejak pengujian stabil.
- **Aktivitas Pemeliharaan**: Mendukung spesifikasi standar Agent Skill (SKILL.md, prompts, automations).
- **Kesesuaian Arsitektur**: Kompatibel dengan Flutter 3.x, Dart 3.x, Android SDK 34+, Firebase v3, dan TensorFlow Lite (TFLite) on-device inference.
- **Keamanan Instruksi**: Dinilai aman oleh audit pemindaian Gen, Socket, dan Snyk (zero malicious behaviors).

---

## 2. Register Skill yang Terinstal

### A. Rekayasa Performa & Optimasi Ukuran (Performance & Size Engineering)

#### 1. `flutter-performance`
- **Sumber**: `thienqo/flutter-skills@flutter-performance`
- **Kategori**: Flutter Performance Optimization
- **Alasan Pemilihan**: Memberikan panduan sistematis untuk mendiagnosis unnecessary widget rebuilds, mengoptimasi render pipeline, offloading komputasi ke background isolates, serta optimasi memory allocation pada Flutter.
- **Fungsi Utama**:
  - Deteksi dan eliminasi jank pada frame rendering (60/120 FPS).
  - Profiling widget rebuild tree dan lifecycle optimasi.
  - Memori management pada caching gambar dan resource allocation.
- **Cara Penggunaan**:
  Diaktifkan saat fase audit UI/isolate di `lib/ui/`, `lib/features/`, dan pipeline feed gambar.

#### 2. `flutter-reducing-app-size`
- **Sumber**: Local Agent Skills (`.agents/skills/flutter-reducing-app-size`)
- **Kategori**: Build & Asset Optimization
- **Alasan Pemilihan**: Fokus pada reduksi ukuran binary Flutter (AAB/APK), analisis asset bloat, font stripping, dan konfigurasi R8 / ProGuard.
- **Fungsi Utama**:
  - Audit asset images, fonts, dan model TFLite (`assets/models/`).
  - Analisis bundle output via `flutter build appbundle --analyze-size`.
- **Cara Penggunaan**:
  Dijalankan bersama profiling build release untuk memastikan target ukuran unduhan Play Store seminimal mungkin tanpa menurunkan kualitas asset/model.

---

### B. Keamanan & Pengerasan Kode (Security Hardening & Code Review)

#### 3. `flutter-security`
- **Sumber**: `thienqo/flutter-skills@flutter-security`
- **Kategori**: Mobile App Security
- **Alasan Pemilihan**: Khusus dirancang untuk mengaudit postur keamanan aplikasi mobile Flutter (secure storage, root/jailbreak consideration, network security config, code obfuscation, dan leakage detection).
- **Fungsi Utama**:
  - Audit logging dan sanitasi data sensitif di console release.
  - Verifikasi Network Security Config (HTTPS enforcement, cleartext traffic prohibition).
  - Evaluasi penyimpanan kredensial lokal (SharedPreferences vs FlutterSecureStorage).
- **Cara Penggunaan**:
  Dipadukan pada audit kode `lib/core/` dan verifikasi `AndroidManifest.xml`.

#### 4. `firebase-apk-scanner`
- **Sumber**: `trailofbits/skills@firebase-apk-scanner` (Trail of Bits)
- **Kategori**: Firebase Security Assessment
- **Alasan Pemilihan**: Dibuat oleh firma audit keamanan ternama Trail of Bits untuk memeriksa potensi salah konfigurasi Firebase pada binary Android.
- **Fungsi Utama**:
  - Memverifikasi kebocoran konfigurasi berisiko tinggi.
  - Memastikan konfigurasi `google-services.json` dan client initialization tidak mengekspos privilege berbahaya ke publik.
- **Cara Penggunaan**:
  Digunakan pada tahap audit Firebase credentials dan integrasi Android release.

#### 5. `firebase-security-rules-auditor` & `firestore-rules-creation`
- **Sumber**: Local Agent Skills (`.agents/skills/firebase-security-rules-auditor`, `firestore-rules-creation`)
- **Kategori**: Cloud Firestore Rules Auditing & Hardening
- **Alasan Pemilihan**: Memastikan aturan Firestore mematuhi prinsip least privilege, validasi skema dokumen, pencegahan privilege escalation, dan autentikasi eksplisit.
- **Fungsi Utama**:
  - Audit `firestore.rules` untuk pencegahan bypass rules antarpengguna.
  - Validasi kepemilikan dokumen pengguna (`request.auth.uid == userId`).
- **Cara Penggunaan**:
  Digunakan dalam evaluasi dan pengetatan `firestore.rules`.

#### 6. `flutter-dart-code-review`
- **Sumber**: `affaan-m/ecc@flutter-dart-code-review` (11K+ installs)
- **Kategori**: Code Quality & Static Analysis
- **Alasan Pemilihan**: Meninjau clean code patterns, asynchronous bugs, unhandled exceptions, resource leaks (misal controller stream unclosed), dan best practices Dart 3.
- **Fungsi Utama**:
  - Mendeteksi memory leak dari `TextEditingController`, `AnimationController`, `StreamSubscription`.
  - Evaluasi pattern matching, null safety robustness, dan immutability.
- **Cara Penggunaan**:
  Digunakan saat meninjau dan merefaktor source code `lib/`.

---

### C. Kesiapan Distribusi Google Play (Google Play Release Readiness)

#### 7. `pre-launch-checklist`
- **Sumber**: Local Agent Skills (`.agents/skills/pre-launch-checklist`)
- **Kategori**: Production Release & Store Compliance
- **Alasan Pemilihan**: Mengadopsi metodologi peluncuran komprehensif Flutter oleh Andrea Bizzotto, mencakup code quality, environment separation, error tracking, compliance, privacy, dan asset checklist.
- **Fungsi Utama**:
  - Audit kesiapan rilis Google Play (Target SDK 34/35, Min SDK, permissions).
  - Audit metadata, Data Safety, Privacy Policy URL, dan Account Deletion requirement.
- **Cara Penggunaan**:
  Menjadi kerangka kerja utama pada Phase 3 (Google Play Readiness Audit).

#### 8. `flutter-build-release`
- **Sumber**: `thienqo/flutter-skills@flutter-build-release`
- **Kategori**: Release Build Pipeline
- **Alasan Pemilihan**: Memberikan panduan presisi dalam membangun Android App Bundle (`.aab`), ProGuard/R8 shrinking, keystore signing configuration, dan split architecture.
- **Fungsi Utama**:
  - Konfigurasi Gradle release signing aman (`key.properties`).
  - Verifikasi R8 rules untuk library native (TFLite / YOLO) agar symbols tidak ter-strip secara salah.
- **Cara Penggunaan**:
  Diterapkan saat memvalidasi build release Android di `android/app/build.gradle`.

---

### D. Testing & Quality Assurance

#### 9. `dart-run-static-analysis`, `dart-add-unit-test`, `flutter-add-widget-test`
- **Sumber**: Local Agent Skills (`.agents/skills/`)
- **Kategori**: Automated Testing & Static Code Analysis
- **Alasan Pemilihan**: Menjamin zero regressions melalui `flutter analyze` dan suite pengujian unit/widget yang komprehensif.
- **Fungsi Utama**:
  - Eksekusi linter Dart tanpa peringatan atau error.
  - Pembuatan dan eksekusi test runner untuk domain logic, model parsing, dan widget rendering.
- **Cara Penggunaan**:
  Dijalankan pada Phase 2 (Baseline) dan Phase 6 (Testing & Verification).

---

## 3. Ringkasan Status

Seluruh skill di atas telah terverifikasi, terpasang di direktori `.agents/skills/` NutriView, dan siap dipanggil sesuai tahapan workflow inisiatif kesiapan produksi.
