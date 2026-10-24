"""
Script to generate all technical diagrams for NutriView Academic Project Implementation Report.
Produces clean, publication-grade diagrams using Matplotlib.
"""

import os
import matplotlib.pyplot as plt
import matplotlib.patches as patches

OUTPUT_DIR = "docs/project-report/diagrams"
os.makedirs(OUTPUT_DIR, exist_ok=True)

plt.rcParams["font.family"] = "sans-serif"
plt.rcParams["font.sans-serif"] = ["DejaVu Sans", "Arial", "Helvetica"]

# -------------------------------------------------------------
# 1. FIG 1: SYSTEM ARCHITECTURE DIAGRAM
# -------------------------------------------------------------
def generate_system_architecture():
    fig, ax = plt.subplots(figsize=(10, 6), dpi=200)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 70)
    ax.axis("off")

    # Title Banner
    ax.text(50, 66, "NutriView — High-Level System Architecture & Deployment Topology", 
            ha="center", va="center", fontsize=13, fontweight="bold", color="#1E293B")

    # Layer 1: Client
    rect_client = patches.FancyBboxPatch((4, 18), 24, 42, boxstyle="round,pad=1.2",
                                         facecolor="#F0FDF4", edgecolor="#16A34A", linewidth=2)
    ax.add_patch(rect_client)
    ax.text(16, 56, "Mobile Client Layer\n(Flutter / Dart)", ha="center", va="center",
            fontsize=10, fontweight="bold", color="#166534")
    
    client_boxes = [
        (16, 47, "Presentation Widgets\n(Screens & UI Components)"),
        (16, 37, "State Management\n(Provider / ChangeNotifier)"),
        (16, 27, "Data / Network Layer\n(ApiClient & Repositories)"),
    ]
    for x, y, text in client_boxes:
        box = patches.FancyBboxPatch((x-10, y-3.5), 20, 7, boxstyle="round,pad=0.5",
                                     facecolor="#FFFFFF", edgecolor="#86EFAC", linewidth=1.2)
        ax.add_patch(box)
        ax.text(x, y, text, ha="center", va="center", fontsize=8, color="#1E293B")

    # Communication Arrow 1
    ax.annotate("", xy=(38, 39), xytext=(28, 39),
                arrowprops=dict(arrowstyle="<->", color="#0284C7", lw=2))
    ax.text(33, 42, "REST API\nHTTPS / JSON\nMultipart", ha="center", va="center",
            fontsize=7.5, fontweight="bold", color="#0284C7")

    # Layer 2: Backend Monolith
    rect_backend = patches.FancyBboxPatch((38, 14), 34, 46, boxstyle="round,pad=1.2",
                                          facecolor="#F8FAFC", edgecolor="#0284C7", linewidth=2)
    ax.add_patch(rect_backend)
    ax.text(55, 56.5, "Backend Service Layer (FastAPI)\nModular Monolith Architecture", ha="center", va="center",
            fontsize=10, fontweight="bold", color="#0369A1")

    backend_modules = [
        (46, 48, "Auth & Security\n(JWT, Argon2)"),
        (64, 48, "Profile Management\n(BMR/TDEE Inputs)"),
        (46, 38, "Food Scanner Service\n(Confidence Filter)"),
        (64, 38, "Nutrition Calculator\n(Deterministic Math)"),
        (46, 28, "Meal Tracking Service\n(Log & History)"),
        (64, 28, "Dashboard Service\n(Daily Aggregation)"),
    ]
    for x, y, text in backend_modules:
        box = patches.FancyBboxPatch((x-8, y-3), 16, 6, boxstyle="round,pad=0.4",
                                     facecolor="#FFFFFF", edgecolor="#BAE6FD", linewidth=1.1)
        ax.add_patch(box)
        ax.text(x, y, text, ha="center", va="center", fontsize=7.5, color="#1E293B")

    # Embedded YOLO Engine within FastAPI
    yolo_box = patches.FancyBboxPatch((41, 16.5), 28, 6.5, boxstyle="round,pad=0.4",
                                     facecolor="#FEF3C7", edgecolor="#F59E0B", linewidth=1.3)
    ax.add_patch(yolo_box)
    ax.text(55, 19.8, "Embedded Computer Vision Model\nYOLO26n Engine (Ultralytics best.pt - 29 Classes)",
            ha="center", va="center", fontsize=7.5, fontweight="bold", color="#92400E")

    # Arrow from Scanner to YOLO
    ax.annotate("", xy=(55, 23.5), xytext=(55, 25),
                arrowprops=dict(arrowstyle="->", color="#D97706", lw=1.5))

    # Communication Arrow 2
    ax.annotate("", xy=(80, 39), xytext=(72, 39),
                arrowprops=dict(arrowstyle="<->", color="#059669", lw=2))
    ax.text(76, 42, "SQLAlchemy\nPyMySQL\nTCP:3306", ha="center", va="center",
            fontsize=7.5, fontweight="bold", color="#059669")

    # Layer 3: Database
    rect_db = patches.FancyBboxPatch((80, 18), 16, 42, boxstyle="round,pad=1.2",
                                     facecolor="#F0FDF4", edgecolor="#059669", linewidth=2)
    ax.add_patch(rect_db)
    ax.text(88, 56, "Database Layer\n(MySQL 8.x)", ha="center", va="center",
            fontsize=10, fontweight="bold", color="#065F46")

    db_tables = ["users", "profiles", "foods", "food_nutrition", "meal_records", "meal_items", "revoked_tokens"]
    for i, tbl in enumerate(db_tables):
        y_pos = 48 - (i * 4.2)
        box = patches.FancyBboxPatch((81.5, y_pos-1.5), 13, 3.2, boxstyle="round,pad=0.3",
                                     facecolor="#FFFFFF", edgecolor="#A7F3D0", linewidth=1)
        ax.add_patch(box)
        ax.text(88, y_pos, tbl, ha="center", va="center", fontsize=7.5, family="monospace", color="#1E293B")

    # Footer note
    ax.text(50, 4, "Sistem memisahkan tanggung jawab: Mobile (UI/State) — Backend (Business Logic & ML) — DB (Persistent Storage).",
            ha="center", va="center", fontsize=8, fontstyle="italic", color="#64748B")

    plt.tight_layout()
    fig.savefig(os.path.join(OUTPUT_DIR, "fig1_system_architecture.png"), bbox_inches="tight")
    plt.close(fig)
    print("Saved fig1_system_architecture.png")

