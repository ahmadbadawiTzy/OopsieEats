# NUTRIVIEW — ROLE, PROFESSION, AND AUTHORIZATION SYSTEM AUDIT & REFACTOR REPORT

> **Dokumen Resmi:** Audit, Penyederhanaan, dan Refaktor Sistem Hak Akses & Pemisahan Profesi NutriView  
> **Status:** Production-Ready & Verified  
> **Tanggal:** 25 Oktober 2026  
> **Target Platform:** Flutter (Mobile/Web), Cloud Firestore (`nutriview-943cd`), Firebase Authentication  

---

## 1. Ringkasan Eksekutif

Audit menyeluruh terhadap sistem otorisasi, hak akses, dan model profil pengguna pada aplikasi NutriView telah selesai dilakukan. 

### Masalah Utama yang Ditemukan Sebelum Refactor:
1. **Pencampuran Konsep Profesi dan Hak Akses:** Terdapat role bernama `dietitian` yang didefinisikan sebagai *security role* di Firestore Rules dan filter UI Admin. Padahal, Ahli Gizi (*dietitian*) pada hakikatnya adalah **profesi/identitas sosial** pengguna, bukan tingkat izin sistem. Hal ini berpotensi membingungkan tata kelola hak akses dan membuka risiko eskalasi jika pengguna biasa mengklaim dirinya sebagai ahli gizi.
2. **Fragmentasi Role Parsial:** Terdapat role `editor` di aturan keamanan Firestore untuk pengelolaan artikel CMS, namun role tersebut tidak memiliki antarmuka khusus ataupun tombol filter di Admin Dashboard UI.
3. **Ketidakhadiran Role Standar `admin`:** Meskipun aplikasi menggunakan label visual dan rute `admin`, di layer database aturan keamanan Firestore justru hanya mengenali `super_admin`, `dietitian`, dan `editor`. Akun dengan role `admin` sebelumnya malah akan ditolak oleh *rules*.
4. **Ketiadaan Atribut Profesi di Profil Pengguna:** Model profil `UserProfile` belum memiliki field untuk menyimpan identitas pekerjaan/profesi pengguna secara independen dari hak otorisasi.

### Tindakan yang Diambil:
1. **Konsolidasi Security Role:** Menyederhanakan sistem menjadi 2 tingkatan utama yang terkontrol:
   - `user`: Pengguna akhir aplikasi mobile (hak akses minimal / *least privilege*).
   - `admin`: Pengelola sistem dan konten (katalog pangan, artikel edukasi, media assets, simulator Atwater).
   - `super_admin`: Administrator utama (pemilik sistem dengan hak eksklusif aktivasi/deaktivasi akun dan inspeksi log audit).
   - Seluruh role warisan (`dietitian`, `editor`) dipetakan dan dikonsolidasikan secara aman ke `admin` dengan jaminan *zero-breakage*.
2. **Pemisahan Total Profesi Sosial (`profession`):** Menambahkan field `profession` ke dalam `UserProfile` (`/users/{uid}.profile.profession`). Pemilihan profesi sosial (misal: *Ahli Gizi*, *Dokter*, *Mahasiswa*) tersimpan terpisah di objek profil dan **tidak pernah** memberikan hak akses ke Portal Admin ataupun data pengguna lain.
3. **Penyempurnaan Firestore Security Rules:** Merilis aturan Firestore baru yang mendukung hierarki `user`, `admin`, dan `super_admin`, mempertahankan *anti-privilege escalation* saat registrasi dan update profil, serta telah di-deploy langsung ke Firebase live (`nutriview-943cd`).
4. **Verifikasi Komprehensif:** 130 test cases lulus 100% dan analisis statis Dart menghasilkan 0 issues.

---

## 2. Tabel Lengkap Hasil Audit Role

