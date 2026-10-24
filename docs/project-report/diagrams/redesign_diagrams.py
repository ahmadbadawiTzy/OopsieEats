"""
Professional Technical Diagram Redesign for NutriView Project Implementation Report.
Adheres strictly to software engineering documentation standards:
- Professional, restrained palette (Forest Green #166534, Slate #1E293B, Neutral Grays #F8FAFC, #E2E8F0, #CBD5E1)
- Crisp typography, balanced padding, zero text overlaps, zero line crossings
- Clean UML and engineering conventions
- High resolution output (250 DPI)
"""

import os
import matplotlib.pyplot as plt
import matplotlib.patches as patches

# Output directories
OUTPUT_DIRS = [
    "docs/project-report/diagrams",
    "docs/project-report/diagrams/rendered"
]
for d in OUTPUT_DIRS:
    os.makedirs(d, exist_ok=True)

# Global matplotlib style settings
plt.rcParams["font.family"] = "sans-serif"
plt.rcParams["font.sans-serif"] = ["DejaVu Sans", "Arial", "Helvetica"]

def save_fig(fig, filename):
    for d in OUTPUT_DIRS:
        target = os.path.join(d, filename)
        fig.savefig(target, dpi=250, bbox_inches="tight", facecolor="#FFFFFF", edgecolor="none")
    plt.close(fig)
    print(f"Successfully generated and saved: {filename}")

# -----------------------------------------------------------------------------
# 1. FIG 1: HIGH-LEVEL SYSTEM ARCHITECTURE (MODULAR MONOLITH)
# -----------------------------------------------------------------------------
def render_fig1_architecture():
    fig, ax = plt.subplots(figsize=(11.5, 6.2))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 70)
    ax.axis("off")

    # Layer 1: Client Layer (Left: x=2..25, width=23)
    c_box = patches.FancyBboxPatch((2, 6), 23, 58, boxstyle="round,pad=0.6",
                                  facecolor="#F8FAFC", edgecolor="#94A3B8", linewidth=1.4)
    ax.add_patch(c_box)
    
    # Header bar
    c_hdr = patches.Rectangle((2, 58), 23, 6, facecolor="#1E293B", edgecolor="#1E293B")
    ax.add_patch(c_hdr)
    ax.text(13.5, 61, "Mobile Client Layer\n(Flutter SDK 3.13+)", ha="center", va="center",
            fontsize=8.2, fontweight="bold", color="#FFFFFF")

    # Client Subcomponents
    c_components = [
        (13.5, 50, "Presentation Widgets\nMaterial 3 UI, Screens & Views"),
        (13.5, 38, "State Management\nProvider & ChangeNotifier"),
        (13.5, 26, "Network / Service Layer\nApiClient & Http Interceptor"),
        (13.5, 14, "Secure Storage\nflutter_secure_storage (JWT)")
    ]
    for cx, cy, ctext in c_components:
        box = patches.FancyBboxPatch((cx-9.5, cy-4), 19, 8, boxstyle="round,pad=0.3",
                                     facecolor="#FFFFFF", edgecolor="#CBD5E1", linewidth=1.1)
        ax.add_patch(box)
        ax.text(cx, cy, ctext, ha="center", va="center", fontsize=7.2, color="#1E293B")

    # Connector 1: Client <---> Backend (x=25..35, width=10)
    ax.annotate("", xy=(35, 38), xytext=(25, 38),
                arrowprops=dict(arrowstyle="<->", color="#0284C7", lw=1.8), zorder=3)
    # Label badge with ample padding
    lbl1 = patches.FancyBboxPatch((26.2, 40.5), 7.6, 7, boxstyle="round,pad=0.3",
                                  facecolor="#F0F9FF", edgecolor="#BAE6FD", lw=1, zorder=5)
    ax.add_patch(lbl1)
    ax.text(30, 44, "REST API\nHTTPS / JSON\nMultipart", ha="center", va="center",
            fontsize=6.5, fontweight="bold", color="#0369A1", zorder=6)

    # Layer 2: Backend Modular Monolith (Middle: x=35..71, width=36)
    b_box = patches.FancyBboxPatch((35, 6), 36, 58, boxstyle="round,pad=0.6",
                                  facecolor="#F8FAFC", edgecolor="#166534", linewidth=1.4)
    ax.add_patch(b_box)
    
    # Backend Header
    b_hdr = patches.Rectangle((35, 58), 36, 6, facecolor="#166534", edgecolor="#166534")
    ax.add_patch(b_hdr)
    ax.text(53.0, 61, "Backend Application Layer (FastAPI)\nModular Monolith Process", ha="center", va="center",
            fontsize=8.2, fontweight="bold", color="#FFFFFF")

    # Gateway bar (Clean 2 lines, no overflow)
    gw = patches.FancyBboxPatch((36.5, 49.5), 33, 6.5, boxstyle="round,pad=0.3",
                                facecolor="#FFFFFF", edgecolor="#86EFAC", linewidth=1)
    ax.add_patch(gw)
    ax.text(53.0, 53.8, "API Gateway & Route Handlers (/api/v1/*)",
            ha="center", va="center", fontsize=7.0, fontweight="bold", color="#166534")
    ax.text(53.0, 51.2, "JWT Authentication & Exception Interceptors",
            ha="center", va="center", fontsize=6.3, color="#15803D")

    # Business Modules (4 boxes in 2x2 grid)
    mod_grid = [
        (44.2, 41.5, "Auth & Profile Service\n(Argon2id, Session, BMR)"),
        (61.8, 41.5, "Nutrition Calculator\n(Deterministic Mifflin-St Jeor)"),
        (44.2, 30.5, "Food Scanner Service\n(Confidence & Class Mapping)"),
        (61.8, 30.5, "Meal Tracking & Dashboard\n(Daily Logs & Aggregations)")
    ]
    for mx, my, mtext in mod_grid:
        box = patches.FancyBboxPatch((mx-7.3, my-4), 14.6, 8, boxstyle="round,pad=0.3",
                                     facecolor="#FFFFFF", edgecolor="#CBD5E1", linewidth=1.1)
        ax.add_patch(box)
        ax.text(mx, my, mtext, ha="center", va="center", fontsize=6.6, color="#1E293B")

    # Embedded ML Engine Subsystem
    ml_container = patches.FancyBboxPatch((36.5, 9.5), 33, 15, boxstyle="round,pad=0.4",
                                          facecolor="#FFFBEB", edgecolor="#F59E0B", linewidth=1.3)
    ax.add_patch(ml_container)
    ax.text(53.0, 21.5, "Embedded Computer Vision Subsystem", ha="center", va="center",
            fontsize=7.3, fontweight="bold", color="#B45309")
    
    ml_sub = patches.FancyBboxPatch((38.0, 11), 30, 8, boxstyle="round,pad=0.3",
                                    facecolor="#FFFFFF", edgecolor="#FCD34D", linewidth=1)
    ax.add_patch(ml_sub)
    ax.text(53.0, 15, "YOLOInferenceService (Ultralytics)\nModel: YOLO26n (best.pt - 29 Kelas Makanan)",
            ha="center", va="center", fontsize=6.7, color="#92400E")

    # Internal arrow Scanner -> ML
    ax.annotate("", xy=(44.2, 24.5), xytext=(44.2, 26.5),
                arrowprops=dict(arrowstyle="->", color="#B45309", lw=1.3))
    ax.text(48.5, 25.5, "in-process call", fontsize=6.2, fontstyle="italic", color="#B45309")

    # Connector 2: Backend <---> Database (x=71..83, width=12)
    ax.annotate("", xy=(83, 38), xytext=(71, 38),
                arrowprops=dict(arrowstyle="<->", color="#166534", lw=1.8), zorder=3)
    # Label badge with 2.2 units clearance on both sides
    lbl2 = patches.FancyBboxPatch((73.2, 40.5), 7.6, 7, boxstyle="round,pad=0.3",
                                  facecolor="#F0FDF4", edgecolor="#BBF7D0", lw=1, zorder=5)
    ax.add_patch(lbl2)
    ax.text(77.0, 44, "SQLAlchemy 2.0\nPyMySQL\nTCP:3306", ha="center", va="center",
            fontsize=6.3, fontweight="bold", color="#166534", zorder=6)

    # Layer 3: Database (Right: x=83..98, width=15)
    d_box = patches.FancyBboxPatch((83, 6), 15, 58, boxstyle="round,pad=0.6",
                                  facecolor="#F8FAFC", edgecolor="#475569", linewidth=1.4)
    ax.add_patch(d_box)
    
    # DB Header
    d_hdr = patches.Rectangle((83, 58), 15, 6, facecolor="#334155", edgecolor="#334155")
    ax.add_patch(d_hdr)
    ax.text(90.5, 61, "Database Layer\n(MySQL 8.x InnoDB)", ha="center", va="center",
            fontsize=7.8, fontweight="bold", color="#FFFFFF")

    # Tables Grouped Logically
    db_groups = [
        (90.5, 50, "User & Auth\n• users\n• profiles\n• revoked_tokens"),
        (90.5, 33, "Food Master\n• foods\n• food_nutrition"),
        (90.5, 16, "Meal Tracking\n• meal_records\n• meal_items")
    ]
    for dx, dy, dtext in db_groups:
        box = patches.FancyBboxPatch((dx-6.2, dy-6), 12.4, 12, boxstyle="round,pad=0.3",
                                     facecolor="#FFFFFF", edgecolor="#CBD5E1", linewidth=1.1)
        ax.add_patch(box)
        ax.text(dx, dy, dtext, ha="center", va="center", fontsize=6.5, color="#1E293B")

    save_fig(fig, "fig1_system_architecture.png")