# -------------------------------------------------------------
# 2. FIG 2: USE CASE DIAGRAM
# -------------------------------------------------------------
def generate_use_case_diagram():
    fig, ax = plt.subplots(figsize=(10, 6.5), dpi=200)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 75)
    ax.axis("off")

    ax.text(50, 71, "NutriView — Use Case Diagram", ha="center", va="center",
            fontsize=13, fontweight="bold", color="#1E293B")

    # System Boundary Box
    boundary = patches.Rectangle((30, 6), 65, 61, linewidth=1.5, edgecolor="#94A3B8",
                                 facecolor="#FAFAFA", linestyle="--")
    ax.add_patch(boundary)
    ax.text(32, 65, "Sistem Aplikasi NutriView (Mobile & Backend)", fontsize=9,
            fontweight="bold", color="#475569")

    # Actor: User
    ax.plot([12, 12], [46, 38], color="#1E293B", lw=2)  # spine
    circle = patches.Circle((12, 49), 3, facecolor="#E2E8F0", edgecolor="#1E293B", lw=2)
    ax.add_patch(circle)  # head
    ax.plot([6, 18], [43, 43], color="#1E293B", lw=2)  # arms
    ax.plot([12, 7], [38, 30], color="#1E293B", lw=2)  # left leg
    ax.plot([12, 17], [38, 30], color="#1E293B", lw=2)  # right leg
    ax.text(12, 26, "Pengguna\n(User / Mahasiswa)", ha="center", va="center",
            fontsize=9, fontweight="bold", color="#1E293B")

    # Use Cases (Ellipses)
    use_cases = [
        (58, 60, "UC-01: Registrasi Akun"),
        (58, 53, "UC-02: Otentikasi & Login (JWT)"),
        (58, 46, "UC-03: Isi Profil Antropometri"),
        (58, 39, "UC-04: Hitung Target Gizi Harian"),
        (58, 32, "UC-05: Pindai Makanan (YOLO26n)"),
        (58, 25, "UC-06: Konfirmasi & Koreksi Porsi"),
        (58, 18, "UC-07: Simpan Catatan Makan"),
        (58, 11, "UC-08: Pantau Dashboard Harian"),
    ]

    for x, y, text in use_cases:
        ellipse = patches.Ellipse((x, y), 28, 4.8, facecolor="#FFFFFF",
                                  edgecolor="#2E7D32", linewidth=1.5)
        ax.add_patch(ellipse)
        ax.text(x, y, text, ha="center", va="center", fontsize=8, fontweight="bold", color="#1E293B")
        # Line from actor to use case
        ax.plot([18, x-14], [43, y], color="#94A3B8", lw=1.2, alpha=0.8)

    # Sub-case / include relationship
    ellipse_manual = patches.Ellipse((86, 25), 18, 4.5, facecolor="#F1F5F9",
                                     edgecolor="#64748B", linewidth=1.2, linestyle=":")
    ax.add_patch(ellipse_manual)
    ax.text(86, 25, "Pencarian\nMakanan Manual", ha="center", va="center", fontsize=7, color="#334155")
    
    # Arrow <<extend>>
    ax.annotate("<<extend>>", xy=(72, 25), xytext=(77, 25),
                arrowprops=dict(arrowstyle="->", color="#64748B", lw=1, linestyle=":"),
                fontsize=6.5, ha="center", va="bottom", color="#64748B")

    plt.tight_layout()
    fig.savefig(os.path.join(OUTPUT_DIR, "fig2_use_case_diagram.png"), bbox_inches="tight")
    plt.close(fig)
    print("Saved fig2_use_case_diagram.png")