| Role Awal | Lokasi Ditemukan | Fungsi Aktual | Masalah / Redundansi | Keputusan | Dipetakan Ke |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `user` | Model `User`, `firestore.rules`, `auth_repository.dart`, UI screens | Pengguna akhir aplikasi consumer NutriView (scan makanan, catat intake harian, hitung kalori, baca artikel) | Tidak ada masalah, ini adalah peran inti aplikasi. | **Pertahankan** | `user` |
| `super_admin` | `firestore.rules`, `admin_repository.dart`, `admin_dashboard_screen.dart` | Akses tingkat tertinggi (kelola aktivasi akun, audit logs, pangan, artikel, Atwater simulator) | Memiliki proteksi teknis valid (*last admin protection*, audit trail inspection). | **Pertahankan** | `super_admin` |
| `dietitian` | `firestore.rules` (fungsi `isDietitian`), `admin_repository.dart`, filter pills UI | Staf yang diizinkan mengedit katalog makanan (`/foods`) | Pencampuran konsep profesi medis dengan hak sistem. Tidak ada portal terpisah dari admin. | **Gabung & Pisahkan** | Security Role: `admin`. Identitas: `profession: 'Ahli Gizi'`. |
| `editor` | `firestore.rules` (fungsi `isEditor`), `admin_repository.dart` | Staf yang diizinkan mengedit artikel (`/cms_articles`) | Redundan. Tidak ada UI terpisah dan tidak ada filter di dashboard admin. | **Gabung** | Security Role: `admin`. |
| `admin` (sebelumnya hanya label) | Label UI, tombol header dashboard, argumen navigasi | Label visual dan rute admin, tetapi belum menjadi *first-class citizen* di `firestore.rules`. | Akun dengan role `admin` di Firestore sebelumnya tidak dikenali oleh helper `isStaff()`. | **Resmikan** | `admin` (First-Class Security Role). |

---

## 3. Desain Sistem Role yang Disederhanakan

Sistem otorisasi NutriView kini memiliki arsitektur hierarki 3 level yang tegas:

