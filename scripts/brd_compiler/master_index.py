"""
Master Index Generator for OopsieEats Professional BRD Suite.
Generates BRD_MASTER_INDEX.docx, BRD_MASTER_INDEX.pdf, and BRD_MASTER_INDEX.md
with exact page numbers, dot leaders, document registry, and diagram/table/figure lists.
"""

import os
import hashlib
from scripts.brd_compiler.builder import ChapterContent

def get_file_sha256(filepath):
    if not os.path.exists(filepath):
        return "N/A"
    h = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()[:16] + "..."

def build_master_index(chapter_metadata_list):
    """
    chapter_metadata_list: list of dicts:
    {
      'id': 'BAB_01',
      'num': 'Bab 1',
      'title': 'Pendahuluan dan Desain Sistem',
      'filename': 'BAB_01_PENDAHULUAN_DAN_DESAIN_SISTEM',
      'pages': int,
      'docx_path': str,
      'pdf_path': str
    }
    """
    total_suite_pages = sum(item['pages'] for item in chapter_metadata_list)

    ch = ChapterContent(
        chapter_id="MASTER_INDEX",
        number_str="Dokumen Kontrol",
        title="Master Index & Navigasi Dokumen BRD",
        subtitle="Business Requirements Document Suite — Master Index, Hubungan Antar-Bab, dan Daftar Isi Terkonsolidasi",
        filename="BRD_MASTER_INDEX"
    )

    # 1. Kontrol Dokumen & Identitas Proyek
    ch.add_h2("1. Lembar Kontrol Dokumen & Identitas Proyek")
    ch.add_p(
        "Dokumen ini berfungsi sebagai Master Index dan gerbang kontrol utama (Central Document Registry) untuk "
        "seluruh suite Business Requirements Document (BRD) aplikasi mobile <strong>OopsieEats</strong>. "
        "Setiap bab diterbitkan sebagai dokumen mandiri (.docx dan .pdf) berstatus resmi untuk kemudahan "
        "penelaahan modular lintas divisi rekayasa perangkat lunak."
    )
    ch.add_table(
        caption="Tabel M.1: Kontrol Metadata Dokumen Resmi Proyek",
        headers=["Parameter Metadata", "Nilai Konfigurasi Resmi", "Keterangan Audit"],
        rows=[
            ["Nama Aplikasi Resmi", "OopsieEats", "Evolusi dari riset arsitektur awal NutriView"],
            ["Application Package ID", "com.oopsieeats.app", "Kunci identitas unik Google Play Store & Android Ecosystem"],
            ["Nomor Versi / Build", "1.0.0+2002 (Target SDK 36, compileSdk 36)", "Kepatuhan penuh standar Google Play API 2026"],
            ["Target Platform", "Android (minSdk 23) & iOS (iOS 13.0+)", "Cakupan 99.2% perangkat seluler aktif global"],
            ["Penyusun & Architect", "Ahmad Badawi (NIM 20090015)", "Lead Software Architect & Full-Stack Mobile Engineer"],
            ["Institusi Akademis", "Universitas Bina Insani — Sistem Informasi", "Dokumentasi Tugas Akhir & Rekayasa Perangkat Lunak 2026"],
            ["Status Dokumen", "DISETUJUI (APPROVED & BASELINED)", "Status rilis resmi untuk audit dan evaluasi produksi"],
            ["Klasifikasi Akses", "CONFIDENTIAL / RESTRICTED", "Hanya untuk keperluan evaluasi internal dan tim rekayasa"],
            ["Integritas Pengujian", "359 Automated Tests Passed (100% Pass)", "0 Lint Issues pada eksekusi flutter analyze --fatal-infos"],
            ["Total Halaman Suite BRD", f"{total_suite_pages} Halaman (Terdistribusi)", "Tergolong ke dalam 10 dokumen bab mandiri + Master Index"]
        ]
    )

    # 2. Ringkasan Eksekutif
    ch.add_h2("2. Ringkasan Eksekutif (Executive Summary)")
    ch.add_p(
        "OopsieEats adalah aplikasi mobile pelacak nutrisi dan pengenalan makanan pintar berbasis Flutter yang "
        "mengintegrasikan kecerdasan buatan on-device (YOLOv8 Nano TFLite, 9.4 MB) dengan basis data resmi "
        "Tabel Komposisi Pangan Indonesia (TKPI 2020) dari Kementerian Kesehatan Republik Indonesia. "
        "Aplikasi ini mengeliminasi friksi pencatatan kalori konvensional yang memakan waktu melalui tiga inovasi pilar:"
    )
    ch.add_list([
        "<strong>Inferensi AI On-Device (< 300 ms)</strong>: Deteksi visual 29 kelas hidangan nusantara diproses 100% pada CPU/NPU lokal perangkat melalui background isolate (Isolate.run), menjamin privasi visual mutlak dan ketahanan luring (offline-first).",
        "<strong>Kalkulasi Gizi Deterministik & Aman</strong>: Penentuan target metabolisme basal (BMR) dan pengeluaran energi (TDEE) dieksekusi secara matematis via persamaan Mifflin-St Jeor dengan perlindungan Safe Calorie Floor (1.500 kcal pria / 1.200 kcal wanita) serta faktor konversi Atwater 4-4-9.",
        "<strong>Arsitektur Nirserver Berbiaya $0</strong>: Memanfaatkan integrasi ganda Cloud Firestore (asia-southeast2) untuk data dokumen terstruktur dan Supabase Storage (ap-southeast-1) untuk foto riwayat makan privat berbatas waktu (Signed URLs)."
    ])

    # 3. Peta Struktur Bab & Panduan Membaca
    ch.add_h2("3. Peta Struktur Bab & Panduan Membaca (Reading Guide)")
    ch.add_p(
        "Suite dokumen BRD OopsieEats dipisahkan menjadi 10 modul independen agar setiap pemangku kepentingan "
        "dapat fokus menelaah bab yang relevan dengan bidang keahliannya:"
    )
    ch.add_table(
        caption="Tabel M.2: Panduan Membaca Dokumen Berdasarkan Peran Pemangku Kepentingan",
        headers=["Peran Pemangku Kepentingan", "Bab Rekomendasi Utama", "Fokus Telaah Kritis"],
        rows=[
            ["Auditor Akademis / Penguji", "Bab 1, Bab 6, Bab 9, Lampiran", "Kesesuaian masalah, wireframe monokrom, bukti uji 359 tests, traceability matrix"],
            ["Software Architect", "Bab 1, Bab 3, Bab 5, Bab 9", "Arsitektur berlapis, skema Firestore, Repository Pattern, profiling kinerja"],
            ["Mobile UI/UX Engineer", "Bab 1, Bab 6", "Desain Overkill Neo-Brutalism, 19 wireframe layar, state management Provider"],
            ["Machine Learning Engineer", "Bab 5, Bab 7, Lampiran C", "Pipeline TFLite, normalisasi tensor, isolate offloading, mAP50 29 kelas pangan"],
            ["Backend & Cloud Engineer", "Bab 2, Bab 3, Bab 4, Bab 5", "Setup multi-flavor, Firestore Security Rules RBAC, Supabase Storage RLS policy"],
            ["Security & Privacy Auditor", "Bab 3, Bab 4, Bab 9", "Hardware KeyStore/Keychain, complete profile guard, alur hapus akun UU PDP"]
        ]
    )

    # 4. Master Table of Contents
    ch.add_h2("4. Master Table of Contents (Daftar Isi Konsolidasi Suite)")
    ch.add_p(
        "Daftar rincian bab, rentang penomoran halaman, dan jumlah halaman per berkas dokumen mandiri dalam direktori <code>docs/brd/chapters/</code>:"
    )

    # Build TOC with dot leaders
    toc_lines = []
    current_page_accum = 1
    for item in chapter_metadata_list:
        start_p = current_page_accum
        end_p = current_page_accum + item['pages'] - 1
        current_page_accum += item['pages']
        item['page_range'] = f"Hal. 1 – {item['pages']} (Kumulatif: Hal. {start_p} – {end_p})"
        dots = "." * (45 - len(item['num']) - len(item['title']))
        if len(dots) < 5:
            dots = "....."
        toc_lines.append(f"<strong>{item['num']}: {item['title']}</strong> {dots} {item['pages']} Halaman")

    ch.add_list(toc_lines)

    # 5. Registry Berkas Dokumen Resmi
    ch.add_h2("5. Registry Berkas Dokumen Resmi (Document File Registry)")
    ch.add_p(
        "Tabel kendali berkas fisik dokumen yang diterbitkan dalam suite BRD beserta ukuran halaman dan checksum integritas:"
    )
    reg_rows = []
    for item in chapter_metadata_list:
        pdf_name = f"{item['filename']}.pdf"
        docx_name = f"{item['filename']}.docx"
        sha_pdf = get_file_sha256(item['pdf_path'])
        reg_rows.append([
            f"{item['num']}",
            f"<code>{pdf_name}</code><br><code>{docx_name}</code>",
            f"{item['pages']} Halaman",
            f"<code>{sha_pdf}</code>",
            "Resmi (Approved)"
        ])

    ch.add_table(
        caption="Tabel M.3: Register Berkas Fisik Bab BRD dalam direktori `docs/brd/chapters/`",
        headers=["Bab", "Nama Berkas Mandiri (.pdf & .docx)", "Jumlah Halaman", "Checksum SHA-256 (PDF)", "Status Rilis"],
        rows=reg_rows
    )

    # 6. Daftar Master Diagram Arsitektur & UML
    ch.add_h2("6. Daftar Master Diagram Arsitektur & UML (20 Diagram Native Mermaid)")
    ch.add_p(
        "Seluruh 20 diagram teknis dan UML dirancang menggunakan format native Mermaid (.mmd) dan dirender menjadi gambar PNG "
        "beresolusi tinggi di dalam direktori <code>docs/brd/diagrams/</code>. Setiap bab dalam suite dokumen BRD ini "
        "dijamin memiliki setidaknya satu diagram teknis/UML yang relevan dan representatif:"
    )
    ch.add_table(
        caption="Tabel M.4: Katalog Lengkap 20 Diagram Arsitektur & UML dan Penempatannya",
        headers=["No", "Nama Diagram Teknis / UML", "Berkas Sumber (.mmd)", "Artefak Render (.png)", "Penempatan Bab"],
        rows=[
            ["1", "System Context Diagram (C4 Context)", "diagrams/mermaid/system-context.mmd", "diagrams/rendered/system-context.png", "Bab 1 (Gambar 1.2)"],
            ["2", "Business Process (As-Is vs To-Be)", "diagrams/mermaid/business-process-as-is-to-be.mmd", "diagrams/rendered/business-process-as-is-to-be.png", "Bab 1 (Gambar 1.1)"],
            ["3", "Layered Application Architecture", "diagrams/mermaid/architecture.mmd", "diagrams/rendered/architecture.png", "Bab 1 (Gambar 1.3)"],
            ["4", "Multi-Cloud Deployment Topology", "diagrams/mermaid/deployment-topology.mmd", "diagrams/rendered/deployment-topology.png", "Bab 1 (Gambar 1.4)"],
            ["5", "Use Case Diagram", "diagrams/mermaid/use-case.mmd", "diagrams/rendered/use-case.png", "Bab 1 (Gambar 1.5)"],
            ["6", "UML Component Diagram: Build & Toolchain", "diagrams/mermaid/uml-build-toolchain.mmd", "diagrams/rendered/uml-build-toolchain.png", "Bab 2 (Gambar 2.1)"],
            ["7", "Database ERD (Cloud Firestore)", "diagrams/mermaid/database-erd.mmd", "diagrams/rendered/database-erd.png", "Bab 3 (Gambar 3.1)"],
            ["8", "Database Schema Hierarchy", "diagrams/mermaid/database-schema.mmd", "diagrams/rendered/database-schema.png", "Bab 3 (Gambar 3.2)"],
            ["9", "UML Class Diagram: Firestore Domain Models", "diagrams/mermaid/uml-firestore-models.mmd", "diagrams/rendered/uml-firestore-models.png", "Bab 3 (Gambar 3.3)"],
            ["10", "Security Rules RBAC Decision Tree", "diagrams/mermaid/security-rules-rbac.mmd", "diagrams/rendered/security-rules-rbac.png", "Bab 3 (Gambar 3.4)"],
            ["11", "Token Security & Session Flow", "diagrams/mermaid/token-security-flow.mmd", "diagrams/rendered/token-security-flow.png", "Bab 4 (Gambar 4.1)"],
            ["12", "Sequence Diagram: Account Deletion (UU PDP)", "diagrams/mermaid/sequence-deletion.mmd", "diagrams/rendered/sequence-deletion.png", "Bab 4 (Gambar 4.2)"],
            ["13", "Offline Storage & Caching Architecture", "diagrams/mermaid/offline-storage-cache.mmd", "diagrams/rendered/offline-storage-cache.png", "Bab 5 (Gambar 5.1)"],
            ["14", "UML Class Diagram: Repository Pattern", "diagrams/mermaid/uml-repository-class.mmd", "diagrams/rendered/uml-repository-class.png", "Bab 5 (Gambar 5.2)"],
            ["15", "Navigation Flow & Route Tree", "diagrams/mermaid/navigation-flow.mmd", "diagrams/rendered/navigation-flow.png", "Bab 6 (Gambar 6.0)"],
            ["16", "UML State Machine Diagram: UI Lifecycle", "diagrams/mermaid/uml-ui-state-machine.mmd", "diagrams/rendered/uml-ui-state-machine.png", "Bab 6 (Gambar 6.0b)"],
            ["17", "Sequence Diagram: CV Meal Logging & AI Pipeline", "diagrams/mermaid/sequence-scan.mmd", "diagrams/rendered/sequence-scan.png", "Bab 7 (Gambar 7.1)"],
            ["18", "UML Sequence Diagram: Nutrition & Safe Calorie Floor", "diagrams/mermaid/uml-nutrition-calc-sequence.mmd", "diagrams/rendered/uml-nutrition-calc-sequence.png", "Bab 8 (Gambar 8.1)"],
            ["19", "UML Activity Diagram: System Lifecycle & QA", "diagrams/mermaid/activity-diagram.mmd", "diagrams/rendered/activity-diagram.png", "Bab 9 (Gambar 9.1)"],
            ["20", "UML Package & Traceability Diagram", "diagrams/mermaid/uml-system-traceability.mmd", "diagrams/rendered/uml-system-traceability.png", "Lampiran (Gambar L.1)"]
        ]
    )

    # 7. Daftar Master Wireframe Layar
    ch.add_h2("7. Daftar Master Wireframe Layar (19 Layar Aplikasi Nyata)")
    ch.add_p(
        "Katalog lengkap 19 wireframe monokrom yang diekstraksi dari tangkapan layar aplikasi riil tanpa banner teks internal, "
        "ditempatkan secara sistematis pada Bab 6:"
    )
    ch.add_table(
        caption="Tabel M.5: Katalog 19 Layar Aplikasi dan Penomoran Gambar Wireframe",
        headers=["No", "Nama Layar Aplikasi", "Nomor Gambar Resmi", "Berkas Wireframe Monokrom", "Kategori Alur"],
        rows=[
            ["1", "Onboarding Slide 1 (Deteksi AI)", "Gambar 6.1", "01_onboarding_slide1-wireframe.png", "Onboarding Walkthrough"],
            ["2", "Onboarding Slide 2 (Kalkulasi Ilmiah)", "Gambar 6.2", "02_onboarding_slide2-wireframe.png", "Onboarding Walkthrough"],
            ["3", "Onboarding Slide 3 (Privasi & CTA)", "Gambar 6.3", "03_onboarding_slide3-wireframe.png", "Onboarding Walkthrough"],
            ["4", "Splash Screen (Pemuatan Sistem)", "Gambar 6.4", "04_splash_screen-wireframe.png", "Inisialisasi"],
            ["5", "Register Screen (Registrasi Akun)", "Gambar 6.5", "05_register_screen-wireframe.png", "Autentikasi"],
            ["6", "Complete Profile Screen (Guard Fisik)", "Gambar 6.6", "06_complete_profile-wireframe.png", "Autentikasi & Guard"],
            ["7", "Login Screen (Masuk Pengguna)", "Gambar 6.7", "07_login_screen-wireframe.png", "Autentikasi"],
            ["8", "Dashboard / Home Screen (Beranda)", "Gambar 6.8", "08_dashboard_home-wireframe.png", "Dasbor Utama"],
            ["9", "Scanner Viewfinder (Kamera Pemindai)", "Gambar 6.9", "09_scanner_viewfinder-wireframe.png", "Pemindai Makanan"],
            ["10", "Detection Confirmation (Konfirmasi AI)", "Gambar 6.10", "10_detection_confirmation-wireframe.png", "Pemindai Makanan"],
            ["11", "Portion Input Screen (Gramasi Porsi)", "Gambar 6.11", "11_portion_input-wireframe.png", "Pemindai Makanan"],
            ["12", "Meal History Screen (Riwayat Makan)", "Gambar 6.12", "12_meal_history-wireframe.png", "Riwayat & Pelacakan"],
            ["13", "Nutrition Analysis Screen (Grafik Gizi)", "Gambar 6.13", "13_nutrition_analysis-wireframe.png", "Analitika & Tren"],
            ["14", "User Profile Screen (Profil Akun)", "Gambar 6.14", "14_user_profile-wireframe.png", "Manajemen Akun"],
            ["15", "Nutrition Articles (Katalog Edukasi)", "Gambar 6.15", "15_nutrition_articles-wireframe.png", "Literasi Gizi"],
            ["16", "Article Detail Screen (Detail Artikel)", "Gambar 6.16", "16_article_detail-wireframe.png", "Literasi Gizi"],
            ["17", "Avatar Selection Dialog (Modal Avatar)", "Gambar 6.17", "17_avatar_dialog-wireframe.png", "Kustomisasi Profil"],
            ["18", "Delete Account Dialog (Modal Hapus)", "Gambar 6.18", "18_delete_account_dialog-wireframe.png", "Privasi & UU PDP"],
            ["19", "Admin Dashboard Screen (Portal CMS)", "Gambar 6.19", "19_admin_dashboard-wireframe.png", "Administrasi CMS"]
        ]
    )

    return ch
