# Engineering Specification — NutriView

> Dokumen ini adalah **sumber kebenaran rekayasa dan arsitektur**. Kebutuhan produk ada di `prd.md`. Dokumen ini ditujukan bagi pengembang dan **AI coding agent**. Kata **WAJIB** / **DILARANG** bersifat mengikat; **SEBAIKNYA** bersifat anjuran.

---

## 1. Engineering Principles

1. **Sederhana dahulu.** Pilih implementasi paling sederhana yang dapat dipelihara. Proyek ini skala perkuliahan.
2. **Cakupan dikunci oleh `prd.md`.** Jangan membangun fitur di luar MVP.
3. **Pemisahan tanggung jawab.** Flutter = tampilan; FastAPI = logika bisnis; MySQL = penyimpanan; YOLO26n = deteksi saja.
4. **Deterministik.** Target gizi dan perhitungan gizi tidak bergantung pada ML dan menghasilkan keluaran yang sama untuk masukan yang sama.
5. **Aman secara default.** Validasi semua input, kredensial di environment, tidak membocorkan detail internal.
6. **Tanpa kompleksitas tak perlu.** Tidak ada infrastruktur, framework, pola desain, atau dependensi baru tanpa justifikasi tertulis.
7. **Dapat diuji.** Logika inti berupa fungsi murni sedapat mungkin.
8. **Manusia tetap dalam alur.** Prediksi YOLO26n hanyalah saran; pengguna yang memutuskan.

## 2. Architecture Overview

Arsitektur: **modular monolith**. Satu proses backend FastAPI berisi modul terpisah; satu basis data MySQL; model YOLO26n dimuat di dalam proses backend.

```text
┌──────────────────────┐
│      Flutter App     │
│      Mobile Client   │
└──────────┬───────────┘
           │  HTTPS / REST (JSON, multipart untuk gambar)
           ▼
┌──────────────────────────────────────────┐
│                 FastAPI                  │
│  ┌────────┐ ┌─────────┐ ┌─────────────┐  │
│  │  Auth  │ │ Profile │ │  Nutrition  │  │
│  │        │ │         │ │  Calculator │  │
│  └────────┘ └─────────┘ └─────────────┘  │
│  ┌──────────────┐  ┌──────────────────┐  │
│  │ Food Scanner │  │  Meal Tracking   │  │
│  │  └─ YOLO26n │  │  + Dashboard     │  │
│  └──────────────┘  └──────────────────┘  │
└────────────────────┬─────────────────────┘
                     ▼
              ┌─────────────┐
              │    MySQL    │
              └─────────────┘
```

**Aliran data utama**

```text
Foto → POST /foods/detect → validasi file → YOLO26n → pemetaan kelas→foods → daftar deteksi
     → (pengguna konfirmasi + porsi gram)
     → POST /meals → nutrition_service menghitung → simpan meal_records + meal_items
     → GET /dashboard/daily → agregasi konsumsi vs target
```

**Batas modul (WAJIB dipatuhi)**

| Modul | Boleh bergantung pada | DILARANG bergantung pada |
|---|---|---|
| `nutrition_service` (target & gizi) | `schemas`, pustaka standar | `app.ml`, FastAPI, akses DB langsung |
| `scanner_service` | `app.ml`, `food_service` | `nutrition_service` |
| `app.ml.detector` | Ultralytics, Pillow, `core.config` | `services`, `db`, `models` |
| `meal_service` | `nutrition_service`, `food_service`, `db` | `app.ml` |
| `api/*` (router) | `services`, `schemas`, `core` | `db` langsung, logika bisnis |

## 3. Architecture Decisions

| ID | Keputusan | Alasan |
|---|---|---|
| AD-01 | Modular monolith | Cukup untuk MVP; mudah dijalankan dan dipelajari |
| AD-02 | YOLO26n dijalankan di dalam proses FastAPI, model dimuat sekali saat startup | Menghindari layanan terpisah; inferensi cepat |
| AD-03 | Endpoint deteksi ditulis sebagai `def` sinkron (bukan `async def`) agar berjalan di threadpool FastAPI | Inferensi CPU-bound tidak boleh memblokir event loop |
| AD-04 | Autentikasi JWT (HS256) berumur pendek + tabel `revoked_tokens` untuk logout | Logout sungguhan tanpa Redis |
| AD-05 | Gizi per 100 g disimpan di `food_nutrition`; nilai per item di-snapshot ke `meal_items` | Riwayat tidak berubah bila data gizi dikoreksi |
| AD-06 | Total gizi didenormalisasi di `meal_records` (dihitung saat simpan) | Dashboard dan riwayat cepat; konsistensi dijaga oleh layanan dan tes |
| AD-07 | Porsi hanya dalam gram | Sesuai cakupan MVP |
| AD-08 | Foto tidak disimpan | Privasi dan kesederhanaan |
| AD-09 | Kolom `consumed_date` (tanggal lokal klien) di `meal_records` | Batas hari benar tanpa logika zona waktu kompleks di server |
| AD-10 | State management Flutter: `provider` (ChangeNotifier) | Ringan; tanpa kompleksitas Bloc/Riverpod |
| AD-11 | SQLAlchemy 2.x + Alembic | ORM/parameterized query dan migrasi skema yang dapat diulang |
| AD-12 | Tidak ada rate limiter/cache pada MVP | Membutuhkan infrastruktur tambahan; dicatat sebagai keterbatasan |

## 4. Technology Stack

| Lapisan | Teknologi | Catatan |
|---|---|---|
| Mobile | Flutter (stable), Dart (null safety) | Android sebagai target utama |
| Backend | Python 3.11+, FastAPI, Uvicorn | |
| Validasi | Pydantic v2, pydantic-settings | |
| ORM & migrasi | SQLAlchemy 2.x, Alembic, PyMySQL | |
| Basis data | MySQL 8.x (InnoDB, `utf8mb4`) | |
| CV | Ultralytics (YOLO26n), Pillow | Pelatihan di Google Colab/`ml/` |
| Keamanan | `argon2-cffi` (hash), `PyJWT` (token) | |
| Upload | `python-multipart` | |
| Pengujian backend | pytest, httpx (TestClient) | |
| Lint/format Python | ruff | |
| Paket Flutter | `provider`, `http`, `image_picker`, `flutter_secure_storage` | |
| Pengujian Flutter | `flutter_test`, `integration_test`, `mocktail` | |

Dependensi di luar tabel ini memerlukan justifikasi tertulis pada deskripsi PR (lihat §22).

**DILARANG** pada MVP: microservices, Kubernetes, Redis, Kafka, Celery, message queue, vector database, LangChain, chatbot berbasis LLM, OR-Tools, model rekomendasi Food.com, sistem terdistribusi, arsitektur event-driven.

## 5. Repository Structure