```
┌─────────────────────────────────────────────────────────────┐
│                       SUPER_ADMIN                           │
│  - Semua wewenang Admin                                     │
│  - Aktivasi / Nonaktifkan Akun Pengguna                     │
│  - Membaca Log Audit Sistem (/cms_audit_logs)               │
│  - Dilindungi dari Self-Lockout & Last Admin Protection     │
└──────────────────────────────┬──────────────────────────────┘
                               │ Mewarisi hak akses
┌──────────────────────────────▼──────────────────────────────┐
│                          ADMIN                              │
│  - Akses Portal Admin NutriView                             │
│  - Kelola Data Katalog Pangan (/foods)                      │
│  - Kelola Artikel & Kategori Edukasi (/cms_articles)        │
│  - Kelola Aset Media (/cms_media)                           │
│  - Melihat Ringkasan & Atwater Simulator                    │
│  - Melihat Daftar Pengguna (Read-only)                      │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                          USER                               │
│  - Akses Aplikasi Mobile NutriView                          │
│  - Scan Makanan (On-Device AI YOLO + Nutrition Engine)      │
│  - CRUD Data Intake / Meal Pribadi (/users/{uid}/meals)     │
│  - Kelola Profil & Biodata Fisik Pribadi                    │
│  - Membaca Katalog Pangan & Artikel Publik (Read-Only)      │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Pemisahan Tegas: Security Role vs Display Profession

Untuk mencegah kerancuan dan eksploitasi keamanan, arsitektur data membedakan secara ketat antara **Security Role** dan **Display Profession**:

| Dimensi | Security Role (`role`) | Display Profession (`profession`) |
| :--- | :--- | :--- |
| **Lokasi Penyimpanan** | Root dokumen `/users/{uid}.role` | Di dalam sub-objek `/users/{uid}.profile.profession` |
| **Tujuan** | Kontrol akses & otorisasi (*authorization boundary*) | Informasi sosial, persona, dan personalisasi konten edukasi |
| **Nilai yang Didukung** | `user`, `admin`, `super_admin` | `Umum`, `Ahli Gizi`, `Dokter`, `Mahasiswa`, `Software Developer`, `Atlet / Trainer`, `Guru / Dosen`, `Lainnya` |
| **Dampak Otorisasi** | Mengizinkan atau menolak pembukaan Portal Admin dan penulisan dokumen CMS | **NOL (Tidak ada hak akses admin sama sekali)** |
| **Hak Edit oleh Pengguna** | **DIBLOKIR TOTAL** oleh Firestore Security Rules | Boleh diubah bebas oleh pemilik akun di halaman Biodata |

### Jaminan Keamanan Anti-Eskalasi:
Pengguna yang memilih profesi `"Ahli Gizi"` atau `"Dokter"` tetap memiliki `role: 'user'`.
Evaluasi `authProvider.isAdmin` dan `firestore.rules` hanya mengevaluasi field `role`, sehingga pengguna berprofesi Ahli Gizi tidak akan pernah bisa mengakses rute admin, membaca data pengguna lain, ataupun mengubah konten CMS.

---

## 5. Analisis & Penguatan Keamanan Alur Akun

### Alur Registrasi (`AuthRepository.register`):
1. Payload pendaftaran akun baru secara mutlak menetapkan:
   ```dart
   'role': 'user',
   'is_active': true,
   ```
2. Parameter fungsi tidak mengekspos argumen `role`.
3. Aturan `firestore.rules` baris 48-50 memvalidasi secara database-level:
   ```firestore.rules
   allow create: if isSignedIn() && request.auth.uid == userId
                 && request.resource.data.role == 'user'
                 && request.resource.data.is_active == true;
   ```
   Upaya menyuntikkan payload `role: 'admin'` atau `role: 'super_admin'` dari klien akan langsung ditolak (`PERMISSION_DENIED`).

### Alur Update Profil & Biodata (`ProfileRepository.updateProfile` / `saveBiodata`):
1. Klien hanya mengirimkan payload field profil (`full_name`, `profile`, `daily_target`, dsb).
2. Aturan `firestore.rules` baris 53-58 memvalidasi:
   ```firestore.rules
   allow update: if isSignedIn() && (
     (request.auth.uid == userId
       && request.resource.data.role == resource.data.role
       && request.resource.data.is_active == resource.data.is_active)
     || isSuperAdmin()
   );
   ```
   Pengguna biasa **mustahil** mengubah nilai `role` miliknya sendiri. Jika klien mencoba mengubah `role`, aturan `request.resource.data.role == resource.data.role` akan bernilai `false` dan operasi dibatalkan seketika oleh database.

### Alur Aktivasi/Deaktivasi Pengguna (`AdminRepository.setUserStatus`):
1. **Otorisasi Super Admin:** Method memeriksa `callerRole == 'super_admin'`. Admin biasa ditolak dengan kode `FORBIDDEN (403)`.
2. **Proteksi Self-Lockout:** Administrator tidak dapat menonaktifkan akunnya sendiri (`SELF_LOCKOUT_FORBIDDEN`).
3. **Proteksi Super Admin Terakhir:** Sistem menghitung sisa super admin aktif. Jika tersisa 1 akun, penonaktifan diblokir (`LAST_ADMIN_PROTECTION`).

---

## 6. Daftar File yang Diubah

1. **`firestore.rules`**
   - Menambahkan helper `isAdmin()` yang mencakup `['super_admin', 'admin', 'dietitian', 'editor']`.
   - Menggantikan fungsi `isDietitian()`, `isEditor()`, dan `isStaff()` dengan `isAdmin()`.
   - Membatasi modifikasi status akun dan role hanya untuk `isSuperAdmin()`.
   - Di-deploy ke Firebase live project `nutriview-943cd`.
2. **`frontend/lib/data/models/profile.dart`**
   - Menambahkan field `final String profession` ke model `UserProfile`.
   - Menyediakan `predefinedProfessions` dan nilai default `'Umum'`.
   - Memperbarui serialization `fromJson`, `toJson`, dan `copyWith`.
3. **`frontend/lib/data/models/user.dart`**
   - Memperbarui getter `isAdmin` agar mendukung role `'admin'`.
   - Menambahkan getter `isSuperAdmin` (`role == 'super_admin'`).
4. **`frontend/lib/features/auth/providers/auth_provider.dart`**
   - Memperbarui getter `isAdmin` dan menambahkan `isSuperAdmin`.
5. **`frontend/lib/features/admin/data/admin_repository.dart`**
   - Memperbarui verifikasi login admin agar mendukung role `'admin'`.
   - Menempatkan pemeriksaan wewenang `callerRole == 'super_admin'` pada method `setUserStatus`.
   - Memperbarui filtering pengguna agar query `role == 'admin'` juga mencakup akun staf legacy.
6. **`frontend/lib/features/admin/presentation/screens/admin_dashboard_screen.dart`**
   - Mengubah pill filter dari `Dietitian` menjadi `Admin`.
   - Memperbarui icon dan badge role pengguna.
   - Menambahkan penjagaan `widget.adminRole == 'super_admin'` pada aksi pengubahan status akun pengguna.
7. **`frontend/lib/features/profile/screens/biodata_screen.dart`**
   - Menambahkan dropdown pilihan profesi dengan badge `PROFIL SOSIAL` dan teks penjelas bahwa profesi tidak mempengaruhi hak akses.
   - Menyimpan field `profession` ke dalam `UserProfile`.
8. **`frontend/lib/features/profile/screens/profile_screen.dart`**
   - Menampilkan badge terpisah: **Display Profession** (hijau/mint) dan **Security Role** (kuning/coral/putih) di bawah avatar.
9. **`scripts/migrate_to_firestore.py`**
   - Menyelaraskan seed pengguna agar menggunakan role `admin` dan profesi `Ahli Gizi` untuk akun demo gizi.
10. **`frontend/test/admin_dashboard_screen_test.dart`**
    - Memperbarui ekspektasi filter pill dari `Dietitian` ke `Admin`.
11. **`frontend/test/role_and_permission_test.dart`**
    - Suite pengujian baru yang menguji evaluasi role, pencegahan eskalasi hak istimewa, serialisasi profesi, dan otorisasi `setUserStatus`.

---

## 7. Firestore Security Rules Baru

Potongan aturan otorisasi utama yang telah aktif di Firebase Cloud Firestore:

```firestore.rules
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }

    function hasRole(roles) {
      return isSignedIn() &&
        exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
        getUserData().role in roles &&
        getUserData().is_active == true;
    }

    // High-Privilege Super Administrator
    function isSuperAdmin() {
      return hasRole(['super_admin']);
    }

    // System Administrator (mendukung role 'admin' & 'super_admin' serta legacy)
    function isAdmin() {
      return hasRole(['super_admin', 'admin', 'dietitian', 'editor']);
    }

    match /users/{userId} {
      allow read: if isSignedIn() && (request.auth.uid == userId || isAdmin());

      allow create: if isSignedIn() && request.auth.uid == userId
                    && request.resource.data.role == 'user'
                    && request.resource.data.is_active == true;

      allow update: if isSignedIn() && (
        (request.auth.uid == userId
          && request.resource.data.role == resource.data.role
          && request.resource.data.is_active == resource.data.is_active)
        || isSuperAdmin()
      );

      allow delete: if isOwner(userId) || isSuperAdmin();

      match /meals/{mealId} {
        allow read, write: if isOwner(userId);
      }
    }

    match /foods/{foodId} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }

    match /cms_articles/{articleId} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }

    match /cms_audit_logs/{logId} {
      allow read: if isSuperAdmin();
      allow create: if isAdmin() && request.resource.data.performed_by == request.auth.uid;
      allow update, delete: if false;
    }

    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 8. Strategi & Skrip Migrasi Data