# -----------------------------------------------------------------------------
# 2. FIG 2: UML USE CASE DIAGRAM
# -----------------------------------------------------------------------------
def render_fig2_use_case():
    fig, ax = plt.subplots(figsize=(11, 7.0))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 75)
    ax.axis("off")

    # System boundary box
    sys_rect = patches.FancyBboxPatch((27, 4), 70, 67, boxstyle="round,pad=0.5",
                                      facecolor="#FCFDFD", edgecolor="#94A3B8", linewidth=1.4, linestyle="--")
    ax.add_patch(sys_rect)
    ax.text(62.0, 68, "Batasan Sistem: NutriView (Mobile App & Backend Service)",
            ha="center", va="center", fontsize=8.5, fontweight="bold", color="#475569")

    # UML Actor Icon (Clean line art)
    act_x = 9
    act_y = 36
    # Head
    head = patches.Circle((act_x, act_y + 9), 2.8, facecolor="#FFFFFF", edgecolor="#1E293B", lw=1.8)
    ax.add_patch(head)
    # Body
    ax.plot([act_x, act_x], [act_y + 6.2, act_y - 2], color="#1E293B", lw=1.8)
    # Arms
    ax.plot([act_x - 4.5, act_x + 4.5], [act_y + 3.5, act_y + 3.5], color="#1E293B", lw=1.8)
    # Legs
    ax.plot([act_x, act_x - 3.8], [act_y - 2, act_y - 9], color="#1E293B", lw=1.8)
    ax.plot([act_x, act_x + 3.8], [act_y - 2, act_y - 9], color="#1E293B", lw=1.8)
    # Actor Label
    ax.text(act_x, act_y - 12.5, "Pengguna\n(Authenticated User)", ha="center", va="center",
            fontsize=8.0, fontweight="bold", color="#0F172A")

    # Clean Actor Association Bus
    bus_x = 20
    ax.plot([act_x + 4.5, bus_x], [act_y + 3.5, act_y + 3.5], color="#64748B", lw=1.3)
    ax.plot([bus_x, bus_x], [10, 60], color="#64748B", lw=1.3)

    # Primary Use Cases (Vertical Column 1: center x=43, rx=14.5, width=29)
    primary_ucs = [
        (43, 60, "UC-01: Registrasi Akun Pengguna"),
        (43, 50, "UC-02: Otentikasi & Login (JWT)"),
        (43, 40, "UC-03: Kelola Profil Fisik & Target"),
        (43, 30, "UC-04: Pindai Makanan (Kamera/Galeri)"),
        (43, 20, "UC-05: Catat Riwayat Makanan (Log)"),
        (43, 10, "UC-06: Lihat Dashboard & Riwayat")
    ]

    for ux, uy, utext in primary_ucs:
        uc_el = patches.Ellipse((ux, uy), 29, 6.4, facecolor="#F0FDF4",
                                edgecolor="#166534", linewidth=1.3)
        ax.add_patch(uc_el)
        ax.text(ux, uy, utext, ha="center", va="center", fontsize=6.8, fontweight="bold", color="#14532D")
        
        # Connect from Association Bus horizontally to Primary UC edge
        ax.plot([bus_x, ux - 14.5], [uy, uy], color="#64748B", lw=1.3)

    # Secondary / Dependent Use Cases (Column 2: center x=83, rx=13, width=26)
    sub_ucs = [
        (83, 40, "UC-07: Kalkulasi Kebutuhan Gizi\n(Mifflin-St Jeor Deterministik)"),
        (83, 30, "UC-08: Koreksi / Cari Manual\n(Katalog Nutrisi Makanan)"),
        (83, 20, "UC-09: Konfirmasi Deteksi &\nPenyesuaian Porsi (Gram)")
    ]

    for sx, sy, stext in sub_ucs:
        sub_el = patches.Ellipse((sx, sy), 26, 6.8, facecolor="#F8FAFC",
                                 edgecolor="#64748B", linewidth=1.2, linestyle="-")
        ax.add_patch(sub_el)
        ax.text(sx, sy, stext, ha="center", va="center", fontsize=6.7, color="#1E293B")

    # UML Relationship 1: UC-03 --<<include>>--> UC-07 (gap: 57.5..70, length=12.5)
    ax.annotate("", xy=(70, 40), xytext=(57.5, 40),
                arrowprops=dict(arrowstyle="->", color="#166534", lw=1.3, linestyle="--"))
    ax.text(63.75, 41.8, "<<include>>", ha="center", va="bottom", fontsize=6.5, color="#166534", fontstyle="italic",
            bbox=dict(boxstyle="square,pad=0.15", facecolor="#FCFDFD", edgecolor="none"))

    # UML Relationship 2: UC-04 <--<<extend>>-- UC-08 (gap: 57.5..70, length=12.5)
    ax.annotate("", xy=(57.5, 30), xytext=(70, 30),
                arrowprops=dict(arrowstyle="->", color="#0284C7", lw=1.3, linestyle="--"))
    ax.text(63.75, 31.8, "<<extend>>", ha="center", va="bottom", fontsize=6.5, color="#0284C7", fontstyle="italic",
            bbox=dict(boxstyle="square,pad=0.15", facecolor="#FCFDFD", edgecolor="none"))

    # UML Relationship 3: UC-05 --<<include>>--> UC-09 (gap: 57.5..70, length=12.5)
    ax.annotate("", xy=(70, 20), xytext=(57.5, 20),
                arrowprops=dict(arrowstyle="->", color="#166534", lw=1.3, linestyle="--"))
    ax.text(63.75, 21.8, "<<include>>", ha="center", va="bottom", fontsize=6.5, color="#166534", fontstyle="italic",
            bbox=dict(boxstyle="square,pad=0.15", facecolor="#FCFDFD", edgecolor="none"))

    save_fig(fig, "fig2_use_case_diagram.png")