```text
nutriview/
├── README.md
├── .gitignore
├── docs/
│   ├── prd.md
│   └── ai.md
├── backend/
│   ├── app/
│   │   ├── main.py                  # pembuatan app, lifespan (muat model), router, handler error
│   │   ├── api/
│   │   │   ├── deps.py              # dependency: sesi DB, current_user
│   │   │   └── v1/
│   │   │       ├── router.py
│   │   │       ├── auth.py
│   │   │       ├── users.py
│   │   │       ├── nutrition.py
│   │   │       ├── foods.py         # daftar makanan + POST /foods/detect
│   │   │       ├── meals.py
│   │   │       └── dashboard.py
│   │   ├── core/
│   │   │   ├── config.py            # Settings dari environment
│   │   │   ├── security.py          # hash kata sandi, buat/verifikasi JWT
│   │   │   ├── errors.py            # AppError + exception handlers
│   │   │   └── logging.py
│   │   ├── db/
│   │   │   ├── base.py
│   │   │   ├── session.py
│   │   │   └── seed/                # foods.csv (diisi manual dari TKPI) + skrip seed
│   │   ├── models/                  # model SQLAlchemy
│   │   ├── schemas/                 # skema Pydantic (request/response)
│   │   ├── services/
│   │   │   ├── auth_service.py
│   │   │   ├── profile_service.py
│   │   │   ├── nutrition_service.py # fungsi murni: target & gizi
│   │   │   ├── food_service.py
│   │   │   ├── scanner_service.py   # validasi hasil YOLO26n → foods
│   │   │   ├── meal_service.py
│   │   │   └── dashboard_service.py
│   │   └── ml/
│   │       ├── detector.py          # pembungkus YOLO26n (satu-satunya tempat mengimpor ultralytics)
│   │       └── weights/             # best.pt (TIDAK di-commit)
│   ├── alembic/  + alembic.ini
│   ├── tests/
│   │   ├── unit/                    # nutrition_service, security, validasi
│   │   └── integration/             # endpoint + MySQL uji
│   ├── requirements.txt
│   └── .env.example
├── frontend/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/                    # konfigurasi, tema, routing, penanganan error
│   │   ├── data/                    # api_client, model DTO, repository
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── profile/
│   │   │   ├── scanner/             # foto, konfirmasi, input porsi
│   │   │   ├── meals/
│   │   │   └── dashboard/
│   │   └── shared/widgets/
│   ├── test/
│   └── integration_test/
└── ml/
    ├── README.md                    # dataset, cara melatih, cara evaluasi, keterbatasan
    ├── classes.yaml                 # daftar kelas YOLO26n yang didukung (sumber tunggal)
    └── notebooks/                   # notebook Colab
```

Aturan: jangan menambah folder tingkat atas baru. Dataset citra dan bobot model besar **tidak** di-commit.

## 6. Frontend Architecture

**Prinsip**

- Struktur *feature-first*; setiap fitur memiliki `screens/`, `providers/`, dan (bila perlu) `widgets/`.
- Lapisan: **Widget (UI)** → **Provider (state)** → **Repository** → **ApiClient (HTTP)**.
- Widget **DILARANG** memanggil HTTP langsung, mengakses MySQL, atau memuat logika bisnis (termasuk perhitungan gizi/target). UI hanya menampilkan data dari API.
- Widget dipecah menjadi komponen kecil; hindari `build()` panjang (> ~150 baris → pecah).
- Navigasi memakai `Navigator` bawaan dengan named routes (tanpa paket routing tambahan).
- Base URL API dari `--dart-define=API_BASE_URL=...`. Tidak ada rahasia di kode Dart.
- Token disimpan di `flutter_secure_storage`. `ApiClient` menambahkan header `Authorization: Bearer <token>`; jika menerima 401, sesi dihapus dan pengguna diarahkan ke login.
- Status UI eksplisit: `loading`, `success`, `error`, `empty`.
- Gambar sebelum diunggah dikompres/diubah ukurannya secara wajar oleh `image_picker` (mis. sisi terpanjang ≤ 1280 px, kualitas JPEG ≈ 85) agar ≤ 5 MB.

**Alur scanner (state di `ScanFlowProvider`)**

```text
ScannerScreen (kamera/galeri)
   → DetectionConfirmationScreen (pertahankan/hapus/ganti/tambah manual)
   → PortionInputScreen (gram per item + jenis makan)
   → submit POST /meals → MealResultScreen (menampilkan gizi hasil server)
```

Layar konfirmasi menampilkan penanda "perlu dicek" bila `low_confidence = true`, dan pesan fallback bila `detections` kosong. Jenis makan default (saran UI berdasarkan jam) dapat diubah pengguna. Aplikasi menampilkan pernyataan bahwa hasil merupakan estimasi dan bukan saran medis.

## 7. Backend Architecture

**Lapisan**

| Lapisan | Tanggung jawab | Aturan |
|---|---|---|
| `api/` (router) | Parsing request, memanggil service, membentuk response | Tipis; tanpa logika bisnis; `response_model` selalu ditetapkan |
| `schemas/` | Kontrak request/response (Pydantic) | Tidak sama dengan model ORM |
| `services/` | Logika bisnis, transaksi | Kelas/fungsi kecil dan fokus; melempar `AppError` |
| `models/` | Definisi tabel SQLAlchemy | Tanpa logika bisnis |
| `db/` | Sesi, base, seed | Sesi via dependency per-request |
| `ml/` | Pembungkus YOLO26n | Terisolasi dari gizi dan DB |
| `core/` | Konfigurasi, keamanan, error, logging | |

**Aturan implementasi**

- Endpoint yang menjalankan YOLO26n memakai `def` (AD-03). Endpoint I/O DB biasa boleh `def` sinkron (SQLAlchemy sinkron) — jangan mencampur sesi sinkron di dalam `async def`.
- Detektor dimuat sekali di `lifespan` dan disimpan di `app.state`. Jika bobot tidak ditemukan, aplikasi tetap berjalan; endpoint deteksi mengembalikan 503 `MODEL_UNAVAILABLE`, endpoint lain tetap berfungsi.
- Transaksi: pembuatan `meal_records` + `meal_items` dilakukan dalam satu transaksi (semua-atau-tidak-sama-sekali).
- Semua endpoint di bawah prefiks `/api/v1`.
- Dokumentasi OpenAPI otomatis (`/docs`) harus akurat; skema response ditetapkan eksplisit.

## 8. Database Architecture

MySQL 8, InnoDB, `utf8mb4`, zona waktu penyimpanan **UTC**. Semua perubahan skema melalui migrasi Alembic.

### 8.1 Relasi

```text
users 1───1 profiles
users 1───* meal_records 1───* meal_items *───1 foods 1───1 food_nutrition
users 1───* revoked_tokens (logis via jti; tanpa FK)
```

### 8.2 Tabel

**`users`**

| Kolom | Tipe | Null | Keterangan |
|---|---|---|---|
| id | BIGINT UNSIGNED AUTO_INCREMENT | NOT NULL | PK |
| email | VARCHAR(255) | NOT NULL | UNIQUE; disimpan lowercase |
| password_hash | VARCHAR(255) | NOT NULL | Argon2 |
| full_name | VARCHAR(100) | NOT NULL | |
| created_at | DATETIME | NOT NULL | default UTC now |
| updated_at | DATETIME | NOT NULL | update otomatis |

