# NutriView — Arsitektur Basis Data & Layanan Backend

Dokumen ini mendokumentasikan spesifikasi teknis dan implementasi aktual basis data serta layanan backend pada aplikasi **NutriView: Food Nutrition Recognition & Daily Tracking App**.

---

## 1. Topologi Layanan Cloud Backend

NutriView beroperasi menggunakan platform **Google Firebase** pada paket **Spark Plan (Bebas Biaya $0)** secara murni tanpa ketergantungan pada server pihak ketiga.

### Layanan yang Aktif Digunakan:
1. **Firebase Authentication**: Mengelola identitas pengguna, login via Email/Password, pendaftaran akun baru, pemulihan kata sandi, dan integrasi Google Sign-In (OAuth 2.0).
2. **Cloud Firestore**: Basis data dokumen NoSQL fleksibel dengan dukungan *real-time listener*, indeks komposit, serta *offline caching* otomatis.
3. **Firebase Local Emulators**: Emulator pengujian lokal untuk Authentication (port 9099), Firestore (port 8080), dan Emulator Suite UI (port 4000).

### Status Layanan yang TIDAK Digunakan (Klarifikasi Faktual):
- **Firebase Cloud Storage**: **TIDAK DIGUNAKAN**. Seluruh aset media artikel CMS dikelola melalui URL gambar eksternal (HTTPS) yang disimpan di koleksi `cms_media`. Avatar profil pengguna digambar secara prosedural oleh Flutter (`AvatarCatalog`) tanpa unggahan berkas foto ke server.
- **Cloud Functions for Firebase**: **TIDAK DIGUNAKAN**. Seluruh logika bisnis dan kalkulasi gizi dieksekusi secara terdistribusi di sisi klien (*edge compute*).
- **Firebase Analytics / Crashlytics**: **TIDAK DIGUNAKAN**. Kebutuhan pemantauan riwayat sistem ditangani melalui koleksi audit internal `cms_audit_logs`.

---

## 2. Struktur Koleksi & Skema Dokumen Firestore

Cloud Firestore pada NutriView menggunakan struktur berorientasi dokumen dengan pemisahan ketat antara data privat pengguna dan data master publik.

### 2.1. Koleksi `users/{userId}` (Profil & Pengaturan Akun)
Menyimpan identitas akun, peran sistem, status aktivasi, serta data fisik pengguna.

```json
{
  "id": 182746281,
  "uid": "ABcdEFGhij1234567890",
  "email": "user@example.com",
  "full_name": "Ahmad Badawi",
  "role": "user",
  "is_active": true,
  "avatar_preset": "chef_pro",
  "photo_url": null,
  "created_at": "2026-10-24T10:00:00.000Z",
  "updated_at": "2026-10-25T14:30:00.000Z",
  "profile": {
    "age": 22,
    "sex": "male",
    "weight_kg": 68.5,
    "height_cm": 175.0,
    "activity_level": "moderate",
    "goal": "maintain_weight",
    "profession": "Mahasiswa",
    "birth_date": "2004-05-15"
  },
  "daily_target": {
    "calories_kcal": 2450,
    "protein_g": 82.2,
    "carbs_g": 345.5,
    "fat_g": 68.1,
    "basis": {
      "bmr_kcal": 1683.8,
      "tdee_kcal": 2610.0,
      "formula": "mifflin_st_jeor"
    }
  }
}
```

### 2.2. Subkoleksi `users/{userId}/meals/{mealId}` (Catatan Asupan Makan)
Menyimpan riwayat konsumsi makanan harian pengguna. Berada di bawah subkoleksi dokumen pengguna untuk isolasi data multi-tenant yang aman.

```json
{
  "id": 1729845600000,
  "meal_type": "breakfast",
  "consumed_at": "2026-10-25T07:30:00.000Z",
  "consumed_date": "2026-10-25",
  "created_at": "2026-10-25T07:32:15.000Z",
  "items": [
    {
      "id": 1,
      "food_id": 14,
      "food_name": "Nasi Putih",
      "portion_grams": 150.0,
      "calories_kcal": 262.5,
      "protein_g": 4.5,
      "carbs_g": 59.7,
      "fat_g": 0.45,
      "source": "TKPI 2020",
      "detection_confidence": 0.9412
    },
    {
      "id": 2,
      "food_id": 25,
      "food_name": "Telur Goreng",
      "portion_grams": 60.0,
      "calories_kcal": 144.0,
      "protein_g": 8.4,
      "carbs_g": 0.6,
      "fat_g": 11.4,
      "source": "TKPI 2020",
      "detection_confidence": 0.8850
    }
  ],
  "totals": {
    "calories_kcal": 406.5,
    "protein_g": 12.9,
    "carbs_g": 60.3,
    "fat_g": 11.9
  }
}
```

### 2.3. Koleksi `foods/{foodId}` (Katalog Master Pangan)
Katalog acuan gizi 29 makanan khas Indonesia yang dapat dibaca oleh seluruh pengguna publik dan hanya dapat dimodifikasi oleh administrator.

```json
{
  "id": 13,
  "name": "Nasi Goreng",
  "yolo_class": "Nasi Goreng",
  "is_active": true,
  "calories_kcal_per_100g": 168.0,
  "protein_g_per_100g": 4.5,
  "carbs_g_per_100g": 22.0,
  "fat_g_per_100g": 6.8,
  "source": "TKPI 2020",
  "has_nutrition_data": true,
  "created_at": "2026-10-24T00:00:00.000Z"
}
```