# -----------------------------------------------------------------------------
# 3. FIG 3: APPLICATION NAVIGATION FLOWCHART (ORTHOGONAL & BALANCED)
# -----------------------------------------------------------------------------
def render_fig3_navigation():
    fig, ax = plt.subplots(figsize=(10.8, 6.2))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 65)
    ax.axis("off")

    # Initial State (Solid dark circle)
    init_node = patches.Circle((5, 42), 2.0, facecolor="#1E293B", edgecolor="#1E293B")
    ax.add_patch(init_node)
    ax.text(5, 46.5, "Start (App Launch)", ha="center", va="center", fontsize=7.2, fontweight="bold", color="#1E293B")

    # Arrow to Auth Gate
    ax.annotate("", xy=(13, 42), xytext=(7.2, 42),
                arrowprops=dict(arrowstyle="->", color="#64748B", lw=1.4))

    # Activity: Auth Gate Check
    ag_box = patches.FancyBboxPatch((13, 37.5), 16, 9, boxstyle="round,pad=0.4",
                                    facecolor="#F8FAFC", edgecolor="#64748B", lw=1.2)
    ax.add_patch(ag_box)
    ax.text(21, 42, "Auth Gate\nPeriksa Token JWT\ndi Secure Storage", ha="center", va="center",
            fontsize=7.0, color="#1E293B")

    # Arrow to Decision
    ax.annotate("", xy=(34, 42), xytext=(29, 42),
                arrowprops=dict(arrowstyle="->", color="#64748B", lw=1.4))

    # Decision Diamond: Sesi Valid?
    d1 = patches.Polygon([[38, 42], [42.5, 46.5], [47, 42], [42.5, 37.5]],
                         facecolor="#FEF3C7", edgecolor="#D97706", lw=1.3)
    ax.add_patch(d1)
    ax.text(42.5, 42, "Token\nValid?", ha="center", va="center", fontsize=6.8, fontweight="bold", color="#92400E")

    # Branch: [Tidak] -> Login Screen (downwards)
    ax.annotate("", xy=(42.5, 25), xytext=(42.5, 37.5),
                arrowprops=dict(arrowstyle="->", color="#DC2626", lw=1.4))
    ax.text(44.2, 31, "[Tidak]", fontsize=6.5, color="#DC2626", fontweight="bold")

    login_box = patches.FancyBboxPatch((34, 16), 17, 9, boxstyle="round,pad=0.4",
                                       facecolor="#FEF2F2", edgecolor="#EF4444", lw=1.2)
    ax.add_patch(login_box)
    ax.text(42.5, 20.5, "Layar Login &\nRegistrasi Akun", ha="center", va="center",
            fontsize=7.2, color="#991B1B")

    # Login Success -> Route to Dashboard (right & up)
    ax.plot([51, 58, 58], [20.5, 20.5, 37.5], color="#166534", lw=1.3)
    ax.annotate("", xy=(58, 37.5), xytext=(58, 34),
                arrowprops=dict(arrowstyle="->", color="#166534", lw=1.3))
    ax.text(54.5, 22.5, "[Sukses Login]", ha="center", va="bottom", fontsize=6.2, color="#166534", fontweight="bold")

    # Branch: [Ya] -> Dashboard (straight right)
    ax.annotate("", xy=(52, 42), xytext=(47, 42),
                arrowprops=dict(arrowstyle="->", color="#166534", lw=1.4))
    ax.text(49.5, 44.5, "[Ya]", ha="center", va="bottom", fontsize=6.5, color="#166534", fontweight="bold")

    dash_box = patches.FancyBboxPatch((52, 37.5), 16, 9, boxstyle="round,pad=0.5",
                                      facecolor="#DCFCE7", edgecolor="#166534", lw=1.5)
    ax.add_patch(dash_box)
    ax.text(60, 42, "Dashboard Utama\n(Ring Kalori & Progres)", ha="center", va="center",
            fontsize=7.5, fontweight="bold", color="#14532D")

    # Professional Orthogonal Navigation Hub (Spine at x=71)
    ax.plot([68, 71], [42, 42], color="#475569", lw=1.3)
    ax.plot([71, 71], [16.5, 51], color="#475569", lw=1.3)

    # Branch 1: Scanner Flow (Top-Right: y=45..57)
    ax.annotate("", xy=(74, 51), xytext=(71, 51),
                arrowprops=dict(arrowstyle="->", color="#0284C7", lw=1.3))
    scan_box = patches.FancyBboxPatch((74, 45), 22, 12, boxstyle="round,pad=0.4",
                                      facecolor="#EFF6FF", edgecolor="#0284C7", lw=1.2)
    ax.add_patch(scan_box)
    ax.text(85, 51, "Alur Pindai Makanan\n• Kamera / Galeri -> YOLO26n\n• Konfirmasi & Skalasi Porsi\n• POST /meals (Simpan)",
            ha="center", va="center", fontsize=6.5, color="#0C4A6E")

    # Return arrow from Scanner to Dashboard (Refresh) - Over the top, 0 crossings!
    ax.plot([85, 85, 60, 60], [57, 61.5, 61.5, 46.5], color="#0284C7", lw=1.2, linestyle=":")
    ax.annotate("", xy=(60, 46.5), xytext=(60, 48.5),
                arrowprops=dict(arrowstyle="->", color="#0284C7", lw=1.2))
    tag_ref = patches.FancyBboxPatch((66, 60.2), 14, 2.6, boxstyle="round,pad=0.2",
                                    facecolor="#FFFFFF", edgecolor="#BAE6FD", lw=0.8, zorder=5)
    ax.add_patch(tag_ref)
    ax.text(73, 61.5, "Simpan & Refresh", ha="center", va="center", fontsize=6.0, fontweight="bold", color="#0284C7", zorder=6)

    # Branch 2: Meal History (Middle-Right: y=28..39)
    ax.annotate("", xy=(74, 33.5), xytext=(71, 33.5),
                arrowprops=dict(arrowstyle="->", color="#7C3AED", lw=1.3))
    hist_box = patches.FancyBboxPatch((74, 28), 22, 11, boxstyle="round,pad=0.4",
                                      facecolor="#F5F3FF", edgecolor="#7C3AED", lw=1.2)
    ax.add_patch(hist_box)
    ax.text(85, 33.5, "Riwayat Makan\n• Filter Kalender Konsumsi\n• Rincian Makro & Item Makan",
            ha="center", va="center", fontsize=6.5, color="#5B21B6")

    # Branch 3: Profile Settings (Bottom-Right: y=11..22)
    ax.annotate("", xy=(74, 16.5), xytext=(71, 16.5),
                arrowprops=dict(arrowstyle="->", color="#D97706", lw=1.3))
    prof_box = patches.FancyBboxPatch((74, 11), 22, 11, boxstyle="round,pad=0.4",
                                      facecolor="#FFFBEB", edgecolor="#D97706", lw=1.2)
    ax.add_patch(prof_box)
    ax.text(85, 16.5, "Profil Antropometri\n• Edit BB/TB/Aktivitas (Gizi)\n• Sesi Logout & Cabut Token",
            ha="center", va="center", fontsize=6.5, color="#78350F")

    # Logout Loop from Profil directly to Login Screen (Orthogonal)
    ax.plot([85, 85, 42.5, 42.5], [11, 5, 5, 16], color="#DC2626", lw=1.2, linestyle="--")
    ax.annotate("", xy=(42.5, 16), xytext=(42.5, 13),
                arrowprops=dict(arrowstyle="->", color="#DC2626", lw=1.2))
    ax.text(63.5, 6.5, "[Logout / Cabut Sesi]", ha="center", va="bottom",
            fontsize=6.2, color="#DC2626", fontstyle="italic")

    save_fig(fig, "fig3_navigation_flow.png")

