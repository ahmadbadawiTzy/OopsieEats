# NutriView

Aplikasi mobile untuk **mengenali makanan secara offline dengan AI On-Device YOLO26n dan melacak asupan gizi harian berbasis Firebase**. Pengguna mengisi profil, sistem menghitung target gizi harian deterministik (Mifflin-St Jeor), lalu pengguna memotret makanan; model YOLO26n TensorFlow Lite berjalan secara lokal di perangkat mendeteksi objek makanan tanpa memerlukan koneksi internet, pengguna mengonfirmasi dan memasukkan porsi (gram), dan aplikasi menghitung nilai gizi presisi serta menyimpannya ke Cloud Firestore dengan persistensi offline penuh.

> Proyek NutriView. Hasil aplikasi bersifat **estimasi** dan **bukan saran medis**.

---

## 🌟 Arsitektur Modern: Serverless Edge AI + Firebase Spark Tier

Aplikasi NutriView telah dimigrasikan secara penuh ke **arsitektur modern Serverless + On-Device Edge ML**:

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        FLUTTER CLIENT APPLICATION                      │
│                                                                        │
│   ┌─────────────────────┐               ┌───────────────────────────┐  │
│   │ On-Device YOLO26n   │               │   Nutrition Calculator    │  │
│   │ TFLite [1,3,640,640]│               │   Mifflin-St Jeor +       │  │
│   │ (best.tflite 9.4MB) │               │   Atwater Validation      │  │
│   └──────────┬──────────┘               └─────────────┬─────────────┘  │
│              │                                        │                │
│              ▼                                        ▼                │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │        Data Repositories & Local Persistent Cache (Offline)     │  │
│   │  (FoodRepository, MealRepository, ProfileRepo, AdminRepo)       │  │
│   └────────────────────────────────┬────────────────────────────────┘  │
└────────────────────────────────────┼───────────────────────────────────┘
                                     │ Direct SDK Connection
                                     ▼ (Secure Rules & RBAC)
┌────────────────────────────────────────────────────────────────────────┐
│                        FIREBASE SERVICES (SPARK TIER)                  │
│                                                                        │
│   ┌──────────────────────┐  ┌─────────────────┐  ┌──────────────────┐  │
│   │ Firebase Auth        │  │ Cloud Firestore │  │ Firebase Storage │  │
│   │ (Email/Password,     │  │ (Multi-tenant   │  │ (CMS Media &     │  │
│   │  Session Cache)      │  │  Meals, Foods,  │  │  Assets, max 5MB)│  │
│   │                      │  │  CMS, Audit)    │  │                  │  │
│   └──────────────────────┘  └─────────────────┘  └──────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

### Keunggulan Arsitektur:
1. **100% On-Device AI:** Model YOLO26n (9.4 MB) dieksekusi langsung di CPU/GPU perangkat menggunakan `tflite_flutter`, tanpa latensi jaringan dan tanpa biaya server komputasi.
2. **Zero Cloud Server Costs (Spark Tier):** Bebas biaya server bulanan, VPS, FastAPI instance, atau Cloud Functions berbayar.
3. **Kerahasiaan & Keamanan Data:** Pengguna memiliki isolasi data multi-tenant di path `users/{uid}/meals/{mealId}` yang dijaga ketat oleh `firestore.rules` deklaratif.
4. **Desain Neubrutalism Konsisten:** Antarmuka bergaya Neubrutalism dengan palet warna berani, border hitam tegas, dan bayangan tajam tetap terjaga 100%.

---

## 📱 Alur Utama Aplikasi

```text
Registrasi/Login → Profil Pengguna → Target Gizi Harian (BMR & TDEE)
  → Kamera/Galeri → Deteksi On-Device YOLO26n (Zero Internet)
  → Konfirmasi Pengguna → Input Porsi (gram)
  → Snapshot Gizi Deterministik → Firestore Sync & Offline Cache
  → Dashboard Progres Harian Makronutrien
```

---

## 🛠️ Daftar Fitur & Status Integrasi

| Modul | Status | Keterangan |
|---|---|---|
| **Autentikasi** | ✅ Produksi | Firebase Auth + Session Caching + Role RBAC (`super_admin`, `dietitian`, `editor`, `user`) |
| **Kalkulator Gizi** | ✅ Produksi | Formula Mifflin-St Jeor deterministik, Atwater factor consistency checking |
| **On-Device Scanner** | ✅ Produksi | YOLO26n TFLite (Input `[1, 3, 640, 640]`, 29 kelas makanan khas Indonesia & global) |
| **Basis Data Makanan** | ✅ Produksi | Cloud Firestore `foods` dengan fallback offline instan `seed_foods.json` |
| **Pencatatan Makanan** | ✅ Produksi | Subkoleksi `users/{uid}/meals` dengan snapshot nilai gizi permanen (*immutable*) |
| **Dashboard Harian** | ✅ Produksi | Agregasi harian real-time dan persentase capaian energi serta makronutrien |
| **CMS Edukasi & Pengumuman** | ✅ Produksi | Artikel gizi, kategori, dan broadcast pengumuman sistem via Firestore |
| **Panel Admin Neubrutalism** | ✅ Produksi | Manajemen makanan, audit log, simulasi energi, dan proteksi deaktivasi akun admin |

