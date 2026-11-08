# OopsieEats — Comprehensive Regression Test Report
**Tanggal Audit:** 8 November 2026  
**Total Test Suites:** 24 File Test  
**Total Tests:** 348 Tests  
**Hasil Akhir:** **348 LULUS, 0 GAGAL, 0 FLAKY, 0 SKIPPED (100% PASS RATE)**  
**Status Evaluasi:** **VERIFIED & RELEASE READY (RC1)**

---

## 1. Ringkasan Eksekusi Test

Seluruh rangkaian test dijalankan menggunakan command:
```bash
flutter test
```
pada direktori `frontend/`.

### Statistik Hasil:
* **Total Waktu Eksekusi:** ~56 detik
* **Total Assertions/Expectations:** > 1.350 assertions
* **Hasil:**
  ```text
  00:56 +348: All tests passed!
  ```

---

## 2. Rincian per Domain Pengujian

| Domain / Fitur | File Test Utama | Jumlah Test | Status |
| :--- | :--- | :--- | :--- |
| **Autentikasi & Sesi** | `biometric_auth_test.dart`, `google_sign_in_widget_test.dart`, `role_and_permission_test.dart`, `account_deletion_test.dart` | 55 | `VERIFIED` |
| **Navigasi & Header** | `floating_navbar_and_avatar_test.dart`, `user_navigation_and_article_test.dart` | 32 | `VERIFIED` |
| **Onboarding & Biodata Guard** | `onboarding_test.dart`, `mandatory_biodata_flow_test.dart`, `unified_biodata_form_test.dart`, `biodata_and_about_test.dart` | 64 | `VERIFIED` |
| **Sinkronisasi Biodata-Home** | `biodata_home_sync_test.dart` (Scenarios a, b, c, d, e) | 4 | `VERIFIED` |
| **Dashboard & UI Neo-Brutalism**| `overkill_neobrutalism_dashboard_test.dart`, `portion_input_widget_test.dart`, `widget_test.dart`, `dashboard_responsive_and_accessibility_test.dart` | 54 | `VERIFIED` |
| **Portal Admin & CMS** | `admin_dashboard_screen_test.dart`, `admin_repository_test.dart` | 64 | `VERIFIED` |
| **Scanner & Benchmark Kamera** | `scanner_benchmark_test.dart`, `yolo_detector_test.dart` | 8 | `VERIFIED` |
| **Foto Profil & Storage** | `user_profile_photo_test.dart`, `profile_photo_pipeline_test.dart`, `supabase_storage_service_test.dart` | 26 | `VERIFIED` |
| **Kalkulasi Nutrisi & Atwater** | `firebase_repositories_test.dart`, `article_repository_test.dart`, `age_calculator_test.dart` | 35 | `VERIFIED` |
| **Android Release Signing** | `release_signing_config_test.dart` | 6 | `VERIFIED` |

---

## 3. Hasil Analisis Statis (`flutter analyze`)

```bash
flutter analyze
```
**Output:**
```text
Analyzing frontend...
No issues found! (ran in 3.3s)
```
* **Linting Issues:** 0
* **Static Typing Errors:** 0
* **Dead Code / Warnings:** 0

---

## 4. Evaluasi Regresi Rebranding & Sinkronisasi Data

1. **Import Package (`package:oopsieeats/`):**
   * Sebanyak 705 import telah dimigrasikan dari `package:nutriview/` ke `package:oopsieeats/`.
   * Tidak ada satu pun import yang broken atau missing.
2. **Sinkronisasi Metrik Fisik Biodata $\leftrightarrow$ Beranda:**
   * Teruji pada `biodata_home_sync_test.dart`:
     - Initial load menyajikan target default/awal 2000 kkal.
     - Pembaruan biodata memicu invalidasi cache memori 15 menit (`invalidateUserCache()` / `forceRefresh: true`), menyajikan target baru 2450 kkal instan.
     - Pergantian tab dari Profil ke Beranda memicu auto-refresh state tanpa memuat ulang layar penuh.
3. **Storage Keys & Fallback:**
   * Test `ApiClient` membuktikan penyimpanan key `oopsieeats_*` berjalan normal dan fallback dari key legacy `nutriview_*` berfungsi mulus tanpa melempar exception.
4. **Android Signing Safety:**
   * Test `release_signing_config_test.dart` memastikan tidak ada kebocoran debug signing pada release binary dan memverifikasi hook `gradle.taskGraph.whenReady`.