**`profiles`**

| Kolom | Tipe | Null | Keterangan |
|---|---|---|---|
| id | BIGINT UNSIGNED AUTO_INCREMENT | NOT NULL | PK |
| user_id | BIGINT UNSIGNED | NOT NULL | FK → users.id, UNIQUE, ON DELETE CASCADE |
| age | TINYINT UNSIGNED | NOT NULL | CHECK 15–100 |
| sex | ENUM('male','female') | NOT NULL | |
| weight_kg | DECIMAL(5,2) | NOT NULL | CHECK 20–300 |
| height_cm | DECIMAL(5,2) | NOT NULL | CHECK 100–250 |
| activity_level | ENUM('sedentary','light','moderate','active','very_active') | NOT NULL | |
| goal | ENUM('lose_weight','maintain_weight','gain_weight') | NOT NULL | |
| created_at, updated_at | DATETIME | NOT NULL | |

**`foods`**

| Kolom | Tipe | Null | Keterangan |
|---|---|---|---|
| id | INT UNSIGNED AUTO_INCREMENT | NOT NULL | PK |
| name | VARCHAR(100) | NOT NULL | UNIQUE; nama tampilan (mis. "Nasi putih") |
| yolo_class | VARCHAR(100) | NULL | UNIQUE; nama kelas YOLO26n; NULL = hanya input manual |
| is_active | BOOLEAN | NOT NULL | default TRUE |
| created_at | DATETIME | NOT NULL | |

Indeks: UNIQUE(name), UNIQUE(yolo_class), INDEX(is_active).

**`food_nutrition`** (satu baris per makanan; nilai per 100 g)

| Kolom | Tipe | Null | Keterangan |
|---|---|---|---|
| food_id | INT UNSIGNED | NOT NULL | PK dan FK → foods.id, ON DELETE CASCADE |
| calories_kcal | DECIMAL(7,2) | NOT NULL | CHECK ≥ 0 |
| protein_g | DECIMAL(7,2) | NOT NULL | CHECK ≥ 0 |
| carbs_g | DECIMAL(7,2) | NOT NULL | CHECK ≥ 0 |
| fat_g | DECIMAL(7,2) | NOT NULL | CHECK ≥ 0 |
| source | VARCHAR(255) | NOT NULL | Mis. "TKPI 2020, kode ..." |
| updated_at | DATETIME | NOT NULL | |

**`meal_records`**

| Kolom | Tipe | Null | Keterangan |
|---|---|---|---|
| id | BIGINT UNSIGNED AUTO_INCREMENT | NOT NULL | PK |
| user_id | BIGINT UNSIGNED | NOT NULL | FK → users.id, ON DELETE CASCADE |
| meal_type | ENUM('breakfast','lunch','dinner','snack') | NOT NULL | |
| consumed_at | DATETIME | NOT NULL | UTC |
| consumed_date | DATE | NOT NULL | Tanggal lokal klien (dari offset pada `consumed_at`) |
| total_calories_kcal | DECIMAL(8,2) | NOT NULL | Jumlah item |
| total_protein_g | DECIMAL(8,2) | NOT NULL | |
| total_carbs_g | DECIMAL(8,2) | NOT NULL | |
| total_fat_g | DECIMAL(8,2) | NOT NULL | |
| created_at | DATETIME | NOT NULL | |

Indeks: INDEX(user_id, consumed_date), INDEX(user_id, consumed_at).

**`meal_items`**

| Kolom | Tipe | Null | Keterangan |
|---|---|---|---|
| id | BIGINT UNSIGNED AUTO_INCREMENT | NOT NULL | PK |
| meal_id | BIGINT UNSIGNED | NOT NULL | FK → meal_records.id, ON DELETE CASCADE |
| food_id | INT UNSIGNED | NOT NULL | FK → foods.id, ON DELETE RESTRICT |
| portion_grams | DECIMAL(7,2) | NOT NULL | CHECK > 0 AND ≤ 5000 |
| calories_kcal | DECIMAL(8,2) | NOT NULL | Snapshot terhitung |
| protein_g | DECIMAL(8,2) | NOT NULL | |
| carbs_g | DECIMAL(8,2) | NOT NULL | |
| fat_g | DECIMAL(8,2) | NOT NULL | |
| source | ENUM('detected','corrected','manual') | NOT NULL | Asal item |
| detection_confidence | DECIMAL(4,3) | NULL | Hanya untuk `detected`/`corrected` |

Indeks: INDEX(meal_id), INDEX(food_id).

**`revoked_tokens`**

| Kolom | Tipe | Null | Keterangan |
|---|---|---|---|
| jti | CHAR(36) | NOT NULL | PK (UUID token) |
| expires_at | DATETIME | NOT NULL | INDEX; baris kedaluwarsa dapat dibersihkan |

### 8.3 Aturan integritas

- Total pada `meal_records` **harus** sama dengan jumlah nilai `meal_items` terkait (dijaga `meal_service`, diuji).
- Hanya makanan `is_active = TRUE` yang dapat dipakai pada meal baru.
- Kelas YOLO26n pada `ml/classes.yaml` harus terpetakan ke `foods.yolo_class` melalui seed; tes memverifikasi kesesuaiannya.
- Data seed `foods` dan `food_nutrition` berasal dari `db/seed/foods.csv` yang diisi tim dengan sumber terverifikasi. Agen AI **DILARANG** mengarang nilai gizi.

## 9. API Conventions

- Base path: `/api/v1`. Format: JSON (`application/json`); kecuali `POST /foods/detect` (`multipart/form-data`).
- Nama field: `snake_case`. Path: huruf kecil, kata benda jamak, tanpa kata kerja (kecuali aksi `detect`).
- Waktu: ISO 8601 dengan offset (`2026-09-29T12:30:00+07:00`); server menyimpan UTC.
- Auth: header `Authorization: Bearer <access_token>`.
- Pagination: `page` (mulai 1), `page_size` (default 20, maks 100). Respons daftar: `{ "items": [...], "page": 1, "page_size": 20, "total": 57 }`.
- Kode status sukses: `200` (baca/aksi), `201` (dibuat), `204` (tanpa isi).
- Kompatibilitas: perubahan pada API yang sudah ada harus *backward compatible* (tambah field opsional; jangan hapus/ubah arti field). Perubahan breaking memerlukan versi baru (`/api/v2`).
- Nilai gizi dalam respons berupa angka desimal (JSON number) dengan maksimal 2 desimal.

**Ringkasan endpoint**

| Metode | Path | Auth | Tujuan |
|---|---|---|---|
| GET | `/health` | Tidak | Health check (di luar `/api/v1`) |
| POST | `/auth/register` | Tidak | Registrasi |
| POST | `/auth/login` | Tidak | Login |
| POST | `/auth/logout` | Ya | Logout |
| GET | `/users/me` | Ya | Data pengguna + profil |
| PUT | `/users/me/profile` | Ya | Buat/perbarui profil |
| GET | `/nutrition/target` | Ya | Target gizi harian |
| POST | `/foods/detect` | Ya | Deteksi makanan dari gambar |
| GET | `/foods` | Ya | Daftar/pencarian makanan |
| GET | `/foods/{id}` | Ya | Detail makanan |
| POST | `/meals` | Ya | Membuat catatan makan |
| GET | `/meals` | Ya | Riwayat makan |
| GET | `/meals/{id}` | Ya | Detail catatan makan |
| GET | `/dashboard/daily` | Ya | Progres harian |

