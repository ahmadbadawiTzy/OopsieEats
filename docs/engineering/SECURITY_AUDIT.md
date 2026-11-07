# SECURITY AUDIT & HARDENING REPORT — NUTRIVIEW

**Aplikasi**: NutriView — Food Nutrition Recognition & Daily Tracking  
**Package**: `com.nutriview.nutriview`  
**Tanggal Audit**: 7 November 2026  
**Auditor**: Senior Android Security Engineer & Firebase Security Auditor  
**Scope**: Flutter Client, Android Platform Configuration, Firebase Auth & Cloud Firestore Security Rules  

---

## 1. Executive Summary

Audit keamanan komprehensif ini dilakukan untuk mengidentifikasi, memitigasi, dan memverifikasi postur keamanan aplikasi **NutriView** sebelum rilis ke publik.

### Skor Keamanan Keseluruhan: **GRADE A (HARDENED PRODUCTION POSTURE)**
- **Critical Vulnerabilities**: 0 Ditemukan
- **High Severity Findings**: 2 Teridentifikasi & Telah Dimitigasi
- **Medium Severity Findings**: 1 Teridentifikasi & Telah Dimitigasi
- **Low / Informational**: 2 Dicatat dengan Rekomendasi Jelas

---

## 2. Temuan Berdasarkan Severity & Tindakan Perbaikan

| ID | Kategori | Tingkat Keparahan | Deskripsi Masalah | Dampak Potensial | Tindakan Perbaikan (Remediasi) | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **SEC-01** | Android Platform | **HIGH** | `android:allowBackup` tidak dideklarasikan pada `AndroidManifest.xml` (default bernilai `true`). | Penyerang dengan akses fisik/ADB dapat mengekstrak data aplikasi (`adb backup`) termasuk cache lokal dan database. | Ditambahkan `android:allowBackup="false"` pada tag `<application>` di `AndroidManifest.xml`. | **RESOLVED** |
| **SEC-02** | Network Security | **HIGH** | Tidak adanya konfigurasi Network Security formal Android untuk memblokir lalu lintas unencrypted HTTP. | Potensi serangan Man-in-the-Middle (MitM) jika terdapat third-party library atau WebView yang memanggil endpoint HTTP biasa. | Dibuat `res/xml/network_security_config.xml` dengan `cleartextTrafficPermitted="false"` dan diikat pada `AndroidManifest.xml`. | **RESOLVED** |
| **SEC-03** | Data Privacy | **MEDIUM** | Kurangnya transparansi in-app mengenai alur pemrosesan foto kamera oleh model Machine Learning. | Kesalahpahaman pengguna atau potensi penolakan review Google Play terkait izin `CAMERA`. | Ditambahkan Section *Privasi & Keamanan Data* pada `AboutScreen` yang menegaskan pemrosesan AI 100% lokal on-device. | **RESOLVED** |
| **SEC-04** | Cloud Firestore | **LOW** | Aturan `meals/{mealId}` mengizinkan penulisan tanpa validasi batas numerik kalori/makro di level database. | Integritas data rusak jika terjadi request manipulasi nilai numerik negatif atau tidak realistis. | Validasi komputasi gizi telah ditegakkan di client repository (`NutritionCalculator`). Direkomendasikan pengetatan skema di rules berikutnya. | **MONITORED** |
| **SEC-05** | Credential Storage | **INFO** | Kunci API Firebase tercantum di `firebase_options.dart` dan `google-services.json`. | Persepsi kebocoran kunci rahasia. | Terverifikasi bahwa Firebase Web/Android API Key hanyalah client identifier publik; otorisasi data 100% diamankan oleh Firestore Rules dan Firebase Auth. Disarankan pembatasan SHA-1 di Google Cloud Console. | **VERIFIED** |

---

## 3. Audit Keamanan Firebase & Cloud Firestore

### A. Evaluasi Firestore Security Rules (`firestore.rules`)
Aturan keamanan Firestore di NutriView telah diaudit menggunakan prinsip **Least Privilege** dan **Defense-in-Depth**:

1. **Autentikasi & Kepemilikan Dokumen**:
   ```javascript
   function isSignedIn() {
     return request.auth != null;
   }
   function isOwner(userId) {
     return isSignedIn() && request.auth.uid == userId;
   }
   ```
   - Setiap pengguna hanya dapat membaca dan menulis dokumen profil miliknya sendiri (`/users/{userId}`).
   - Akses antarpengguna (IDOR - Insecure Direct Object Reference) dicegah secara total.

2. **Isolasi Multi-Tenant Subcollection (`/users/{userId}/meals/{mealId}`)**:
   ```javascript
   match /meals/{mealId} {
     allow read, write: if isOwner(userId);
   }
   ```
   - Riwayat makanan harian tersimpan dalam subkoleksi privat yang terkunci secara kriptografis pada UID autentikasi pengguna. Pengguna lain tidak memiliki izin baca maupun tulis.

