# DOKUMEN KONTROL: Master Index & Navigasi Dokumen BRD

**Business Requirements Document Suite — Master Index, Hubungan Antar-Bab, dan Daftar Isi Terkonsolidasi**

---

**Aplikasi:** OopsieEats (`com.oopsieeats.app`) | **Versi:** 1.0.0+2002  
**Penyusun:** Ahmad Badawi (NIM 20090015) — Universitas Bina Insani  
**Status:** Approved & Baselined | **Klasifikasi:** Confidential / Restricted

---


## 1. Lembar Kontrol Dokumen & Identitas Proyek

Dokumen ini berfungsi sebagai Master Index dan gerbang kontrol utama (Central Document Registry) untuk seluruh suite Business Requirements Document (BRD) aplikasi mobile <strong>OopsieEats</strong>. Setiap bab diterbitkan sebagai dokumen mandiri (.docx dan .pdf) berstatus resmi untuk kemudahan penelaahan modular lintas divisi rekayasa perangkat lunak.

**Tabel M.1: Kontrol Metadata Dokumen Resmi Proyek**

| Parameter Metadata | Nilai Konfigurasi Resmi | Keterangan Audit |
| --- | --- | --- |
| Nama Aplikasi Resmi | OopsieEats | Evolusi dari riset arsitektur awal NutriView |
| Application Package ID | com.oopsieeats.app | Kunci identitas unik Google Play Store & Android Ecosystem |
| Nomor Versi / Build | 1.0.0+2002 (Target SDK 36, compileSdk 36) | Kepatuhan penuh standar Google Play API 2026 |
| Target Platform | Android (minSdk 23) & iOS (iOS 13.0+) | Cakupan 99.2% perangkat seluler aktif global |
| Penyusun & Architect | Ahmad Badawi (NIM 20090015) | Lead Software Architect & Full-Stack Mobile Engineer |
| Institusi Akademis | Universitas Bina Insani — Sistem Informasi | Dokumentasi Tugas Akhir & Rekayasa Perangkat Lunak 2026 |
| Status Dokumen | DISETUJUI (APPROVED & BASELINED) | Status rilis resmi untuk audit dan evaluasi produksi |
| Klasifikasi Akses | CONFIDENTIAL / RESTRICTED | Hanya untuk keperluan evaluasi internal dan tim rekayasa |
| Integritas Pengujian | 359 Automated Tests Passed (100% Pass) | 0 Lint Issues pada eksekusi flutter analyze --fatal-infos |
| Total Halaman Suite BRD | 94 Halaman (Terdistribusi) | Tergolong ke dalam 10 dokumen bab mandiri + Master Index |


## 2. Ringkasan Eksekutif (Executive Summary)

OopsieEats adalah aplikasi mobile pelacak nutrisi dan pengenalan makanan pintar berbasis Flutter yang mengintegrasikan kecerdasan buatan on-device (YOLOv8 Nano TFLite, 9.4 MB) dengan basis data resmi Tabel Komposisi Pangan Indonesia (TKPI 2020) dari Kementerian Kesehatan Republik Indonesia. Aplikasi ini mengeliminasi friksi pencatatan kalori konvensional yang memakan waktu melalui tiga inovasi pilar:

- <strong>Inferensi AI On-Device (< 300 ms)</strong>: Deteksi visual 29 kelas hidangan nusantara diproses 100% pada CPU/NPU lokal perangkat melalui background isolate (Isolate.run), menjamin privasi visual mutlak dan ketahanan luring (offline-first).
- <strong>Kalkulasi Gizi Deterministik & Aman</strong>: Penentuan target metabolisme basal (BMR) dan pengeluaran energi (TDEE) dieksekusi secara matematis via persamaan Mifflin-St Jeor dengan perlindungan Safe Calorie Floor (1.500 kcal pria / 1.200 kcal wanita) serta faktor konversi Atwater 4-4-9.
- <strong>Arsitektur Nirserver Berbiaya $0</strong>: Memanfaatkan integrasi ganda Cloud Firestore (asia-southeast2) untuk data dokumen terstruktur dan Supabase Storage (ap-southeast-1) untuk foto riwayat makan privat berbatas waktu (Signed URLs).


## 3. Peta Struktur Bab & Panduan Membaca (Reading Guide)

Suite dokumen BRD OopsieEats dipisahkan menjadi 10 modul independen agar setiap pemangku kepentingan dapat fokus menelaah bab yang relevan dengan bidang keahliannya:

**Tabel M.2: Panduan Membaca Dokumen Berdasarkan Peran Pemangku Kepentingan**

