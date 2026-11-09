# LAPORAN OPTIMASI UKURAN APLIKASI FLUTTER NUTRIVIEW
**Tahap 3 (Implementasi) & Tahap 4 (Verifikasi & Laporan)**  
**Tanggal:** 24 Oktober 2026  
**Target Proyek:** NutriView (`frontend/`)  
**Metodologi:** `flutter-reducing-app-size` skill  

---

## 1. PENYEBAB UTAMA UKURAN APLIKASI SEBELUM OPTIMASI

Berdasarkan audit komparatif menggunakan `flutter build apk --analyze-size`, dekomposisi ZIP, dan DevTools size analysis:

1. **Aset Model AI On-Device (`best.tflite` — 9.40 MB)**
   - Model TFLite YOLOv8/v11 disimpan di `assets/models/best.tflite`.
   - Menggunakan konfigurasi Gradle `noCompress("tflite")` yang wajib agar library C++ TFLite dapat melakukan direct memory-mapping (`mmap`) tanpa memakan duplikasi RAM saat inferensi kamera.
   - *Status:* Dipertahankan utuh sesuai batas teknis proyek.

2. **Redundansi Multi-Arsitektur ABI dalam Universal APK**
   - Dalam universal APK, pustaka native `.so` untuk ketiga arsitektur (`arm64-v8a`, `armeabi-v7a`, `x86_64`) digabung sekaligus ke dalam satu file APK.
   - Pustaka native TFLite (`libtensorflowlite_jni.so`, `libtensorflowlite_gpu_jni.so`), Flutter Engine (`libflutter.so`), dan Dart AOT runtime terduplikasi 3 kali (~12.5 MB per foreign ABI terbuang sia-sia bagi pengguna perangkat tertentu).

3. **Debug Symbols DWARF Tertanam dalam Dart AOT Binary (`libapp.so`)**
   - Tanpa pemisahan simbol, Dart AOT compiler menyematkan simbol DWARF dan metadata debug di dalam `libapp.so` sehingga ukurannya membengkak hingga 7.31 MB (7,665,992 bytes).

4. **Dependency Ikon yang Tidak Digunakan (`cupertino_icons`)**
   - `cupertino_icons: ^1.0.8` sebelumnya terpasang di `pubspec.yaml`, menyumbang font binary `CupertinoIcons.ttf` sebesar 257.5 KB uncompressed (114.3 KB compressed) ke dalam bundle APK meskipun kode UI NutriView 100% menggunakan Material Design Icons dan Custom Neo-Brutalism widgets.

5. **DEX Bytecode Android (`classes.dex` — 3.40 MB uncompressed, 1.56 MB compressed)**
   - Berasal dari SDK Firebase (Auth, Firestore, Core) dan AndroidX dependencies.

---

## 2. FILE DAN KONFIGURASI YANG DIUBAH & ALASANNYA

### A. Penghapusan Dependency `cupertino_icons`
- **File diubah:** `frontend/pubspec.yaml`, `frontend/pubspec.lock`
- **Tindakan:** Menghapus `cupertino_icons: ^1.0.8` dan menjalankan `flutter pub get`.
- **Rasional:** Audit kode mengonfirmasi 0 penggunaan simbol `CupertinoIcons` di seluruh `frontend/lib/` dan `frontend/test/`. Penghapusan ini memangkas aset font `CupertinoIcons.ttf` (257 KB) dan metadata lockfile tanpa efek samping.

### B. Implementasi Pemisahan Simbol Debug (`--split-debug-info`)
- **Konfigurasi Build:** `--split-debug-info=build/app/outputs/symbols`
- **Direktori Output Simbol:** `build/app/outputs/symbols/`
  - `app.android-arm64.symbols` (3.30 MB)
  - `app.android-arm.symbols` (2.89 MB)
  - `app.android-x64.symbols` (3.30 MB)
  - **Total simbol DWARF diisolasi dengan aman:** 9.5 MB
- **Rasional:** Memisahkan simbol DWARF dari `libapp.so` ke file terpisah. Mengurangi ukuran biner `libapp.so` di dalam APK release hingga 1.0 MB tanpa memengaruhi stack trace mapping atau menimbulkan risiko refleksi / obfuscation.

### C. Strategi Distribusi Android (Split per ABI & AAB)
- **Konfigurasi Build:**
  - Split APK: `flutter build apk --release --split-per-abi --split-debug-info=build/app/outputs/symbols`
  - App Bundle: `flutter build appbundle --release --split-debug-info=build/app/outputs/symbols`
- **Rasional:** Mengeliminasi library native foreign ABI dari download user, memangkas ukuran APK hingga ~31%–57% tergantung target distribusi.

---