### 2.4. Koleksi Konten & CMS
1. **`cms_articles/{articleId}`**: Artikel edukasi pola makan sehat (`title`, `slug`, `status: "published"`, `cover_image_url`, `author_name`, `category_id`, `excerpt`, `content`, `published_at`).
2. **`cms_categories/{categoryId}`**: Kategori artikel (`name`, `slug`, `icon`).
3. **`cms_announcements/{announcementId}`**: Pengumuman berkala aplikasi (`title`, `message`, `is_active`).
4. **`cms_media/{mediaId}`**: Entri metadata berkas media dan URL web gambar publik (`filename`, `url`, `file_size`, `created_at`).

### 2.5. Koleksi `cms_audit_logs/{logId}` (Log Audit Tak Terubah)
Menyimpan jejak aktivitas pengelolaan admin. Didesain **bersifat permanen (*immutable*)**; aturan keamanan secara ketat memblokir operasi update dan delete.

```json
{
  "id": 1729851234000,
  "user_id": 9823412,
  "user_email": "admin@nutriview.id",
  "performed_by": "AdmInUid1234567890",
  "action": "update",
  "entity_type": "food",
  "entity_id": "13",
  "details": "Updated calories for Nasi Goreng to 168.0",
  "created_at": "2026-10-25T09:15:00.000Z"
}
```

---

## 3. Aturan Keamanan Database (`firestore.rules`)

Aturan keamanan mengimplementasikan prinsip keamanan *least privilege*, *defense in depth*, dan pencegahan eskalasi hak akses (*anti-privilege escalation*).

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }

    // Strict 2-Role System: only 'admin' and 'user'
    function isAdmin() {
      return isSignedIn() &&
        exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
        getUserData().role == 'admin' &&
        getUserData().is_active == true;
    }

    // --- Users & Profiles ---
    match /users/{userId} {
      // User dapat membaca datanya sendiri; Admin dapat mengaudit semua akun
      allow read: if isSignedIn() && (request.auth.uid == userId || isAdmin());

      // Registrasi: Pengguna hanya boleh mendaftar sebagai role 'user' & aktif
      allow create: if isSignedIn() && request.auth.uid == userId
                    && request.resource.data.role == 'user'
                    && request.resource.data.is_active == true;

      // Update profil: Pengguna dilarang menaikkan role atau mematikan status aktifnya sendiri
      allow update: if isSignedIn() && (
        (request.auth.uid == userId
          && request.resource.data.role == resource.data.role
          && request.resource.data.is_active == resource.data.is_active)
        || isAdmin()
      );

      allow delete: if isOwner(userId) || isAdmin();

      // Subkoleksi Catatan Makan (Isolasi Multi-tenant Ketat)
      match /meals/{mealId} {
        allow read, write: if isOwner(userId);
      }
    }

    // --- Foods Catalog (Publik Baca, Modifikasi Khusus Admin) ---
    match /foods/{foodId} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }

    // --- CMS Articles, Categories, Announcements, Media ---
    match /cms_articles/{articleId} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }
    match /cms_categories/{categoryId} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }
    match /cms_announcements/{announcementId} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }
    match /cms_media/{mediaId} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }

    // --- CMS Audit Logs (Hanya Admin yang dapat membaca & mencatat; DILARANG UBAH/HAPUS) ---
    match /cms_audit_logs/{logId} {
      allow read: if isAdmin();
      allow create: if isAdmin() && request.resource.data.performed_by == request.auth.uid;
      allow update, delete: if false; // Immutable!
    }

    // Default Deny
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 4. Indeks Komposit Basis Data (`firestore.indexes.json`)

Untuk mendukung kueri analitik dan penyaringan data secara efisien tanpa *table scan*, indeks komposit berikut didefinisikan:

| Koleksi | Field Path | Urutan Pengurutan | Tujuan Kueri |
|---|---|---|---|
| `meals` | `consumed_date` (ASC), `consumed_at` (DESC) | Mendukung filter riwayat makan per rentang tanggal terurut waktu makan |
| `cms_articles` | `status` (ASC), `created_at` (DESC) | Menampilkan artikel terbitan terbaru di dashboard pengguna |
| `cms_articles` | `category_id` (ASC), `status` (ASC), `created_at` (DESC) | Menyaring artikel terbitan berdasarkan kategori pilihan |
| `foods` | `is_active` (ASC), `name` (ASC) | Menampilkan katalog makanan aktif terurut abjad pada modal pencarian |

---

## 5. Mekanisme Ketahanan & Caching Offline (Offline Resilience)

Aplikasi NutriView dirancang untuk tetap berfungsi saat perangkat kehilangan koneksi internet:

1. **Firestore Bounded Persistence**:
   - Dikonfigurasi pada `frontend/lib/main.dart`:
     ```dart
     FirebaseFirestore.instance.settings = const Settings(
       persistenceEnabled: true,
       cacheSizeBytes: 104857600, // 100 MB
     );
     ```
   - Membatasi footprint disk dan RAM agar tidak terjadi memory leak atau pembengkakan penyimpanan lokal.
2. **Fallback Katalog Pangan Lokal**:
   - Jika Cloud Firestore tidak dapat dihubungi saat pencarian atau pencocokan deteksi YOLO, `FoodRepository` secara otomatis membaca berkas `frontend/assets/data/seed_foods.json`.
3. **Penyimpanan Sesi Kredensial Terenkripsi**:
   - `ApiClient` membungkus pustaka `FlutterSecureStorage` (menggunakan KeyStore pada Android dan Keychain pada iOS) untuk menyimpan UID pengguna, role, status *remember me*, dan preferensi biometrik.