# -------------------------------------------------------------
# 3. FIG 3: NAVIGATION FLOW
# -------------------------------------------------------------
def generate_navigation_flow():
    fig, ax = plt.subplots(figsize=(10, 6.5), dpi=200)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 75)
    ax.axis("off")

    ax.text(50, 71, "NutriView — Application Navigation Flowchart", ha="center", va="center",
            fontsize=13, fontweight="bold", color="#1E293B")

    # Step 1: Splash / Auth Gate
    box_start = patches.FancyBboxPatch((5, 45), 16, 8, boxstyle="round,pad=0.5",
                                       facecolor="#EFF6FF", edgecolor="#3B82F6", lw=1.5)
    ax.add_patch(box_start)
    ax.text(13, 49, "App Startup\n(Auth Gate)", ha="center", va="center",
            fontsize=8.5, fontweight="bold", color="#1E40AF")

    # Decision: Logged In?
    diamond = patches.Polygon([[30, 49], [36, 54], [42, 49], [36, 44]],
                              facecolor="#FEF3C7", edgecolor="#D97706", lw=1.5)
    ax.add_patch(diamond)
    ax.text(36, 49, "Sudah\nLogin?", ha="center", va="center", fontsize=7.5, fontweight="bold", color="#92400E")

    ax.annotate("", xy=(30, 49), xytext=(21, 49), arrowprops=dict(arrowstyle="->", color="#64748B", lw=1.5))

    # Path: No -> Login / Register
    ax.annotate("Tidak", xy=(36, 35), xytext=(36, 44), arrowprops=dict(arrowstyle="->", color="#DC2626", lw=1.5),
                ha="right", va="center", fontsize=7.5, color="#DC2626", fontweight="bold")
    box_auth = patches.FancyBboxPatch((28, 25), 16, 10, boxstyle="round,pad=0.5",
                                      facecolor="#FEE2E2", edgecolor="#DC2626", lw=1.5)
    ax.add_patch(box_auth)
    ax.text(36, 30, "Layar Login /\nRegistrasi", ha="center", va="center",
            fontsize=8, fontweight="bold", color="#991B1B")

    # Path: Auth success -> Profile check / Dashboard
    ax.annotate("Sukses Login", xy=(55, 30), xytext=(44, 30), arrowprops=dict(arrowstyle="->", color="#16A34A", lw=1.5),
                ha="center", va="bottom", fontsize=7.5, color="#16A34A", fontweight="bold")

    # Path: Yes -> Main Dashboard
    ax.annotate("Ya", xy=(55, 49), xytext=(42, 49), arrowprops=dict(arrowstyle="->", color="#16A34A", lw=1.5),
                ha="center", va="bottom", fontsize=7.5, color="#16A34A", fontweight="bold")

    box_dash = patches.FancyBboxPatch((55, 44), 18, 10, boxstyle="round,pad=0.6",
                                      facecolor="#DCFCE7", edgecolor="#16A34A", lw=2)
    ax.add_patch(box_dash)
    ax.text(64, 49, "Dashboard Utama\n(Progres Kalori & Gizi)", ha="center", va="center",
            fontsize=8.5, fontweight="bold", color="#166534")

    # Connect Auth to Dashboard
    ax.plot([64, 64], [35, 44], color="#16A34A", lw=1.5, linestyle="--")

    # Navigation Tabs from Dashboard
    # 1. Scanner Flow (Top Branch)
    ax.annotate("", xy=(80, 58), xytext=(73, 52), arrowprops=dict(arrowstyle="->", color="#0284C7", lw=1.5))
    box_scan = patches.FancyBboxPatch((80, 53), 17, 9, boxstyle="round,pad=0.4",
                                      facecolor="#E0F2FE", edgecolor="#0284C7", lw=1.5)
    ax.add_patch(box_scan)
    ax.text(88.5, 57.5, "Alur Pindai Makanan\n(Kamera / Galeri → YOLO\n→ Porsi → Hasil)", ha="center", va="center",
            fontsize=7.5, fontweight="bold", color="#075985")

    # 2. Meal History (Middle Branch)
    ax.annotate("", xy=(80, 45), xytext=(73, 48), arrowprops=dict(arrowstyle="->", color="#7C3AED", lw=1.5))
    box_hist = patches.FancyBboxPatch((80, 40), 17, 9, boxstyle="round,pad=0.4",
                                      facecolor="#F3E8FF", edgecolor="#7C3AED", lw=1.5)
    ax.add_patch(box_hist)
    ax.text(88.5, 44.5, "Riwayat Makan\n(Daftar Konsumsi &\nDetail Makanan)", ha="center", va="center",
            fontsize=7.5, fontweight="bold", color="#5B21B6")

    # 3. Profile Screen (Bottom Branch)
    ax.annotate("", xy=(80, 29), xytext=(71, 45), arrowprops=dict(arrowstyle="->", color="#D97706", lw=1.5))
    box_prof = patches.FancyBboxPatch((80, 25), 17, 9, boxstyle="round,pad=0.4",
                                      facecolor="#FEF3C7", edgecolor="#D97706", lw=1.5)
    ax.add_patch(box_prof)
    ax.text(88.5, 29.5, "Profil Pengguna\n(Pengaturan Parameter\nAntropometri & Target)", ha="center", va="center",
            fontsize=7.5, fontweight="bold", color="#92400E")

    # Return loop after saving meal
    ax.plot([97, 98, 98, 64, 64], [57.5, 57.5, 66, 66, 54], color="#0284C7", lw=1.2, linestyle=":")
    ax.text(81, 67.5, "Simpan Makan → Kembali ke Dashboard (Refresh State)", fontsize=7, color="#0284C7", fontstyle="italic")

    plt.tight_layout()
    fig.savefig(os.path.join(OUTPUT_DIR, "fig3_navigation_flow.png"), bbox_inches="tight")
    plt.close(fig)
    print("Saved fig3_navigation_flow.png")

