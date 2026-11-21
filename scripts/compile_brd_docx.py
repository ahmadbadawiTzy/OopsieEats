import os
import re
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

DOC_DIR = "docs/brd"
INPUT_MD = os.path.join(DOC_DIR, "NutriView_BRD_Project_Report.md")
OUTPUT_DOCX = os.path.join(DOC_DIR, "BRD_NutriView_Final.docx")

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    tcPr.append(parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>'))

def set_cell_margins(cell, top=120, bottom=120, left=180, right=180):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(
        f'<w:tcMar {nsdecls("w")}>'
        f'<w:top w:w="{top}" w:type="dxa"/>'
        f'<w:bottom w:w="{bottom}" w:type="dxa"/>'
        f'<w:left w:w="{left}" w:type="dxa"/>'
        f'<w:right w:w="{right}" w:type="dxa"/>'
        f'</w:tcMar>'
    )
    tcPr.append(tcMar)

def set_table_borders(table, color="CBD5E1", sz="4", val="single"):
    tblPr = table._tbl.tblPr
    tblBorders = parse_xml(
        f'<w:tblBorders {nsdecls("w")}>'
        f'<w:top w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'<w:bottom w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'<w:left w:val="none"/>'
        f'<w:right w:val="none"/>'
        f'<w:insideH w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>'
        f'<w:insideV w:val="none"/>'
        f'</w:tblBorders>'
    )
    tblPr.append(tblBorders)

def add_page_number_to_run(run):
    fldSimple = OxmlElement('w:fldSimple')
    fldSimple.set(qn('w:instr'), 'PAGE')
    run._r.append(fldSimple)

def add_numpages_to_run(run):
    fldSimple = OxmlElement('w:fldSimple')
    fldSimple.set(qn('w:instr'), 'NUMPAGES')
    run._r.append(fldSimple)

def add_callout(doc, text, title="CATATAN TEKNIS", color="2563EB", bg="EFF6FF"):
    tbl = doc.add_table(rows=1, cols=1)
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    cell = tbl.cell(0, 0)
    set_cell_background(cell, bg)
    
    tcPr = cell._tc.get_or_add_tcPr()
    borders = parse_xml(
        f'<w:tcBorders {nsdecls("w")}>'
        f'<w:top w:val="none"/>'
        f'<w:bottom w:val="none"/>'
        f'<w:left w:val="single" w:sz="24" w:space="0" w:color="{color}"/>'
        f'<w:right w:val="none"/>'
        f'</w:tcBorders>'
    )
    tcPr.append(borders)
    
    p = cell.paragraphs[0]
    p.paragraph_format.space_before = Pt(4)
    p.paragraph_format.space_after = Pt(2)
    p.paragraph_format.left_indent = Inches(0.1)
    p.paragraph_format.right_indent = Inches(0.1)
    
    r_title = p.add_run(f"[{title}] ")
    r_title.bold = True
    r_title.font.size = Pt(9.5)
    r_title.font.name = "Arial"
    r_title.font.color.rgb = RGBColor(0x1E, 0x40, 0xAF)
    
    r_txt = p.add_run(text)
    r_txt.font.size = Pt(9.5)
    r_txt.font.name = "Arial"
    r_txt.font.color.rgb = RGBColor(0x1E, 0x29, 0x3B)
    
    p_after = doc.add_paragraph()
    p_after.paragraph_format.space_after = Pt(4)

def parse_inline_formatting(paragraph, text, base_font_size=10.5, is_italic_base=False, text_color=(0x1E, 0x29, 0x3B)):
    # Simple regex parser for **bold** and *italic* and `code`
    tokens = re.split(r'(\*\*.*?\*\*|\*.*?\*|`.*?`)', text)
    for tok in tokens:
        if not tok:
            continue
        if tok.startswith('**') and tok.endswith('**'):
            run = paragraph.add_run(tok[2:-2])
            run.bold = True
            run.font.name = "Arial"
            run.font.size = Pt(base_font_size)
            run.font.color.rgb = RGBColor(*text_color)
        elif tok.startswith('*') and tok.endswith('*'):
            run = paragraph.add_run(tok[1:-1])
            run.italic = True
            run.font.name = "Arial"
            run.font.size = Pt(base_font_size)
            run.font.color.rgb = RGBColor(*text_color)
        elif tok.startswith('`') and tok.endswith('`'):
            run = paragraph.add_run(tok[1:-1])
            run.font.name = "Consolas"
            run.font.size = Pt(base_font_size * 0.92)
            run.font.color.rgb = RGBColor(0x0F, 0x17, 0x2A)
        else:
            run = paragraph.add_run(tok)
            if is_italic_base:
                run.italic = True
            run.font.name = "Arial"
            run.font.size = Pt(base_font_size)
            run.font.color.rgb = RGBColor(*text_color)

def build_docx():
    print("Initializing python-docx document...")
    doc = docx.Document()
    
    # Page setup - A4 with 1.0 inch margins
    section = doc.sections[0]
    section.page_width = Inches(8.27)
    section.page_height = Inches(11.69)
    section.top_margin = Inches(1.0)
    section.bottom_margin = Inches(1.0)
    section.left_margin = Inches(1.0)
    section.right_margin = Inches(1.0)
    section.different_first_page_header_footer = True
    
    # Setup Header & Footer for normal pages
    header = section.header
    hp = header.paragraphs[0]
    hp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    hr = hp.add_run("NutriView — Business Requirements Document & Project Report")
    hr.font.name = "Arial"
    hr.font.size = Pt(8.5)
    hr.font.color.rgb = RGBColor(0x94, 0xA3, 0xB8)
    
    footer = section.footer
    fp = footer.paragraphs[0]
    fp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    fr_left = fp.add_run("Ahmad Badawi (NIM 20090015) — Universitas Bina Insani        |        Halaman ")
    fr_left.font.name = "Arial"
    fr_left.font.size = Pt(8.5)
    fr_left.font.color.rgb = RGBColor(0x94, 0xA3, 0xB8)
    add_page_number_to_run(fp.add_run())
    fr_mid = fp.add_run(" dari ")
    fr_mid.font.name = "Arial"
    fr_mid.font.size = Pt(8.5)
    fr_mid.font.color.rgb = RGBColor(0x94, 0xA3, 0xB8)
    add_numpages_to_run(fp.add_run())

    # ==========================================
    # 1. FORMAL COVER PAGE
    # ==========================================
    print("Generating Formal Cover Page...")
    p_top_bar = doc.add_paragraph()
    p_top_bar.paragraph_format.space_before = Pt(36)
    p_top_bar.paragraph_format.space_after = Pt(12)
    r_cat = p_top_bar.add_run("LAPORAN TEKNIS AKADEMIK & SPESIFIKASI KEBUTUHAN SISTEM")
    r_cat.font.name = "Arial"
    r_cat.font.size = Pt(11)
    r_cat.font.bold = True
    r_cat.font.color.rgb = RGBColor(0x25, 0x63, 0xEB)

    p_title = doc.add_paragraph()
    p_title.paragraph_format.space_after = Pt(4)
    r_title = p_title.add_run("OOPSIEEATS")
    r_title.font.name = "Arial"
    r_title.font.size = Pt(32)
    r_title.font.bold = True
    r_title.font.color.rgb = RGBColor(0x0F, 0x17, 0x2A)

    p_sub = doc.add_paragraph()
    p_sub.paragraph_format.space_after = Pt(18)
    r_sub = p_sub.add_run("Food Nutrition Recognition & Daily Tracking App (Historically NutriView)")
    r_sub.font.name = "Arial"
    r_sub.font.size = Pt(15)
    r_sub.font.color.rgb = RGBColor(0x47, 0x55, 0x69)

    # Accent divider table
    t_div = doc.add_table(rows=1, cols=1)
    t_div.alignment = WD_TABLE_ALIGNMENT.CENTER
    c_div = t_div.cell(0, 0)
    set_cell_background(c_div, "2563EB")
    c_div.paragraphs[0].paragraph_format.space_before = Pt(2)
    c_div.paragraphs[0].paragraph_format.space_after = Pt(2)
    
    p_desc = doc.add_paragraph()
    p_desc.paragraph_format.space_before = Pt(24)
    p_desc.paragraph_format.space_after = Pt(28)
    r_desc = p_desc.add_run(
        "Dokumen Business Requirements Document (BRD) dan Rekonstruksi Spesifikasi Teknis Komprehensif: "
        "Arsitektur Flutter Layered, Komputasi On-Device Edge AI (YOLO26n TFLite Worker Isolate), "
        "Basis Data NoSQL Cloud Firestore Multi-Tenant, Penyimpanan Citra Supabase Storage dengan Row-Level Security, "
        "Formulasi Deterministik Mifflin-St Jeor & Atwater 4-4-9, serta Pengujian Mutu Otomatis 359 Test Cases (42 File Uji)."
    )
    r_desc.font.name = "Arial"
    r_desc.font.size = Pt(11)
    r_desc.font.color.rgb = RGBColor(0x33, 0x41, 0x55)

    # Metadata Block Table
    t_meta = doc.add_table(rows=6, cols=2)
    t_meta.alignment = WD_TABLE_ALIGNMENT.CENTER
    meta_info = [
        ("Penyusun / Penulis", "Ahmad Badawi"),
        ("Nomor Induk Mahasiswa (NIM)", "20090015"),
        ("Program Studi / Jurusan", "Sistem Informasi"),
        ("Institusi Akademik", "Universitas Bina Insani"),
        ("Versi Dokumen / Status", "Versi 1.1.0 (Full Reconstruction Release)"),
        ("Tahun Akademik & Tanggal", "2026 / 13 November 2026")
    ]
    for i, (k, v) in enumerate(meta_info):
        c0, c1 = t_meta.cell(i, 0), t_meta.cell(i, 1)
        c0.width = Inches(2.5)
        c1.width = Inches(3.7)
        set_cell_margins(c0, 80, 80, 100, 100)
        set_cell_margins(c1, 80, 80, 100, 100)
        set_cell_background(c0, "F8FAFC")
        set_cell_background(c1, "FFFFFF")
        
        p0 = c0.paragraphs[0]
        r0 = p0.add_run(k)
        r0.font.name = "Arial"
        r0.font.size = Pt(10)
        r0.font.bold = True
        r0.font.color.rgb = RGBColor(0x0F, 0x17, 0x2A)
        
        p1 = c1.paragraphs[0]
        r1 = p1.add_run(v)
        r1.font.name = "Arial"
        r1.font.size = Pt(10)
        r1.font.color.rgb = RGBColor(0x33, 0x41, 0x55)
    set_table_borders(t_meta, "CBD5E1")

    doc.add_page_break()

    # ==========================================
    # 2. DOCUMENT CONTROL & REVISION HISTORY
    # ==========================================
    print("Generating Document Control Table...")
    p_dc_title = doc.add_paragraph()
    p_dc_title.paragraph_format.space_before = Pt(12)
    p_dc_title.paragraph_format.space_after = Pt(8)
    r_dc = p_dc_title.add_run("LEMBAR PENGESAHAN & KONTROL DOKUMEN")
    r_dc.font.name = "Arial"
    r_dc.font.size = Pt(14)
    r_dc.font.bold = True
    r_dc.font.color.rgb = RGBColor(0x0F, 0x17, 0x2A)

    t_dc = doc.add_table(rows=4, cols=2)
    t_dc.alignment = WD_TABLE_ALIGNMENT.CENTER
    dc_rows = [
        ("Nama Dokumen", "Business Requirements Document (BRD) & Project Report"),
        ("Klasifikasi Dokumen", "Dokumentasi Teknis & Laporan Tugas Akhir / Proyek"),
        ("Distribusi Salinan", "Dosen Pembimbing, Dosen Penguji, Arsip Akademik"),
        ("Integritas Sistem", "100% Berbasis Kode Sumber Terverifikasi (359/359 Automated Tests Passed, 42 Test Files)")
    ]
    for i, (k, v) in enumerate(dc_rows):
        c0, c1 = t_dc.cell(i, 0), t_dc.cell(i, 1)
        c0.width = Inches(2.2)
        c1.width = Inches(4.0)
        set_cell_margins(c0, 80, 80, 100, 100)
        set_cell_margins(c1, 80, 80, 100, 100)
        set_cell_background(c0, "F8FAFC")
        set_cell_background(c1, "FFFFFF")
        p0 = c0.paragraphs[0]
        p0.add_run(k).font.bold = True
        p0.runs[0].font.name = "Arial"
        p0.runs[0].font.size = Pt(9.5)
        p1 = c1.paragraphs[0]
        p1.add_run(v).font.name = "Arial"
        p1.runs[0].font.size = Pt(9.5)
    set_table_borders(t_dc, "CBD5E1")

    p_rev_title = doc.add_paragraph()
    p_rev_title.paragraph_format.space_before = Pt(20)
    p_rev_title.paragraph_format.space_after = Pt(6)
    r_rev = p_rev_title.add_run("Riwayat Revisi Dokumen")
    r_rev.font.name = "Arial"
    r_rev.font.size = Pt(12)
    r_rev.font.bold = True
    r_rev.font.color.rgb = RGBColor(0x1E, 0x40, 0xAF)

    t_rev = doc.add_table(rows=5, cols=5)
    t_rev.alignment = WD_TABLE_ALIGNMENT.CENTER
    rev_headers = ["Versi", "Tanggal", "Penulis", "Perubahan Utama", "Status"]
    rev_data = [
        ["0.1.0", "15 Okt 2026", "Ahmad Badawi", "Draft inisial kebutuhan fungsional & arsitektur", "Superseded"],
        ["0.9.0", "01 Nov 2026", "Ahmad Badawi", "Audit arsitektur edge AI & sinkronisasi NoSQL", "Reviewed"],
        ["1.0.0", "07 Nov 2026", "Ahmad Badawi", "Final release: Redesain diagram UML & 256 tests audit", "Superseded"],
        ["1.1.0", "13 Nov 2026", "Ahmad Badawi", "Rekonstruksi Total: OopsieEats Rebranding, Supabase Storage, Complete Profile Guard & 359 Tests", "Approved"]
    ]
    for j, h in enumerate(rev_headers):
        cell = t_rev.cell(0, j)
        set_cell_background(cell, "0F172A")
        set_cell_margins(cell, 100, 100, 100, 100)
        p = cell.paragraphs[0]
        run = p.add_run(h)
        run.bold = True
        run.font.name = "Arial"
        run.font.size = Pt(9)
        run.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
    
    col_w = [Inches(0.8), Inches(1.1), Inches(1.2), Inches(2.2), Inches(0.9)]
    for row_idx, r in enumerate(rev_data, start=1):
        bg = "FFFFFF" if row_idx % 2 == 1 else "F8FAFC"
        for col_idx, val in enumerate(r):
            cell = t_rev.cell(row_idx, col_idx)
            cell.width = col_w[col_idx]
            set_cell_background(cell, bg)
            set_cell_margins(cell, 80, 80, 100, 100)
            p = cell.paragraphs[0]
            run = p.add_run(val)
            run.font.name = "Arial"
            run.font.size = Pt(8.5)
            run.font.color.rgb = RGBColor(0x1E, 0x29, 0x3B)
    set_table_borders(t_rev, "CBD5E1")

    doc.add_page_break()

    # ==========================================
    # 3. DAFTAR ISI, DAFTAR GAMBAR, DAFTAR TABEL
    # ==========================================
    print("Generating TOC and Lists...")
    p_toc = doc.add_paragraph()
    p_toc.paragraph_format.space_before = Pt(12)
    p_toc.paragraph_format.space_after = Pt(8)
    r_toc = p_toc.add_run("DAFTAR ISI")
    r_toc.font.name = "Arial"
    r_toc.font.size = Pt(16)
    r_toc.font.bold = True
    r_toc.font.color.rgb = RGBColor(0x0F, 0x17, 0x2A)

    toc_chapters = [
        ("1 Project Planning and System Design", [
            "1.1 Introduction to NutriView", "1.2 Project Background and Objectives",
            "1.3 Functional Requirements", "1.4 Non-Functional Requirements",
            "1.5 Application Features and User Roles", "1.6 Technology Stack Overview",
            "1.7 High-Level System Architecture", "1.8 Application Use Case Diagram",
            "1.9 Application Navigation Flow", "1.10 UI/UX Wireframe Design",
            "1.11 Database Entity Relationship Diagram (ERD)", "1.12 Database / Repository Service Specification"
        ]),
        ("2 Development Environment Setup", [
            "2.1 Creating the NutriView Flutter Project", "2.2 Installing Required Flutter Packages",
            "2.3 Organizing the Flutter Project Structure", "2.4 Configuring Environment Variables & Flutter Assets",
            "2.5 Creating a Firebase Project", "2.6 Enabling Firebase Email/Password Authentication",
            "2.7 Configuring Cloud Firestore Database", "2.8 Configuring Firebase Direct SDK Integration",
            "2.9 Preparing Configuration & App Constants", "2.10 Testing Development Environment"
        ]),
        ("3 Database and CMS Implementation", [
            "3.1 Designing the NutriView Firestore Database", "3.2 Creating the Users & Profiles Collection",
            "3.3 Creating the Food Master Catalog Collection", "3.4 Creating the Meals Subcollection",
            "3.5 Creating the Daily Target Schema", "3.6 Creating the CMS Articles & Media Collections",
            "3.7 Defining Document Relationships", "3.8 Creating Database Constraints & Composite Indexes",
            "3.9 Configuring Declarative Security Rules", "3.10 Configuring Offline Persistence & Local Cache",
            "3.11 Managing Foods & Content Through Admin Panel", "3.12 Inserting 29 Indonesian Food Catalog",
            "3.13 Testing Database Access & Multi-Tenant Isolation"
        ]),
        ("4 Firebase Authentication Implementation", [
            "4.1 Configuring Firebase in Flutter", "4.2 Building the Registration Screen",
            "4.3 Implementing User Registration", "4.4 Building the Login Screen",
            "4.5 Implementing User Login", "4.6 Managing Firebase Authentication State",
            "4.7 Retrieving Firebase UID & Secure Storage", "4.8 Configuring Strict 2-Role RBAC",
            "4.9 Implementing Protected Routes", "4.10 Implementing Logout & Session Invalidation",
            "4.11 Testing Authentication, Biometrics, and Authorization"
        ]),
        ("5 Data Repository & Service Integration", [
            "5.1 Creating the Data Repository Architecture", "5.2 Configuring Firestore Instance & Cache Settings",
            "5.3 Managing Local Credentials via ApiClient", "5.4 Creating DTO Models",
            "5.5 Implementing JSON Serialization & Atwater Deserialization", "5.6 Food Query & Search",
            "5.7 Meal Logging & Query", "5.8 Meal Creation & Portion Calculation",
            "5.9 Profile & Target Updates", "5.10 Account Deletion & Data Purge",
            "5.11 Date Range Filtering & Sorting", "5.12 Centralized Error Handling",
            "5.13 Testing Repository Integration with Mocktail"
        ]),
        ("6 NutriView Mobile UI Development", [
            "6.1 Application Theme & Overkill Neo-Brutalism Design System", "6.2 Main Navigation (NeoBottomNav Shell)",
            "6.3 Dashboard Screen", "6.4 Daily Calorie Intake vs Target",
            "6.5 Macronutrient Bento Grid", "6.6 Meal History Screen",
            "6.7 Add Meal & Detection Confirmation Screen", "6.8 Food Search Modal",
            "6.9 Portion Weight Input", "6.10 Meal Detail Screen",
            "6.11 Delete Confirmation Dialog", "6.12 Profile Screen & Biodata Form",
            "6.13 Loading, Empty, and Error States", "6.14 Provider State Management"
        ]),
        ("7 Specialized Feature: Computer Vision & Food Detection Pipeline", [
            "7.1 Camera & Gallery Access", "7.2 Capturing Food Images",
            "7.3 Selecting Gallery Images", "7.4 Image Preprocessing in Background Isolate",
            "7.5 Loading On-Device YOLO26n TFLite Model", "7.6 Model Inference Pipeline & Tensor Output",
            "7.7 Postprocessing & NMS Filtering", "7.8 Food Detection to Nutrition Database Mapping",
            "7.9 Handling Low Confidence & Graceful Degradation"
        ]),
        ("8 Nutrition Analytics, Formulations, and Visualization", [
            "8.1 Calculating BMR via Mifflin-St Jeor", "8.2 Calculating TDEE",
            "8.3 Calorie Goals & Safe Calorie Floor", "8.4 Daily Date Navigation & Aggregation",
            "8.5 Macronutrient Distribution", "8.6 Atwater Energy Verification Factor",
            "8.7 Daily & Historical Nutrition Intake Summaries", "8.8 Target Progress Indicators",
            "8.9 Real-Time Nutritional Balance Indicators"
        ]),
        ("9 Testing, Optimization, and Deployment", [
            "9.1 Flutter Application Testing Strategy", "9.2 Unit Testing for Nutrition Calculations",
            "9.3 Widget & Design System Testing", "9.4 Repository & Offline Fallback Testing",
            "9.5 Authentication & Biometric Security Testing", "9.6 Database Security Rules Testing",
            "9.7 Computer Vision Scanner Benchmark Testing", "9.8 Error Handling & Graceful Degradation",
            "9.9 Optimizing Database Reads", "9.10 Managing Free-Tier Spark Plan Resource Usage",
            "9.11 Building Android Release APK & App Bundle", "9.12 Physical Device Verification",
            "9.13 Final Project Evaluation & Requirements Verification", "9.14 Final Screen Gallery"
        ]),
        ("Checklist Bukti Implementasi Laporan", []),
        ("Daftar Referensi (Format IEEE)", []),
        ("Lampiran — Panduan Konsistensi Skema Database", [])
    ]

    for chap, subs in toc_chapters:
        p_c = doc.add_paragraph()
        p_c.paragraph_format.space_before = Pt(4)
        p_c.paragraph_format.space_after = Pt(1)
        r_c = p_c.add_run(chap)
        r_c.font.name = "Arial"
        r_c.font.size = Pt(10)
        r_c.font.bold = True
        r_c.font.color.rgb = RGBColor(0x0F, 0x17, 0x2A)
        
        for s in subs:
            p_s = doc.add_paragraph()
            p_s.paragraph_format.left_indent = Inches(0.25)
            p_s.paragraph_format.space_before = Pt(0)
            p_s.paragraph_format.space_after = Pt(0)
            r_s = p_s.add_run(s)
            r_s.font.name = "Arial"
            r_s.font.size = Pt(9)
            r_s.font.color.rgb = RGBColor(0x47, 0x55, 0x69)

    doc.add_page_break()

    # Daftar Gambar
    p_dg = doc.add_paragraph()
    p_dg.paragraph_format.space_before = Pt(12)
    p_dg.paragraph_format.space_after = Pt(8)
    r_dg = p_dg.add_run("DAFTAR GAMBAR")
    r_dg.font.name = "Arial"
    r_dg.font.size = Pt(14)
    r_dg.font.bold = True
    r_dg.font.color.rgb = RGBColor(0x0F, 0x17, 0x2A)

    figures_list = [
        ("Figure 1", "High-Level System Architecture — Edge AI On-Device & Serverless Cloud"),
        ("Figure 1b", "UML Deployment Architecture — Client Node, Cloud Node, and Play Store Distribution"),
        ("Figure 2", "NutriView UML Standard Use Case Diagram — Actors: Regular User & Administrator"),
        ("Figure 3", "Application Navigation Flowchart — NeoBottomNav Shell & Auth Gates"),
        ("Figure 3b", "UML Activity Diagram with Swimlanes — On-Device AI Detection & Meal Logging Flow"),
        ("Figure 4", "UI/UX Wireframes: Login, Dashboard, Scanner, History"),
        ("Figure 5", "NutriView Cloud Firestore Document Schema Model (ERD)"),
        ("Figure 6", "Firebase Console Project Setup UI Mockup / Configuration Illustration"),
        ("Figure 7", "Cloud Firestore Database Configuration UI Mockup"),
        ("Figure 8", "Firebase Token and Secure Session Flow Topology"),
        ("Figure 9", "Database Logical Schema Diagram & Document Hierarchy"),
        ("Figure 10", "Security Rules and RBAC Configuration UI Mockup"),
        ("Figure 11", "Offline Fallback & Cache Storage Configuration UI Mockup"),
        ("Figure 12", "Food Master Catalog Management UI Mockup"),
        ("Figure 13", "Registration Screen UI Mockup"),
        ("Figure 14", "Login Screen UI Mockup"),
        ("Figure 15", "Dashboard UI Mockup / Configuration Illustration"),
        ("Figure 16", "Meal History UI Mockup / Configuration Illustration"),
        ("Figure 17", "Detection Confirmation UI Mockup"),
        ("Figure 18", "Profile & Biodata UI Mockup"),
        ("Figure 19", "Camera Scanner UI Mockup"),
        ("Figure 20", "UML Sequence Diagram: Computer Vision & Meal Logging Flow"),
        ("Figure 21", "Daily Calorie Target vs Intake Visualization"),
        ("Figure 22", "Macronutrient Bento Distribution Chart"),
        ("Figure 23", "Daily Nutrition Breakdown Report"),
        ("Figure 24", "Release Build Compilation Output UI Mockup"),
        ("Figure 25", "Test Suite & Quality Verification Output (256 Tests Passed)"),
        ("Figure 26", "Final Application Screen Gallery")
    ]
    for fid, fcaption in figures_list:
        p_fig_item = doc.add_paragraph()
        p_fig_item.paragraph_format.space_before = Pt(1)
        p_fig_item.paragraph_format.space_after = Pt(1)
        r_f1 = p_fig_item.add_run(f"{fid}: ")
        r_f1.font.bold = True
        r_f1.font.name = "Arial"
        r_f1.font.size = Pt(9.5)
        r_f2 = p_fig_item.add_run(fcaption)
        r_f2.font.name = "Arial"
        r_f2.font.size = Pt(9.5)
        r_f2.font.color.rgb = RGBColor(0x33, 0x41, 0x55)

    doc.add_page_break()

    # ==========================================
    # 4. PARSE AND RENDER MARKDOWN BODY
    # ==========================================
    print("Reading and rendering markdown body...")
    with open(INPUT_MD, "r", encoding="utf-8") as f:
        md_text = f.read()

    lines = md_text.split("\n")
    i = 0
    in_code_block = False
    in_mermaid_block = False
    table_lines = []

    # Skip initial title lines that we already put on cover page
    # Start parsing at "# 1 Project Planning and System Design"
    start_parsing = False

    while i < len(lines):
        line = lines[i].rstrip()
        
        # Detect start of chapter 1
        if line.startswith("# 1 Project Planning and System Design"):
            start_parsing = True

        if not start_parsing:
            # Let's also include Petunjuk Penggunaan Laporan if encountered
            if line.startswith("# Petunjuk Penggunaan Laporan"):
                p_pp = doc.add_paragraph()
                p_pp.paragraph_format.space_before = Pt(14)
                p_pp.paragraph_format.space_after = Pt(6)
                r_pp = p_pp.add_run("Petunjuk Penggunaan Laporan")
                r_pp.font.name = "Arial"
                r_pp.font.size = Pt(14)
                r_pp.font.bold = True
                r_pp.font.color.rgb = RGBColor(0x0F, 0x17, 0x2A)
                i += 1
                continue
            elif line.startswith("> **Integritas Single Source of Truth**"):
                add_callout(doc, line[2:].strip(), title="INTEGRITAS SINGLE SOURCE OF TRUTH", color="059669", bg="ECFDF5")
                i += 1
                continue
            elif line and not line.startswith("#") and not line.startswith("---") and not line.startswith("**Ahmad"):
                p = doc.add_paragraph()
                p.paragraph_format.space_after = Pt(4)
                parse_inline_formatting(p, line, base_font_size=10.5)
                i += 1
                continue
            else:
                i += 1
                continue

        # Check code blocks
        if line.startswith("```"):
            if line.startswith("```mermaid"):
                in_mermaid_block = True
                i += 1
                continue
            elif in_mermaid_block:
                in_mermaid_block = False
                i += 1
                continue
            elif not in_code_block:
                in_code_block = True
                code_lines = []
                i += 1
                continue
            else:
                in_code_block = False
                # Render code box
                if code_lines:
                    tbl = doc.add_table(rows=1, cols=1)
                    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
                    c = tbl.cell(0, 0)
                    set_cell_background(c, "F8FAFC")
                    set_cell_margins(c, 100, 100, 120, 120)
                    p = c.paragraphs[0]
                    p.paragraph_format.space_before = Pt(2)
                    p.paragraph_format.space_after = Pt(2)
                    run = p.add_run("\n".join(code_lines))
                    run.font.name = "Consolas"
                    run.font.size = Pt(8.5)
                    run.font.color.rgb = RGBColor(0x0F, 0x17, 0x2A)
                    set_table_borders(tbl, "E2E8F0")
                i += 1
                continue

        if in_mermaid_block:
            # Skip raw mermaid text because high-res PNG diagram is already rendered underneath
            i += 1
            continue

        if in_code_block:
            code_lines.append(line)
            i += 1
            continue

        # Check tables
        if line.startswith("|") and "|" in line[1:]:
            table_lines.append(line)
            i += 1
            # Check if table continues
            if i < len(lines) and lines[i].startswith("|"):
                continue
            else:
                # Render accumulated table
                rows_data = []
                for tl in table_lines:
                    if re.match(r'^\|[\s\-:|]+\|$', tl):
                        continue # separator
                    cells = [c.strip() for c in tl.split("|")[1:-1]]
                    rows_data.append(cells)
                table_lines = []
                
                if rows_data:
                    num_cols = max(len(r) for r in rows_data)
                    tbl = doc.add_table(rows=len(rows_data), cols=num_cols)
                    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
                    
                    for r_idx, row_vals in enumerate(rows_data):
                        is_header = (r_idx == 0)
                        bg = "0F172A" if is_header else ("FFFFFF" if r_idx % 2 == 1 else "F8FAFC")
                        for c_idx in range(num_cols):
                            cell = tbl.cell(r_idx, c_idx)
                            set_cell_background(cell, bg)
                            set_cell_margins(cell, 80, 80, 100, 100)
                            p = cell.paragraphs[0]
                            p.paragraph_format.space_before = Pt(1)
                            p.paragraph_format.space_after = Pt(1)
                            val = row_vals[c_idx] if c_idx < len(row_vals) else ""
                            if is_header:
                                run = p.add_run(val)
                                run.font.name = "Arial"
                                run.font.size = Pt(9)
                                run.font.bold = True
                                run.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
                            else:
                                parse_inline_formatting(p, val, base_font_size=8.5)
                    set_table_borders(tbl, "CBD5E1")
                    p_spacer = doc.add_paragraph()
                    p_spacer.paragraph_format.space_after = Pt(4)
                continue

        # Check callouts (> ...)
        if line.startswith(">"):
            callout_text = line[1:].strip()
            # Collect multiline callouts
            while i + 1 < len(lines) and lines[i+1].startswith(">"):
                i += 1
                callout_text += " " + lines[i][1:].strip()
            title = "CATATAN TEKNIS"
            color = "2563EB"
            bg = "EFF6FF"
            if "Integritas Single Source of Truth" in callout_text:
                title = "INTEGRITAS DATA"
                color = "059669"
                bg = "ECFDF5"
            elif "Aturan Keamanan" in callout_text or "PENTING" in callout_text:
                title = "PERINGATAN ARSITEKTUR KEAMANAN"
                color = "DC2626"
                bg = "FEF2F2"
            add_callout(doc, callout_text, title=title, color=color, bg=bg)
            i += 1
            continue

        # Check images
        img_match = re.match(r'!\[(.*?)\]\((.*?)\)', line)
        if img_match:
            alt_text = img_match.group(1)
            img_rel_path = img_match.group(2)
            img_abs_path = os.path.join(DOC_DIR, img_rel_path)
            
            if os.path.exists(img_abs_path):
                p_img = doc.add_paragraph()
                p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
                p_img.paragraph_format.space_before = Pt(8)
                p_img.paragraph_format.space_after = Pt(2)
                p_img.paragraph_format.keep_with_next = True
                
                # Insert picture with appropriate width (max 5.8 inches)
                try:
                    doc.add_picture(img_abs_path, width=Inches(5.8))
                except Exception as e:
                    print(f"Warning: could not add picture {img_abs_path}: {e}")
            i += 1
            continue

        # Check image caption (*Figure X...*)
        caption_match = re.match(r'^\*(Figure\s+[0-9a-zA-Z]+[\.\:].*?)\*$', line)
        if caption_match:
            cap_text = caption_match.group(1)
            p_cap = doc.add_paragraph()
            p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p_cap.paragraph_format.space_before = Pt(2)
            p_cap.paragraph_format.space_after = Pt(10)
            run = p_cap.add_run(cap_text)
            run.font.name = "Arial"
            run.font.size = Pt(8.5)
            run.italic = True
            run.font.color.rgb = RGBColor(0x64, 0x74, 0x8B)
            i += 1
            continue

        # Check Headings
        if line.startswith("# "):
            h_text = line[2:].strip()
            # Add page break before major chapters (except if top of page)
            doc.add_page_break()
            p_h = doc.add_paragraph()
            p_h.paragraph_format.space_before = Pt(18)
            p_h.paragraph_format.space_after = Pt(8)
            p_h.paragraph_format.keep_with_next = True
            run = p_h.add_run(h_text)
            run.font.name = "Arial"
            run.font.size = Pt(18)
            run.font.bold = True
            run.font.color.rgb = RGBColor(0x0F, 0x17, 0x2A)
            i += 1
            continue

        if line.startswith("## "):
            h_text = line[3:].strip()
            p_h = doc.add_paragraph()
            p_h.paragraph_format.space_before = Pt(14)
            p_h.paragraph_format.space_after = Pt(4)
            p_h.paragraph_format.keep_with_next = True
            run = p_h.add_run(h_text)
            run.font.name = "Arial"
            run.font.size = Pt(13.5)
            run.font.bold = True
            run.font.color.rgb = RGBColor(0x1E, 0x40, 0xAF)
            i += 1
            continue

        if line.startswith("### "):
            h_text = line[4:].strip()
            p_h = doc.add_paragraph()
            p_h.paragraph_format.space_before = Pt(10)
            p_h.paragraph_format.space_after = Pt(2)
            p_h.paragraph_format.keep_with_next = True
            run = p_h.add_run(h_text)
            run.font.name = "Arial"
            run.font.size = Pt(11)
            run.font.bold = True
            run.font.color.rgb = RGBColor(0x33, 0x41, 0x55)
            i += 1
            continue

        # Lists (- or * or 1.)
        list_match = re.match(r'^(\-|\*|\d+\.)\s+(.+)$', line)
        if list_match:
            bullet_sym = list_match.group(1)
            item_text = list_match.group(2)
            p_li = doc.add_paragraph()
            p_li.paragraph_format.left_indent = Inches(0.25)
            p_li.paragraph_format.space_before = Pt(1)
            p_li.paragraph_format.space_after = Pt(2)
            
            prefix = "• " if bullet_sym in ["-", "*"] else f"{bullet_sym} "
            r_pre = p_li.add_run(prefix)
            r_pre.font.name = "Arial"
            r_pre.font.size = Pt(10)
            r_pre.font.bold = True
            r_pre.font.color.rgb = RGBColor(0x25, 0x63, 0xEB)
            
            parse_inline_formatting(p_li, item_text, base_font_size=10)
            i += 1
            continue

        # Standard Paragraph
        if line.strip():
            p_body = doc.add_paragraph()
            p_body.paragraph_format.space_before = Pt(2)
            p_body.paragraph_format.space_after = Pt(5)
            p_body.paragraph_format.line_spacing = 1.15
            parse_inline_formatting(p_body, line.strip(), base_font_size=10.5)

        i += 1

    print(f"Saving compiled Word document to {OUTPUT_DOCX}...")
    doc.save(OUTPUT_DOCX)
    print(f"BRD_NutriView_Final.docx created successfully! Size: {os.path.getsize(OUTPUT_DOCX)} bytes")

if __name__ == "__main__":
    build_docx()