Untuk memastikan akun pengguna dan staf yang sudah ada tidak terganggu:
1. **Fallback Nilai Default:** Model `UserProfile.fromJson` dan Firestore query secara otomatis memberikan nilai fallback `profession: 'Umum'` untuk semua dokumen pengguna yang belum memiliki field tersebut.
2. **Backward Compatibility Role Warisan:**
   - Aturan Firestore Security Rules dan kode aplikasi Flutter memperlakukan role lama `'dietitian'` dan `'editor'` setara dengan `'admin'`.
   - Tidak ada pengguna atau staf yang kehilangan akses ketika aturan baru diberlakukan.
3. **Skrip Migrasi Opsional:** Jika ingin melakukan normalisasi massal dokumen Firestore lama agar seragam:
   ```bash
   python3 scripts/migrate_to_firestore.py
   ```
   Skrip ini secara otomatis menetapkan role baru `admin` untuk staf dan `user` dengan atribut profesi masing-masing.

---

## 9. Hasil Pengujian & Verifikasi

### Eksekusi `flutter analyze`
```bash
flutter analyze
```
**Hasil:** `No issues found! (ran in 3.3s)` — 0 warnings, 0 errors.

### Eksekusi `dart format`
```bash
dart format --output=none --set-exit-if-changed lib test
```
**Hasil:** `Formatted 96 files (0 changed)` — Seluruh kode mengikuti standar konvensi Dart resmi.