# -------------------------------------------------------------
# 4. FIG 4: UI WIREFRAME MOCKUPS
# -------------------------------------------------------------
def generate_ui_wireframes():
    fig, axes = plt.subplots(1, 4, figsize=(12, 6.5), dpi=200)

    screens = [
        ("1. Layar Login", [
            ("title", "NutriView"),
            ("subtitle", "Masuk ke Akun Anda"),
            ("input", "Email (pengguna@contoh.com)"),
            ("input", "Kata Sandi (••••••••)"),
            ("btn", "Masuk"),
            ("link", "Belum punya akun? Daftar")
        ], "#F8FAFC"),
        ("2. Dashboard Utama", [
            ("header", "Halo, Ahmad Badawi!"),
            ("ring", "Target: 2.100 kcal\nTerpenuhi: 1.450 kcal\n(69%)"),
            ("macro", "Karbohidrat: 180 / 260 g"),
            ("macro", "Protein: 75 / 110 g"),
            ("macro", "Lemak: 45 / 60 g"),
            ("section", "Catatan Makan Hari Ini:"),
            ("item", "Sarapan: Nasi Goreng (350 kcal)"),
            ("item", "Makan Siang: Ayam Goreng (480 kcal)")
        ], "#F0FDF4"),
        ("3. Konfirmasi & Porsi", [
            ("header", "Hasil Pindai Foto"),
            ("box", "[ Foto Makanan Terdeteksi ]\nBounding Box: Ayam Goreng (92%)"),
            ("input", "Porsi Konsumsi: 150 gram"),
            ("calc", "Estimasi Gizi:\nKalori: 390 kcal | Protein: 34.5 g\nKarbo: 0 g | Lemak: 27.0 g"),
            ("btn", "Simpan ke Catatan Makan")
        ], "#EFF6FF"),
        ("4. Riwayat Makan", [
            ("header", "Riwayat Konsumsi"),
            ("filter", "Pilih Tanggal: [ 16 Okt 2026 ▾ ]"),
            ("card", "Sarapan (07:30)\nNasi Putih (150g) + Telur Goreng\nTotal: 410 kcal"),
            ("card", "Makan Siang (12:45)\nAyam Goreng (150g) + Tumis Kangkung\nTotal: 465 kcal"),
            ("btn_outline", "Ekspor Ringkasan")
        ], "#FAF5FF")
    ]

    for ax, (screen_title, elements, bg_color) in zip(axes, screens):
        ax.set_xlim(0, 100)
        ax.set_ylim(0, 140)
        ax.axis("off")

        # Phone frame
        phone = patches.FancyBboxPatch((5, 5), 90, 130, boxstyle="round,pad=1.5",
                                       facecolor=bg_color, edgecolor="#334155", lw=2)
        ax.add_patch(phone)

        # Notch / Camera
        ax.plot([40, 60], [132, 132], color="#334155", lw=3)

        # Title
        ax.text(50, 122, screen_title, ha="center", va="center",
                fontsize=8.5, fontweight="bold", color="#0F172A")
        ax.plot([15, 85], [116, 116], color="#CBD5E1", lw=1)

        y_cursor = 108
        for elem_type, elem_val in elements:
            if elem_type == "title":
                ax.text(50, y_cursor, elem_val, ha="center", va="center",
                        fontsize=12, fontweight="bold", color="#166534")
                y_cursor -= 12
            elif elem_type == "subtitle":
                ax.text(50, y_cursor, elem_val, ha="center", va="center",
                        fontsize=7.5, color="#64748B")
                y_cursor -= 14
            elif elem_type == "header":
                ax.text(15, y_cursor, elem_val, ha="left", va="center",
                        fontsize=8, fontweight="bold", color="#1E293B")
                y_cursor -= 10
            elif elem_type == "input":
                ibox = patches.FancyBboxPatch((15, y_cursor-4), 70, 8, boxstyle="round,pad=0.3",
                                             facecolor="#FFFFFF", edgecolor="#94A3B8", lw=1)
                ax.add_patch(ibox)
                ax.text(20, y_cursor, elem_val, ha="left", va="center", fontsize=6.5, color="#64748B")
                y_cursor -= 14
            elif elem_type == "btn":
                bbox = patches.FancyBboxPatch((15, y_cursor-4), 70, 9, boxstyle="round,pad=0.4",
                                              facecolor="#2E7D32", edgecolor="#1B5E20", lw=1)
                ax.add_patch(bbox)
                ax.text(50, y_cursor, elem_val, ha="center", va="center",
                        fontsize=7.5, fontweight="bold", color="#FFFFFF")
                y_cursor -= 15
            elif elem_type == "btn_outline":
                bbox = patches.FancyBboxPatch((15, y_cursor-4), 70, 8, boxstyle="round,pad=0.4",
                                              facecolor="#FFFFFF", edgecolor="#2E7D32", lw=1)
                ax.add_patch(bbox)
                ax.text(50, y_cursor, elem_val, ha="center", va="center",
                        fontsize=7, fontweight="bold", color="#2E7D32")
                y_cursor -= 14
            elif elem_type == "link":
                ax.text(50, y_cursor, elem_val, ha="center", va="center",
                        fontsize=7, color="#2563EB")
                y_cursor -= 10
            elif elem_type == "ring":
                rbox = patches.FancyBboxPatch((15, y_cursor-10), 70, 20, boxstyle="round,pad=0.5",
                                              facecolor="#FFFFFF", edgecolor="#86EFAC", lw=1.2)
                ax.add_patch(rbox)
                ax.text(50, y_cursor, elem_val, ha="center", va="center",
                        fontsize=7.5, fontweight="bold", color="#15803D")
                y_cursor -= 24
            elif elem_type == "macro":
                mbox = patches.FancyBboxPatch((15, y_cursor-3), 70, 6, boxstyle="round,pad=0.3",
                                              facecolor="#FFFFFF", edgecolor="#E2E8F0", lw=1)
                ax.add_patch(mbox)
                ax.text(20, y_cursor, elem_val, ha="left", va="center", fontsize=6.5, color="#334155")
                y_cursor -= 8
            elif elem_type == "section":
                ax.text(15, y_cursor, elem_val, ha="left", va="center",
                        fontsize=7.5, fontweight="bold", color="#334155")
                y_cursor -= 8
            elif elem_type == "item" or elem_type == "card":
                cbox = patches.FancyBboxPatch((15, y_cursor-7), 70, 13, boxstyle="round,pad=0.4",
                                              facecolor="#FFFFFF", edgecolor="#CBD5E1", lw=1)
                ax.add_patch(cbox)
                ax.text(20, y_cursor, elem_val, ha="left", va="center", fontsize=6.5, color="#1E293B")
                y_cursor -= 16
            elif elem_type == "box":
                bbox = patches.FancyBboxPatch((15, y_cursor-12), 70, 22, boxstyle="round,pad=0.4",
                                              facecolor="#F1F5F9", edgecolor="#64748B", lw=1, linestyle="--")
                ax.add_patch(bbox)
                ax.text(50, y_cursor-2, elem_val, ha="center", va="center", fontsize=7, color="#475569")
                y_cursor -= 26
            elif elem_type == "calc":
                cbox = patches.FancyBboxPatch((15, y_cursor-10), 70, 18, boxstyle="round,pad=0.4",
                                              facecolor="#EFF6FF", edgecolor="#93C5FD", lw=1)
                ax.add_patch(cbox)
                ax.text(50, y_cursor-1, elem_val, ha="center", va="center", fontsize=7, color="#1E40AF")
                y_cursor -= 22
            elif elem_type == "filter":
                ax.text(15, y_cursor, elem_val, ha="left", va="center", fontsize=7, color="#2563EB")
                y_cursor -= 10

        # Bottom nav bar placeholder
        ax.plot([10, 90], [18, 18], color="#CBD5E1", lw=1)
        ax.text(25, 11, "Home", ha="center", va="center", fontsize=6.5, color="#64748B")
        ax.text(50, 11, "Scan", ha="center", va="center", fontsize=6.5, color="#166534", fontweight="bold")
        ax.text(75, 11, "Profil", ha="center", va="center", fontsize=6.5, color="#64748B")

    plt.tight_layout()
    fig.savefig(os.path.join(OUTPUT_DIR, "fig4_ui_wireframes.png"), bbox_inches="tight")
    plt.close(fig)
    print("Saved fig4_ui_wireframes.png")