| Peran Pemangku Kepentingan | Bab Rekomendasi Utama | Fokus Telaah Kritis |
| --- | --- | --- |
| Auditor Akademis / Penguji | Bab 1, Bab 6, Bab 9, Lampiran | Kesesuaian masalah, wireframe monokrom, bukti uji 359 tests, traceability matrix |
| Software Architect | Bab 1, Bab 3, Bab 5, Bab 9 | Arsitektur berlapis, skema Firestore, Repository Pattern, profiling kinerja |
| Mobile UI/UX Engineer | Bab 1, Bab 6 | Desain Overkill Neo-Brutalism, 19 wireframe layar, state management Provider |
| Machine Learning Engineer | Bab 5, Bab 7, Lampiran C | Pipeline TFLite, normalisasi tensor, isolate offloading, mAP50 29 kelas pangan |
| Backend & Cloud Engineer | Bab 2, Bab 3, Bab 4, Bab 5 | Setup multi-flavor, Firestore Security Rules RBAC, Supabase Storage RLS policy |
| Security & Privacy Auditor | Bab 3, Bab 4, Bab 9 | Hardware KeyStore/Keychain, complete profile guard, alur hapus akun UU PDP |


## 4. Master Table of Contents (Daftar Isi Konsolidasi Suite)

Daftar rincian bab, rentang penomoran halaman, dan jumlah halaman per berkas dokumen mandiri dalam direktori <code>docs/brd/chapters/</code>:

- <strong>Bab 1: Pendahuluan dan Desain Sistem</strong> ........... 13 Halaman
- <strong>Bab 2: Setup Lingkungan Pengembangan</strong> ........... 6 Halaman
- <strong>Bab 3: Implementasi Database dan CMS</strong> ........... 12 Halaman
- <strong>Bab 4: Implementasi Autentikasi Firebase</strong> ....... 6 Halaman
- <strong>Bab 5: Integrasi Repositori dan Service</strong> ........ 6 Halaman
- <strong>Bab 6: Pengembangan Mobile UI</strong> .................. 25 Halaman
- <strong>Bab 7: Computer Vision dan Deteksi Makanan</strong> ..... 6 Halaman
- <strong>Bab 8: Analitika Nutrisi dan Visualisasi</strong> ....... 5 Halaman
- <strong>Bab 9: Pengujian, Optimasi, dan Deployment</strong> ..... 8 Halaman
- <strong>Lampiran: Checklist dan Referensi Teknis</strong> ....... 7 Halaman


## 5. Registry Berkas Dokumen Resmi (Document File Registry)

Tabel kendali berkas fisik dokumen yang diterbitkan dalam suite BRD beserta ukuran halaman dan checksum integritas:

**Tabel M.3: Register Berkas Fisik Bab BRD dalam direktori `docs/brd/chapters/`**

| Bab | Nama Berkas Mandiri (.pdf & .docx) | Jumlah Halaman | Checksum SHA-256 (PDF) | Status Rilis |
| --- | --- | --- | --- | --- |
| Bab 1 | <code>BAB_01_PENDAHULUAN_DAN_DESAIN_SISTEM.pdf</code><br><code>BAB_01_PENDAHULUAN_DAN_DESAIN_SISTEM.docx</code> | 13 Halaman | <code>334eab59d74feacc...</code> | Resmi (Approved) |
| Bab 2 | <code>BAB_02_SETUP_LINGKUNGAN_PENGEMBANGAN.pdf</code><br><code>BAB_02_SETUP_LINGKUNGAN_PENGEMBANGAN.docx</code> | 6 Halaman | <code>c3ed1545cf1b93ad...</code> | Resmi (Approved) |
| Bab 3 | <code>BAB_03_IMPLEMENTASI_DATABASE_DAN_CMS.pdf</code><br><code>BAB_03_IMPLEMENTASI_DATABASE_DAN_CMS.docx</code> | 12 Halaman | <code>11341798b2764465...</code> | Resmi (Approved) |
| Bab 4 | <code>BAB_04_IMPLEMENTASI_AUTENTIKASI_FIREBASE.pdf</code><br><code>BAB_04_IMPLEMENTASI_AUTENTIKASI_FIREBASE.docx</code> | 6 Halaman | <code>75d7fa3fb9bdfb6c...</code> | Resmi (Approved) |
| Bab 5 | <code>BAB_05_INTEGRASI_REPOSITORI_DAN_SERVICE.pdf</code><br><code>BAB_05_INTEGRASI_REPOSITORI_DAN_SERVICE.docx</code> | 6 Halaman | <code>47465c03e0a3c50d...</code> | Resmi (Approved) |
| Bab 6 | <code>BAB_06_PENGEMBANGAN_MOBILE_UI.pdf</code><br><code>BAB_06_PENGEMBANGAN_MOBILE_UI.docx</code> | 25 Halaman | <code>6a30777d36bbaed9...</code> | Resmi (Approved) |
| Bab 7 | <code>BAB_07_COMPUTER_VISION_DAN_DETEKSI_MAKANAN.pdf</code><br><code>BAB_07_COMPUTER_VISION_DAN_DETEKSI_MAKANAN.docx</code> | 6 Halaman | <code>07fc721a6c539b99...</code> | Resmi (Approved) |
| Bab 8 | <code>BAB_08_ANALITIKA_NUTRISI_DAN_VISUALISASI.pdf</code><br><code>BAB_08_ANALITIKA_NUTRISI_DAN_VISUALISASI.docx</code> | 5 Halaman | <code>773fba31845d1ef4...</code> | Resmi (Approved) |
| Bab 9 | <code>BAB_09_PENGUJIAN_OPTIMASI_DAN_DEPLOYMENT.pdf</code><br><code>BAB_09_PENGUJIAN_OPTIMASI_DAN_DEPLOYMENT.docx</code> | 8 Halaman | <code>f830bf27de5cd58b...</code> | Resmi (Approved) |
| Lampiran | <code>LAMPIRAN_CHECKLIST_DAN_REFERENSI.pdf</code><br><code>LAMPIRAN_CHECKLIST_DAN_REFERENSI.docx</code> | 7 Halaman | <code>10a0bf31c6725069...</code> | Resmi (Approved) |


