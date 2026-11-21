# OopsieEats — Business Requirements Document (BRD) Suite
**Identitas Aplikasi**: `com.oopsieeats.app` | **Versi**: `1.0.0+2002` (Target SDK 36, compileSdk 36)  
**Lead Software Architect**: Ahmad Badawi (NIM 20090015) — Universitas Bina Insani  
**Status**: Approved & Baselined | **Klasifikasi**: Confidential / Restricted

---

## 1. Ikhtisar Suite Dokumen
Dokumentasi Business Requirements Document (BRD) aplikasi mobile **OopsieEats** diterbitkan secara modular berdasarkan bab untuk menjamin kemudahan audit, keterbacaan, dan pemeliharaan jangka panjang. Seluruh dokumen tersedia dalam format ganda (**DOCX** dan **PDF**) dengan tata letak profesional, running header, running footer, dan penomoran halaman otomatis.

Dokumen gerbang utama:
- [BRD Master Index (.pdf)](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/OopsieEats/docs/brd/BRD_MASTER_INDEX.pdf)
- [BRD Master Index (.docx)](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/OopsieEats/docs/brd/BRD_MASTER_INDEX.docx)
- [BRD Master Index (.md)](file:///home/ahmadbadawi/Documents/CodinganKu/Flutter/OopsieEats/docs/brd/markdown_sources/BRD_MASTER_INDEX.md)

---

## 2. Struktur Direktori BRD
```
docs/brd/
├── BRD_MASTER_INDEX.pdf                 # Gerbang navigasi master, TOC, dan ringkasan eksekutif
├── BRD_MASTER_INDEX.docx                # Versi dokumen Word resmi
├── README.md                            # Panduan dokumentasi ini
├── DOCUMENTATION_CHANGELOG.md           # Catatan audit & histori transformasi BRD
├── chapters/                            # Berkas mandiri per bab (.docx & .pdf)
│   ├── BAB_01_PENDAHULUAN_DAN_DESAIN_SISTEM.pdf / .docx
│   ├── BAB_02_SETUP_LINGKUNGAN_PENGEMBANGAN.pdf / .docx
│   ├── BAB_03_IMPLEMENTASI_DATABASE_DAN_CMS.pdf / .docx
│   ├── BAB_04_IMPLEMENTASI_AUTENTIKASI_FIREBASE.pdf / .docx
│   ├── BAB_05_INTEGRASI_REPOSITORI_DAN_SERVICE.pdf / .docx
│   ├── BAB_06_PENGEMBANGAN_MOBILE_UI.pdf / .docx
│   ├── BAB_07_COMPUTER_VISION_DAN_DETEKSI_MAKANAN.pdf / .docx
│   ├── BAB_08_ANALITIKA_NUTRISI_DAN_VISUALISASI.pdf / .docx
│   ├── BAB_09_PENGUJIAN_OPTIMASI_DAN_DEPLOYMENT.pdf / .docx
│   └── LAMPIRAN_CHECKLIST_DAN_REFERENSI.pdf / .docx
├── diagrams/
│   ├── mermaid/                         # 20 berkas sumber native Mermaid (.mmd)
│   └── rendered/                        # 20 artefak render PNG resolusi tinggi
├── wireframes/
│   ├── original/                        # 19 tangkapan layar asli aplikasi (1080x2400)
│   └── monochrome/                      # 19 wireframe monokrom dengan border perangkat 1.5px
└── markdown_sources/                    # Berkas sumber teks Markdown lengkap
```

---

## 3. Register Bab & Jumlah Halaman
| Bab | Judul Dokumen | Berkas PDF & DOCX | Halaman | Status |
| :--- | :--- | :--- | :---: | :---: |
| Bab 1 | Pendahuluan dan Desain Sistem | `BAB_01_PENDAHULUAN_DAN_DESAIN_SISTEM.pdf` | 13 | Approved |
| Bab 2 | Setup Lingkungan Pengembangan | `BAB_02_SETUP_LINGKUNGAN_PENGEMBANGAN.pdf` | 6 | Approved |
| Bab 3 | Implementasi Database dan CMS | `BAB_03_IMPLEMENTASI_DATABASE_DAN_CMS.pdf` | 12 | Approved |
| Bab 4 | Implementasi Autentikasi Firebase | `BAB_04_IMPLEMENTASI_AUTENTIKASI_FIREBASE.pdf` | 6 | Approved |
| Bab 5 | Integrasi Repositori dan Service | `BAB_05_INTEGRASI_REPOSITORI_DAN_SERVICE.pdf` | 6 | Approved |
| Bab 6 | Pengembangan Mobile UI | `BAB_06_PENGEMBANGAN_MOBILE_UI.pdf` | 25 | Approved |
| Bab 7 | Computer Vision dan Deteksi Makanan | `BAB_07_COMPUTER_VISION_DAN_DETEKSI_MAKANAN.pdf` | 6 | Approved |
| Bab 8 | Analitika Nutrisi dan Visualisasi | `BAB_08_ANALITIKA_NUTRISI_DAN_VISUALISASI.pdf` | 5 | Approved |
| Bab 9 | Pengujian, Optimasi, dan Deployment | `BAB_09_PENGUJIAN_OPTIMASI_DAN_DEPLOYMENT.pdf` | 8 | Approved |
| Lampiran | Checklist dan Referensi Teknis | `LAMPIRAN_CHECKLIST_DAN_REFERENSI.pdf` | 7 | Approved |
| **Total** | **Seluruh 10 Modul Bab** | — | **94** | **Baselined** |

---

## 4. Jaminan Kualitas & Integritas Teknis
- **Dedicated Cover Pages**: Setiap bab dan Master Index memiliki halaman sampul depan resmi mandiri (Page 1) tanpa header/footer berulang, diikuti konten mulai Halaman 2 dengan running header/footer presisi (`Halaman X dari Y`).
- **Diagram UML & Arsitektur Lengkap**: 20 diagram native Mermaid (100% diagram coverage di setiap bab) terkompilasi ke format PNG tajam.
- **Automated Tests**: 359/359 tests passed (100% pass) terdistribusi pada 42 berkas pengujian.
- **Static Analysis**: 0 warnings, 0 errors pada eksekusi `flutter analyze --fatal-infos`.
- **Artefak Wireframe**: 19 wireframe monokrom diekstraksi dari kode aktual tanpa teks banner internal.