# -------------------------------------------------------------
# 5. FIG 5: DATABASE ERD
# -------------------------------------------------------------
def generate_database_erd():
    fig, ax = plt.subplots(figsize=(11, 7), dpi=200)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 80)
    ax.axis("off")

    ax.text(50, 77, "NutriView — Database Entity Relationship Diagram (ERD)", ha="center", va="center",
            fontsize=13, fontweight="bold", color="#1E293B")

    # Table specifications
    tables = [
        # (name, x, y, w, h, [columns])
        ("users", 8, 48, 24, 22, [
            "id: BigInteger [PK]",
            "email: String(255) [UQ]",
            "password_hash: String(255)",
            "full_name: String(100)",
            "created_at: DateTime",
            "updated_at: DateTime"
        ], "#DCFCE7", "#16A34A"),
        
        ("profiles", 8, 14, 24, 28, [
            "id: BigInteger [PK]",
            "user_id: BigInteger [FK, UQ]",
            "age: SmallInteger (15-100)",
            "sex: Enum(male, female)",
            "weight_kg: Numeric(5,2)",
            "height_cm: Numeric(5,2)",
            "activity_level: Enum(5)",
            "goal: Enum(3)",
            "created_at: DateTime",
            "updated_at: DateTime"
        ], "#FEF3C7", "#D97706"),

        ("foods", 40, 48, 22, 20, [
            "id: Integer [PK]",
            "name: String(100) [UQ]",
            "yolo_class: String(100) [UQ]",
            "is_active: Boolean",
            "created_at: DateTime"
        ], "#E0F2FE", "#0284C7"),

        ("food_nutrition", 40, 16, 22, 24, [
            "food_id: Integer [PK, FK]",
            "calories_kcal: Numeric(7,2)",
            "protein_g: Numeric(7,2)",
            "carbs_g: Numeric(7,2)",
            "fat_g: Numeric(7,2)",
            "source: String(255)",
            "updated_at: DateTime"
        ], "#E0F2FE", "#0284C7"),

        ("meal_records", 70, 46, 24, 25, [
            "id: BigInteger [PK]",
            "user_id: BigInteger [FK]",
            "meal_type: Enum(4)",
            "consumed_at: DateTime",
            "consumed_date: Date",
            "total_calories_kcal: Num",
            "total_protein_g: Num",
            "total_carbs_g: Num",
            "total_fat_g: Num"
        ], "#F3E8FF", "#7C3AED"),

        ("meal_items", 70, 12, 24, 28, [
            "id: BigInteger [PK]",
            "meal_id: BigInteger [FK]",
            "food_id: Integer [FK]",
            "portion_grams: Num(7,2)",
            "calories_kcal: Num(8,2)",
            "protein_g: Num(8,2)",
            "carbs_g: Num(8,2)",
            "fat_g: Num(8,2)",
            "source: Enum(3)",
            "detection_confidence: Num"
        ], "#F3E8FF", "#7C3AED"),

        ("revoked_tokens", 40, 4, 22, 9, [
            "jti: String(36) [PK]",
            "expires_at: DateTime"
        ], "#F1F5F9", "#64748B")
    ]

    for name, x, y, w, h, cols, bg, border in tables:
        # Header Box
        hdr = patches.Rectangle((x, y + h - 5), w, 5, facecolor=border, edgecolor=border)
        ax.add_patch(hdr)
        ax.text(x + w/2, y + h - 2.5, name, ha="center", va="center",
                fontsize=8.5, fontweight="bold", color="#FFFFFF")
        # Body Box
        body = patches.Rectangle((x, y), w, h - 5, facecolor=bg, edgecolor=border, lw=1.2)
        ax.add_patch(body)
        
        # Column text
        for i, col in enumerate(cols):
            cy = y + h - 7.5 - (i * 2.1)
            ax.text(x + 1, cy, col, ha="left", va="center", fontsize=6.8,
                    family="monospace", color="#1E293B")

    # Relationships (Lines & Arrows)
    # 1. users -> profiles (1 : 1)
    ax.annotate("1 : 1", xy=(20, 42), xytext=(20, 48),
                arrowprops=dict(arrowstyle="->", color="#16A34A", lw=1.5),
                fontsize=7.5, fontweight="bold", color="#16A34A", ha="right")

    # 2. users -> meal_records (1 : N)
    ax.plot([32, 51, 51, 70], [59, 59, 63, 63], color="#16A34A", lw=1.5)
    ax.annotate("1 : N", xy=(70, 63), xytext=(55, 64),
                arrowprops=dict(arrowstyle="->", color="#16A34A", lw=1.5),
                fontsize=7.5, fontweight="bold", color="#16A34A")

    # 3. foods -> food_nutrition (1 : 1)
    ax.annotate("1 : 1", xy=(51, 40), xytext=(51, 48),
                arrowprops=dict(arrowstyle="->", color="#0284C7", lw=1.5),
                fontsize=7.5, fontweight="bold", color="#0284C7", ha="right")

    # 4. meal_records -> meal_items (1 : N)
    ax.annotate("1 : N", xy=(82, 40), xytext=(82, 46),
                arrowprops=dict(arrowstyle="->", color="#7C3AED", lw=1.5),
                fontsize=7.5, fontweight="bold", color="#7C3AED", ha="right")

    # 5. foods -> meal_items (1 : N)
    ax.plot([62, 66, 66, 70], [52, 52, 28, 28], color="#0284C7", lw=1.5)
    ax.annotate("1 : N", xy=(70, 28), xytext=(63, 30),
                arrowprops=dict(arrowstyle="->", color="#0284C7", lw=1.5),
                fontsize=7.5, fontweight="bold", color="#0284C7")

    plt.tight_layout()
    fig.savefig(os.path.join(OUTPUT_DIR, "fig5_database_erd.png"), bbox_inches="tight")
    plt.close(fig)
    print("Saved fig5_database_erd.png")