### Eksekusi `flutter test`
```bash
flutter test
```
**Hasil:** **130/130 tests passed! (100% Pass Rate)**
Termasuk pengujian pada:
- `test/role_and_permission_test.dart` (Model roles, separation of profession, AuthProvider, AdminRepository guard).
- `test/admin_dashboard_screen_test.dart` (Admin UI, filter pills, audit log, Atwater simulator).
- `test/biodata_and_about_test.dart` (Form biodata, perhitungan umur, profile rendering).
- `test/design_system_standards_test.dart` (Design system tokens, iconography).
- `test/account_deletion_test.dart` (Otorisasi penghapusan akun multi-tenant).

---

## 10. Panduan Penetapan Role Admin

Demi keamanan, penetapan role `admin` atau `super_admin` **tidak pernah** dapat dilakukan melalui aplikasi client oleh pengguna biasa.

### Prosedur Resmi Promosi Akun Menjadi Admin:
1. Buka [Firebase Console](https://console.firebase.google.com/project/nutriview-943cd/firestore).
2. Masuk ke menu **Firestore Database** -> Koleksi `users`.
3. Cari dokumen pengguna berdasarkan UID atau email pengguna yang ingin dipromosikan.
4. Ubah nilai field `role`:
   - Ganti `'user'` menjadi `'admin'` untuk staf pengelola konten.
   - Ganti `'user'` menjadi `'super_admin'` untuk pemilik/pengelola sistem tingkat tinggi.
5. Simpan perubahan. Pengguna akan langsung memiliki akses administrator saat login kembali ke aplikasi.

---

## 11. Rekomendasi Lanjutan

1. **Audit Berkala Log Akses:** Memanfaatkan koleksi `cms_audit_logs` untuk meninjau secara berkala aktivitas penulisan artikel, perubahan katalog makanan, dan aktivasi akun.
2. **Firebase Custom Claims (Jangka Panjang):** Untuk aplikasi berskala enterprise, pertimbangkan untuk menyematkan `role` ke dalam Firebase Auth Custom Claims melalui Firebase Cloud Functions guna menghemat pembacaan dokumen Firestore (`getUserData()`).
3. **Rate Limiting Login Admin:** Tambahkan jeda waktu atau proteksi captcha jika terjadi kegagalan autentikasi berulang pada halaman login admin.

---

## 12. Kesimpulan

Sistem role, otorisasi, dan profesi pada proyek NutriView kini telah disederhanakan secara tuntas, aman, dan berstandar industri:
- Konsep **Security Role** (`user`, `admin`, `super_admin`) dan **Display Profession** (`profession`) telah terpisah 100%.
- Celah *privilege escalation* dari sisi registrasi maupun pembaruan profil tertutup rapat secara *multi-layer* (Client, Repository, dan Firestore Database Rules).
- Seluruh 130 pengujian otomatis lulus dengan sempurna dan aturan keamanan terbaru telah aktif di cloud.
- **Sistem otorisasi NutriView siap sepenuhnya untuk production deployment.**