---

## 🚀 Panduan Setup Firebase & Menjalankan Aplikasi

### Prasyarat
- Flutter SDK 3.x+ (Channel stable)
- OpenJDK 17 atau 21 / Android SDK (minSdk 23)

### 1. Menghubungkan ke Proyek Firebase Console Anda
Jika Anda menggunakan proyek Firebase baru di [Firebase Console](https://console.firebase.google.com):
1. **Buat Proyek:** Buka Firebase Console, klik **Add project**, beri nama (misal: `nutriview-app`).
2. **Aktifkan Authentication:**
   - Masuk ke menu **Build** > **Authentication** > klik **Get Started**.
   - Pada tab **Sign-in method**, pilih **Email/Password**, aktifkan toggle **Enable**, lalu klik **Save**.
3. **Aktifkan Cloud Firestore:**
   - Masuk ke menu **Build** > **Firestore Database** > klik **Create database**.
   - Pilih lokasi server terdekat (misal `asia-southeast2` Jakarta), mulai dalam mode produksi (*production mode*).
4. **Aktifkan Cloud Storage:**
   - Masuk ke menu **Build** > **Storage** > klik **Get Started**.
5. **Daftarkan Aplikasi Android di Firebase Console:**
   - Tambahkan aplikasi Android dengan Package Name: `com.nutriview.nutriview`.
   - Unduh berkas `google-services.json` dan letakkan di direktori:
     ```text
     frontend/android/app/google-services.json
     ```
   - Atau gunakan FlutterFire CLI di terminal:
     ```bash
     flutterfire configure
     ```

### 2. Cara Membuat Akun Admin Pertama (Bootstrap Super Admin)
Secara desain keamanan, Security Rules melarang pengguna aplikasi menetapkan `role: 'super_admin'` secara mandiri dari klien (*privilege escalation protection*). Untuk membuat admin pertama:

**Metode Rekomendasi (Melalui Firebase Console):**
1. Buka aplikasi NutriView dan lakukan pendaftaran akun Anda sendiri melalui layar **Daftar Akun** (atau buat akun langsung di **Firebase Console** > **Authentication** > **Add user**).
2. Di **Firebase Console** > **Authentication** > tab **Users**, salin **User UID** dari akun Anda (contoh: `abc123xyz456`).
3. Buka **Firebase Console** > **Firestore Database** > pilih koleksi `users` > buka dokumen dengan ID yang sesuai dengan UID Anda (`users/{UID}`).
4. Ubah nilai field:
   - `role`: `"super_admin"`
   - `is_active`: `true`
5. Selesai! Sekarang Anda dapat langsung masuk melalui layar login utama (`/login`) menggunakan email dan kata sandi tersebut. Sistem akan secara otomatis mengarahkan akun administrator ke **Panel Admin Neubrutalism**, dengan opsi berpindah ke mode pengguna kapan saja.

**Metode Skrip Otomatis (Menggunakan Service Account Admin):**
Jika Anda memiliki berkas service account private key:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
python scripts/migrate_to_firestore.py
```

### 3. Menjalankan Aplikasi Flutter
```bash
cd frontend
flutter pub get
flutter run
```

### 4. Menjalankan Pengujian Otomatis
```bash
cd frontend
flutter test
```
Seluruh 46 tes unit, widget, dan integrasi (meliputi inferensi model on-device, formula gizi Mifflin-St Jeor, Atwater, session caching, dan repositori) berjalan 100% lulus.

---

## 🔒 Aturan Keamanan (Security Rules)

- **Firestore (`firestore.rules`):**
  - Pengguna hanya memiliki hak baca dan tulis pada data profil dan rekam makannya sendiri (`users/$(request.auth.uid)`).
  - Koleksi `foods`, `cms_articles`, `cms_categories`, `cms_announcements` dapat dibaca publik.
  - Perubahan data katalog makanan dan CMS dibatasi untuk staf berwenang (`super_admin`, `dietitian`, `editor`).
  - Rekam jejak audit (`cms_audit_logs`) bersifat *append-only* dan tidak dapat diubah atau dihapus.
  - Perlindungan *self-lockout*: Super admin tidak dapat menonaktifkan akunnya sendiri atau super admin terakhir.
- **Storage (`storage.rules`):**
  - Ukuran unggahan dibatasi maksimal 5 MB.
  - Tipe berkas dibatasi pada citra yang valid (`image/jpeg`, `image/png`, `image/webp`).

---

## 📜 Lisensi & Atribusi

- **Model YOLO26n:** Dilatih untuk 29 kelas makanan Indonesia & internasional. Bobot TFLite terpasang di `frontend/assets/models/best.tflite`.
- **Data Nilai Gizi:** Tabel Komposisi Pangan Indonesia (TKPI 2020), Kementerian Kesehatan Republik Indonesia.