## 6. Daftar Master Diagram Arsitektur & UML (20 Diagram Native Mermaid)

Seluruh 20 diagram teknis dan UML dirancang menggunakan format native Mermaid (.mmd) dan dirender menjadi gambar PNG beresolusi tinggi di dalam direktori <code>docs/brd/diagrams/</code>. Setiap bab dalam suite dokumen BRD ini dijamin memiliki setidaknya satu diagram teknis/UML yang relevan dan representatif:

**Tabel M.4: Katalog Lengkap 20 Diagram Arsitektur & UML dan Penempatannya**

| No | Nama Diagram Teknis / UML | Berkas Sumber (.mmd) | Artefak Render (.png) | Penempatan Bab |
| --- | --- | --- | --- | --- |
| 1 | System Context Diagram (C4 Context) | diagrams/mermaid/system-context.mmd | diagrams/rendered/system-context.png | Bab 1 (Gambar 1.2) |
| 2 | Business Process (As-Is vs To-Be) | diagrams/mermaid/business-process-as-is-to-be.mmd | diagrams/rendered/business-process-as-is-to-be.png | Bab 1 (Gambar 1.1) |
| 3 | Layered Application Architecture | diagrams/mermaid/architecture.mmd | diagrams/rendered/architecture.png | Bab 1 (Gambar 1.3) |
| 4 | Multi-Cloud Deployment Topology | diagrams/mermaid/deployment-topology.mmd | diagrams/rendered/deployment-topology.png | Bab 1 (Gambar 1.4) |
| 5 | Use Case Diagram | diagrams/mermaid/use-case.mmd | diagrams/rendered/use-case.png | Bab 1 (Gambar 1.5) |
| 6 | UML Component Diagram: Build & Toolchain | diagrams/mermaid/uml-build-toolchain.mmd | diagrams/rendered/uml-build-toolchain.png | Bab 2 (Gambar 2.1) |
| 7 | Database ERD (Cloud Firestore) | diagrams/mermaid/database-erd.mmd | diagrams/rendered/database-erd.png | Bab 3 (Gambar 3.1) |
| 8 | Database Schema Hierarchy | diagrams/mermaid/database-schema.mmd | diagrams/rendered/database-schema.png | Bab 3 (Gambar 3.2) |
| 9 | UML Class Diagram: Firestore Domain Models | diagrams/mermaid/uml-firestore-models.mmd | diagrams/rendered/uml-firestore-models.png | Bab 3 (Gambar 3.3) |
| 10 | Security Rules RBAC Decision Tree | diagrams/mermaid/security-rules-rbac.mmd | diagrams/rendered/security-rules-rbac.png | Bab 3 (Gambar 3.4) |
| 11 | Token Security & Session Flow | diagrams/mermaid/token-security-flow.mmd | diagrams/rendered/token-security-flow.png | Bab 4 (Gambar 4.1) |
| 12 | Sequence Diagram: Account Deletion (UU PDP) | diagrams/mermaid/sequence-deletion.mmd | diagrams/rendered/sequence-deletion.png | Bab 4 (Gambar 4.2) |
| 13 | Offline Storage & Caching Architecture | diagrams/mermaid/offline-storage-cache.mmd | diagrams/rendered/offline-storage-cache.png | Bab 5 (Gambar 5.1) |
| 14 | UML Class Diagram: Repository Pattern | diagrams/mermaid/uml-repository-class.mmd | diagrams/rendered/uml-repository-class.png | Bab 5 (Gambar 5.2) |
| 15 | Navigation Flow & Route Tree | diagrams/mermaid/navigation-flow.mmd | diagrams/rendered/navigation-flow.png | Bab 6 (Gambar 6.0) |
| 16 | UML State Machine Diagram: UI Lifecycle | diagrams/mermaid/uml-ui-state-machine.mmd | diagrams/rendered/uml-ui-state-machine.png | Bab 6 (Gambar 6.0b) |
| 17 | Sequence Diagram: CV Meal Logging & AI Pipeline | diagrams/mermaid/sequence-scan.mmd | diagrams/rendered/sequence-scan.png | Bab 7 (Gambar 7.1) |
| 18 | UML Sequence Diagram: Nutrition & Safe Calorie Floor | diagrams/mermaid/uml-nutrition-calc-sequence.mmd | diagrams/rendered/uml-nutrition-calc-sequence.png | Bab 8 (Gambar 8.1) |
| 19 | UML Activity Diagram: System Lifecycle & QA | diagrams/mermaid/activity-diagram.mmd | diagrams/rendered/activity-diagram.png | Bab 9 (Gambar 9.1) |
| 20 | UML Package & Traceability Diagram | diagrams/mermaid/uml-system-traceability.mmd | diagrams/rendered/uml-system-traceability.png | Lampiran (Gambar L.1) |