> Penyesuaian dari contoh awal: `PUT /users/me` menjadi `PUT /users/me/profile` agar jelas bahwa yang diubah adalah profil.

### 9.1 `POST /auth/register`
- **Tujuan:** membuat akun. **Auth:** tidak.
- **Request:** `{ "email": "rina@example.com", "password": "Passw0rd123", "full_name": "Rina" }`
- **Validasi:** email valid & unik (case-insensitive); password 8–128 karakter, mengandung huruf dan angka; `full_name` 1–100 karakter.
- **Response 201:** `{ "id": 1, "email": "rina@example.com", "full_name": "Rina" }`
- **Error:** 422 `VALIDATION_ERROR`; 409 `EMAIL_ALREADY_REGISTERED`.

### 9.2 `POST /auth/login`
- **Request:** `{ "email": "...", "password": "..." }`
- **Response 200:** `{ "access_token": "<jwt>", "token_type": "bearer", "expires_in": 3600 }`
- **Error:** 401 `INVALID_CREDENTIALS` (pesan generik); 422.

### 9.3 `POST /auth/logout`
- **Auth:** ya. **Request:** tanpa body. Mencatat `jti` token ke `revoked_tokens`.
- **Response:** 204. **Error:** 401.

### 9.4 `GET /users/me`
- **Response 200:** `{ "id": 1, "email": "...", "full_name": "...", "profile": { "age": 21, "sex": "female", "weight_kg": 55.0, "height_cm": 160.0, "activity_level": "light", "goal": "lose_weight" } }`; `profile` bernilai `null` bila belum diisi.
- **Error:** 401.

### 9.5 `PUT /users/me/profile`
- **Request:** semua field profil wajib (penggantian penuh): `age`, `sex`, `weight_kg`, `height_cm`, `activity_level`, `goal`.
- **Validasi:** rentang dan enum sesuai §8.2. **Response 200:** objek profil.
- **Error:** 401; 422.

### 9.6 `GET /nutrition/target`
- **Response 200:**
  ```json
  {
    "calories_kcal": 2546,
    "protein_g": 84.0,
    "carbs_g": 393.4,
    "fat_g": 70.7,
    "basis": { "bmr_kcal": 1642.5, "tdee_kcal": 2545.9, "formula": "mifflin_st_jeor" }
  }
  ```
- **Error:** 401; 400 `PROFILE_INCOMPLETE`.

### 9.7 `POST /foods/detect`
- **Request:** `multipart/form-data`, field `image` (satu file).
- **Validasi:** lihat §11.4. **Response 200:**
  ```json
  {
    "detections": [
      { "food_id": 1, "food_name": "Nasi putih", "confidence": 0.91, "low_confidence": false },
      { "food_id": 2, "food_name": "Ayam goreng", "confidence": 0.87, "low_confidence": false }
    ],
    "low_confidence_threshold": 0.5
  }
  ```
  Daftar kosong `[]` valid (status 200) bila tidak ada deteksi yang dikenali.
- **Error:** 401; 400 `MISSING_FILE` / `FILE_TOO_LARGE` / `UNSUPPORTED_IMAGE_TYPE` / `INVALID_IMAGE`; 503 `MODEL_UNAVAILABLE`.
- Endpoint ini **tidak** menyimpan apa pun ke database dan **tidak** mengembalikan nilai gizi.

### 9.8 `GET /foods`
- **Query:** `q` (opsional, pencarian nama, `LIKE` terparameter), `page`, `page_size`.
- **Response 200:** daftar berhalaman; item: `{ "id", "name", "calories_kcal_per_100g", "protein_g_per_100g", "carbs_g_per_100g", "fat_g_per_100g" }`. Hanya makanan aktif.
- **Error:** 401; 422.

### 9.9 `GET /foods/{id}`
- **Response 200:** objek makanan seperti di atas ditambah `source`. **Error:** 401; 404 `FOOD_NOT_FOUND`.

### 9.10 `POST /meals`
- **Request:**
  ```json
  {
    "meal_type": "lunch",
    "consumed_at": "2026-09-29T12:30:00+07:00",
    "items": [
      { "food_id": 1, "portion_grams": 250, "source": "detected", "detection_confidence": 0.91 },
      { "food_id": 5, "portion_grams": 50,  "source": "manual" }
    ]
  }
  ```
- **Validasi:** `meal_type` enum; `consumed_at` memuat offset zona waktu dan tidak lebih dari 5 menit di masa depan; `items` 1–20 elemen; `food_id` ada dan aktif; `portion_grams` > 0 dan ≤ 5000; `source` enum; `detection_confidence` 0–1 dan hanya untuk `detected`/`corrected`. **Klien tidak boleh mengirim nilai gizi** (field tidak dikenal ditolak).
- **Response 201:**
  ```json
  {
    "id": 10, "meal_type": "lunch", "consumed_at": "2026-09-29T05:30:00Z", "consumed_date": "2026-09-29",
    "items": [
      { "id": 21, "food_id": 1, "food_name": "Nasi putih", "portion_grams": 250,
        "calories_kcal": 325.0, "protein_g": 6.75, "carbs_g": 70.0, "fat_g": 0.75,
        "source": "detected", "detection_confidence": 0.91 }
    ],
    "totals": { "calories_kcal": 380.0, "protein_g": 9.5, "carbs_g": 76.0, "fat_g": 3.0 },
    "created_at": "2026-09-29T05:31:02Z"
  }
  ```
  (Angka pada contoh hanya ilustrasi format, bukan data gizi resmi.)
- **Error:** 401; 404 `FOOD_NOT_FOUND`; 422.

### 9.11 `GET /meals`
- **Query:** `date_from`, `date_to` (`YYYY-MM-DD`, terhadap `consumed_date`), `page`, `page_size`. Urutan `consumed_at` menurun.
- **Response 200:** daftar berhalaman; tiap item: `id`, `meal_type`, `consumed_at`, `consumed_date`, `item_count`, `totals`.
- **Error:** 401; 422 (mis. `date_from` > `date_to`).

### 9.12 `GET /meals/{id}`
- **Response 200:** objek seperti respons `POST /meals`.
- **Error:** 401; 404 `MEAL_NOT_FOUND` (juga untuk meal milik pengguna lain).