# -----------------------------------------------------------------------------
# 4. FIG 4: HIGH-FIDELITY WIREFRAME DESIGN (CLEAN FIT)
# -----------------------------------------------------------------------------
def render_fig4_wireframes():
    fig, axes = plt.subplots(1, 4, figsize=(11.5, 6.2))

    screens_data = [
        # Screen 1: Login
        {
            "header": "Layar Login",
            "has_nav": False,
            "elements": [
                ("logo", "NutriView", "Nutrisi Cerdas & Pelacak Harian"),
                ("field", "Email", "ahmad.badawi@binainsani.ac.id"),
                ("field", "Kata Sandi", "••••••••••••"),
                ("btn", "MASUK KE APLIKASI"),
                ("link", "Belum memiliki akun? Daftar di sini")
            ]
        },
        # Screen 2: Dashboard
        {
            "header": "Layar Dashboard",
            "has_nav": True,
            "active_tab": "Home",
            "elements": [
                ("text", "Halo, Ahmad Badawi!", "Target Kalori Harian: 2.100 kcal"),
                ("ring", "1.650 / 2.100 kcal", "Terpenuhi 78.5% (Defisit 450 kcal)"),
                ("macro", "Karbohidrat: 195 / 260 g (75%)"),
                ("macro", "Protein: 78 / 110 g (71%)"),
                ("macro", "Lemak: 48 / 60 g (80%)"),
                ("card_wrap", "Makan Siang (12:45)", "Ayam Goreng (150g) + Nasi Putih", "650 kcal • Terpenuhi 31%")
            ]
        },
        # Screen 3: Detection Confirmation
        {
            "header": "Konfirmasi & Porsi",
            "has_nav": True,
            "active_tab": "Scan",
            "elements": [
                ("preview_clean", "[ Citra Foto Makanan ]", "BBox: Ayam Goreng (91%)"),
                ("field", "Porsi Konsumsi (gram)", "150 gram"),
                ("preview_calc", "Estimasi Nutrisi Porsi:", "Kalori: 390.0 kcal | Prot: 34.5g\nKarbo: 0.0g | Lemak: 27.0g"),
                ("btn", "SIMPAN CATATAN MAKAN")
            ]
        },
        # Screen 4: Meal History
        {
            "header": "Riwayat Makan",
            "has_nav": True,
            "active_tab": "Riwayat",
            "elements": [
                ("filter", "Filter Tanggal", "Jumat, 16 Oktober 2026 ▾"),
                ("card", "Sarapan (07:15) • 420 kcal", "Nasi Goreng Telur (200g)\nProt: 14g | Karbo: 52g | Lemak: 18g"),
                ("card", "Makan Siang (12:45) • 585 kcal", "Nasi Putih (150g) + Ayam Goreng\nProt: 38g | Karbo: 43g | Lemak: 27g"),
                ("card", "Camilan (16:30) • 105 kcal", "Pisang / Banana (120g)\nProt: 1.3g | Karbo: 27g | Lemak: 0.4g")
            ]
        }
    ]

    for ax, sdata in zip(axes, screens_data):
        ax.set_xlim(0, 100)
        ax.set_ylim(0, 150)
        ax.axis("off")

        # Phone frame
        chassis = patches.FancyBboxPatch((4, 4), 92, 142, boxstyle="round,pad=1.2",
                                         facecolor="#FFFFFF", edgecolor="#334155", lw=1.8)
        ax.add_patch(chassis)

        # Phone speaker notch
        ax.plot([40, 60], [143, 143], color="#64748B", lw=2.5, solid_capstyle="round")

        # Top App Bar
        top_bar = patches.Rectangle((4, 126), 92, 12, facecolor="#F8FAFC", edgecolor="#CBD5E1", lw=0.8)
        ax.add_patch(top_bar)
        ax.text(50, 132, sdata["header"], ha="center", va="center",
                fontsize=7.8, fontweight="bold", color="#1E293B")

        # Render elements
        y_pos = 118
        for item in sdata["elements"]:
            itype = item[0]
            if itype == "logo":
                lbox = patches.FancyBboxPatch((25, y_pos-14), 50, 16, boxstyle="round,pad=0.3",
                                              facecolor="#F0FDF4", edgecolor="#86EFAC", lw=1)
                ax.add_patch(lbox)
                ax.text(50, y_pos-4, item[1], ha="center", va="center", fontsize=10, fontweight="bold", color="#166534")
                ax.text(50, y_pos-10, item[2], ha="center", va="center", fontsize=6, color="#475569")
                y_pos -= 20
            elif itype == "field":
                ax.text(12, y_pos, item[1], ha="left", va="bottom", fontsize=6.5, fontweight="bold", color="#334155")
                fbox = patches.FancyBboxPatch((12, y_pos-9), 76, 8, boxstyle="round,pad=0.2",
                                              facecolor="#FFFFFF", edgecolor="#CBD5E1", lw=1)
                ax.add_patch(fbox)
                ax.text(16, y_pos-5, item[2], ha="left", va="center", fontsize=6.5, color="#1E293B")
                y_pos -= 15
            elif itype == "btn":
                bbox = patches.FancyBboxPatch((12, y_pos-9), 76, 9, boxstyle="round,pad=0.3",
                                              facecolor="#166534", edgecolor="#14532D", lw=1)
                ax.add_patch(bbox)
                ax.text(50, y_pos-4.5, item[1], ha="center", va="center",
                        fontsize=7, fontweight="bold", color="#FFFFFF")
                y_pos -= 15
            elif itype == "link":
                ax.text(50, y_pos-2, item[1], ha="center", va="center", fontsize=6.2, color="#0284C7")
                y_pos -= 10
            elif itype == "text":
                ax.text(12, y_pos, item[1], ha="left", va="center", fontsize=7.2, fontweight="bold", color="#1E293B")
                ax.text(12, y_pos-6, item[2], ha="left", va="center", fontsize=6.2, color="#64748B")
                y_pos -= 14
            elif itype == "ring":
                rbox = patches.FancyBboxPatch((12, y_pos-14), 76, 15, boxstyle="round,pad=0.3",
                                              facecolor="#F0FDF4", edgecolor="#86EFAC", lw=1)
                ax.add_patch(rbox)
                ax.text(50, y_pos-5, item[1], ha="center", va="center", fontsize=8.5, fontweight="bold", color="#166534")
                ax.text(50, y_pos-10.5, item[2], ha="center", va="center", fontsize=6.2, color="#15803D")
                y_pos -= 19
            elif itype == "macro":
                mbox = patches.FancyBboxPatch((12, y_pos-5.5), 76, 6, boxstyle="round,pad=0.2",
                                              facecolor="#F8FAFC", edgecolor="#E2E8F0", lw=0.8)
                ax.add_patch(mbox)
                ax.text(16, y_pos-2.5, item[1], ha="left", va="center", fontsize=6.2, color="#334155")
                y_pos -= 8
            elif itype == "card_wrap":
                cd = patches.FancyBboxPatch((12, y_pos-13), 76, 13, boxstyle="round,pad=0.3",
                                            facecolor="#FFFFFF", edgecolor="#CBD5E1", lw=1)
                ax.add_patch(cd)
                ax.text(15, y_pos-3.5, item[1], ha="left", va="center", fontsize=6.3, fontweight="bold", color="#1E293B")
                ax.text(15, y_pos-7.5, item[2], ha="left", va="center", fontsize=5.8, color="#334155")
                ax.text(15, y_pos-11, item[3], ha="left", va="center", fontsize=5.5, color="#166534", fontweight="bold")
                y_pos -= 16
            elif itype == "preview_clean":
                pbox = patches.FancyBboxPatch((12, y_pos-24), 76, 24, boxstyle="round,pad=0.3",
                                              facecolor="#F1F5F9", edgecolor="#94A3B8", lw=1, linestyle="--")
                ax.add_patch(pbox)
                ax.text(50, y_pos-5.5, item[1], ha="center", va="center", fontsize=6.5, color="#64748B")
                # Bounding box simulation
                bb = patches.Rectangle((20, y_pos-22), 60, 13, facecolor="none", edgecolor="#DC2626", lw=1.5)
                ax.add_patch(bb)
                tag = patches.Rectangle((20, y_pos-12), 42, 4.0, facecolor="#DC2626")
                ax.add_patch(tag)
                ax.text(22, y_pos-10.0, item[2], fontsize=5.0, fontweight="bold", color="#FFFFFF")
                y_pos -= 28
            elif itype == "preview_calc":
                cbox = patches.FancyBboxPatch((12, y_pos-14), 76, 14, boxstyle="round,pad=0.3",
                                              facecolor="#F0F9FF", edgecolor="#BAE6FD", lw=1)
                ax.add_patch(cbox)
                ax.text(16, y_pos-4, item[1], ha="left", va="center", fontsize=6.2, fontweight="bold", color="#0369A1")
                ax.text(16, y_pos-9.5, item[2], ha="left", va="center", fontsize=5.8, color="#0C4A6E")
                y_pos -= 18
            elif itype == "filter":
                ax.text(12, y_pos, item[1], ha="left", va="bottom", fontsize=6.5, fontweight="bold", color="#334155")
                ft = patches.FancyBboxPatch((12, y_pos-8), 76, 7.5, boxstyle="round,pad=0.2",
                                            facecolor="#F8FAFC", edgecolor="#CBD5E1", lw=1)
                ax.add_patch(ft)
                ax.text(50, y_pos-4.2, item[2], ha="center", va="center", fontsize=6.5, color="#0284C7")
                y_pos -= 14
            elif itype == "card":
                cd = patches.FancyBboxPatch((12, y_pos-12), 76, 12, boxstyle="round,pad=0.3",
                                            facecolor="#FFFFFF", edgecolor="#CBD5E1", lw=1)
                ax.add_patch(cd)
                ax.text(15, y_pos-4, item[1], ha="left", va="center", fontsize=6.2, fontweight="bold", color="#1E293B")
                ax.text(15, y_pos-8.5, item[2], ha="left", va="center", fontsize=5.5, color="#475569")
                y_pos -= 15

        # Bottom navigation bar
        if sdata["has_nav"]:
            b_nav = patches.Rectangle((4, 4), 92, 14, facecolor="#F8FAFC", edgecolor="#CBD5E1", lw=0.8)
            ax.add_patch(b_nav)
            tabs = [("Home", 22), ("Scan", 50), ("Riwayat", 78)]
            for tname, tx in tabs:
                is_act = (tname == sdata.get("active_tab"))
                tcol = "#166534" if is_act else "#64748B"
                fweight = "bold" if is_act else "normal"
                ax.text(tx, 11, tname, ha="center", va="center", fontsize=6.5, fontweight=fweight, color=tcol)
                if is_act:
                    ax.plot([tx-6, tx+6], [6.5, 6.5], color="#166534", lw=2)

    save_fig(fig, "fig4_ui_wireframes.png")

