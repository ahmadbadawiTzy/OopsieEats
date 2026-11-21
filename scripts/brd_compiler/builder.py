"""
Core compiler engine for OopsieEats Professional BRD chapters and master index.
Generates Markdown, DOCX, and stamped PDF with dedicated Cover Pages and exact page numbering.
"""

import os
import subprocess
import html
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT

from scripts.brd_compiler.styles import (
    COLOR_NAVY, COLOR_ROYAL, COLOR_DARK, COLOR_GRAY, COLOR_MUTED,
    HEX_NAVY, HEX_BG_LIGHT, HEX_CALLOUT_BG, HEX_CALLOUT_BORDER,
    HTML_CSS_TEMPLATE, setup_docx_document, add_docx_running_header_footer,
    style_docx_table, stamp_pdf_with_headers_and_footers
)

class ChapterContent:
    def __init__(self, chapter_id, number_str, title, subtitle, filename):
        self.chapter_id = chapter_id
        self.number_str = number_str
        self.title = title
        self.subtitle = subtitle
        self.filename = filename
        self.elements = []

    def add_p(self, text):
        self.elements.append(('p', text))

    def add_h2(self, text):
        self.elements.append(('h2', text))

    def add_h3(self, text):
        self.elements.append(('h3', text))

    def add_h4(self, text):
        self.elements.append(('h4', text))

    def add_list(self, items, ordered=False):
        self.elements.append(('list', items, ordered))

    def add_callout(self, text):
        self.elements.append(('callout', text))

    def add_table(self, caption, headers, rows):
        self.elements.append(('table', caption, headers, rows))

    def add_figure(self, path, caption, is_wireframe=False):
        self.elements.append(('figure', path, caption, is_wireframe))

    def to_markdown(self):
        lines = []
        lines.append(f"# {self.number_str.upper()}: {self.title}\n")
        lines.append(f"**{self.subtitle}**\n")
        lines.append("---\n")
        lines.append(f"**Aplikasi:** OopsieEats (`com.oopsieeats.app`) | **Versi:** 1.0.0+2002  ")
        lines.append(f"**Penyusun:** Ahmad Badawi (NIM 20090015) — Universitas Bina Insani  ")
        lines.append(f"**Status:** Approved & Baselined | **Klasifikasi:** Confidential / Restricted\n")
        lines.append("---\n")

        for elem in self.elements:
            kind = elem[0]
            if kind == 'p':
                lines.append(f"{elem[1]}\n")
            elif kind == 'h2':
                lines.append(f"\n## {elem[1]}\n")
            elif kind == 'h3':
                lines.append(f"\n### {elem[1]}\n")
            elif kind == 'h4':
                lines.append(f"\n#### {elem[1]}\n")
            elif kind == 'list':
                items, ordered = elem[1], elem[2]
                for idx, item in enumerate(items, start=1):
                    prefix = f"{idx}." if ordered else "-"
                    lines.append(f"{prefix} {item}")
                lines.append("")
            elif kind == 'callout':
                lines.append(f"> **Catatan Arsitektural**: {elem[1]}\n")
            elif kind == 'table':
                caption, headers, rows = elem[1], elem[2], elem[3]
                lines.append(f"**{caption}**\n")
                lines.append("| " + " | ".join(headers) + " |")
                lines.append("| " + " | ".join(["---"] * len(headers)) + " |")
                for r in rows:
                    lines.append("| " + " | ".join(str(c) for c in r) + " |")
                lines.append("")
            elif kind == 'figure':
                path, caption, is_wireframe = elem[1], elem[2], elem[3]
                lines.append(f"\n![{caption}]({path})")
                lines.append(f"*{caption}*\n")

        return "\n".join(lines)

    def to_html(self):
        body_parts = []

        # 1. DEDICATED FULL COVER PAGE (Halaman Sampul Depan)
        body_parts.append("<div class='cover-container'>")
        body_parts.append("  <div class='cover-top'>")
        body_parts.append("    <div class='cover-app-badge'>OOPSIEEATS MOBILE APPLICATION</div>")
        body_parts.append("    <div class='cover-doc-series'>BUSINESS REQUIREMENTS DOCUMENT (BRD) SUITE</div>")
        body_parts.append("  </div>")
        body_parts.append("  <div class='cover-center'>")
        body_parts.append(f"    <div class='cover-chapter-badge'>{html.escape(self.number_str.upper())}</div>")
        body_parts.append(f"    <h1 class='cover-title'>{html.escape(self.title)}</h1>")
        body_parts.append("    <div class='cover-divider'></div>")
        body_parts.append(f"    <div class='cover-subtitle'>{html.escape(self.subtitle)}</div>")
        body_parts.append("  </div>")
        body_parts.append("  <div class='cover-bottom'>")
        body_parts.append("    <table class='cover-meta-table'>")
        body_parts.append("      <tr><td class='label'>Nama Aplikasi Resmi</td><td class='val'>OopsieEats (<code>com.oopsieeats.app</code>)</td></tr>")
        body_parts.append("      <tr><td class='label'>Versi & Target SDK</td><td class='val'>1.0.0+2002 (Target SDK 36, compileSdk 36, minSdk 23)</td></tr>")
        body_parts.append(f"      <tr><td class='label'>Modul Dokumen</td><td class='val'>{html.escape(self.number_str)}: {html.escape(self.title)}</td></tr>")
        body_parts.append("      <tr><td class='label'>Penulis / Architect</td><td class='val'>Ahmad Badawi (NIM 20090015) — Lead Software Architect</td></tr>")
        body_parts.append("      <tr><td class='label'>Status Verifikasi</td><td class='val'>DISETUJUI &amp; BASELINED (359/359 Automated Tests Passed, 0 Lints)</td></tr>")
        body_parts.append("      <tr><td class='label'>Klasifikasi Akses</td><td class='val'>CONFIDENTIAL / RESTRICTED (Dokumen Resmi Rekayasa)</td></tr>")
        body_parts.append("    </table>")
        body_parts.append("    <div class='cover-institution'>")
        body_parts.append("      PROGRAM STUDI SISTEM INFORMASI &bull; FAKULTAS ILMU KOMPUTER<br>")
        body_parts.append("      UNIVERSITAS BINA INSANI &bull; TAHUN 2026")
        body_parts.append("    </div>")
        body_parts.append("  </div>")
        body_parts.append("</div>")

        # 2. CHAPTER CONTENT (Starts on Page 2)
        body_parts.append("<div class='chapter-header'>")
        body_parts.append(f"<div class='chapter-number'>{self.number_str}</div>")
        body_parts.append(f"<h1 class='chapter-title'>{html.escape(self.title)}</h1>")
        body_parts.append(f"<div class='chapter-subtitle'>{html.escape(self.subtitle)}</div>")
        body_parts.append("</div>")

        for elem in self.elements:
            kind = elem[0]
            if kind == 'p':
                body_parts.append(f"<p>{elem[1]}</p>")
            elif kind == 'h2':
                body_parts.append(f"<h2>{html.escape(elem[1])}</h2>")
            elif kind == 'h3':
                body_parts.append(f"<h3>{html.escape(elem[1])}</h3>")
            elif kind == 'h4':
                body_parts.append(f"<h4>{html.escape(elem[1])}</h4>")
            elif kind == 'list':
                items, ordered = elem[1], elem[2]
                tag = "ol" if ordered else "ul"
                body_parts.append(f"<{tag}>")
                for it in items:
                    body_parts.append(f"<li>{it}</li>")
                body_parts.append(f"</{tag}>")
            elif kind == 'callout':
                body_parts.append(f"<div class='callout'><strong>Catatan Arsitektur & Implementasi:</strong> {elem[1]}</div>")
            elif kind == 'table':
                caption, headers, rows = elem[1], elem[2], elem[3]
                body_parts.append(f"<div class='table-caption'>{html.escape(caption)}</div>")
                body_parts.append("<table>")
                body_parts.append("<thead><tr>")
                for h in headers:
                    body_parts.append(f"<th>{html.escape(h)}</th>")
                body_parts.append("</tr></thead><tbody>")
                for r in rows:
                    body_parts.append("<tr>")
                    for cell in r:
                        body_parts.append(f"<td>{cell}</td>")
                    body_parts.append("</tr>")
                body_parts.append("</tbody></table>")
            elif kind == 'figure':
                path, caption, is_wireframe = elem[1], elem[2], elem[3]
                cls = "wireframe-img" if is_wireframe else "figure-img"
                abs_path = os.path.abspath(path)
                body_parts.append("<div class='figure-box'>")
                body_parts.append(f"<img class='{cls}' src='file://{abs_path}' alt='{html.escape(caption)}'>")
                body_parts.append(f"<div class='figure-caption'>{html.escape(caption)}</div>")
                body_parts.append("</div>")

        full_html = HTML_CSS_TEMPLATE.format(
            title=f"{self.number_str} — {self.title}",
            content="\n".join(body_parts)
        )
        return full_html

    def compile_docx(self, output_path):
        doc = setup_docx_document()
        add_docx_running_header_footer(doc, f"{self.number_str}: {self.title}")

        # ==========================================
        # HALAMAN SAMPUL RESMI (COVER PAGE)
        # ==========================================
        top_p = doc.add_paragraph()
        top_p.paragraph_format.space_before = Pt(20)
        top_p.paragraph_format.space_after = Pt(2)
        top_run = top_p.add_run("OOPSIEEATS MOBILE APPLICATION")
        top_run.font.name = "Arial"
        top_run.font.size = Pt(12)
        top_run.font.bold = True
        top_run.font.color.rgb = COLOR_ROYAL

        sub_top = doc.add_paragraph()
        sub_top.paragraph_format.space_after = Pt(40)
        st_run = sub_top.add_run("BUSINESS REQUIREMENTS DOCUMENT (BRD) SUITE")
        st_run.font.name = "Arial"
        st_run.font.size = Pt(9.5)
        st_run.font.bold = True
        st_run.font.color.rgb = COLOR_MUTED

        # Chapter Number Badge
        num_p = doc.add_paragraph()
        num_p.paragraph_format.space_after = Pt(6)
        nrun = num_p.add_run(self.number_str.upper())
        nrun.font.name = "Arial"
        nrun.font.size = Pt(13)
        nrun.font.bold = True
        nrun.font.color.rgb = COLOR_ROYAL

        # Chapter Title
        title_p = doc.add_paragraph()
        title_p.paragraph_format.space_after = Pt(12)
        trun = title_p.add_run(self.title)
        trun.font.name = "Arial"
        trun.font.size = Pt(24)
        trun.font.bold = True
        trun.font.color.rgb = COLOR_NAVY

        # Subtitle
        sub_p = doc.add_paragraph()
        sub_p.paragraph_format.space_after = Pt(36)
        srun = sub_p.add_run(self.subtitle)
        srun.font.name = "Arial"
        srun.font.size = Pt(11)
        srun.font.italic = True
        srun.font.color.rgb = COLOR_GRAY

        # Cover Metadata Table
        meta_table = doc.add_table(rows=6, cols=2)
        meta_table.alignment = WD_TABLE_ALIGNMENT.CENTER
        meta_data = [
            ("Nama Aplikasi Resmi", "OopsieEats (com.oopsieeats.app)"),
            ("Versi & Target SDK", "1.0.0+2002 (Target SDK 36, compileSdk 36, minSdk 23)"),
            ("Modul Dokumen", f"{self.number_str}: {self.title}"),
            ("Penyusun & Architect", "Ahmad Badawi (NIM 20090015) — Lead Software Architect"),
            ("Status Verifikasi", "DISETUJUI & BASELINED (359/359 Tests Passed, 0 Lints)"),
            ("Klasifikasi Akses", "CONFIDENTIAL / RESTRICTED (Dokumen Resmi Rekayasa)")
        ]
        for row_idx, (label, val) in enumerate(meta_data):
            cell_l = meta_table.rows[row_idx].cells[0]
            cell_v = meta_table.rows[row_idx].cells[1]
            cell_l.width = Inches(2.2)
            cell_v.width = Inches(4.3)
            cell_l.paragraphs[0].add_run(label).font.bold = True
            cell_l.paragraphs[0].runs[0].font.size = Pt(9)
            cell_l.paragraphs[0].runs[0].font.color.rgb = COLOR_NAVY
            cell_v.paragraphs[0].add_run(val).font.size = Pt(9)
        style_docx_table(meta_table)

        doc.add_paragraph() # spacing
        inst_p = doc.add_paragraph()
        inst_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        inst_p.paragraph_format.space_before = Pt(40)
        irun = inst_p.add_run("PROGRAM STUDI SISTEM INFORMASI • FAKULTAS ILMU KOMPUTER\nUNIVERSITAS BINA INSANI • 2026")
        irun.font.name = "Arial"
        irun.font.size = Pt(9)
        irun.font.bold = True
        irun.font.color.rgb = COLOR_MUTED

        # PAGE BREAK — Content begins on Page 2
        doc.add_page_break()

        # ==========================================
        # KONTEN BAB (STARTS ON PAGE 2)
        # ==========================================
        c_head_num = doc.add_paragraph()
        c_head_num.paragraph_format.space_before = Pt(10)
        c_head_num.paragraph_format.space_after = Pt(2)
        c_hn_run = c_head_num.add_run(self.number_str.upper())
        c_hn_run.font.name = "Arial"
        c_hn_run.font.size = Pt(11)
        c_hn_run.font.bold = True
        c_hn_run.font.color.rgb = COLOR_ROYAL

        c_head_title = doc.add_paragraph()
        c_head_title.paragraph_format.space_after = Pt(4)
        c_ht_run = c_head_title.add_run(self.title)
        c_ht_run.font.name = "Arial"
        c_ht_run.font.size = Pt(18)
        c_ht_run.font.bold = True
        c_ht_run.font.color.rgb = COLOR_NAVY

        c_head_sub = doc.add_paragraph()
        c_head_sub.paragraph_format.space_after = Pt(16)
        c_hs_run = c_head_sub.add_run(self.subtitle)
        c_hs_run.font.name = "Arial"
        c_hs_run.font.size = Pt(10)
        c_hs_run.font.color.rgb = COLOR_GRAY

        # Render elements
        for elem in self.elements:
            kind = elem[0]
            if kind == 'p':
                p = doc.add_paragraph()
                p.paragraph_format.line_spacing = 1.15
                p.paragraph_format.space_after = Pt(6)
                raw = elem[1]
                parts = raw.replace('<b>', '<strong>').replace('</b>', '</strong>').split('<strong>')
                first = True
                for part in parts:
                    if first:
                        if part:
                            r = p.add_run(part.replace('<code>', '').replace('</code>', ''))
                            r.font.name = "Arial"
                            r.font.size = Pt(10)
                            r.font.color.rgb = COLOR_DARK
                        first = False
                    else:
                        subparts = part.split('</strong>')
                        bold_text = subparts[0]
                        r_b = p.add_run(bold_text.replace('<code>', '').replace('</code>', ''))
                        r_b.font.name = "Arial"
                        r_b.font.size = Pt(10)
                        r_b.font.bold = True
                        r_b.font.color.rgb = COLOR_DARK
                        if len(subparts) > 1 and subparts[1]:
                            r_norm = p.add_run(subparts[1].replace('<code>', '').replace('</code>', ''))
                            r_norm.font.name = "Arial"
                            r_norm.font.size = Pt(10)
                            r_norm.font.color.rgb = COLOR_DARK

            elif kind == 'h2':
                h2 = doc.add_paragraph()
                h2.paragraph_format.space_before = Pt(16)
                h2.paragraph_format.space_after = Pt(6)
                h2.paragraph_format.keep_with_next = True
                run = h2.add_run(elem[1])
                run.font.name = "Arial"
                run.font.size = Pt(13)
                run.font.bold = True
                run.font.color.rgb = COLOR_NAVY

            elif kind == 'h3':
                h3 = doc.add_paragraph()
                h3.paragraph_format.space_before = Pt(12)
                h3.paragraph_format.space_after = Pt(4)
                h3.paragraph_format.keep_with_next = True
                run = h3.add_run(elem[1])
                run.font.name = "Arial"
                run.font.size = Pt(11)
                run.font.bold = True
                run.font.color.rgb = COLOR_ROYAL

            elif kind == 'h4':
                h4 = doc.add_paragraph()
                h4.paragraph_format.space_before = Pt(8)
                h4.paragraph_format.space_after = Pt(3)
                h4.paragraph_format.keep_with_next = True
                run = h4.add_run(elem[1])
                run.font.name = "Arial"
                run.font.size = Pt(10)
                run.font.bold = True
                run.font.color.rgb = COLOR_DARK

            elif kind == 'list':
                items, ordered = elem[1], elem[2]
                for idx, it in enumerate(items, start=1):
                    lp = doc.add_paragraph(style='List Bullet' if not ordered else 'List Number')
                    lp.paragraph_format.space_after = Pt(3)
                    clean_it = it.replace('<strong>', '').replace('</strong>', '').replace('<code>', '').replace('</code>', '')
                    r = lp.add_run(clean_it)
                    r.font.name = "Arial"
                    r.font.size = Pt(9.5)
                    r.font.color.rgb = COLOR_DARK

            elif kind == 'callout':
                cp = doc.add_paragraph()
                cp.paragraph_format.space_before = Pt(8)
                cp.paragraph_format.space_after = Pt(8)
                r_c = cp.add_run(f"CATATAN TEKNIS: {elem[1]}")
                r_c.font.name = "Arial"
                r_c.font.size = Pt(9)
                r_c.font.italic = True
                r_c.font.color.rgb = COLOR_NAVY

            elif kind == 'table':
                caption, headers, rows = elem[1], elem[2], elem[3]
                cap_p = doc.add_paragraph()
                cap_p.paragraph_format.space_before = Pt(10)
                cap_p.paragraph_format.space_after = Pt(3)
                cap_p.paragraph_format.keep_with_next = True
                cap_r = cap_p.add_run(caption)
                cap_r.font.name = "Arial"
                cap_r.font.size = Pt(9)
                cap_r.font.bold = True
                cap_r.font.color.rgb = COLOR_NAVY

                t = doc.add_table(rows=len(rows) + 1, cols=len(headers))
                for col_idx, h in enumerate(headers):
                    t.rows[0].cells[col_idx].paragraphs[0].text = h
                for row_idx, r_data in enumerate(rows, start=1):
                    for col_idx, c_val in enumerate(r_data):
                        clean_val = str(c_val).replace('<strong>', '').replace('</strong>', '').replace('<code>', '').replace('</code>', '')
                        t.rows[row_idx].cells[col_idx].paragraphs[0].text = clean_val
                style_docx_table(t)
                doc.add_paragraph()

            elif kind == 'figure':
                path, caption, is_wireframe = elem[1], elem[2], elem[3]
                if os.path.exists(path):
                    fig_p = doc.add_paragraph()
                    fig_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                    fig_p.paragraph_format.space_before = Pt(12)
                    fig_p.paragraph_format.space_after = Pt(4)
                    width = Inches(2.6) if is_wireframe else Inches(5.6)
                    fig_p.add_run().add_picture(path, width=width)

                    cap_p = doc.add_paragraph()
                    cap_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                    cap_p.paragraph_format.space_after = Pt(12)
                    cap_p.paragraph_format.keep_with_next = True
                    cap_r = cap_p.add_run(caption)
                    cap_r.font.name = "Arial"
                    cap_r.font.size = Pt(8.5)
                    cap_r.font.italic = True
                    cap_r.font.color.rgb = COLOR_GRAY

        doc.save(output_path)

    def compile_pdf(self, output_path, temp_dir="/tmp/brd_render"):
        os.makedirs(temp_dir, exist_ok=True)
        raw_html_path = os.path.join(temp_dir, f"{self.filename}.html")
        raw_pdf_path = os.path.join(temp_dir, f"{self.filename}_raw.pdf")

        with open(raw_html_path, "w", encoding="utf-8") as f:
            f.write(self.to_html())

        cmd = [
            "brave-browser",
            "--headless",
            "--disable-gpu",
            "--no-pdf-header-footer",
            f"--print-to-pdf={raw_pdf_path}",
            raw_html_path
        ]
        res = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if res.returncode != 0 or not os.path.exists(raw_pdf_path):
            raise RuntimeError(f"Failed to render PDF for {self.filename}")

        header_title = f"{self.number_str}: {self.title}"
        stamp_pdf_with_headers_and_footers(raw_pdf_path, output_path, header_title, has_cover=True)

        from pypdf import PdfReader
        r = PdfReader(output_path)
        return len(r.pages)
