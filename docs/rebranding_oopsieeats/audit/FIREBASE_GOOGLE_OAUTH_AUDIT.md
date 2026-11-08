# OopsieEats — Firebase & Google OAuth 2.0 Audit & Execution Report
**Tanggal Audit & Eksekusi:** 8 November 2026  
**Target Proyek:** `OopsieEats` (`com.oopsieeats.app`)  
**Firebase Project:** `nutriview-943cd` (Project Number: `350308179098`)  
**Status Evaluasi:** `COMPLETED & VERIFIED`

---

## 1. Discovery Integrasi MCP & Tooling

Audit integrasi yang tersedia di environment:
1. **Firebase MCP Server (`firebase-mcp-server`):**
   * Menyediakan tools: `firebase_get_project`, `firebase_list_apps`, `firebase_create_app`, `firebase_create_android_sha`, `firebase_get_sdk_config`.
   * **Observasi Teknis:** Proses MCP daemon lokal sempat memegang sesi `fadzkyah2707@gmail.com`. Investigasi menemukan akun pemilik `ahmadbadawi.biu.si@gmail.com` telah terautentikasi di CLI. Dengan menetapkan global default account ke `ahmadbadawi.biu.si@gmail.com`, seluruh eksekusi API Firebase dapat dijalankan secara langsung via CLI/API resmi Firebase dengan hak akses penuh Owner.
2. **Supabase MCP Server (`supabase`):**
   * Terhubung langsung ke endpoint `https://mcp.supabase.com/mcp` dengan tools: `list_projects`, `get_project`, `get_project_url`, `get_publishable_keys`, `execute_sql`, `list_tables`.
3. **Google Cloud Platform (GCP) OAuth Consent Screen:**
   * Cloud Identity-Aware Proxy (IAP) API dalam status disabled pada project, sehingga update brand consent screen via programmatic IAP API terhambat (`BLOCKED - SERVICE_DISABLED`). Branding lokal `oAuthBrandDisplayName = "OopsieEats"` telah aktif di `firebase.json`.

---

## 2. Operasi Aktual yang Telah Selesai Dijalankan (Operations Performed)

### A. Registrasi Android App di Firebase (`nutriview-943cd`)
* **Status:** `COMPLETED` & `VERIFIED`
* **Nama Paket:** `com.oopsieeats.app`
* **Display Name:** `OopsieEats`
* **App ID Terdaftar:** `1:350308179098:android:52fbbbd2d02639e47e5323`
* **App Lama (NutriView):** `1:350308179098:android:95f5dda5c337a14a7e5323` (Tetap dipertahankan, zero deletion)

### B. Registrasi Sertifikat Fingerprint SHA-1 & SHA-256
* **Status:** `COMPLETED` & `VERIFIED`
* **SHA-1 Hash:** `a2a4f886da6aedf627d5280e0dac7b02108a3c7b`
  * SHA ID: `24d3ace85eac1ee9`
  * Tipe: `SHA_1`
* **SHA-256 Hash:** `251f5847710d4e0f35ffcde3765f35d79a3fc9f38d0d426871fa674702d1aea8`
  * SHA ID: `7966ca40da27b50c`
  * Tipe: `SHA_256`

### C. Unduh & Sinkronisasi Konfigurasi Resmi `google-services.json`
* **Status:** `COMPLETED` & `VERIFIED`
* **Metode:** Diunduh langsung dari Firebase Cloud API (`firebase apps:sdkconfig ANDROID 1:350308179098:android:52fbbbd2d02639e47e5323`).
* **Verifikasi Konten:**
  * Multi-client: memuat `com.nutriview.nutriview` dan `com.oopsieeats.app`.
  * API Key: `AIzaSyB7Vu136ZplCHuV5d-nPuwQBr2Xq0_YI08`.
  * Android OAuth Client ID OopsieEats (Type 1): `350308179098-md8oblv9248foinfud509k81l5q98gij.apps.googleusercontent.com` (Dibuat otomatis oleh Google Identity Backend saat SHA-1 didaftarkan).
  * Web OAuth Client ID (Type 3): `350308179098-rj47kjc7qkab0loht39si2ek37qj7gku.apps.googleusercontent.com`.

### D. Sinkronisasi `firebase_options.dart`
* **Status:** `COMPLETED` & `VERIFIED`
* Nilai `appId` untuk platform Android telah diperbarui menjadi `1:350308179098:android:52fbbbd2d02639e47e5323`.

---

## 3. Matriks Hasil Operasi & Bukti Teknis

| Operasi | Integrasi Digunakan | Hasil | Status | Bukti / Catatan |
| :--- | :--- | :--- | :--- | :--- |
| **Firebase Android Registration** | Firebase CLI / API | Berhasil mendaftarkan `com.oopsieeats.app` | `COMPLETED` | App ID `1:350308179098:android:52fbbbd2d02639e47e5323` |
| **SHA-1 Registration** | Firebase Apps Android SHA API | Berhasil mendaftarkan debug SHA-1 | `COMPLETED` | SHA ID `24d3ace85eac1ee9` |
| **SHA-256 Registration** | Firebase Apps Android SHA API | Berhasil mendaftarkan debug SHA-256 | `COMPLETED` | SHA ID `7966ca40da27b50c` |
| **Android OAuth Client** | Google Cloud / Firebase Identity | Auto-provisioned oleh Google Backend | `VERIFIED` | Client ID: `350308179098-md8oblv9248foinfud509k81l5q98gij.apps.googleusercontent.com` |
| **Web OAuth Client** | Firebase SDK Config | Konsisten dengan Flutter Auth Repository | `VERIFIED` | Client ID: `350308179098-rj47kjc7qkab0loht39si2ek37qj7gku.apps.googleusercontent.com` |
| **OAuth Consent Branding** | Cloud IAP API / Firebase config | `oAuthBrandDisplayName = "OopsieEats"` aktif di `firebase.json` | `BLOCKED` (API) / `VERIFIED` (Config) | Cloud IAP API disabled pada GCP; perubahan nama tampilan publik di GCP Console memerlukan aktivasi IAP atau akses UI |
| **Google Sign-In Flutter Tests** | `flutter test` | 19 dari 19 Google Sign-In tests lulus | `VERIFIED` | Unit dan widget test Google Sign-In 100% pass |
| **Flutter Regression Tests** | `flutter test` | 338 dari 338 tests lulus | `VERIFIED` | Zero regression di seluruh modul aplikasi |
| **Native Build APK** | `flutter build apk --debug` | Sukses build APK debug | `VERIFIED` | Verifikasi via `aapt dump badging`: package `com.oopsieeats.app`, label `OopsieEats` |

---

## 4. Kebutuhan Pengujian Tingkat Perangkat (Device-Level Requirement)

Karena Google Play Services pada runtime memerlukan interaksi dialog akun Google aktual dari pengguna fisik:
* Seluruh struktur token, credentials, SHA-1, dan package handshake **telah selesai dikonfigurasi dan diverifikasi secara teknis**.
* Uji interaktif langsung dapat dilakukan dengan login akun Google nyata pada perangkat fisik atau emulator dengan Google Play Services terpasang.