# -----------------------------------------------------------------------------
# 5. FIG 5: DATABASE ENTITY RELATIONSHIP DIAGRAM (CROW'S FOOT NOTATION)
# -----------------------------------------------------------------------------
def render_fig5_erd():
    fig, ax = plt.subplots(figsize=(11.5, 7.2))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 82)
    ax.axis("off")

    def draw_entity(name, x, y, w, h, cols):
        # Header Box
        hdr = patches.Rectangle((x, y + h - 5.5), w, 5.5, facecolor="#1E293B", edgecolor="#1E293B", zorder=4)
        ax.add_patch(hdr)
        ax.text(x + w/2, y + h - 2.8, name, ha="center", va="center",
                fontsize=8, fontweight="bold", color="#FFFFFF", zorder=5)
        # Body Box
        body = patches.Rectangle((x, y), w, h - 5.5, facecolor="#FFFFFF", edgecolor="#94A3B8", lw=1.2, zorder=4)
        ax.add_patch(body)
        
        # Attributes
        for i, (col_name, col_type, col_key) in enumerate(cols):
            cy = y + h - 8.5 - (i * 2.3)
            ax.text(x + 1.2, cy, col_name, ha="left", va="center",
                    fontsize=6.5, family="monospace", fontweight="bold" if col_key else "normal",
                    color="#0F172A" if col_key else "#334155", zorder=5)
            key_tag = f"[{col_key}]" if col_key else ""
            ax.text(x + w - 1.2, cy, f"{col_type} {key_tag}".strip(), ha="right", va="center",
                    fontsize=6.2, family="monospace", color="#0369A1" if "FK" in key_tag else "#64748B", zorder=5)

    # Column 1 (Left: Users & Profiles & Revoked Tokens)
    draw_entity("users", 4, 48, 26, 26, [
        ("id", "BIGINT", "PK"),
        ("email", "VARCHAR(255)", "UQ"),
        ("password_hash", "VARCHAR(255)", ""),
        ("full_name", "VARCHAR(100)", ""),
        ("created_at", "DATETIME", ""),
        ("updated_at", "DATETIME", "")
    ])

    draw_entity("profiles", 4, 15, 26, 29, [
        ("id", "BIGINT", "PK"),
        ("user_id", "BIGINT", "FK, UQ"),
        ("age", "SMALLINT", "CHK"),
        ("sex", "ENUM(2)", ""),
        ("weight_kg", "NUMERIC(5,2)", "CHK"),
        ("height_cm", "NUMERIC(5,2)", "CHK"),
        ("activity_level", "ENUM(5)", ""),
        ("goal", "ENUM(3)", ""),
        ("created_at", "DATETIME", "")
    ])

    draw_entity("revoked_tokens", 4, 3, 26, 9.5, [
        ("jti", "VARCHAR(36)", "PK"),
        ("expires_at", "DATETIME", "IDX")
    ])

    # Column 2 (Middle: Foods & Food Nutrition)
    draw_entity("foods", 37, 48, 26, 24, [
        ("id", "INT", "PK"),
        ("name", "VARCHAR(100)", "UQ"),
        ("yolo_class", "VARCHAR(100)", "UQ"),
        ("is_active", "BOOLEAN", "IDX"),
        ("created_at", "DATETIME", "")
    ])

    draw_entity("food_nutrition", 37, 18, 26, 26, [
        ("food_id", "INT", "PK, FK"),
        ("calories_kcal", "NUMERIC(7,2)", "CHK"),
        ("protein_g", "NUMERIC(7,2)", "CHK"),
        ("carbs_g", "NUMERIC(7,2)", "CHK"),
        ("fat_g", "NUMERIC(7,2)", "CHK"),
        ("source", "VARCHAR(255)", ""),
        ("updated_at", "DATETIME", "")
    ])

    # Column 3 (Right: Meal Records & Meal Items)
    draw_entity("meal_records", 70, 44, 27, 30, [
        ("id", "BIGINT", "PK"),
        ("user_id", "BIGINT", "FK"),
        ("meal_type", "ENUM(4)", ""),
        ("consumed_at", "DATETIME", "IDX"),
        ("consumed_date", "DATE", "IDX"),
        ("total_calories_kcal", "NUMERIC(8,2)", ""),
        ("total_protein_g", "NUMERIC(8,2)", ""),
        ("total_carbs_g", "NUMERIC(8,2)", ""),
        ("total_fat_g", "NUMERIC(8,2)", "")
    ])

    draw_entity("meal_items", 70, 9, 27, 31, [
        ("id", "BIGINT", "PK"),
        ("meal_id", "BIGINT", "FK"),
        ("food_id", "INT", "FK"),
        ("portion_grams", "NUMERIC(7,2)", "CHK"),
        ("calories_kcal", "NUMERIC(8,2)", ""),
        ("protein_g", "NUMERIC(8,2)", ""),
        ("carbs_g", "NUMERIC(8,2)", ""),
        ("fat_g", "NUMERIC(8,2)", ""),
        ("source", "ENUM(3)", ""),
        ("detection_confidence", "NUMERIC(4,3)", "")
    ])

    # NON-CROSSING RELATIONAL CONNECTORS WITH EXPLICIT ZORDER
    # 1. users -> profiles (1:1)
    ax.plot([17, 17], [48, 44], color="#166534", lw=1.5, zorder=2)
    ax.annotate("", xy=(17, 44), xytext=(17, 46), arrowprops=dict(arrowstyle="->", color="#166534", lw=1.5), zorder=2)
    tag1 = patches.FancyBboxPatch((19.5, 45), 6.5, 3.2, boxstyle="round,pad=0.2",
                                  facecolor="#FFFFFF", edgecolor="#86EFAC", lw=1, zorder=6)
    ax.add_patch(tag1)
    ax.text(22.75, 46.6, "1 : 1", ha="center", va="center", fontsize=6.2, fontweight="bold", color="#166534", zorder=7)

    # 2. users -> meal_records (1:N) - Routed OVER the top!
    ax.plot([17, 17, 83.5, 83.5], [74, 78, 78, 74], color="#166534", lw=1.5, zorder=2)
    ax.annotate("", xy=(83.5, 74), xytext=(83.5, 76), arrowprops=dict(arrowstyle="->", color="#166534", lw=1.5), zorder=2)
    tag2 = patches.FancyBboxPatch((46.5, 76.4), 11, 3.2, boxstyle="round,pad=0.2",
                                  facecolor="#FFFFFF", edgecolor="#86EFAC", lw=1, zorder=6)
    ax.add_patch(tag2)
    ax.text(52, 78.0, "1 : N (user_id)", ha="center", va="center", fontsize=6.2, fontweight="bold", color="#166534", zorder=7)

    # 3. foods -> food_nutrition (1:1)
    ax.plot([50, 50], [48, 44], color="#0284C7", lw=1.5, zorder=2)
    ax.annotate("", xy=(50, 44), xytext=(50, 46), arrowprops=dict(arrowstyle="->", color="#0284C7", lw=1.5), zorder=2)
    tag3 = patches.FancyBboxPatch((52.5, 45), 6.5, 3.2, boxstyle="round,pad=0.2",
                                  facecolor="#FFFFFF", edgecolor="#BAE6FD", lw=1, zorder=6)
    ax.add_patch(tag3)
    ax.text(55.75, 46.6, "1 : 1", ha="center", va="center", fontsize=6.2, fontweight="bold", color="#0284C7", zorder=7)

    # 4. meal_records -> meal_items (1:N)
    ax.plot([83.5, 83.5], [44, 40], color="#7C3AED", lw=1.5, zorder=2)
    ax.annotate("", xy=(83.5, 40), xytext=(83.5, 42), arrowprops=dict(arrowstyle="->", color="#7C3AED", lw=1.5), zorder=2)
    tag4 = patches.FancyBboxPatch((85.5, 41), 10, 3.2, boxstyle="round,pad=0.2",
                                  facecolor="#FFFFFF", edgecolor="#DDD6FE", lw=1, zorder=6)
    ax.add_patch(tag4)
    ax.text(90.5, 42.6, "1 : N (meal_id)", ha="center", va="center", fontsize=6.2, fontweight="bold", color="#7C3AED", zorder=7)

    # 5. foods -> meal_items (1:N) - Routed cleanly horizontally between entities
    ax.plot([63, 66.5, 66.5, 70], [52, 52, 25, 25], color="#0284C7", lw=1.5, zorder=2)
    ax.annotate("", xy=(70, 25), xytext=(68, 25), arrowprops=dict(arrowstyle="->", color="#0284C7", lw=1.5), zorder=2)
    tag5 = patches.FancyBboxPatch((61.5, 37), 10, 3.2, boxstyle="round,pad=0.2",
                                  facecolor="#FFFFFF", edgecolor="#BAE6FD", lw=1, zorder=6)
    ax.add_patch(tag5)
    ax.text(66.5, 38.6, "1 : N (food_id)", ha="center", va="center", fontsize=6.2, fontweight="bold", color="#0284C7", zorder=7)

    save_fig(fig, "fig5_database_erd.png")