### 9.13 `GET /dashboard/daily`
- **Query:** `date` (`YYYY-MM-DD`, default hari ini menurut UTC bila tidak dikirim; klien SEBAIKNYA selalu mengirim tanggal lokal).
- **Response 200:**
  ```json
  {
    "date": "2026-09-29",
    "meal_count": 2,
    "target":   { "calories_kcal": 2546, "protein_g": 84.0, "carbs_g": 393.4, "fat_g": 70.7 },
    "consumed": { "calories_kcal": 1200.5, "protein_g": 45.2, "carbs_g": 180.0, "fat_g": 30.1 },
    "progress": {
      "calories_kcal": { "consumed": 1200.5, "target": 2546, "percentage": 47.2 },
      "protein_g":     { "consumed": 45.2,   "target": 84.0, "percentage": 53.8 },
      "carbs_g":       { "consumed": 180.0,  "target": 393.4, "percentage": 45.8 },
      "fat_g":         { "consumed": 30.1,   "target": 70.7, "percentage": 42.6 }
    }
  }
  ```
  `percentage` dibulatkan 1 desimal dan tidak dibatasi 100.
- **Error:** 401; 400 `PROFILE_INCOMPLETE`; 422.

## 10. Authentication

- **Hash kata sandi:** Argon2id via `argon2-cffi` dengan parameter bawaan pustaka. Kata sandi tidak pernah disimpan, dicatat di log, atau dikembalikan dalam respons.
- **Token:** JWT HS256, ditandatangani dengan `JWT_SECRET_KEY` (≥ 32 karakter acak). Klaim hanya: `sub` (user id), `jti` (UUID), `iat`, `exp`. **Tidak boleh** memuat kata sandi, email, atau data sensitif.
- **Masa berlaku:** `ACCESS_TOKEN_EXPIRE_MINUTES` (default 60). Tidak ada refresh token pada MVP.
- **Verifikasi:** dependency `get_current_user` memeriksa tanda tangan, `exp`, dan keberadaan `jti` di `revoked_tokens`; lalu memuat pengguna dari DB. Gagal → 401 (`UNAUTHORIZED`/`TOKEN_EXPIRED`/`TOKEN_REVOKED`).
- **Logout:** menyimpan `jti` + `exp` ke `revoked_tokens`. Baris kedaluwarsa dibersihkan secara oportunistik saat logout.
- **Login:** waktu respons dan pesan kesalahan tidak boleh membedakan "email tidak ada" dari "kata sandi salah". Gunakan verifikasi hash dummy bila pengguna tidak ditemukan.
- **Otorisasi:** semua query data pengguna **wajib** difilter `user_id = current_user.id`. Kepemilikan tidak sesuai → 404 (bukan 403) untuk mencegah enumerasi. Kode 403 dicadangkan bila peran/izin ditambahkan kelak.

## 11. Security Requirements

### 11.1 Rahasia
- Semua rahasia dan konfigurasi sensitif dari environment variable (`pydantic-settings`).
- Kredensial DB, `JWT_SECRET_KEY`, dan kunci API **DILARANG** di-hardcode atau di-commit.
- `.env` **wajib** ada di `.gitignore`; sediakan `backend/.env.example` berisi placeholder (tanpa nilai nyata).
- `.gitignore` juga mencakup: `*.pt` (bobot model), `__pycache__/`, `.venv/`, `build/`, `.dart_tool/`, dataset citra, dan berkas unggahan sementara.

### 11.2 Keamanan API
- Validasi seluruh input dengan Pydantic; tolak field tak dikenal pada request penting (`extra="forbid"`).
- Setiap endpoint kecuali `/health`, `/auth/register`, `/auth/login` memerlukan autentikasi.
- Gunakan ORM/query terparameter; **DILARANG** membangun SQL dengan string formatting/concatenation.
- Jangan membocorkan exception internal atau stack trace; log detail hanya di server (§14, §16).
- CORS: daftar origin eksplisit dari `CORS_ALLOWED_ORIGINS`; tidak memakai `*` di luar `APP_ENV=development`.
- HTTPS: produksi/demo publik harus melalui TLS (reverse proxy atau layanan hosting). HTTP tanpa TLS hanya untuk pengembangan lokal.
- Keterbatasan MVP yang diketahui: tidak ada rate limiting/lockout login (membutuhkan infrastruktur tambahan) — dicatat di README.

### 11.3 Privasi
- Foto tidak disimpan setelah inferensi (AD-08). Foto, token, dan kata sandi tidak boleh masuk log.

### 11.4 Keamanan unggah gambar
Urutan validasi pada `POST /foods/detect` (berhenti pada kegagalan pertama):

1. Field `image` ada (`MISSING_FILE`).
2. Ekstensi nama file ∈ {`.jpg`, `.jpeg`, `.png`, `.webp`} (`UNSUPPORTED_IMAGE_TYPE`).
3. `Content-Type` ∈ {`image/jpeg`, `image/png`, `image/webp`} (`UNSUPPORTED_IMAGE_TYPE`).
4. Ukuran ≤ `MAX_UPLOAD_SIZE_MB` (default 5). Baca berkas secara bertahap dan hentikan begitu batas terlewati (`FILE_TOO_LARGE`).
5. Verifikasi isi sebenarnya dengan Pillow (`Image.open` + `verify()`), format hasil ∈ {JPEG, PNG, WEBP}, dan batas piksel (mis. ≤ 25 juta piksel) untuk mencegah *decompression bomb* (`INVALID_IMAGE`).
6. Hanya setelah lolos, gambar diberikan ke YOLO26n.

Ketentuan tambahan: nama file dari klien **tidak dipakai** untuk jalur berkas; gambar diproses di memori bila memungkinkan, atau di berkas sementara bernama UUID (via `tempfile`) yang **wajib** dihapus dalam blok `finally`; berkas unggahan tidak pernah dieksekusi dan tidak disajikan kembali.

## 12. YOLO26n Integration

**Tanggung jawab YOLO26n:** `gambar → inferensi → kelas makanan + confidence`. Tidak lebih.

**YOLO26n DILARANG:** menghitung kalori/protein/karbohidrat/lemak, menghitung target harian, menilai kesehatan, mendiagnosis, atau merekomendasikan makanan.

**Kontrak `app/ml/detector.py`**

- Satu-satunya modul yang mengimpor `ultralytics`.
- Antarmuka: `detect(image) -> list[RawDetection]`, dengan `RawDetection(class_name: str, confidence: float)`.
- Model dimuat sekali dari `MODEL_PATH` saat startup; inferensi memakai `conf=DETECTION_MIN_CONFIDENCE` (default 0.25).

**Pemrosesan di `scanner_service`**

1. Petakan `class_name` → `foods.yolo_class`. Kelas tak terpetakan atau makanan tidak aktif → dibuang dan dicatat sebagai WARNING (kelas tidak didukung).
2. Gabungkan deteksi duplikat per makanan; ambil confidence tertinggi.
3. Tandai `low_confidence = confidence < DETECTION_LOW_CONFIDENCE_THRESHOLD` (default 0.50).
4. Urutkan menurun menurut confidence; batasi maksimum 10 makanan.
5. Kembalikan daftar (dapat kosong).

**Fallback manual (wajib didukung klien dan API):** daftar kosong, `low_confidence`, deteksi keliru, dan kelas tidak didukung ditangani dengan alat koreksi/penambahan manual melalui `GET /foods`. Backend tidak pernah membuat meal dari hasil deteksi tanpa `POST /meals` eksplisit.

