"""
Style definitions, docx XML helpers, HTML templates, and ReportLab PDF stamper
for the OopsieEats Professional BRD Suite.
"""

import os
import io
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from pypdf import PdfReader, PdfWriter

# Color Palette Constants
COLOR_NAVY = RGBColor(0x1E, 0x3A, 0x8A)      # #1E3A8A
COLOR_ROYAL = RGBColor(0x25, 0x63, 0xEB)     # #2563EB
COLOR_DARK = RGBColor(0x1F, 0x29, 0x37)      # #1F2937
COLOR_GRAY = RGBColor(0x4B, 0x55, 0x63)      # #4B5563
COLOR_MUTED = RGBColor(0x64, 0x74, 0x8B)     # #64748B
COLOR_WHITE = RGBColor(0xFF, 0xFF, 0xFF)     # #FFFFFF

HEX_NAVY = "1E3A8A"
HEX_ROYAL = "2563EB"
HEX_BG_LIGHT = "F8FAFC"
HEX_BORDER = "E2E8F0"
HEX_CALLOUT_BG = "EFF6FF"
HEX_CALLOUT_BORDER = "3B82F6"

HTML_CSS_TEMPLATE = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>{title}</title>
<style>
  @page {{
    size: A4;
    margin: 25mm 20mm 25mm 20mm;
  }}
  * {{
    box-sizing: border-box;
  }}
  body {{
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    font-size: 10.5pt;
    line-height: 1.65;
    color: #1f2937;
    margin: 0;
    padding: 0;
    background-color: #ffffff;
  }}

  /* Full Page Cover Styling */
  .cover-container {{
    min-height: 245mm;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    border: 3px solid #1e3a8a;
    padding: 30px;
    background-color: #ffffff;
    box-shadow: inset 0 0 0 2px #e2e8f0;
    page-break-after: always;
  }}
  .cover-top {{
    border-bottom: 2px solid #2563eb;
    padding-bottom: 15px;
  }}
  .cover-app-badge {{
    font-size: 12pt;
    font-weight: 800;
    color: #2563eb;
    letter-spacing: 2px;
    text-transform: uppercase;
  }}
  .cover-doc-series {{
    font-size: 9pt;
    font-weight: 600;
    color: #64748b;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    margin-top: 4px;
  }}
  .cover-center {{
    margin: 40px 0;
    text-align: left;
  }}
  .cover-chapter-badge {{
    display: inline-block;
    background-color: #1e3a8a;
    color: #ffffff;
    font-size: 11pt;
    font-weight: 700;
    padding: 4px 14px;
    border-radius: 4px;
    letter-spacing: 1px;
    text-transform: uppercase;
    margin-bottom: 16px;
  }}
  .cover-title {{
    font-size: 24pt;
    font-weight: 800;
    color: #0f172a;
    line-height: 1.2;
    margin: 0 0 16px 0;
  }}
  .cover-divider {{
    width: 80px;
    height: 4px;
    background-color: #2563eb;
    margin-bottom: 16px;
  }}
  .cover-subtitle {{
    font-size: 12pt;
    font-weight: 500;
    color: #475569;
    line-height: 1.5;
    margin: 0;
  }}
  .cover-bottom {{
    margin-top: auto;
  }}
  .cover-meta-table {{
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 20px;
    font-size: 9pt;
  }}
  .cover-meta-table td {{
    padding: 6px 10px;
    border: 1px solid #cbd5e1;
  }}
  .cover-meta-table td.label {{
    width: 28%;
    background-color: #f1f5f9;
    font-weight: 700;
    color: #1e3a8a;
  }}
  .cover-meta-table td.val {{
    width: 72%;
    color: #0f172a;
  }}
  .cover-institution {{
    text-align: center;
    font-size: 8.5pt;
    font-weight: 600;
    color: #475569;
    border-top: 1px solid #e2e8f0;
    padding-top: 12px;
    line-height: 1.4;
  }}

  /* Content Header on Page 2+ */
  .chapter-header {{
    border-bottom: 3px solid #1e3a8a;
    padding-bottom: 14px;
    margin-bottom: 24px;
  }}
  .chapter-number {{
    font-size: 10.5pt;
    font-weight: 700;
    color: #2563eb;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    margin-bottom: 4px;
  }}
  .chapter-title {{
    font-size: 20pt;
    font-weight: 800;
    color: #1e3a8a;
    line-height: 1.25;
    margin: 0;
  }}
  .chapter-subtitle {{
    font-size: 10.5pt;
    color: #4b5563;
    margin-top: 6px;
    margin-bottom: 0;
  }}

  h2 {{
    font-size: 13.5pt;
    font-weight: 700;
    color: #1e3a8a;
    border-bottom: 1.5px solid #cbd5e1;
    padding-bottom: 6px;
    margin-top: 28px;
    margin-bottom: 12px;
    page-break-after: avoid;
  }}
  h3 {{
    font-size: 11pt;
    font-weight: 700;
    color: #2563eb;
    margin-top: 20px;
    margin-bottom: 8px;
    page-break-after: avoid;
  }}
  h4 {{
    font-size: 10pt;
    font-weight: 700;
    color: #334155;
    margin-top: 14px;
    margin-bottom: 6px;
    page-break-after: avoid;
  }}
  p {{
    margin: 8px 0;
    text-align: justify;
  }}
  ul, ol {{
    margin: 8px 0 12px 20px;
    padding: 0;
  }}
  li {{
    margin-bottom: 4px;
  }}
  code {{
    font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
    font-size: 9pt;
    background-color: #f1f5f9;
    border: 1px solid #e2e8f0;
    border-radius: 3px;
    padding: 1px 4px;
    color: #0f172a;
  }}
  pre {{
    font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
    font-size: 8.5pt;
    background-color: #f8fafc;
    border: 1px solid #cbd5e1;
    border-radius: 6px;
    padding: 12px;
    overflow-x: auto;
    line-height: 1.45;
    margin: 12px 0;
    page-break-inside: avoid;
  }}
  table {{
    width: 100%;
    border-collapse: collapse;
    margin: 16px 0;
    font-size: 9pt;
    page-break-inside: avoid;
  }}
  th {{
    background-color: #1e3a8a;
    color: #ffffff;
    font-weight: 700;
    text-align: left;
    padding: 7px 9px;
    border: 1px solid #1e3a8a;
  }}
  td {{
    padding: 6px 9px;
    border: 1px solid #e2e8f0;
    vertical-align: top;
  }}
  tr:nth-child(even) {{
    background-color: #f8fafc;
  }}
  .table-caption {{
    font-size: 9.5pt;
    font-weight: 700;
    color: #1e3a8a;
    margin-bottom: 4px;
    page-break-after: avoid;
  }}
  .callout {{
    background-color: #eff6ff;
    border-left: 4px solid #3b82f6;
    border-radius: 4px;
    padding: 10px 14px;
    margin: 14px 0;
    font-size: 9.5pt;
    color: #1e3a8a;
    page-break-inside: avoid;
  }}
  .callout strong {{
    color: #1e40af;
  }}
  .figure-box {{
    text-align: center;
    margin: 20px 0;
    page-break-inside: avoid;
  }}
  .figure-img {{
    max-width: 95%;
    height: auto;
    border: 1px solid #cbd5e1;
    border-radius: 6px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    background-color: #ffffff;
  }}
  .figure-caption {{
    font-size: 9pt;
    font-style: italic;
    color: #475569;
    margin-top: 6px;
  }}
  .wireframe-img {{
    max-height: 380px;
    width: auto;
    border: 1px solid #94a3b8;
    border-radius: 4px;
    background-color: #ffffff;
  }}
  .page-break {{
    page-break-after: always;
  }}