# -----------------------------------------------------------------------------
# 6. FIG 6: UML SEQUENCE DIAGRAM (SCAN & LOG MEAL)
# -----------------------------------------------------------------------------
def render_fig6_sequence():
    fig, ax = plt.subplots(figsize=(10.8, 7.2))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 85)
    ax.axis("off")

    participants = [
        (12, "Pengguna\n(User / Client)"),
        (34, "Flutter UI\n(ScanFlowProvider)"),
        (56, "FastAPI Backend\n(Food/Meal Routers)"),
        (76, "YOLO26n Detector\n(Ultralytics Service)"),
        (92, "MySQL Database\n(InnoDB Engine)")
    ]

    # Draw Participant Boxes & Lifelines
    for px, ptitle in participants:
        pbox = patches.FancyBboxPatch((px-7.5, 76), 15, 6.5, boxstyle="round,pad=0.3",
                                      facecolor="#1E293B", edgecolor="#1E293B", zorder=4)
        ax.add_patch(pbox)
        ax.text(px, 79.2, ptitle, ha="center", va="center", fontsize=7.2, fontweight="bold", color="#FFFFFF", zorder=5)
        # Lifeline
        ax.plot([px, px], [2, 76], color="#CBD5E1", lw=1.2, linestyle="--", zorder=1)

    # Draw Execution Activation Bars
    act_bars = [
        (12, 6, 72),
        (34, 6, 70),
        (56, 11, 57),
        (76, 56, 12),
        (92, 16, 16),
        (92, 46, 6)
    ]
    for bx, by, bh in act_bars:
        bar = patches.Rectangle((bx-1, by), 2, bh, facecolor="#F1F5F9", edgecolor="#64748B", lw=1, zorder=2)
        ax.add_patch(bar)

    # Sequence Messages
    steps = [
        # (from_x, to_x, y, text, is_reply, color)
        (12, 34, 71, "1. Memotret / Pilih Gambar Makanan", False, "#1E293B"),
        (34, 56, 66, "2. POST /foods/detect (multipart/form-data)", False, "#0284C7"),
        (56, 76, 61, "3. validate_and_prepare() & detect(image)", False, "#B45309"),
        (76, 56, 55, "4. raw_detections (class_name, confidence, bbox)", True, "#B45309"),
        (56, 92, 49, "5. SELECT food & nutrition WHERE yolo_class = ?", False, "#166534"),
        (92, 56, 44, "6. return food record & standard nutrient per 100g", True, "#166534"),
        (56, 34, 39, "7. 200 OK (DetectFoodResponse: mapped food & nutrients)", True, "#0284C7"),
        (34, 12, 34, "8. Tampilkan bounding box & formulir input porsi", False, "#1E293B"),
        (12, 34, 29, "9. Konfirmasi menu & masukkan porsi (150 gram)", False, "#1E293B"),
        (34, 56, 24, "10. POST /meals (meal_type, food_id, portion_grams)", False, "#0284C7"),
        (56, 92, 19, "11. INSERT meal_records & meal_items (Atomik)", False, "#166534"),
        (92, 56, 14, "12. Transaksi Commit & return record id", True, "#166534"),
        (56, 34, 9.5, "13. 201 Created (MealRecordResponse)", True, "#0284C7"),
        (34, 12, 5, "14. Navigasi ke Dashboard & Refresh Progres", False, "#166534")
    ]

    for from_x, to_x, y, text, is_rep, col in steps:
        ls = ":" if is_rep else "-"
        # Line with arrow
        ax.annotate("", xy=(to_x, y), xytext=(from_x, y),
                    arrowprops=dict(arrowstyle="->", color=col, lw=1.2, linestyle=ls), zorder=3)
        # Text label with subtle white background to guarantee 0 collision with lifelines
        mid_x = (from_x + to_x) / 2
        ax.text(mid_x, y + 0.8, text, ha="center", va="bottom",
                fontsize=6.3, fontweight="bold", color=col, zorder=5,
                bbox=dict(boxstyle="square,pad=0.15", facecolor="#FFFFFF", edgecolor="none", alpha=0.9))

    save_fig(fig, "fig6_scan_sequence_diagram.png")