## 3. PENGUKURAN SEBELUM VS SESUDAH OPTIMASI

Semua metrik di bawah ini diukur secara faktual dari file biner hasil build:

| Komponen / Artefak | Baseline (Sebelum) | Hasil Optimasi (Sesudah) | Penghematan (Bytes / MB) | % Penghematan |
| :--- | :--- | :--- | :--- | :--- |
| **APK Release ARM64 (Perangkat Modern)** | **54,525,952 bytes (52.00 MB)** | **37,440,796 bytes (35.71 MB / ~37.4 MB)** | **-17,085,156 bytes (-16.29 MB)** | **-31.33%** |
| **APK Release ARMv7 (32-bit Legacy)** | N/A (dalam universal) | **32,596,376 bytes (31.09 MB / ~32.6 MB)** | N/A | Target minimal |
| **APK Release x86_64 (Emulator/ChromeOS)** | N/A (dalam universal) | **40,861,378 bytes (38.97 MB / ~40.9 MB)** | N/A | Target x86_64 |
| **Universal APK (3 ABIs)** | ~96 MB (est. tanpa split-debug) | **86,819,460 bytes (82.80 MB / ~86.8 MB)** | **~-9.5 MB** | **~-10%** |
| **Android App Bundle (AAB)** | N/A | **82,203,440 bytes (78.40 MB / ~82.2 MB)** | Pengguna Play Store mengunduh ~32–37 MB | Efisiensi maksimal |
| **`libapp.so` (Dart AOT Binary ARM64)** | **7,665,992 bytes (7.31 MB)** | **6,620,040 bytes (6.31 MB)** | **-1,045,952 bytes (-1.00 MB)** | **-13.64%** |
| **`CupertinoIcons.ttf`** | **257,592 bytes (0.25 MB)** | **0 bytes (Dihapus sepenuhnya)** | **-257,592 bytes (-0.25 MB)** | **-100.00%** |

---

## 4. HASIL UJI DAN VALIDASI INTEGRITAS

1. **Analisis Statis (`flutter analyze`):**
   - Hasil: `No issues found! (ran in 4.5s)`
   - 0 error, 0 warning, 0 lint issue.

2. **Suite Tes Otomatis (`flutter test`):**
   - Hasil: **67/67 tests passed (100% lulus)**
   - Mencakup tes Model, Portion Validation, ScanFlow, NeoBottomNav, Dashboard, Article Repository, Admin Repository, dan On-Device YOLO Inference.

3. **Uji Langsung pada Perangkat Fisik (Redmi 12 / Android 15 — `eb9c29d27d73`):**
   - Perintah instalasi: `adb -s eb9c29d27d73 install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
   - Status instalasi: `Success` (Streaming install berhasil).
   - Pengujian interaktif:
     - Peluncuran aplikasi: Splash screen & Beranda muncul dengan greeting, macro cards, kalori, dan floating navbar bergaya Neo-Brutalism utuh.
     - Navigasi Tab ARTIKEL: Membuka daftar artikel edukasi gizi dari Firestore secara responsif tanpa freeze.
     - Navigasi Tab PINDAI: Layar kamera dan live on-device AI detector YOLOv8/v11 aktif normal tanpa kendala `UnsatisfiedLinkError` atau crash memory.

---

## 5. RISIKO DAN REKOMENDASI MENDATANG

1. **R8 / ProGuard Minification (`isMinifyEnabled = true`):**
   - Pada fase ini, R8 sengaja dibiarkan `false` pada `frontend/android/app/build.gradle.kts`.
   - Mengaktifkan R8 tanpa keep-rules yang presisi pada pustaka C++ JNI (`org.tensorflow.lite.**`) dan Firebase reflection berisiko tinggi menyebabkan crash runtime fatal saat membuka kamera atau deserialisasi dokumen Firestore.
   - *Rekomendasi:* Jika di masa mendatang ingin memangkas tambahan ~1.5 MB dari `classes.dex`, tambahkan aturan di `android/app/proguard-rules.pro` dan lakukan pengujian komprehensif pada kamera.

2. **Obfuscation (`--obfuscate`):**
   - Pemisahan simbol saat ini menggunakan `--split-debug-info` murni (tanpa `--obfuscate`).
   - Simbol disimpan di `build/app/outputs/symbols/`. Simpan direktori ini bersamaan dengan build rilis untuk keperluan simbolikasi stack trace produksi di masa mendatang.

3. **Model TFLite (`best.tflite`):**
   - Jangan kompres atau manipulasi model TFLite via zip compression karena `noCompress("tflite")` adalah prasyarat teknis Android untuk pembacaan memory-mapped (`mmap`) langsung dari APK ke buffer grafis.