# -------------------------------------------------------------
# 6. FIG 6: SEQUENCE DIAGRAM (SCAN & LOG MEAL)
# -------------------------------------------------------------
def generate_scan_sequence():
    fig, ax = plt.subplots(figsize=(10.5, 6.5), dpi=200)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 80)
    ax.axis("off")

    ax.text(50, 77, "NutriView — Food Detection & Meal Logging Sequence Diagram",
            ha="center", va="center", fontsize=12, fontweight="bold", color="#1E293B")

    lifelines = [
        ("Mobile Client\n(Flutter UI/Provider)", 14),
        ("FastAPI Backend\n(Food Router)", 38),
        ("YOLO26n Detector\n(Ultralytics Engine)", 62),
        ("MySQL Database\n(Tables & Engine)", 86)
    ]

    for title, x in lifelines:
        box = patches.FancyBboxPatch((x-10, 68), 20, 6, boxstyle="round,pad=0.4",
                                     facecolor="#E2E8F0", edgecolor="#475569", lw=1.2)
        ax.add_patch(box)
        ax.text(x, 71, title, ha="center", va="center", fontsize=7.5, fontweight="bold", color="#1E293B")
        ax.plot([x, x], [8, 68], color="#94A3B8", lw=1, linestyle="--")

    steps = [
        # (from_x, to_x, y, text, is_return, color)
        (14, 38, 62, "1. POST /foods/detect (multipart image)", False, "#0284C7"),
        (38, 62, 57, "2. validate & detect(image)", False, "#D97706"),
        (62, 38, 52, "3. raw detections (class_name, conf, bbox)", True, "#D97706"),
        (38, 86, 47, "4. query food by yolo_class & nutrition", False, "#059669"),
        (86, 38, 42, "5. return food entity & nutrient data", True, "#059669"),
        (38, 14, 37, "6. DetectFoodResponse (mapped items & nutrients)", True, "#0284C7"),
        (14, 14, 32, "7. User reviews detection, adjusts gram portion", False, "#16A34A"),
        (14, 38, 26, "8. POST /meals (meal_type, food_id, portion_g)", False, "#0284C7"),
        (38, 38, 21, "9. nutrition_service calculates scaled nutrients", False, "#7C3AED"),
        (38, 86, 16, "10. INSERT meal_records & meal_items", False, "#059669"),
        (86, 38, 12, "11. commit transaction & return record id", True, "#059669"),
        (38, 14, 8, "12. MealRecordResponse 201 Created", True, "#16A34A")
    ]

    for from_x, to_x, y, text, is_ret, col in steps:
        if from_x == to_x:
            # Self call
            ax.plot([from_x, from_x+5, from_x+5, from_x], [y+1, y+1, y-1.5, y-1.5], color=col, lw=1.2)
            ax.annotate("", xy=(from_x, y-1.5), xytext=(from_x+2, y-1.5),
                        arrowprops=dict(arrowstyle="->", color=col, lw=1.2))
            ax.text(from_x+6, y, text, ha="left", va="center", fontsize=6.8, fontweight="bold", color=col)
        else:
            style = "<--" if is_ret else "-->"
            ls = ":" if is_ret else "-"
            ax.annotate("", xy=(to_x, y), xytext=(from_x, y),
                        arrowprops=dict(arrowstyle="->", color=col, lw=1.3, linestyle=ls))
            mid_x = (from_x + to_x) / 2
            ax.text(mid_x, y + 1.8, text, ha="center", va="bottom", fontsize=6.8,
                    fontweight="bold", color=col)

    plt.tight_layout()
    fig.savefig(os.path.join(OUTPUT_DIR, "fig6_scan_sequence_diagram.png"), bbox_inches="tight")
    plt.close(fig)
    print("Saved fig6_scan_sequence_diagram.png")