**Keterbatasan (harus tercantum di `ml/README.md` dan README):** model hanya mendukung 10–20 kelas (`ml/classes.yaml`) dan tidak mewakili seluruh makanan Indonesia; akurasi bergantung pada kualitas dataset, pencahayaan, dan sudut foto.

**Pelatihan:** dilakukan di luar backend (Google Colab/`ml/notebooks/`) dengan Ultralytics; keluaran `best.pt` ditempatkan di `MODEL_PATH`. Bobot tidak di-commit; cara memperolehnya dijelaskan di `ml/README.md`. Jika daftar kelas berubah, `classes.yaml`, seed `foods`, dan tes pemetaan harus diperbarui bersamaan.

## 13. Nutrition Calculation

Seluruhnya di `services/nutrition_service.py` sebagai **fungsi murni** (tanpa DB, tanpa I/O, tanpa impor `app.ml`). Gunakan `decimal.Decimal` dengan pembulatan `ROUND_HALF_UP`.

### 13.1 Target harian

**Langkah 1 — BMR (Mifflin-St Jeor)**

```text
male:   BMR = 10 × berat_kg + 6.25 × tinggi_cm − 5 × usia + 5
female: BMR = 10 × berat_kg + 6.25 × tinggi_cm − 5 × usia − 161
```

**Langkah 2 — TDEE = BMR × faktor aktivitas**

| activity_level | Faktor |
|---|---|
| sedentary | 1.2 |
| light | 1.375 |
| moderate | 1.55 |
| active | 1.725 |
| very_active | 1.9 |

**Langkah 3 — Kalori target (disesuaikan tujuan)**

| goal | Kalori target |
|---|---|
| lose_weight | TDEE − 500 |
| maintain_weight | TDEE |
| gain_weight | TDEE + 300 |

Batas bawah: kalori target tidak boleh kurang dari 1200 (female) atau 1500 (male).

**Langkah 4 — Makronutrien**

| goal | Protein (g/kg berat badan) |
|---|---|
| lose_weight | 1.6 |
| maintain_weight | 1.2 |
| gain_weight | 1.6 |

```text
protein_g = protein_per_kg × berat_kg
fat_g     = 0.25 × kalori_target / 9
carbs_g   = (kalori_target − protein_g × 4 − fat_g × 9) / 4    # minimal 0
```

Semua perhitungan memakai nilai tak dibulatkan; pembulatan hanya pada keluaran akhir: kalori → bilangan bulat; protein, karbohidrat, lemak → 1 desimal. Nilai `basis` (BMR/TDEE) dibulatkan 1 desimal.

**Contoh uji wajib (harus menjadi unit test):** pria, 25 tahun, 70 kg, 170 cm, `moderate`, `maintain_weight`
BMR = 1642.5 → TDEE = 2545.875 → kalori 2546; protein 84.0 g; lemak 70.7 g; karbohidrat 393.4 g.

Hasil merupakan estimasi umum, bukan saran medis. Pengubahan rumus/konstanta memerlukan pembaruan dokumen ini dan tes.

### 13.2 Gizi makanan

```text
nutrisi_dikonsumsi = nutrisi_per_100g × portion_grams / 100
```

- Berlaku untuk kalori, protein, karbohidrat, lemak.
- Pembulatan: tiap nilai per item dibulatkan ke 2 desimal (`ROUND_HALF_UP`) lalu disimpan sebagai snapshot di `meal_items`.
- Total meal = jumlah nilai item yang telah dibulatkan (agar total selalu sama dengan jumlah item).
- Dashboard: konsumsi = jumlah `total_*` seluruh `meal_records` pengguna pada `consumed_date` terpilih.
- Hanya backend yang menghitung. Klien tidak mengirim dan tidak menghitung gizi.

## 14. Error Handling