# -----------------------------------------------------------------------------
# 7. FIG 7: DETERMINISTIC NUTRITION CALCULATION PIPELINE
# -----------------------------------------------------------------------------
def render_fig7_nutrition_pipeline():
    fig, ax = plt.subplots(figsize=(11, 6.5))
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 75)
    ax.axis("off")

    # Section 1 Header: Target Formulation (Top Container)
    sec1 = patches.FancyBboxPatch((2, 38), 96, 34, boxstyle="round,pad=0.6",
                                  facecolor="#F8FAFC", edgecolor="#94A3B8", lw=1.2)
    ax.add_patch(sec1)
    ax.text(50, 69.5, "Tahap 1: Formulasi Kebutuhan Energi & Makronutrien Harian Pengguna (Deterministik)",
            ha="center", va="center", fontsize=8.5, fontweight="bold", color="#1E293B")

    # Step 1: Input Antropometri
    b1 = patches.FancyBboxPatch((4, 42), 15, 24, boxstyle="round,pad=0.4",
                                facecolor="#FFFFFF", edgecolor="#CBD5E1", lw=1)
    ax.add_patch(b1)
    ax.text(11.5, 62, "Input Profil", ha="center", va="center", fontsize=7.5, fontweight="bold", color="#1E293B")
    ax.text(11.5, 52, "• Usia (15–100 th)\n• Jenis Kelamin\n• Berat (20–300 kg)\n• Tinggi (100–250 cm)\n• Aktivitas (5 level)\n• Sasaran (3 goal)",
            ha="center", va="center", fontsize=6.2, color="#475569")

    # Arrow 1 -> 2
    ax.annotate("", xy=(21.5, 54), xytext=(19, 54), arrowprops=dict(arrowstyle="->", color="#64748B", lw=1.4))

    # Step 2: BMR Calculation
    b2 = patches.FancyBboxPatch((21.5, 42), 17, 24, boxstyle="round,pad=0.4",
                                facecolor="#FFFFFF", edgecolor="#86EFAC", lw=1.2)
    ax.add_patch(b2)
    ax.text(30, 62, "1. Hitung BMR", ha="center", va="center", fontsize=7.5, fontweight="bold", color="#166534")
    ax.text(30, 52, "Mifflin-St Jeor:\nL: 10W + 6.25H\n   - 5A + 5\nP: 10W + 6.25H\n   - 5A - 161",
            ha="center", va="center", fontsize=6.5, color="#14532D")

    # Arrow 2 -> 3
    ax.annotate("", xy=(41, 54), xytext=(38.5, 54), arrowprops=dict(arrowstyle="->", color="#64748B", lw=1.4))

    # Step 3: TDEE Calculation
    b3 = patches.FancyBboxPatch((41, 42), 17, 24, boxstyle="round,pad=0.4",
                                facecolor="#FFFFFF", edgecolor="#BAE6FD", lw=1.2)
    ax.add_patch(b3)
    ax.text(49.5, 62, "2. Hitung TDEE", ha="center", va="center", fontsize=7.5, fontweight="bold", color="#0284C7")
    ax.text(49.5, 52, "TDEE = BMR × Factor\n• Sedentary: 1.200\n• Light: 1.375\n• Moderate: 1.550\n• Active: 1.725\n• Very Active: 1.900",
            ha="center", va="center", fontsize=6.2, color="#0C4A6E")

    # Arrow 3 -> 4
    ax.annotate("", xy=(60.5, 54), xytext=(58, 54), arrowprops=dict(arrowstyle="->", color="#64748B", lw=1.4))

    # Step 4: Calorie Target & Floor
    b4 = patches.FancyBboxPatch((60.5, 42), 17, 24, boxstyle="round,pad=0.4",
                                facecolor="#FFFFFF", edgecolor="#FECACA", lw=1.2)
    ax.add_patch(b4)
    ax.text(69, 62, "3. Target Kalori", ha="center", va="center", fontsize=7.5, fontweight="bold", color="#DC2626")
    ax.text(69, 52, "TDEE + Goal Delta\n• Lose: -500 kcal\n• Maintain: 0\n• Gain: +300 kcal\n\nFloor: L≥1500, P≥1200",
            ha="center", va="center", fontsize=6.2, color="#991B1B")

    # Arrow 4 -> 5
    ax.annotate("", xy=(80, 54), xytext=(77.5, 54), arrowprops=dict(arrowstyle="->", color="#64748B", lw=1.4))

    # Step 5: Macronutrient Split
    b5 = patches.FancyBboxPatch((80, 42), 16, 24, boxstyle="round,pad=0.4",
                                facecolor="#FFFFFF", edgecolor="#DDD6FE", lw=1.2)
    ax.add_patch(b5)
    ax.text(88, 62, "4. Makronutrien", ha="center", va="center", fontsize=7.5, fontweight="bold", color="#7C3AED")
    ax.text(88, 52, "• Protein: 1.2–1.6 g/kg\n• Lemak: 25% kalori / 9\n• Karbo: Sisa kalori / 4\n(Presisi 1 desimal)",
            ha="center", va="center", fontsize=6.2, color="#5B21B6")

    # Section 2 Header: Portion Nutrition Calculation (Bottom-Left: x=2..60)
    sec2 = patches.FancyBboxPatch((2, 4), 58, 30, boxstyle="round,pad=0.6",
                                  facecolor="#F0FDF4", edgecolor="#166534", lw=1.2)
    ax.add_patch(sec2)
    ax.text(31, 30.5, "Tahap 2: Skalasi Nutrisi Porsi Makanan Konsumsi (Deterministic Scaling)",
            ha="center", va="center", fontsize=8, fontweight="bold", color="#166534")

    p_formula = patches.FancyBboxPatch((4, 7), 54, 20, boxstyle="round,pad=0.4",
                                      facecolor="#FFFFFF", edgecolor="#86EFAC", lw=1)
    ax.add_patch(p_formula)
    ax.text(31, 22.5, "Rumus Skalasi Nutrisi Porsi (Decimal ROUND_HALF_UP):",
            ha="center", va="center", fontsize=7.2, fontweight="bold", color="#14532D")
    ax.text(31, 14, "nutrisi_dikonsumsi = ( nutrisi_per_100g × porsi_gram ) / 100\n\n"
                      "Diterapkan secara deterministik pada Kalori (kcal), Protein (g), Karbohidrat (g), dan Lemak (g)\n"
                      "Contoh: Nasi Putih 250g -> 130 kcal × 2.5 = 325.00 kcal | Prot: 2.4g × 2.5 = 6.00g",
            ha="center", va="center", fontsize=6.5, color="#1E293B")

    # Section 3: Aggregation to Dashboard (Bottom-Right: x=64..98)
    sec3 = patches.FancyBboxPatch((64, 4), 34, 30, boxstyle="round,pad=0.6",
                                  facecolor="#F0F9FF", edgecolor="#0284C7", lw=1.2)
    ax.add_patch(sec3)
    ax.text(81, 30.5, "Tahap 3: Agregasi Dashboard", ha="center", va="center",
            fontsize=8, fontweight="bold", color="#0284C7")

    dash_box = patches.FancyBboxPatch((66, 7), 30, 20, boxstyle="round,pad=0.4",
                                      facecolor="#FFFFFF", edgecolor="#BAE6FD", lw=1)
    ax.add_patch(dash_box)
    ax.text(81, 21.5, "Akumulasi Harian & Defisit/Surplus", ha="center", va="center",
            fontsize=7, fontweight="bold", color="#0369A1")
    ax.text(81, 13.5, "• Total Konsumsi = Σ Item Makan\n• Progres (%) = (Konsumsi / Target) × 100\n• Sisa Energi = Target - Konsumsi\nDitampilkan pada ring & kartu makro",
            ha="center", va="center", fontsize=6.2, color="#0C4A6E")

    # Connect Stage 2 (Consumption) into Stage 3 (Aggregation)
    ax.annotate("", xy=(64, 17), xytext=(60, 17),
                arrowprops=dict(arrowstyle="->", color="#166534", lw=1.5), zorder=3)
    tag_s2 = patches.FancyBboxPatch((58.5, 18.5), 7.0, 2.8, boxstyle="round,pad=0.2",
                                    facecolor="#FFFFFF", edgecolor="#86EFAC", lw=0.8, zorder=5)
    ax.add_patch(tag_s2)
    ax.text(62.0, 19.9, "Konsumsi", ha="center", va="center", fontsize=6.0, fontweight="bold", color="#166534", zorder=6)

    # Connect Stage 1 (Target) directly into Stage 3 (Aggregation) from top
    ax.plot([81, 81], [38, 34], color="#7C3AED", lw=1.5, zorder=3)
    ax.annotate("", xy=(81, 34), xytext=(81, 36),
                arrowprops=dict(arrowstyle="->", color="#7C3AED", lw=1.5), zorder=3)
    tag_t1 = patches.FancyBboxPatch((76, 35), 10, 2.8, boxstyle="round,pad=0.2",
                                   facecolor="#FFFFFF", edgecolor="#DDD6FE", lw=0.8, zorder=5)
    ax.add_patch(tag_t1)
    ax.text(81, 36.4, "Target Gizi", ha="center", va="center", fontsize=6.0, fontweight="bold", color="#7C3AED", zorder=6)

    save_fig(fig, "fig7_nutrition_calc_flow.png")


if __name__ == "__main__":
    print("Beginning professional redesign of all technical diagrams...")
    render_fig1_architecture()
    render_fig2_use_case()
    render_fig3_navigation()
    render_fig4_wireframes()
    render_fig5_erd()
    render_fig6_sequence()
    render_fig7_nutrition_pipeline()
    print("All 7 technical diagrams redesigned and rendered successfully!")