# -------------------------------------------------------------
# 7. FIG 7: NUTRITION CALCULATION PIPELINE
# -------------------------------------------------------------
def generate_nutrition_calc_pipeline():
    fig, ax = plt.subplots(figsize=(10.5, 6), dpi=200)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 70)
    ax.axis("off")

    ax.text(50, 66, "NutriView — Deterministic Nutrition & Calorie Calculation Pipeline",
            ha="center", va="center", fontsize=12, fontweight="bold", color="#1E293B")

    # Step 1: Input anthropometry
    b1 = patches.FancyBboxPatch((4, 38), 16, 18, boxstyle="round,pad=0.5",
                                facecolor="#F8FAFC", edgecolor="#64748B", lw=1.2)
    ax.add_patch(b1)
    ax.text(12, 52, "Input Profil", ha="center", va="center", fontsize=8.5, fontweight="bold", color="#0F172A")
    ax.text(12, 44, "• Usia (tahun)\n• Jenis Kelamin\n• Berat (kg)\n• Tinggi (cm)",
            ha="center", va="center", fontsize=7, color="#334155")

    ax.annotate("", xy=(24, 47), xytext=(20, 47), arrowprops=dict(arrowstyle="->", color="#64748B", lw=1.5))

    # Step 2: BMR Calculation
    b2 = patches.FancyBboxPatch((24, 38), 17, 18, boxstyle="round,pad=0.5",
                                facecolor="#FEF3C7", edgecolor="#D97706", lw=1.3)
    ax.add_patch(b2)
    ax.text(32.5, 52, "1. Hitung BMR", ha="center", va="center", fontsize=8.5, fontweight="bold", color="#92400E")
    ax.text(32.5, 44, "Rumus Mifflin-St Jeor:\nL: 10W + 6.25H - 5A + 5\nP: 10W + 6.25H - 5A - 161",
            ha="center", va="center", fontsize=6.5, color="#78350F")

    ax.annotate("", xy=(45, 47), xytext=(41, 47), arrowprops=dict(arrowstyle="->", color="#64748B", lw=1.5))

    # Step 3: TDEE Calculation
    b3 = patches.FancyBboxPatch((45, 38), 16, 18, boxstyle="round,pad=0.5",
                                facecolor="#E0F2FE", edgecolor="#0284C7", lw=1.3)
    ax.add_patch(b3)
    ax.text(53, 52, "2. Hitung TDEE", ha="center", va="center", fontsize=8.5, fontweight="bold", color="#075985")
    ax.text(53, 44, "TDEE = BMR × Faktor\n• Sedentary: 1.200\n• Light: 1.375\n• Moderate: 1.550\n• Active: 1.725\n• Very Active: 1.900",
            ha="center", va="center", fontsize=6.5, color="#0C4A6E")

    ax.annotate("", xy=(65, 47), xytext=(61, 47), arrowprops=dict(arrowstyle="->", color="#64748B", lw=1.5))

    # Step 4: Goal Delta & Floor
    b4 = patches.FancyBboxPatch((65, 38), 16, 18, boxstyle="round,pad=0.5",
                                facecolor="#FEE2E2", edgecolor="#DC2626", lw=1.3)
    ax.add_patch(b4)
    ax.text(73, 52, "3. Target Kalori", ha="center", va="center", fontsize=8.5, fontweight="bold", color="#991B1B")
    ax.text(73, 44, "TDEE + Goal Delta\n• Turun: -500 kcal\n• Pertahankan: 0\n• Naik: +300 kcal\nBatas: L≥1500, P≥1200",
            ha="center", va="center", fontsize=6.5, color="#7F1D1D")

    ax.annotate("", xy=(85, 47), xytext=(81, 47), arrowprops=dict(arrowstyle="->", color="#64748B", lw=1.5))

    # Step 5: Macronutrient Split
    b5 = patches.FancyBboxPatch((85, 38), 13, 18, boxstyle="round,pad=0.5",
                                facecolor="#DCFCE7", edgecolor="#16A34A", lw=1.3)
    ax.add_patch(b5)
    ax.text(91.5, 52, "4. Makronutrien", ha="center", va="center", fontsize=8.5, fontweight="bold", color="#166534")
    ax.text(91.5, 44, "• Protein: 1.2-1.6g/kg\n• Lemak: 25% kalori\n• Karbo: Sisa kalori",
            ha="center", va="center", fontsize=6.5, color="#14532D")

    # Lower Pipeline: Portion Nutrients
    ax.plot([50, 50], [38, 26], color="#64748B", lw=1.5, linestyle="--")
    ax.annotate("", xy=(50, 26), xytext=(50, 30), arrowprops=dict(arrowstyle="->", color="#64748B", lw=1.5))

    lower_box = patches.FancyBboxPatch((15, 8), 70, 16, boxstyle="round,pad=0.6",
                                       facecolor="#F3E8FF", edgecolor="#7C3AED", lw=1.5)
    ax.add_patch(lower_box)
    ax.text(50, 20, "Perhitungan Nutrisi Porsi Makanan (Deterministic Portion Scaling)",
            ha="center", va="center", fontsize=8.5, fontweight="bold", color="#5B21B6")
    ax.text(50, 13, "Gizi Konsumsi = ( Nilai Nutrisi per 100g × Porsi Gram ) / 100\n"
                    "Diterapkan secara presisi desimal (ROUND_HALF_UP 2 desimal) untuk Kalori, Protein, Karbohidrat, dan Lemak.",
            ha="center", va="center", fontsize=7.5, color="#4C1D95")

    plt.tight_layout()
    fig.savefig(os.path.join(OUTPUT_DIR, "fig7_nutrition_calc_flow.png"), bbox_inches="tight")
    plt.close(fig)
    print("Saved fig7_nutrition_calc_flow.png")


if __name__ == "__main__":
    generate_system_architecture()
    generate_use_case_diagram()
    generate_navigation_flow()
    generate_ui_wireframes()
    generate_database_erd()
    generate_scan_sequence()
    generate_nutrition_calc_pipeline()
    print("All diagrams generated successfully!")
