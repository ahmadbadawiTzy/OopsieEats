# OopsieEats — Post-Rebranding Security Audit Findings
**Tanggal Audit:** 8 November 2026  
**Auditor:** Mobile Application Security Specialist  
**Klasifikasi Risiko Keseluruhan:** **LOW / ACCEPTABLE**  
**Status Evaluasi:** `VERIFIED`

---

## 1. Ringkasan Temuan Keamanan

Audit keamanan dilakukan pasca-rebranding untuk memastikan tidak ada celah keamanan baru, kebocoran data, atau eskalasi privilege yang timbul akibat perubahan nama paket, namespace, dan kunci penyimpanan lokal.

---

## 2. Matriks Temuan Keamanan

| ID Temuan | Komponen | Deskripsi | Tingkat Risiko | Status Mitigasi |
| :--- | :--- | :--- | :--- | :--- |
| **SEC-01** | **Local Session Storage** | Migrasi kunci sesi dari `nutriview_*` ke `oopsieeats_*`. | `Rendah` | **DIMITIGASI:** Menggunakan `flutter_secure_storage` berbasis Android Keystore / EncryptedSharedPreferences. Tidak menyimpan token dalam plain text SharedPreferences. |
| **SEC-02** | **Session Flush on Logout** | Pembersihan data saat logout harus menghapus kunci lama dan baru. | `Rendah` | **DIMITIGASI:** Fungsi `clearToken()` dan `clearBiometricPreference()` menghapus seluruh key `oopsieeats_*` dan `nutriview_*`. |
| **SEC-03** | **Android Permissions** | Validasi izin aplikasi di `AndroidManifest.xml`. | `Informatif` | **TERVERIFIKASI:** Hanya meminta `INTERNET`, `CAMERA`, `USE_BIOMETRIC`, `USE_FINGERPRINT`, `ACCESS_NETWORK_STATE`. Tidak ada izin berbahaya seperti `READ_EXTERNAL_STORAGE`, `ACCESS_FINE_LOCATION`, atau `READ_CONTACTS`. |
| **SEC-04** | **Hardware Biometric Fallback** | Bypass autentikasi biometrik. | `Rendah` | **DIMITIGASI:** Biometrik terikat pada hash `UID` dan `email`. Jika ada pergantian user atau mismatch, aplikasi memaksa fallback ke input sandi manual. |
| **SEC-05** | **Hardcoded Secrets Hygiene** | Pencarian private keys atau service account secrets di source code. | `Nihil` | **TERVERIFIKASI:** Tidak ada service account key atau database password tersimpan di codebase. Hanya public config (`google-services.json` dan Supabase public anon key). |

---

## 3. Analisis Android Component Security

Berdasarkan inspeksi `aapt dump badging` pada APK hasil build:
* **Exported Activities:**
  * `MainActivity` adalah satu-satunya activity yang diekspor (`android:exported="true"`) dengan filter `MAIN` dan `LAUNCHER`. Ini sesuai dengan standar Android modern.
* **Custom Dynamic Receiver Permission:**
  * Izin receiver privat terdaftar dengan namespace baru: `com.oopsieeats.app.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`.
  * Komponen internal terproteksi dari akses aplikasi pihak ketiga di perangkat yang sama.

---

## 4. Kesimpulan Keamanan
Aplikasi OopsieEats berada dalam kondisi aman, mematuhi prinsip least privilege, dan siap untuk fase rilis publik dari perspektif keamanan mobile.
