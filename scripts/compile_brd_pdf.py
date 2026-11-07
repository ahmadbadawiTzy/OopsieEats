import os
import re
import subprocess

DOC_DIR = os.path.abspath("docs/brd")
INPUT_MD = os.path.join(DOC_DIR, "NutriView_BRD_Project_Report.md")
HTML_TEMP = "/tmp/nutriview_brd_report.html"
OUTPUT_PDF = os.path.join(DOC_DIR, "BRD_NutriView_Final.pdf")

def markdown_to_html():
    print("Reading markdown report...")
    with open(INPUT_MD, "r", encoding="utf-8") as f:
        md_text = f.read()

    # Pre-render cover page HTML
    cover_html = """
    <div class="cover-page">
      <div class="cover-top-bar"></div>
      <div class="cover-content">
        <div class="cover-badge">BUSINESS REQUIREMENTS DOCUMENT &amp; TECHNICAL REPORT</div>
        <h1 class="cover-title">NUTRIVIEW</h1>
        <div class="cover-subtitle">Food Nutrition Recognition &amp; Daily Tracking Mobile Application</div>
        
        <div class="cover-divider"></div>
        
        <p class="cover-abstract">
          Dokumen Business Requirements Document (BRD) dan Rekonstruksi Spesifikasi Teknis Komprehensif: 
          Arsitektur Flutter Layered, Komputasi On-Device Edge AI (YOLO26n TFLite Worker Isolate), 
          Basis Data NoSQL Cloud Firestore Multi-Tenant, Formulasi Deterministik Mifflin-St Jeor &amp; Atwater 4-4-9, 
          serta Pengujian Mutu Otomatis 256 Test Cases.
        </p>

        <div class="cover-meta-grid">
          <div class="meta-card">
            <span class="meta-label">Penyusun / Penulis</span>
            <span class="meta-value"><strong>Ahmad Badawi</strong></span>
          </div>
          <div class="meta-card">
            <span class="meta-label">Nomor Induk Mahasiswa (NIM)</span>
            <span class="meta-value">20090015</span>
          </div>
          <div class="meta-card">
            <span class="meta-label">Program Studi &amp; Institusi</span>
            <span class="meta-value">Sistem Informasi — Universitas Bina Insani</span>
          </div>
          <div class="meta-card">
            <span class="meta-label">Versi &amp; Status Dokumen</span>
            <span class="meta-value"><span class="status-tag">Versi 1.0.0 (Release Candidate)</span></span>
          </div>
          <div class="meta-card">
            <span class="meta-label">Tahun Akademik &amp; Tanggal Rilis</span>
            <span class="meta-value">2026 / 07 November 2026</span>
          </div>
          <div class="meta-card">
            <span class="meta-label">Integritas Kode Sumber</span>
            <span class="meta-value"><span class="badge-success">256/256 Automated Tests Passed (100%)</span></span>
          </div>
        </div>
      </div>
      <div class="cover-footer-text">
        Dokumen ini disusun untuk keperluan akademik dan spesifikasi teknis standar industri perangkat lunak mobile.
      </div>
    </div>
    """

    # Document Control Table HTML
    doc_control_html = """
    <div class="page-break"></div>
    <div class="section-container">
      <h2 class="section-title">Lembar Pengesahan &amp; Kontrol Dokumen</h2>
      <table class="academic-table doc-control-table">
        <tbody>
          <tr>
            <th style="width: 28%;">Nama Dokumen</th>
            <td>Business Requirements Document (BRD) &amp; Project Report — NutriView</td>
          </tr>
          <tr>
            <th>Klasifikasi Dokumen</th>
            <td>Spesifikasi Kebutuhan Sistem &amp; Laporan Proyek Perangkat Lunak</td>
          </tr>
          <tr>
            <th>Target Implementasi</th>
            <td>Flutter 3.24+ / Dart 3.5+, Android SDK 34, Google Firebase (asia-southeast2)</td>
          </tr>
          <tr>
            <th>Distribusi Salinan</th>
            <td>Dosen Pembimbing, Dosen Penguji, Arsip Akademik Universitas Bina Insani</td>
          </tr>
          <tr>
            <th>Integritas Data</th>
            <td>100% Berbasis Kode Sumber Terverifikasi (0 Test Failure, 0 Analyze Warning)</td>
          </tr>
        </tbody>
      </table>

      <h3 style="margin-top: 28px; color: #1e40af;">Riwayat Revisi Dokumen</h3>
      <table class="academic-table">
        <thead>
          <tr>
            <th>Versi</th>
            <th>Tanggal</th>
            <th>Penulis</th>
            <th>Perubahan Utama</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>0.1.0</strong></td>
            <td>15 Okt 2026</td>
            <td>Ahmad Badawi</td>
            <td>Draft inisial kebutuhan fungsional &amp; arsitektur sistem</td>
            <td><span class="status-muted">Superseded</span></td>
          </tr>
          <tr>
            <td><strong>0.9.0</strong></td>
            <td>01 Nov 2026</td>
            <td>Ahmad Badawi</td>
            <td>Audit arsitektur edge AI &amp; sinkronisasi NoSQL Firestore</td>
            <td><span class="status-muted">Reviewed</span></td>
          </tr>
          <tr>
            <td><strong>1.0.0</strong></td>
            <td>07 Nov 2026</td>
            <td>Ahmad Badawi</td>
            <td>Final release: Redesain diagram UML standar &amp; 256 automated test audit</td>
            <td><span class="status-approved">Approved</span></td>
          </tr>
        </tbody>
      </table>
    </div>
    """

    # Table of Contents HTML
    toc_html = """
    <div class="page-break"></div>
    <div class="toc-container">
      <h2 class="chapter-title" style="page-break-before: avoid; margin-top: 0;">Daftar Isi</h2>
      <div class="toc-block">
        <div class="toc-item toc-chap"><strong>1 Project Planning and System Design</strong></div>
        <div class="toc-item toc-sub">1.1 Introduction to NutriView &bull; 1.2 Project Background and Objectives &bull; 1.3 Functional Requirements &bull; 1.4 Non-Functional Requirements &bull; 1.5 Application Features and User Roles &bull; 1.6 Technology Stack Overview &bull; 1.7 High-Level System Architecture &bull; 1.8 Application Use Case Diagram &bull; 1.9 Application Navigation Flow &bull; 1.10 UI/UX Wireframe Design &bull; 1.11 Database ERD &bull; 1.12 Database / Repository Service Specification</div>

        <div class="toc-item toc-chap"><strong>2 Development Environment Setup</strong></div>
        <div class="toc-item toc-sub">2.1 Flutter Project &bull; 2.2 Flutter Packages &bull; 2.3 Project Structure &bull; 2.4 Assets Configuration &bull; 2.5 Firebase Project &bull; 2.6 Email/Password Auth &bull; 2.7 Firestore DB &bull; 2.8 Direct SDK &bull; 2.9 App Constants &bull; 2.10 Testing Environment</div>

        <div class="toc-item toc-chap"><strong>3 Database and CMS Implementation</strong></div>
        <div class="toc-item toc-sub">3.1 Firestore Schema &bull; 3.2 Users &amp; Profiles &bull; 3.3 Food Catalog &bull; 3.4 Meals Subcollection &bull; 3.5 Daily Target Schema &bull; 3.6 CMS Collections &bull; 3.7 Multi-Tenant Isolation &bull; 3.8 Composite Indexes &bull; 3.9 Security Rules &bull; 3.10 Offline Cache &bull; 3.11 Admin Panel &bull; 3.12 29 Food Catalog &bull; 3.13 Database Testing</div>

        <div class="toc-item toc-chap"><strong>4 Firebase Authentication Implementation</strong></div>
        <div class="toc-item toc-sub">4.1 Flutter Firebase &bull; 4.2 Registration UI &bull; 4.3 Registration Logic &bull; 4.4 Login UI &bull; 4.5 Login Logic &bull; 4.6 Auth State &bull; 4.7 Secure Storage &bull; 4.8 Strict 2-Role RBAC &bull; 4.9 Protected Routes &bull; 4.10 Logout Logic &bull; 4.11 Auth &amp; Biometric Testing</div>

        <div class="toc-item toc-chap"><strong>5 Data Repository &amp; Service Integration</strong></div>
        <div class="toc-item toc-sub">5.1 Repository Architecture &bull; 5.2 Firestore &amp; Cache &bull; 5.3 Local Credentials &bull; 5.4 Models DTO &bull; 5.5 Atwater Serialization &bull; 5.6 Food Search &bull; 5.7 Meal Logging &bull; 5.8 Portion Calculation &bull; 5.9 Profile Updates &bull; 5.10 Account Deletion &bull; 5.11 Date Filtering &bull; 5.12 Error Handling &bull; 5.13 Mocktail Testing</div>

        <div class="toc-item toc-chap"><strong>6 NutriView Mobile UI Development</strong></div>
        <div class="toc-item toc-sub">6.1 Overkill Neo-Brutalism &bull; 6.2 NeoBottomNav &bull; 6.3 Dashboard Screen &bull; 6.4 Calorie Dial &bull; 6.5 Macronutrient Bento Grid &bull; 6.6 Meal History &bull; 6.7 Confirmation Screen &bull; 6.8 Search Modal &bull; 6.9 Portion Input &bull; 6.10 Meal Detail &bull; 6.11 Delete Dialog &bull; 6.12 Profile &amp; Biodata &bull; 6.13 Responsive States &bull; 6.14 Provider State</div>

        <div class="toc-item toc-chap"><strong>7 Specialized Feature: Computer Vision &amp; Food Detection Pipeline</strong></div>
        <div class="toc-item toc-sub">7.1 Camera Access &bull; 7.2 Camera Capture &bull; 7.3 Gallery Selection &bull; 7.4 Isolate Preprocessing &bull; 7.5 YOLO26n TFLite Model &bull; 7.6 Inference Pipeline &bull; 7.7 NMS Postprocessing &bull; 7.8 Nutrition Database Mapping &bull; 7.9 Graceful Degradation</div>

        <div class="toc-item toc-chap"><strong>8 Nutrition Analytics, Formulations, and Visualization</strong></div>
        <div class="toc-item toc-sub">8.1 BMR Formulation &bull; 8.2 TDEE Formulation &bull; 8.3 Safe Calorie Floor &bull; 8.4 Date Navigation &bull; 8.5 Macronutrient Split &bull; 8.6 Atwater Factor Cross-Check &bull; 8.7 Intake Summaries &bull; 8.8 Overconsumption Warnings &bull; 8.9 Balance Indicators</div>

        <div class="toc-item toc-chap"><strong>9 Testing, Optimization, and Deployment</strong></div>
        <div class="toc-item toc-sub">9.1 Testing Strategy &bull; 9.2 Nutrition Calculation Tests &bull; 9.3 Widget Tests &bull; 9.4 Offline Fallback Tests &bull; 9.5 Auth &amp; Biometric Tests &bull; 9.6 Security Rules Tests &bull; 9.7 Benchmark Tests &bull; 9.8 Error Handling Tests &bull; 9.9 Firestore Optimization &bull; 9.10 Spark Plan Boundary &bull; 9.11 Release APK Build &bull; 9.12 Device Testing &bull; 9.13 Requirements Matrix &bull; 9.14 Final Screen Gallery</div>

        <div class="toc-item toc-chap"><strong>Checklist Bukti Implementasi &bull; Referensi IEEE &bull; Lampiran Skema Database</strong></div>
      </div>

      <h2 class="subchapter-title" style="margin-top: 28px;">Daftar Gambar (List of Figures)</h2>
      <table class="academic-table" style="font-size: 8pt;">
        <thead>
          <tr>
            <th style="width: 15%;">Nomor</th>
            <th>Judul Gambar / Deskripsi Diagram</th>
          </tr>
        </thead>
        <tbody>
          <tr><td>Figure 1</td><td>High-Level System Architecture — Edge AI On-Device &amp; Serverless Cloud Topology</td></tr>
          <tr><td>Figure 1b</td><td>UML Deployment Architecture — Client Node, Cloud Node, and Play Store Distribution</td></tr>
          <tr><td>Figure 2</td><td>NutriView UML Standard Use Case Diagram — Actors: Regular User &amp; Administrator</td></tr>
          <tr><td>Figure 3</td><td>Application Navigation Flowchart — NeoBottomNav Shell &amp; Auth Gates</td></tr>
          <tr><td>Figure 3b</td><td>UML Activity Diagram with Swimlanes — On-Device AI Detection &amp; Meal Logging Flow</td></tr>
          <tr><td>Figure 4</td><td>UI/UX Wireframes: Login, Dashboard, Scanner, History</td></tr>
          <tr><td>Figure 5</td><td>NutriView Cloud Firestore Document Schema Model (ERD)</td></tr>
          <tr><td>Figure 6</td><td>Firebase Console Project Setup UI Mockup / Configuration Illustration</td></tr>
          <tr><td>Figure 7</td><td>Cloud Firestore Database Configuration UI Mockup</td></tr>
          <tr><td>Figure 8</td><td>Firebase Token and Secure Session Flow Topology</td></tr>
          <tr><td>Figure 9</td><td>Database Logical Schema Diagram &amp; Document Hierarchy</td></tr>
          <tr><td>Figure 10</td><td>Security Rules and RBAC Configuration UI Mockup</td></tr>
          <tr><td>Figure 11</td><td>Offline Fallback &amp; Cache Storage Configuration UI Mockup</td></tr>
          <tr><td>Figure 12</td><td>Food Master Catalog Management UI Mockup</td></tr>
          <tr><td>Figure 13</td><td>Registration Screen UI Mockup</td></tr>
          <tr><td>Figure 14</td><td>Login Screen UI Mockup</td></tr>
          <tr><td>Figure 15</td><td>Dashboard UI Mockup / Configuration Illustration</td></tr>
          <tr><td>Figure 16</td><td>Meal History UI Mockup / Configuration Illustration</td></tr>
          <tr><td>Figure 17</td><td>Detection Confirmation UI Mockup</td></tr>
          <tr><td>Figure 18</td><td>Profile &amp; Biodata UI Mockup</td></tr>
          <tr><td>Figure 19</td><td>Camera Scanner UI Mockup</td></tr>
          <tr><td>Figure 20</td><td>UML Sequence Diagram: Computer Vision &amp; Meal Logging Flow</td></tr>
          <tr><td>Figure 21</td><td>Daily Calorie Target vs Intake Visualization</td></tr>
          <tr><td>Figure 22</td><td>Macronutrient Bento Distribution Chart</td></tr>
          <tr><td>Figure 23</td><td>Daily Nutrition Breakdown Report</td></tr>
          <tr><td>Figure 24</td><td>Release Build Compilation Output UI Mockup</td></tr>
          <tr><td>Figure 25</td><td>Test Suite &amp; Quality Verification Output (256 Tests Passed)</td></tr>
          <tr><td>Figure 26</td><td>Final Application Screen Gallery</td></tr>
        </tbody>
      </table>
    </div>
    """

    # Parse lines of Markdown
    lines = md_text.split("\n")
    body_html_parts = []
    
    i = 0
    in_code_block = False
    in_mermaid_block = False
    table_lines = []
    
    start_parsing = False

    while i < len(lines):
        line = lines[i].rstrip()
        
        # Omit pre-chapter text that was already captured on cover page
        if line.startswith("# 1 Project Planning and System Design"):
            start_parsing = True

        if not start_parsing:
            if line.startswith("# Petunjuk Penggunaan Laporan"):
                body_html_parts.append('<div class="page-break"></div>')
                body_html_parts.append('<h2 class="chapter-title" style="page-break-before: avoid; margin-top: 0;">Petunjuk Penggunaan Laporan</h2>')
                i += 1
                continue
            elif line.startswith("> **Integritas Single Source of Truth**"):
                body_html_parts.append(f'<div class="callout callout-success"><strong>[INTEGRITAS DATA SINGLE SOURCE OF TRUTH]</strong> {line[2:].strip()}</div>')
                i += 1
                continue
            elif line.startswith("Dokumen Business Requirements Document"):
                body_html_parts.append(f'<p>{line}</p>')
                i += 1
                continue
            elif line.startswith("Struktur pembahasan, urutan bab"):
                body_html_parts.append(f'<p>{line}</p>')
                i += 1
                continue
            else:
                # Skip cover metadata lines in body
                i += 1
                continue

        # Check mermaid
        if line.startswith("```mermaid"):
            in_mermaid_block = True
            i += 1
            continue
        elif in_mermaid_block:
            if line.startswith("```"):
                in_mermaid_block = False
            i += 1
            continue

        # Check other code blocks
        if line.startswith("```"):
            if not in_code_block:
                in_code_block = True
                code_lang = line[3:].strip()
                code_lines = []
                i += 1
                continue
            else:
                in_code_block = False
                escaped_code = "\n".join(code_lines).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                body_html_parts.append(f'<pre class="code-box"><code>{escaped_code}</code></pre>')
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
            if i < len(lines) and lines[i].startswith("|"):
                continue
            else:
                # Build HTML table
                rows_data = []
                for tl in table_lines:
                    if re.match(r'^\|[\s\-:|]+\|$', tl):
                        continue
                    cells = [c.strip() for c in tl.split("|")[1:-1]]
                    rows_data.append(cells)
                table_lines = []
                
                if rows_data:
                    table_html = ['<table class="academic-table">']
                    for r_idx, r in enumerate(rows_data):
                        if r_idx == 0:
                            table_html.append('<thead><tr>')
                            for c in r:
                                table_html.append(f'<th>{c}</th>')
                            table_html.append('</tr></thead><tbody>')
                        else:
                            table_html.append('<tr>')
                            for c in r:
                                cf = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', c)
                                cf = re.sub(r'\*(.*?)\*', r'<em>\1</em>', cf)
                                cf = re.sub(r'`(.*?)`', r'<code>\1</code>', cf)
                                table_html.append(f'<td>{cf}</td>')
                            table_html.append('</tr>')
                    table_html.append('</tbody></table>')
                    body_html_parts.append("\n".join(table_html))
                continue

        # Check callouts
        if line.startswith(">"):
            callout_text = line[1:].strip()
            while i + 1 < len(lines) and lines[i+1].startswith(">"):
                i += 1
                callout_text += " " + lines[i][1:].strip()
            cf = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', callout_text)
            callout_type = "callout-info"
            title = "CATATAN TEKNIS"
            if "Integritas" in cf:
                callout_type = "callout-success"
                title = "INTEGRITAS DATA"
            elif "Aturan Keamanan" in cf or "PENTING" in cf:
                callout_type = "callout-danger"
                title = "PERINGATAN KEAMANAN"
            body_html_parts.append(f'<div class="callout {callout_type}"><strong>[{title}]</strong> {cf}</div>')
            i += 1
            continue

        # Check image
        img_match = re.match(r'!\[(.*?)\]\((.*?)\)', line)
        if img_match:
            alt = img_match.group(1)
            rel_src = img_match.group(2)
            abs_src = os.path.join(DOC_DIR, rel_src)
            cap_text = alt
            if i + 1 < len(lines) and lines[i+1].startswith("*Figure"):
                cap_text = lines[i+1].strip()[1:-1]
                i += 1
            body_html_parts.append(f'''
            <figure class="academic-figure">
              <img src="file://{abs_src}" alt="{alt}" />
              <figcaption>{cap_text}</figcaption>
            </figure>
            ''')
            i += 1
            continue

        # Check Headings
        if line.startswith("# "):
            h_text = line[2:].strip()
            body_html_parts.append(f'<div class="page-break"></div><h1 class="chapter-title">{h_text}</h1>')
            i += 1
            continue

        if line.startswith("## "):
            h_text = line[3:].strip()
            body_html_parts.append(f'<h2 class="subchapter-title">{h_text}</h2>')
            i += 1
            continue

        if line.startswith("### "):
            h_text = line[4:].strip()
            body_html_parts.append(f'<h3 class="section-title">{h_text}</h3>')
            i += 1
            continue

        # Lists
        list_match = re.match(r'^(\-|\*|\d+\.)\s+(.+)$', line)
        if list_match:
            bullet_sym = list_match.group(1)
            item_text = list_match.group(2)
            item_text = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', item_text)
            item_text = re.sub(r'\*(.*?)\*', r'<em>\1</em>', item_text)
            item_text = re.sub(r'`(.*?)`', r'<code>\1</code>', item_text)
            body_html_parts.append(f'<ul class="academic-list"><li>{item_text}</li></ul>')
            i += 1
            continue

        # Standard Paragraph
        if line.strip():
            p_text = line.strip()
            p_text = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', p_text)
            p_text = re.sub(r'\*(.*?)\*', r'<em>\1</em>', p_text)
            p_text = re.sub(r'`(.*?)`', r'<code>\1</code>', p_text)
            body_html_parts.append(f'<p>{p_text}</p>')

        i += 1

    # Full HTML Document
    full_html = f"""<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <title>NutriView — Business Requirements Document &amp; Project Report</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap');

    @page {{
      size: A4 portrait;
      margin: 25mm 20mm 25mm 20mm;
      @top-right {{
        content: "NutriView — Business Requirements Document & Project Report";
        font-family: 'Inter', system-ui, sans-serif;
        font-size: 8pt;
        color: #94a3b8;
      }}
      @bottom-left {{
        content: "Ahmad Badawi (NIM 20090015) — Universitas Bina Insani";
        font-family: 'Inter', system-ui, sans-serif;
        font-size: 8pt;
        color: #94a3b8;
      }}
      @bottom-right {{
        content: counter(page);
        font-family: 'Inter', system-ui, sans-serif;
        font-size: 8.5pt;
        font-weight: 700;
        color: #0f172a;
      }}
    }}

    @page:first {{
      margin: 0;
      @top-right {{ content: none; }}
      @bottom-left {{ content: none; }}
      @bottom-right {{ content: none; }}
    }}

    * {{
      box-sizing: border-box;
    }}

    body {{
      font-family: 'Inter', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      font-size: 10pt;
      line-height: 1.6;
      color: #1e293b;
      margin: 0;
      padding: 0;
      background-color: #ffffff;
    }}

    .page-break {{
      page-break-before: always;
    }}

    /* Cover Page Styling */
    .cover-page {{
      height: 100vh;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      padding: 40mm 25mm 30mm 25mm;
      background: linear-gradient(180deg, #f8fafc 0%, #ffffff 100%);
      page-break-after: always;
    }}

    .cover-top-bar {{
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      height: 12px;
      background: linear-gradient(90deg, #2563eb 0%, #3b82f6 50%, #60a5fa 100%);
    }}

    .cover-badge {{
      display: inline-block;
      font-size: 8.5pt;
      font-weight: 700;
      letter-spacing: 0.1em;
      text-transform: uppercase;
      color: #2563eb;
      background: #eff6ff;
      border: 1px solid #bfdbfe;
      padding: 6px 14px;
      border-radius: 20px;
      margin-bottom: 24px;
    }}

    .cover-title {{
      font-size: 42pt;
      font-weight: 800;
      line-height: 1.1;
      color: #0f172a;
      letter-spacing: -0.02em;
      margin: 0 0 10px 0;
    }}

    .cover-subtitle {{
      font-size: 16pt;
      font-weight: 500;
      color: #475569;
      margin-bottom: 24px;
    }}

    .cover-divider {{
      width: 80px;
      height: 4px;
      background: #2563eb;
      border-radius: 2px;
      margin-bottom: 24px;
    }}

    .cover-abstract {{
      font-size: 10.5pt;
      line-height: 1.7;
      color: #334155;
      margin-bottom: 36px;
      max-width: 650px;
    }}

    .cover-meta-grid {{
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px;
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      padding: 20px;
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
    }}

    .meta-card {{
      display: flex;
      flex-direction: column;
    }}

    .meta-label {{
      font-size: 8pt;
      font-weight: 600;
      color: #64748b;
      text-transform: uppercase;
      margin-bottom: 4px;
    }}

    .meta-value {{
      font-size: 9.5pt;
      color: #0f172a;
    }}

    .status-tag {{
      display: inline-block;
      background: #f1f5f9;
      color: #0f172a;
      padding: 2px 8px;
      border-radius: 4px;
      font-weight: 600;
      border: 1px solid #cbd5e1;
    }}

    .badge-success {{
      display: inline-block;
      background: #ecfdf5;
      color: #065f46;
      padding: 2px 8px;
      border-radius: 4px;
      font-weight: 600;
      border: 1px solid #a7f3d0;
    }}

    .cover-footer-text {{
      font-size: 8pt;
      color: #94a3b8;
      text-align: center;
      margin-top: 20px;
    }}

    /* TOC styling */
    .toc-container {{
      margin: 10px 0;
    }}

    .toc-block {{
      margin: 16px 0;
    }}

    .toc-chap {{
      font-size: 9.5pt;
      font-weight: 700;
      color: #0f172a;
      margin-top: 10px;
      margin-bottom: 2px;
    }}

    .toc-sub {{
      font-size: 8.5pt;
      color: #475569;
      margin-left: 12px;
      margin-bottom: 6px;
      line-height: 1.45;
    }}

    /* Chapter and Section Titles */
    h1.chapter-title {{
      font-size: 20pt;
      font-weight: 800;
      color: #0f172a;
      border-bottom: 2.5px solid #2563eb;
      padding-bottom: 8px;
      margin-top: 10px;
      margin-bottom: 20px;
      page-break-after: avoid;
    }}

    h2.subchapter-title {{
      font-size: 13.5pt;
      font-weight: 700;
      color: #1e40af;
      margin-top: 26px;
      margin-bottom: 10px;
      page-break-after: avoid;
    }}

    h3.section-title {{
      font-size: 11pt;
      font-weight: 600;
      color: #334155;
      margin-top: 18px;
      margin-bottom: 6px;
      page-break-after: avoid;
    }}

    p {{
      margin: 8px 0;
      text-align: justify;
    }}

    /* Tables */
    table.academic-table {{
      width: 100%;
      border-collapse: collapse;
      margin: 16px 0;
      font-size: 8.5pt;
      page-break-inside: avoid;
    }}

    table.academic-table th {{
      background-color: #0f172a;
      color: #ffffff;
      font-weight: 700;
      text-align: left;
      padding: 8px 10px;
      border: 1px solid #0f172a;
    }}

    table.academic-table td {{
      padding: 7px 10px;
      border-bottom: 1px solid #e2e8f0;
      border-right: 1px solid #f1f5f9;
      border-left: 1px solid #f1f5f9;
      color: #1e293b;
      vertical-align: top;
    }}

    table.academic-table tbody tr:nth-child(even) {{
      background-color: #f8fafc;
    }}

    table.doc-control-table th {{
      background-color: #f8fafc;
      color: #0f172a;
      border: 1px solid #e2e8f0;
      font-size: 8.5pt;
    }}

    table.doc-control-table td {{
      border: 1px solid #e2e8f0;
    }}

    .status-approved {{
      background: #ecfdf5;
      color: #047857;
      padding: 2px 6px;
      border-radius: 4px;
      font-weight: 600;
    }}

    .status-muted {{
      color: #64748b;
    }}

    /* Callout Boxes */
    .callout {{
      padding: 12px 16px;
      margin: 14px 0;
      border-radius: 0 6px 6px 0;
      font-size: 9pt;
      line-height: 1.5;
      page-break-inside: avoid;
    }}

    .callout-info {{
      border-left: 4px solid #2563eb;
      background-color: #eff6ff;
      color: #1e3a8a;
    }}

    .callout-success {{
      border-left: 4px solid #059669;
      background-color: #ecfdf5;
      color: #064e3b;
    }}

    .callout-danger {{
      border-left: 4px solid #dc2626;
      background-color: #fef2f2;
      color: #7f1d1d;
    }}

    /* Figures and Images */
    figure.academic-figure {{
      margin: 22px 0;
      text-align: center;
      page-break-inside: avoid;
    }}

    figure.academic-figure img {{
      max-width: 95%;
      max-height: 520px;
      height: auto;
      border: 1px solid #cbd5e1;
      border-radius: 6px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.06);
    }}

    figure.academic-figure figcaption {{
      font-size: 8.5pt;
      font-style: italic;
      color: #475569;
      margin-top: 8px;
    }}

    /* Code Boxes */
    pre.code-box {{
      background-color: #f8fafc;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      padding: 12px;
      font-family: 'JetBrains Mono', Consolas, monospace;
      font-size: 8pt;
      line-height: 1.45;
      color: #0f172a;
      overflow-x: auto;
      page-break-inside: avoid;
      margin: 12px 0;
    }}

    code {{
      font-family: 'JetBrains Mono', Consolas, monospace;
      font-size: 8.5pt;
      background: #f1f5f9;
      color: #0f172a;
      padding: 1px 4px;
      border-radius: 3px;
    }}

    /* Lists */
    ul.academic-list {{
      margin: 6px 0;
      padding-left: 20px;
    }}

    ul.academic-list li {{
      margin-bottom: 4px;
      color: #1e293b;
    }}
  </style>
</head>
<body>
  {cover_html}
  {doc_control_html}
  {toc_html}
  {"".join(body_html_parts)}
</body>
</html>"""

    print(f"Writing compiled HTML to {HTML_TEMP}...")
    with open(HTML_TEMP, "w", encoding="utf-8") as f:
        f.write(full_html)
    print(f"HTML generated successfully! Size: {os.path.getsize(HTML_TEMP)} bytes")

    print(f"Compiling PDF via Headless Brave Browser to {OUTPUT_PDF}...")
    cmd = [
        "/usr/bin/brave-browser",
        "--headless",
        "--disable-gpu",
        "--no-sandbox",
        "--run-all-compositor-stages-before-draw",
        f"--print-to-pdf={OUTPUT_PDF}",
        HTML_TEMP
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print("Error compiling PDF:", res.stderr)
    else:
        print(f"PDF generated successfully! Output: {OUTPUT_PDF}, Size: {os.path.getsize(OUTPUT_PDF)} bytes")

if __name__ == "__main__":
    markdown_to_html()
