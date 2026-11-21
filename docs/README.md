# Dokumentasi Resmi Proyek OopsieEats (NutriView)

Selamat datang di portal dokumentasi teknis resmi **OopsieEats** (sebelumnya dikenal sebagai *NutriView*).

Dokumentasi ini disusun secara profesional berdasarkan implementasi kode aktual (*single source of truth*) pada repositori, mencakup arsitektur perangkat lunak, basis data, pipeline kecerdasan buatan (*Computer Vision*), sistem desain antarmuka, strategi pengujian, hingga panduan rilis produksi Google Play Store.

---

## 1. Peta Jalan & Indeks Dokumentasi

Berikut adalah direktori dan dokumen teknis yang aktif dan diverifikasi terhadap kode sumber:

### A. Arsitektur & Rekayasa Perangkat Lunak
| Dokumen | Deskripsi Teknis |
|---|---|
| [**Arsitektur Sistem**](ARCHITECTURE.md) | Arsitektur Serverless Edge-AI, diagram berlapis, tanggung jawab per layer, dan diagram sekuensial. |
| [**Panduan Pengembangan & Standar Rekayasa**](DEVELOPMENT_GUIDE.md) | Konvensi kode Dart, implementasi prinsip SOLID, sistem desain Overkill Neo-Brutalism, dan hierarki error. |
| [**Koleksi Diagram Arsitektur (.mmd)**](diagrams/) | Berkas diagram Mermaid original (System Context, App Architecture, Data Flow, ERD, ML Pipeline, dll). |

### B. Basis Data, Penyimpanan & Layanan Cloud
| Dokumen | Deskripsi Teknis |
|---|---|
| [**Basis Data & Layanan Backend**](DATABASE_AND_BACKEND.md) | Topologi Google Firebase Spark Tier, skema dokumen Cloud Firestore, aturan keamanan deklaratif (`firestore.rules`), dan indeks komposit. |
| [**Integrasi Supabase Storage**](SUPABASE_IMAGE_STORAGE.md) | Konfigurasi bucket privat `food-history-images`, Row Level Security (RLS), alur foto inspeksi makanan & foto profil pengguna. |

### C. Kecerdasan Buatan & Formulasi Gizi
| Dokumen | Deskripsi Teknis |
|---|---|
| [**Machine Learning & Formulasi Gizi**](MACHINE_LEARNING.md) | Pipeline inferensi YOLO26n TFLite on-device (~9.4 MB), pra-pemrosesan di background isolate, NMS, 29 kelas makanan, rumus Mifflin-St Jeor, dan validasi faktor energi Atwater. |

### D. Pengujian Kualitas, QA & Kesiapan Rilis
| Dokumen | Deskripsi Teknis |
|---|---|
| [**Pengujian Kualitas & Hasil QA**](TESTING_AND_QA.md) | Piramida pengujian, inventaris 42 berkas pengujian (`frontend/test/`), hasil eksekusi 359 kasus uji (100% lulus), dan bukti analisis statis kode. |
| [**Panduan Operasional & Deployment**](deployment.md) | Konfigurasi Firebase CLI, penandatanganan rilis Android App Bundle (`.aab`), R8 ProGuard, dan kepatuhan Google Play Store API 36. |
| [**Panduan Build Rilis & Validasi**](release/RELEASE_BUILD_GUIDE.md) | Langkah-langkah build rilis terobfuskasi, penanganan simbol debug Dart/R8, dan skrip validasi `./scripts/validate_release.sh`. |
| [**Kepatuhan Google Play Store**](release/GOOGLE_PLAY_COMPLIANCE.md) | Kepatuhan target API 36, izin minimal, halaman privasi, dan mekanisme penghapusan akun. |

### E. Alur Pengguna & Desain Antarmuka
| Dokumen | Deskripsi Teknis |
|---|---|
| [**Ikhtisar Alur Pengguna (User Flows)**](user-flows/USER_FLOW_OVERVIEW.md) | Peta alur pengguna untuk seluruh 7 modul fungsional aplikasi. |
| [**Alur Navigasi Aplikasi**](user-flows/APPLICATION_NAVIGATION_FLOW.md) | Struktur rute navigasi `AppRoutes` dan guard `completeProfile`. |
| [**Desain Ulang Onboarding**](onboarding_redesign/README.md) | Dokumentasi teknis 3 slide onboarding interaktif dengan stiker dan stiker starburst kustom. |

### F. Riwayat Perubahan & Audit
| Dokumen | Deskripsi Teknis |
|---|---|
| [**Changelog Dokumentasi**](DOCUMENTATION_CHANGELOG.md) | Catatan kronologis evolusi dan sinkronisasi dokumentasi proyek. |
| [**Laporan Audit Dokumentasi Sebelumnya**](DOCUMENTATION_AUDIT_REPORT.md) | Arsip laporan audit dokumentasi per 6 November 2026. |

---

## 2. Identitas & Informasi Aplikasi Aktual

- **Nama Aplikasi**: OopsieEats
- **Branding Historis**: NutriView
- **Application ID / Package Name**: `com.oopsieeats.app`
- **Versi Rilis**: `1.0.0+2002`
- **Target Platform**: Android (Minimum SDK 23, Target SDK 36, Compile SDK 36)
- **Bahasa & Framework**: Flutter 3.x / Dart SDK `^3.13.4`
- **Kredensial Legal & Google Play Compliance**:
  - Kebijakan Privasi Publik: [https://nutriview-943cd.web.app/privacy](https://nutriview-943cd.web.app/privacy)
  - Penghapusan Akun Publik: [https://nutriview-943cd.web.app/delete-account](https://nutriview-943cd.web.app/delete-account)
  - Pengembang: Ahmad Badawi ([GitHub](https://github.com/ahmadbadawiTzy) · [LinkedIn](https://www.linkedin.com/in/ahmad-badawi-b87274410))

---

## 3. Klasifikasi Dokumen Historis (Historical Archives)

Beberapa dokumen dipertahankan sebagai arsip sejarah evolusi arsitektur dan ditandai secara eksplisit dengan banner `DOKUMEN HISTORIS`:
- [`docs/prd.md`](prd.md) — Product Requirements Document prototipe awal (29 September 2026).
- [`docs/ai.md`](ai.md) — Spesifikasi rekayasa backend awal berbasis FastAPI, SQLAlchemy, dan MySQL.
- [`docs/CMS_IMPLEMENTATION_SPEC.md`](CMS_IMPLEMENTATION_SPEC.md) — Dokumen RFC perbandingan awal modul CMS.
- [`docs/reports/legacy_nutriview/`](reports/legacy_nutriview/) — Laporan audit fase transisi NutriView.