## 7. Daftar Master Wireframe Layar (19 Layar Aplikasi Nyata)

Katalog lengkap 19 wireframe monokrom yang diekstraksi dari tangkapan layar aplikasi riil tanpa banner teks internal, ditempatkan secara sistematis pada Bab 6:

**Tabel M.5: Katalog 19 Layar Aplikasi dan Penomoran Gambar Wireframe**

| No | Nama Layar Aplikasi | Nomor Gambar Resmi | Berkas Wireframe Monokrom | Kategori Alur |
| --- | --- | --- | --- | --- |
| 1 | Onboarding Slide 1 (Deteksi AI) | Gambar 6.1 | 01_onboarding_slide1-wireframe.png | Onboarding Walkthrough |
| 2 | Onboarding Slide 2 (Kalkulasi Ilmiah) | Gambar 6.2 | 02_onboarding_slide2-wireframe.png | Onboarding Walkthrough |
| 3 | Onboarding Slide 3 (Privasi & CTA) | Gambar 6.3 | 03_onboarding_slide3-wireframe.png | Onboarding Walkthrough |
| 4 | Splash Screen (Pemuatan Sistem) | Gambar 6.4 | 04_splash_screen-wireframe.png | Inisialisasi |
| 5 | Register Screen (Registrasi Akun) | Gambar 6.5 | 05_register_screen-wireframe.png | Autentikasi |
| 6 | Complete Profile Screen (Guard Fisik) | Gambar 6.6 | 06_complete_profile-wireframe.png | Autentikasi & Guard |
| 7 | Login Screen (Masuk Pengguna) | Gambar 6.7 | 07_login_screen-wireframe.png | Autentikasi |
| 8 | Dashboard / Home Screen (Beranda) | Gambar 6.8 | 08_dashboard_home-wireframe.png | Dasbor Utama |
| 9 | Scanner Viewfinder (Kamera Pemindai) | Gambar 6.9 | 09_scanner_viewfinder-wireframe.png | Pemindai Makanan |
| 10 | Detection Confirmation (Konfirmasi AI) | Gambar 6.10 | 10_detection_confirmation-wireframe.png | Pemindai Makanan |
| 11 | Portion Input Screen (Gramasi Porsi) | Gambar 6.11 | 11_portion_input-wireframe.png | Pemindai Makanan |
| 12 | Meal History Screen (Riwayat Makan) | Gambar 6.12 | 12_meal_history-wireframe.png | Riwayat & Pelacakan |
| 13 | Nutrition Analysis Screen (Grafik Gizi) | Gambar 6.13 | 13_nutrition_analysis-wireframe.png | Analitika & Tren |
| 14 | User Profile Screen (Profil Akun) | Gambar 6.14 | 14_user_profile-wireframe.png | Manajemen Akun |
| 15 | Nutrition Articles (Katalog Edukasi) | Gambar 6.15 | 15_nutrition_articles-wireframe.png | Literasi Gizi |
| 16 | Article Detail Screen (Detail Artikel) | Gambar 6.16 | 16_article_detail-wireframe.png | Literasi Gizi |
| 17 | Avatar Selection Dialog (Modal Avatar) | Gambar 6.17 | 17_avatar_dialog-wireframe.png | Kustomisasi Profil |
| 18 | Delete Account Dialog (Modal Hapus) | Gambar 6.18 | 18_delete_account_dialog-wireframe.png | Privasi & UU PDP |
| 19 | Admin Dashboard Screen (Portal CMS) | Gambar 6.19 | 19_admin_dashboard-wireframe.png | Administrasi CMS |
