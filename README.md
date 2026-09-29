# NutriView

Aplikasi mobile untuk **mengenali makanan dari foto dan melacak asupan gizi harian**. Pengguna mengisi profil, sistem menghitung target gizi harian, lalu pengguna memotret makanan; YOLO26n mendeteksi jenis makanan, pengguna mengonfirmasi dan memasukkan porsi (gram), dan backend menghitung gizi secara deterministik dari basis data nutrisi.

> Proyek perkuliahan. Hasil aplikasi bersifat **estimasi** dan **bukan saran medis**.

## Alur Utama

```text
Profil → Target Gizi Harian → Foto Makanan → Deteksi YOLO26n → Konfirmasi Pengguna
      → Input Porsi (gram) → Perhitungan Gizi → Catatan Makan → Progres Harian
```

## Fitur MVP

Registrasi/login/logout · profil pengguna · target kalori & makronutrien harian · scan makanan (kamera/galeri) · konfirmasi & koreksi deteksi · input porsi gram · perhitungan gizi · riwayat makan · dashboard harian · pencarian makanan manual.

Rincian kebutuhan: [`docs/prd.md`](docs/prd.md).

## Teknologi

| Lapisan | Teknologi |
|---|---|
| Mobile | Flutter, Dart |
| Backend | Python 3.11+, FastAPI |
| Basis data | MySQL 8 |
| Computer vision | YOLO26n (Ultralytics); pelatihan di Google Colab |
| Komunikasi | REST API, JSON |

## Arsitektur

Modular monolith: satu backend FastAPI (Auth, Profile, Food Scanner + YOLO26n, Nutrition Calculator, Meal Tracking) dan satu database MySQL.

```text
Flutter App ──HTTPS/REST──► FastAPI (modul + YOLO26n) ──► MySQL
```

Prinsip penting: Flutter tidak mengakses database; YOLO26n hanya mendeteksi makanan dan **tidak** menghitung gizi; gizi dihitung backend dengan rumus `nutrisi_per_100g × porsi_gram / 100`. Detail lengkap: [`docs/ai.md`](docs/ai.md).

## Struktur Repositori

```text
├── backend/    # FastAPI, layanan bisnis, model YOLO26n wrapper, migrasi, tes
├── frontend/   # Aplikasi Flutter
├── ml/         # Catatan dataset/pelatihan, classes.yaml, notebook Colab
└── docs/       # prd.md dan ai.md
```

## Prasyarat

- Python 3.11+
- MySQL 8.x
- Flutter SDK (stable) dan Android emulator/perangkat
- Bobot model YOLO26n `best.pt` (lihat [`ml/README.md`](ml/README.md); tidak disertakan di repositori)

## Memulai

### 1. Backend

```bash
cd backend
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env               # lalu isi nilai sebenarnya (jangan di-commit)
```

Buat database MySQL (`utf8mb4`), sesuaikan `DATABASE_URL` di `.env`, lalu:

```bash
alembic upgrade head               # membuat skema
python -m app.db.seed              # mengisi data makanan & gizi dari app/db/seed/foods.csv
uvicorn app.main:app --reload
```

Letakkan bobot model di `backend/app/ml/weights/best.pt` (atau atur `MODEL_PATH`). Tanpa model, endpoint deteksi mengembalikan `503`, sedangkan fitur lain tetap berjalan.

- Dokumentasi API interaktif: `http://localhost:8000/docs`
- Health check: `http://localhost:8000/health`

### 2. Frontend

```bash
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

`10.0.2.2` adalah alamat host dari emulator Android. Gunakan IP mesin Anda untuk perangkat fisik.

## Konfigurasi

Seluruh konfigurasi backend melalui environment variable (lihat `backend/.env.example`):

| Variabel | Fungsi |
|---|---|
| `DATABASE_URL` | Koneksi MySQL |
| `JWT_SECRET_KEY` | Kunci penandatangan token (acak, ≥ 32 karakter) |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Masa berlaku token |
| `MODEL_FAMILY` | Arsitektur model deteksi (default: `YOLO26n`) |
| `MODEL_PATH` | Lokasi bobot model (default: `app/ml/weights/best.pt`) |
| `DETECTION_MIN_CONFIDENCE` / `DETECTION_LOW_CONFIDENCE_THRESHOLD` | Ambang deteksi |
| `MAX_UPLOAD_SIZE_MB` | Batas ukuran gambar (default 5) |

`.env` tidak boleh di-commit.

## Pengujian

```bash
# Backend
cd backend
ruff check .
pytest

# Frontend
cd frontend
flutter analyze
flutter test
```

Tes integrasi backend memakai database MySQL khusus uji (`DATABASE_URL_TEST`). Strategi lengkap: `docs/ai.md` §17.

## Endpoint Utama

`POST /auth/register` · `POST /auth/login` · `POST /auth/logout` · `GET /users/me` · `PUT /users/me/profile` · `GET /nutrition/target` · `POST /foods/detect` · `GET /foods` · `GET /foods/{id}` · `POST /meals` · `GET /meals` · `GET /meals/{id}` · `GET /dashboard/daily`

Semua berada di bawah `/api/v1`. Kontrak lengkap: `docs/ai.md` §9.

## Keterbatasan

- Model hanya mendukung **10–20 kelas makanan** dan **tidak mewakili seluruh makanan Indonesia**; selalu tersedia input manual.
- Porsi diisi pengguna dalam gram; **tidak ada** estimasi porsi otomatis dari gambar.
- Target gizi adalah estimasi umum; aplikasi tidak memberikan diagnosis atau saran medis.
- Belum ada rate limiting login, reset kata sandi, atau edit/hapus catatan makan.
- Data gizi bersumber dari referensi yang dicatat pada tabel `food_nutrition.source` (mis. TKPI) dan harus diverifikasi tim.

## Di Luar Cakupan

Chatbot/LLM, rekomendasi makanan, optimasi belanja (OR-Tools), model rekomendasi Food.com, coaching real-time, wearable/IoT, fitur sosial, microservices, dan infrastruktur terdistribusi. Daftar lengkap: `docs/prd.md` §17.

## Panduan untuk AI Coding Agent

Sebelum mengerjakan apa pun, baca **`docs/prd.md`** (sumber kebenaran produk) dan **`docs/ai.md`** (sumber kebenaran rekayasa), terutama §22 (*AI Coding Agent Rules*) dan §23 (*Definition of Done*). Jangan menambah fitur, dependensi, atau infrastruktur di luar yang didefinisikan tanpa permintaan eksplisit.

## Dokumentasi

| Dokumen | Isi |
|---|---|
| [`docs/prd.md`](docs/prd.md) | Kebutuhan produk, user story, kriteria penerimaan, metrik |
| [`docs/ai.md`](docs/ai.md) | Arsitektur, skema database, API, keamanan, standar kode, aturan agen AI |
| [`ml/README.md`](ml/README.md) | Dataset, pelatihan, dan evaluasi model |