**Format error tunggal untuk semua kegagalan:**

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Data yang dikirim tidak valid.",
    "details": [ { "field": "portion_grams", "message": "Harus lebih besar dari 0." } ],
    "request_id": "b1c2d3e4-..."
  }
}
```

`details` opsional (dipakai untuk validasi). `message` berbahasa Indonesia, aman, dan mudah dipahami.

| HTTP | Kode error (contoh) | Kapan |
|---|---|---|
| 400 | `BAD_REQUEST`, `PROFILE_INCOMPLETE`, `MISSING_FILE`, `FILE_TOO_LARGE`, `UNSUPPORTED_IMAGE_TYPE`, `INVALID_IMAGE` | Permintaan tidak dapat diproses karena aturan bisnis/berkas |
| 401 | `UNAUTHORIZED`, `INVALID_CREDENTIALS`, `TOKEN_EXPIRED`, `TOKEN_REVOKED` | Tidak/gagal autentikasi |
| 403 | `FORBIDDEN` | Diautentikasi tetapi tidak berhak (dicadangkan) |
| 404 | `NOT_FOUND`, `FOOD_NOT_FOUND`, `MEAL_NOT_FOUND` | Sumber daya tidak ada / bukan milik pengguna |
| 409 | `EMAIL_ALREADY_REGISTERED` | Konflik data (tambahan di luar daftar minimum) |
| 422 | `VALIDATION_ERROR` | Validasi skema/field gagal |
| 500 | `INTERNAL_SERVER_ERROR` | Kesalahan tak terduga |
| 503 | `MODEL_UNAVAILABLE` | Model YOLO26n belum tersedia (tambahan) |

**Aturan**

- Layanan melempar `AppError(status, code, message)`; handler global di `core/errors.py` menerjemahkannya ke format di atas, termasuk `RequestValidationError` (→ 422) dan `Exception` tak tertangani (→ 500).
- Pesan 500 selalu generik ("Terjadi kesalahan pada server."). Stack trace, SQL, path berkas, dan pesan pustaka **tidak pernah** dikirim ke klien; dicatat di log dengan `request_id`.
- Flutter memetakan `error.code` ke pesan antarmuka yang ramah; UI tidak menampilkan JSON mentah.

## 15. Validation

- **Backend adalah otoritas validasi.** Validasi klien hanya untuk kenyamanan pengguna dan tidak menggantikan validasi server.
- Validasi bentuk/tipe/rentang → skema Pydantic. Validasi yang melibatkan DB (eksistensi makanan, keunikan email) → service.
- Rentang profil dan porsi sesuai `prd.md` §13 dan §8.2 (satu sumber: konstanta di `core/config.py` atau modul konstanta skema).
- Normalisasi: email di-`strip()` dan lowercase.
- Parameter `page_size` dibatasi maks 100; `date` divalidasi format ISO.
- Field tak dikenal ditolak pada body JSON.

## 16. Logging

- Pustaka standar `logging`; format: `waktu | level | request_id | logger | pesan`. Level dari `LOG_LEVEL`.
- Middleware menetapkan `request_id` (UUID) per permintaan, mengembalikannya di header `X-Request-ID` dan di body error.
- Catat: startup/shutdown, pemuatan model, permintaan gagal (WARNING/ERROR), kelas YOLO26n tidak terpetakan, dan exception tak terduga (dengan traceback, hanya di log).
- **DILARANG mencatat:** kata sandi, hash, token, `JWT_SECRET_KEY`, kredensial DB, isi/byte gambar, dan data profil sensitif.
- Jangan memakai `print()` untuk logging.

## 17. Testing Strategy

**Prinsip:** uji perilaku yang penting; utamakan tes deterministik dan cepat. Target cakupan `services/` ≥ 70% (M-03).

### 17.1 Backend (pytest)

| Area | Jenis | Kasus minimum |
|---|---|---|
| Nutrition target | Unit | Contoh wajib §13.1; ketiga goal; kedua jenis kelamin; semua faktor aktivitas; batas bawah kalori; karbohidrat tidak negatif |
| Nutrition calculation | Unit | Rumus per 100 g; pembulatan `ROUND_HALF_UP`; porsi kecil/besar; total = jumlah item |
| Autentikasi | Integrasi | Registrasi sukses/duplikat/validasi; login sukses/salah; kata sandi tersimpan sebagai hash; token kedaluwarsa; logout mencabut token |
| Otorisasi | Integrasi | Tanpa token → 401; meal pengguna lain → 404; data terpisah antar pengguna |
| Profil | Integrasi | Buat, perbarui, validasi rentang, `GET /users/me` sebelum/sesudah profil |
| Target endpoint | Integrasi | Profil lengkap → sesuai rumus; belum lengkap → `PROFILE_INCOMPLETE` |
| Food retrieval | Integrasi | Daftar, pencarian `q`, paginasi, detail, 404 |
| Meal creation | Integrasi | Sukses + snapshot gizi benar; total = jumlah item; makanan tak ada; porsi tidak valid; item kosong; transaksi atomik |
| Meal retrieval | Integrasi | Daftar + filter tanggal; detail; 404 untuk milik orang lain |
| Dashboard | Integrasi | Agregasi lintas beberapa meal; hari tanpa data (konsumsi 0); `PROFILE_INCOMPLETE` |
| Food detection | Integrasi (detektor di-*mock*) | Gambar valid; tanpa deteksi (daftar kosong); banyak deteksi; duplikasi per kelas digabung; kelas tak terpetakan dibuang; `low_confidence`; 503 bila model tak ada |
| File validation | Unit + integrasi | Ekstensi salah; MIME salah; ukuran > batas; file bukan gambar dengan ekstensi `.jpg`; gambar rusak; berkas sementara terhapus |
| Batas arsitektur | Unit | `nutrition_service` tidak mengimpor `app.ml` |
| Konsistensi seed | Unit | Setiap kelas di `ml/classes.yaml` terpetakan ke satu makanan |

- Tes integrasi memakai basis data MySQL khusus uji (skema terpisah, mis. `*_test`), dibuat via Alembic; **bukan** SQLite, agar perilaku ENUM/DECIMAL sama dengan produksi.
- Tes API deteksi memakai detektor tiruan. Satu tes *smoke* opsional (`@pytest.mark.ml`) menjalankan model asli pada gambar contoh bila bobot tersedia.
- Dilarang memanggil layanan eksternal pada tes.

### 17.2 Flutter

| Level | Cakupan |
|---|---|
| Unit | Parsing DTO, `ApiClient` (penanganan error/401), provider penting |
| Widget | Login, form profil, layar konfirmasi deteksi (hapus/ganti/tambah, penanda confidence rendah, daftar kosong), input porsi (validasi), dashboard (progres) |
| Integrasi | Alur utama dengan API tiruan: login → profil → scan → konfirmasi → porsi → simpan → dashboard |

Repository dan API diganti tiruan (`mocktail`) pada tes widget.

## 18. Environment Configuration

**`backend/.env.example`** (nilai adalah placeholder):

```text
APP_ENV=development
LOG_LEVEL=INFO
DATABASE_URL=mysql+pymysql://<user>:<password>@localhost:3306/food_nutrition_scanner
JWT_SECRET_KEY=<ganti-dengan-string-acak-minimal-32-karakter>
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
CORS_ALLOWED_ORIGINS=http://localhost:3000
MODEL_PATH=app/ml/weights/best.pt
DETECTION_MIN_CONFIDENCE=0.25
DETECTION_LOW_CONFIDENCE_THRESHOLD=0.50
MAX_UPLOAD_SIZE_MB=5
```

- Aplikasi gagal start dengan pesan jelas bila variabel wajib (`DATABASE_URL`, `JWT_SECRET_KEY`) tidak ada.
- Basis data uji memakai `DATABASE_URL_TEST` (hanya untuk pytest).
- Flutter: `--dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1` (emulator Android). Cleartext HTTP hanya untuk build debug.
- Perintah standar (didokumentasikan di README): `alembic upgrade head`, skrip seed, `uvicorn app.main:app --reload`, `pytest`, `ruff check .`, `flutter test`.

## 19. Coding Standards

### 19.1 Python
- PEP 8; format dan lint dengan `ruff` (panjang baris 100).
- `snake_case` untuk fungsi/variabel/modul; `PascalCase` untuk kelas; `UPPER_SNAKE_CASE` untuk konstanta.
- Type hints wajib pada fungsi publik dan seluruh service.
- Fungsi kecil dan fokus (satu tanggung jawab); hindari fungsi > ~40 baris tanpa alasan.
- Ikuti konvensi FastAPI: `APIRouter` per modul, dependency injection untuk DB dan pengguna, `response_model`, kode status eksplisit.
- Pisahkan tanggung jawab (router → service → model). Hindari abstraksi tak perlu (tidak ada *repository pattern*, *factory*, atau *DI container* tambahan).
- Nama jelas; komentar menjelaskan *mengapa*, bukan *apa*. Docstring singkat untuk fungsi publik non-trivial.
- Tidak ada `except:` kosong; tangkap exception spesifik.

### 19.2 Dart / Flutter
- Gaya resmi Dart; `dart format` dan `flutter analyze` tanpa peringatan.
- `camelCase` untuk variabel/fungsi; `PascalCase` untuk kelas; `snake_case` untuk nama berkas.
- Null safety penuh; hindari `!` kecuali terbukti aman; hindari `dynamic`.
- Widget berukuran kecil dengan tanggung jawab jelas; ekstrak komponen yang dipakai ulang ke `shared/widgets`.
- Gunakan `const` bila memungkinkan; `dispose()` controller.
- Tidak ada logika bisnis atau HTTP di widget. Hindari kerumitan state management di luar `provider`.

## 20. Git Conventions

- Cabang: `main` (stabil) dan cabang fitur pendek: `feat/<topik>`, `fix/<topik>`, `docs/<topik>`, `chore/<topik>`, `test/<topik>`.
- Pesan commit mengikuti **Conventional Commits**: `feat(meals): add meal creation endpoint`; jenis: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`.
- Satu commit = satu perubahan logis. Jangan mencampur refactor dengan fitur.
- **Jangan pernah** commit: `.env`, rahasia, bobot model (`*.pt`), dataset, artefak build.
- Pull request menyertakan: ringkasan, ID FR/AC terkait, hasil tes, dan justifikasi dependensi baru (jika ada).
- `main` hanya menerima perubahan yang lulus tes dan memenuhi Definition of Done.

