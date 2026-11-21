# Panduan Build Rilis Android App Bundle (`.aab`) — NutriView (`OopsieEats`)

Dokumen ini menjelaskan langkah-langkah terstandarisasi untuk membangun, memvalidasi, dan memelihara artifact rilis produksi **OopsieEats (`com.oopsieeats.app`)**.

---

## 1. Prasyarat Lingkungan Build

Pastikan lingkungan pengembangan lokal atau CI memiliki:
- **Flutter SDK:** `>= 3.47.0` (teruji pada `3.47.8` stable)
- **Java Development Kit (JDK):** Versi 17 (`JavaVersion.VERSION_17`)
- **Android SDK:**
  - `platforms;android-36`
  - `build-tools;36.0.0`
  - `ndk;28.2.13676358`
- **Konfigurasi Keystore Produksi:**
  - File `frontend/android/key.properties` (tidak pernah di-commit ke Git)
  - File upload keystore `.jks` yang dirujuk oleh `storeFile` di dalam `key.properties`

### Format `frontend/android/key.properties`
```properties
storePassword=<password-keystore-anda>
keyPassword=<password-key-anda>
keyAlias=oopsieeats_upload
storeFile=app/oopsieeats-upload-keystore.jks
```

> **Peringatan Keamanan:** Sistem build pada `frontend/android/app/build.gradle.kts` menerapkan mekanisme *fail-fast* (`gradle.taskGraph.whenReady`). Apabila `key.properties` atau file `.jks` tidak ditemukan atau kosong, proses build rilis akan langsung dihentikan dan **tidak akan pernah** melakukan *fallback* ke *debug signing key*.

---

## 2. Perintah Build Release AAB Standar Produksi

Jalankan perintah berikut dari direktori `frontend/` untuk membangun Android App Bundle (`.aab`) dengan obfuskasi kode Dart/R8 serta pemisahan simbol debug (*split debug info*):

```bash
cd frontend
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release --obfuscate --split-debug-info=../symbols/android
```

Atau jalankan langsung skrip validasi satu pintu dari root repositori:

```bash
./scripts/validate_release.sh
```

Apabila artifact `.aab` sudah selesai dibangun dan Anda hanya ingin memvalidasi cepat tanpa mengulang kompilasi:

```bash
./scripts/validate_release.sh --skip-build --skip-tests
```

---

## 3. Lokasi Output Artifact & Simbol Debug

Setelah proses build selesai, pastikan ketiga artefak berikut diarsipkan untuk setiap versi rilis (`versionCode`):

| Artefak | Lokasi File | Kegunaan |
| :--- | :--- | :--- |
| **Release App Bundle (`.aab`)** | `frontend/build/app/outputs/bundle/release/app-release.aab` | File utama yang diunggah ke Google Play Console (Internal / Closed / Production Track). |
| **R8 / ProGuard Mapping** | `frontend/build/app/outputs/mapping/release/mapping.txt` | Diunggah ke Google Play Console (*App bundle explorer → Downloads → Reobfuscation file*) untuk mendekode stack trace Java/Kotlin yang terobfuskasi. (Juga otomatis dibundel di dalam `BUNDLE-METADATA/com.android.tools.build.obfuscation/proguard.map`). |
| **Native Debug Symbols** | Bundel otomatis di dalam `app-release.aab` pada `BUNDLE-METADATA/com.android.tools.build.debugsymbols/` | Digunakan oleh Google Play Console untuk mendekode crash native C/C++. |
| **Dart Split Debug Symbols** | `symbols/android/app.android-arm64.symbols`<br>`symbols/android/app.android-arm.symbols`<br>`symbols/android/app.android-x64.symbols` | Disimpan oleh developer untuk mendekode stack trace Dart yang terobfuskasi menggunakan perintah `flutter symbolize -i <stack_trace_file> -d symbols/android/app.android-arm64.symbols`. |

---

## 4. Aturan Menaikkan Versi (`versionName` & `versionCode`)

Google Play Console menolak unggahan `.aab` jika `versionCode` sama atau lebih rendah dari `.aab` yang pernah diunggah sebelumnya pada track mana pun.

Untuk setiap rilis baru:
1. Buka `frontend/pubspec.yaml` dan perbarui baris `version:`:
   ```yaml
   # Format: <major>.<minor>.<patch>+<versionCode>
   version: 1.0.1+2003
   ```
2. Selaraskan konstanta `CreatorConfig.appVersion` di `frontend/lib/core/config/creator_config.dart`:
   ```dart
   static const String appVersion = '1.0.1+2003';
   ```
3. Jalankan `./scripts/validate_release.sh` untuk membangun ulang dan memverifikasi artifact baru.

---

## 5. Verifikasi Manual Tanda Tangan & Alignment 16 KB

Untuk memverifikasi tanda tangan kriptografi `.aab`:
```bash
jarsigner -verify -verbose -certs frontend/build/app/outputs/bundle/release/app-release.aab | grep -E "Signed by|jar verified" | sort -u
```

Untuk memeriksa alignment segmen ELF `LOAD` 16 KB pada pustaka native di dalam `.aab`:
```bash
TMP_DIR=$(mktemp -d)
unzip -q frontend/build/app/outputs/bundle/release/app-release.aab "base/lib/arm64-v8a/*.so" -d "$TMP_DIR"
for so in "$TMP_DIR"/base/lib/arm64-v8a/*.so; do
  echo "=== $(basename "$so") ==="
  readelf -l "$so" | grep -E "LOAD" -A 1
done
rm -rf "$TMP_DIR"
```
Pastikan kolom terakhir (Align) pada setiap segmen `LOAD` bernilai `0x4000` (16 KB) atau `0x10000` (64 KB).