3. **Pencegahan Privilege Escalation (Anti-Self-Elevation)**:
   ```javascript
   // Pendaftaran awal: Pengguna biasa HANYA dapat mendaftar dengan role 'user'
   allow create: if isSignedIn() && request.auth.uid == userId
                 && request.resource.data.role == 'user'
                 && request.resource.data.is_active == true;

   // Pembaruan profil: Pengguna TIDAK BISA mengubah role atau status akun mereka
   allow update: if isSignedIn() && (
     (request.auth.uid == userId
       && request.resource.data.role == resource.data.role
       && request.resource.data.is_active == resource.data.is_active)
     || isAdmin()
   );
   ```
   - Mencegah serangan di mana pengguna biasa mencoba mengirim payload `role: 'admin'` untuk membobol hak istimewa sistem.

4. **Katalog Publik vs Modifikasi Terbatas**:
   - Koleksi `/foods`, `/cms_articles`, `/cms_categories`, `/cms_announcements`, dan `/cms_media` dapat dibaca oleh publik (`allow read: if true;`) guna mendukung katalog nutrisi dan artikel edukasi, tetapi hak modifikasi (`create, update, delete`) **eksklusif hanya untuk Admin aktif**.

5. **Audit Trail Immutability (`/cms_audit_logs/{logId}`)**:
   - Hanya Admin yang dapat melihat log audit.
   - Admin hanya dapat mencatat aksi miliknya sendiri (`performed_by == request.auth.uid`).
   - Log audit bersifat **immutable** (tidak dapat diubah atau dihapus: `allow update, delete: if false;`).

6. **Default Deny**:
   ```javascript
   match /{document=**} {
     allow read, write: if false;
   }
   ```
   - Menjamin koleksi atau path yang tidak didefinisikan secara eksplisit akan otomatis ditolak aksesnya.

---

## 4. Audit Keamanan Flutter & Android Client

### A. Penyimpanan Kredensial & Manajemen Sesi
- **Mekanisme**: Digunakan `FlutterSecureStorage` pada `ApiClient` (`frontend/lib/data/api_client.dart`).
- **Implementasi Native Android**: Menggunakan Android Keystore System yang mengenkripsi data menggunakan kunci hardware (MasterKey / AES-256 GCM) melalui `EncryptedSharedPreferences`.
- **Data yang Diamankan**:
  - `nutriview_access_token`
  - `nutriview_user_role`
  - `nutriview_user_email`
  - Kredensial biometrik (`nutriview_biometric_uid`, `nutriview_biometric_user_email`).
- **Pembersihan Sesi**:
  - Metode `clearToken()` menghapus seluruh token dan sesi saat pengguna memilih logout atau token kedaluwarsa (HTTP 401).

### B. Proteksi Android Platform & Manifest
1. **Pencegahan Data Backup Leaks**:
   - `android:allowBackup="false"` mencegah pencadangan aplikasi melalui USB debugging/ADB.
2. **Penegakan Enkripsi Jaringan**:
   - `network_security_config.xml` mewajibkan komunikasi HTTPS dan mempercayai CA sertifikat sistem resmi.
3. **Komponen Android yang Diekspos (Exported Components)**:
   - Satu-satunya komponen berstatus `android:exported="true"` adalah `MainActivity` dengan `intent-filter` `MAIN` dan `LAUNCHER`.
   - Tidak ada BroadcastReceiver, Service, atau ContentProvider eksternal yang terbuka tanpa izin.
4. **Verifikasi Izin (Permission Scrutiny)**:
   - Aplikasi tidak meminta izin penyimpanan luas (`MANAGE_EXTERNAL_STORAGE` atau `READ_EXTERNAL_STORAGE`).
   - Izin kamera diberi flag `android:required="false"` untuk fleksibilitas perangkat.

### C. Keamanan Pemrosesan AI / YOLO26n
- **Zero Cloud Upload**: Gambar makanan yang dipindai kamera atau galeri tidak pernah dikirimkan melalui HTTP/API ke server pihak ketiga manapun.
- **Isolate Sandbox**: Pemrosesan gambar (decode, orientasi, resize) dijalankan dalam background isolate `Isolate.run()` di memori perangkat, sehingga meminimalkan risiko eksploitasi buffer parsing di thread UI utama.
- **Resource Cleanup**: Model interpreter ditutup secara aman saat tidak lagi digunakan (`detector.close()`), mencegah dangling native pointers.

---

## 5. Rekomendasi Pasca-Rilis & Penguatan Lanjutan

1. **Google Cloud Console API Key Restrictions**:
   - Pada Google Cloud Console project `nutriview-943cd`, batasi Android API Key agar hanya dapat dipanggil oleh package `com.nutriview.nutriview` dengan SHA-1 fingerprint signing key resmi (Release Keystore & Play App Signing Key).
2. **Firebase App Check**:
   - Mengaktifkan Firebase App Check dengan provider Play Integrity di masa mendatang untuk memverifikasi bahwa hanya binary resmi dari Play Store yang dapat mengakses layanan backend Firestore.
3. **Continuous Dependency Scanning**:
   - Menjalankan audit dependensi berkala melalui `flutter pub outdated` untuk memantau package yang telah usang.

---

## 6. Kesimpulan Keamanan

NutriView telah memenuhi standar keamanan aplikasi mobile kelas produksi (*production-grade mobile security*). Tidak terdapat kerentanan kritis atau celah arsitektural yang membahayakan privasi dan data pengguna.