## 21. Development Workflow

1. Pilih kebutuhan (FR/AC) dari `prd.md`.
2. Periksa struktur proyek dan kode yang relevan.
3. Buat cabang fitur.
4. Bila ada perubahan data: buat migrasi Alembic.
5. Implementasikan berurutan dari dalam ke luar: model → schema → service (+ unit test) → router (+ tes integrasi) → klien Flutter (+ tes).
6. Jalankan `ruff check`, `pytest`, `flutter analyze`, `flutter test`.
7. Perbarui dokumentasi bila kontrak berubah (`ai.md`, README, OpenAPI).
8. Ajukan PR dan verifikasi terhadap Definition of Done.

**Urutan implementasi yang disarankan:** fondasi (config, DB, error, logging) → auth → profil & target → foods + seed → meals → dashboard → deteksi YOLO26n → seluruh alur Flutter → tes end-to-end.

## 22. AI Coding Agent Rules

Aturan berikut **mengikat** bagi setiap agen AI yang bekerja di repositori ini.

**Sumber kebenaran**
1. Perlakukan `docs/prd.md` sebagai sumber kebenaran kebutuhan produk.
2. Perlakukan `docs/ai.md` sebagai sumber kebenaran rekayasa dan arsitektur.
3. Bila terdapat kontradiksi atau ambiguitas yang memengaruhi arsitektur atau desain data secara material, **identifikasi dan laporkan ambiguitas sebelum implementasi**; jangan menebak diam-diam.

**Sebelum mengerjakan**
4. Sebelum mengimplementasikan fitur, periksa struktur proyek dan kode terkait yang sudah ada.
5. Gunakan kembali komponen dan utilitas yang ada bila sesuai.

**Cakupan dan kesederhanaan**
6. Jangan mengimplementasikan fungsi di luar cakupan yang didefinisikan kecuali diminta secara eksplisit.
7. Jangan memperkenalkan dependensi, framework, pola arsitektur, abstraksi, atau komponen infrastruktur baru tanpa alasan teknis yang jelas dan dicatat.
8. Pilih implementasi termudah yang dapat dipelihara. Jangan over-engineer.
9. Buat perubahan yang terfokus dan terisolasi. Jangan mengubah fungsi yang tidak terkait.
10. Jangan memperkenalkan teknologi yang dilarang di §4.

**Arsitektur (tidak boleh dilanggar)**
11. Flutter tidak pernah mengakses MySQL secara langsung; Flutter hanya berkomunikasi dengan FastAPI melalui REST.
12. FastAPI memiliki logika bisnis, perhitungan gizi, dan inferensi YOLO26n; akses database hanya di backend.
13. YOLO26n terisolasi dari logika gizi (§2, §12); perhitungan gizi tetap deterministik.
14. UI tidak memuat logika bisnis.
15. Jangan mengarang data gizi; gunakan hanya data yang disediakan pada seed bersumber.

**Keamanan dan kualitas**
16. Jangan pernah meng-hardcode kredensial atau rahasia; jangan menampilkan rahasia di log atau output.
17. Validasi semua input eksternal (JSON, query, path, berkas).
18. Jaga kompatibilitas mundur saat mengubah API yang sudah ada.
19. Jalankan tes yang relevan setelah implementasi dan laporkan hasilnya jujur; jangan menandai selesai bila tes gagal atau tidak dijalankan tanpa menyatakannya.
20. Jangan menghapus atau melemahkan tes agar lolos.
21. Perbarui dokumentasi bila perilaku, kontrak API, atau konfigurasi berubah.

**Kolaborasi**
22. Bila permintaan pengguna bertentangan dengan `prd.md`/`ai.md`, sampaikan konflik tersebut dan minta keputusan sebelum melanjutkan.
23. Dokumentasi teknis dan pesan antarmuka ditulis dalam Bahasa Indonesia; identifier kode, nama endpoint, dan pesan commit dalam Bahasa Inggris.

## 23. Definition of Done

Sebuah fitur dianggap selesai hanya jika **semua kriteria yang berlaku** terpenuhi; kode yang sekadar dapat dikompilasi belum selesai.

- [ ] Kebutuhan (FR) dan kriteria penerimaan (AC) terkait di `prd.md` terpenuhi.
- [ ] Validasi input diimplementasikan (backend; UI bila relevan).
- [ ] Penanganan error mengikuti format §14; tidak ada kebocoran detail internal.
- [ ] Persyaratan keamanan §10–§11 terpenuhi (autentikasi, otorisasi kepemilikan data, rahasia, validasi unggahan bila relevan).
- [ ] Tes relevan ditulis (unit/integrasi/widget) dan lulus.
- [ ] Seluruh tes yang sudah ada tetap lulus.
- [ ] Batas arsitektur terjaga (YOLO26n ↔ gizi terisolasi; tanpa logika bisnis di UI/router).
- [ ] Migrasi Alembic disertakan bila skema berubah dan dapat dijalankan dari nol.
- [ ] Dokumentasi API/README/`ai.md` diperbarui bila perlu dan tetap konsisten dengan `prd.md`.
- [ ] Tidak ada dependensi tak perlu; dependensi baru dijustifikasi.
- [ ] Kode mengikuti konvensi §19 (`ruff`, `dart format`, `flutter analyze` bersih).
- [ ] Tidak ada rahasia, `.env`, bobot model, atau data pribadi di commit.
- [ ] Perubahan terfokus dan pesan commit mengikuti §20.

---

## Lampiran A — Keterlacakan Kebutuhan → Implementasi

| Kebutuhan (`prd.md`) | Backend | Klien | Tes utama |
|---|---|---|---|
| FR-AUTH-01..04 | `auth.py`, `auth_service`, `security.py`, `revoked_tokens` | `features/auth` | Tes autentikasi & otorisasi |
| FR-PROF-01..02 | `users.py`, `profile_service`, `profiles` | `features/profile` | Tes profil |
| FR-TGT-01..03 | `nutrition.py`, `nutrition_service` | Layar target/dashboard | Unit target §13.1, `PROFILE_INCOMPLETE` |
| FR-SCAN-01..04 | `foods.py` (`/foods/detect`), `scanner_service`, `ml/detector.py` | `features/scanner` | Tes deteksi & validasi file |
| FR-CONF-01..02, FR-PORT-01 | (tanpa persistensi hingga `POST /meals`) | `ScanFlowProvider`, layar konfirmasi & porsi | Widget test konfirmasi & porsi |
| FR-NUT-01..04 | `nutrition_service`, `meal_service`, `food_nutrition`, `meal_items` | Menampilkan hasil server | Unit gizi, tes meal creation |
| FR-MEAL-01..04 | `meals.py`, `meal_service` | `features/meals` | Tes meal creation/retrieval, otorisasi |
| FR-DASH-01..02 | `dashboard.py`, `dashboard_service` | `features/dashboard` | Tes dashboard, widget dashboard |
| FR-FOOD-01..02 | `foods.py`, `food_service` | Pencarian makanan di konfirmasi | Tes food retrieval |