</style>
</head>
<body>
{content}
</body>
</html>
"""


def stamp_pdf_with_headers_and_footers(input_path, output_path, chapter_title, has_cover=True):
    """
    Stamps header and footer with exact page count on every page of the PDF.
    If has_cover=True:
      - Page 1 (index 0) is the Cover Page and receives NO header or footer stamps.
      - Page 2..N (index 1..N-1) receive running header and running footer:
        Header: Left: OOPSIEEATS — Business Requirements Document, Right: chapter_title
        Footer: Left: CONFIDENTIAL — STRICTLY FOR INTERNAL / ACADEMIC AUDIT, Right: Halaman X dari Y
    """
    writer = PdfWriter(clone_from=input_path)
    total_pages = len(writer.pages)
    width, height = A4

    for i, page in enumerate(writer.pages):
        # Skip stamping on Cover Page (page index 0)
        if has_cover and i == 0:
            continue

        packet = io.BytesIO()
        can = canvas.Canvas(packet, pagesize=A4)

        # Header
        can.setFont("Helvetica-Bold", 8)
        can.setFillColorRGB(0.12, 0.23, 0.54)  # #1E3A8A
        can.drawString(45, height - 35, "OOPSIEEATS")
        can.setFont("Helvetica", 8)
        can.setFillColorRGB(0.39, 0.45, 0.55)
        can.drawString(108, height - 35, "— Business Requirements Document")
        can.drawRightString(width - 45, height - 35, chapter_title)

        can.setStrokeColorRGB(0.8, 0.84, 0.88)
        can.setLineWidth(0.5)
        can.line(45, height - 40, width - 45, height - 40)

        # Footer
        can.line(45, 45, width - 45, 45)
        can.drawString(45, 33, "CONFIDENTIAL — STRICTLY FOR INTERNAL / ACADEMIC AUDIT")
        can.drawRightString(width - 45, 33, f"Halaman {i + 1} dari {total_pages}")

        can.save()
        packet.seek(0)
        stamp_reader = PdfReader(packet)
        page.merge_page(stamp_reader.pages[0])

    with open(output_path, "wb") as f:
        writer.write(f)


def setup_docx_document():
    """Initializes a new python-docx Document with standard A4 margins and styles."""
    doc = Document()
    for section in doc.sections:
        section.top_margin = Inches(1.0)
        section.bottom_margin = Inches(1.0)
        section.left_margin = Inches(1.0)
        section.right_margin = Inches(1.0)
        section.page_width = Inches(8.27)
        section.page_height = Inches(11.69)
    return doc


def add_docx_running_header_footer(doc, chapter_title):
    """Adds running headers and footers to a docx document, with empty first page for cover."""
    for section in doc.sections:
        section.different_first_page_header_footer = True
        header = section.header
        hp = header.paragraphs[0]
        hp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        hrun1 = hp.add_run("OOPSIEEATS — Business Requirements Document  |  ")
        hrun1.font.name = "Arial"
        hrun1.font.size = Pt(8.5)
        hrun1.font.color.rgb = COLOR_GRAY
        hrun2 = hp.add_run(chapter_title)
        hrun2.font.name = "Arial"
        hrun2.font.size = Pt(8.5)
        hrun2.font.bold = True
        hrun2.font.color.rgb = COLOR_NAVY

        footer = section.footer
        fp = footer.paragraphs[0]
        frun = fp.add_run("CONFIDENTIAL — STRICTLY FOR INTERNAL / ACADEMIC AUDIT")
        frun.font.name = "Arial"
        frun.font.size = Pt(8)
        frun.font.color.rgb = COLOR_GRAY


def style_docx_table(table):
    """Styles a python-docx table with Navy header, white text, and light borders."""
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    # Format header row
    header_tr = table.rows[0]._tr.get_or_add_trPr()
    header_tr.append(parse_xml(r'<w:tblHeader %s/>' % nsdecls('w')))
    
    for cell in table.rows[0].cells:
        tcPr = cell._tc.get_or_add_tcPr()
        tcPr.append(parse_xml(r'<w:shd %s w:fill="%s"/>' % (nsdecls('w'), HEX_NAVY)))
        for p in cell.paragraphs:
            for r in p.runs:
                r.font.bold = True
                r.font.color.rgb = COLOR_WHITE
                r.font.size = Pt(9.5)

    # Format data rows
    for r_idx, row in enumerate(table.rows[1:], start=1):
        bg = HEX_BG_LIGHT if r_idx % 2 == 1 else "FFFFFF"
        for cell in row.cells:
            tcPr = cell._tc.get_or_add_tcPr()
            tcPr.append(parse_xml(r'<w:shd %s w:fill="%s"/>' % (nsdecls('w'), bg)))
            for p in cell.paragraphs:
                for r in p.runs:
                    r.font.size = Pt(9)
                    r.font.color.rgb = COLOR_DARK
