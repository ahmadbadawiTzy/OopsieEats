"""
Generates dedicated high-fidelity screen illustrations for NutriView project report.
Saved in docs/project-report/screenshots/
"""

import os
import matplotlib.pyplot as plt
import matplotlib.patches as patches

OUTPUT_DIR = "docs/project-report/screenshots"
os.makedirs(OUTPUT_DIR, exist_ok=True)

plt.rcParams["font.family"] = "sans-serif"
plt.rcParams["font.sans-serif"] = ["DejaVu Sans", "Arial", "Helvetica"]

def create_phone_base(title, subtitle=None):
    fig, ax = plt.subplots(figsize=(4.5, 8), dpi=200)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 180)
    ax.axis("off")

    # Phone chassis
    chassis = patches.FancyBboxPatch((4, 4), 92, 172, boxstyle="round,pad=1.5",
                                     facecolor="#F8FAF9", edgecolor="#1E293B", lw=2.5)
    ax.add_patch(chassis)

    # Notch / speaker bar
    ax.plot([40, 60], [171, 171], color="#1E293B", lw=3.5, solid_capstyle="round")
    ax.plot([63, 64], [171, 171], color="#1E293B", lw=3.5, solid_capstyle="round")

    # Status Bar
    ax.text(12, 166, "09:41", fontsize=7, fontweight="bold", color="#1E293B")
    ax.text(88, 166, "100%", fontsize=6.5, fontweight="bold", color="#1E293B", ha="right")

    # App Bar
    app_bar = patches.Rectangle((4, 146), 92, 16, facecolor="#FFFFFF", edgecolor="#E5E7EB", lw=1)
    ax.add_patch(app_bar)
    ax.text(50, 155, title, fontsize=9.5, fontweight="bold", color="#1E293B", ha="center", va="center")
    if subtitle:
        ax.text(50, 149, subtitle, fontsize=6.5, color="#64748B", ha="center", va="center")

    # Bottom Nav Bar
    nav_bar = patches.Rectangle((4, 4), 92, 16, facecolor="#FFFFFF", edgecolor="#E5E7EB", lw=1)
    ax.add_patch(nav_bar)
    
    tabs = [
        (20, "Home", True if "Dashboard" in title else False),
        (50, "Scan", True if "Scan" in title or "Porsi" in title or "Deteksi" in title else False),
        (80, "Profil", True if "Profil" in title else False),
    ]
    for tx, tname, is_act in tabs:
        col = "#2E7D32" if is_act else "#64748B"
        weight = "bold" if is_act else "normal"
        ax.text(tx, 12, tname, fontsize=7, color=col, fontweight=weight, ha="center")
        if is_act:
            ax.plot([tx-6, tx+6], [7, 7], color="#2E7D32", lw=2)

    return fig, ax

def generate_screens():
    # 1. Login Screen
    fig, ax = create_phone_base("NutriView", "Masuk ke Akun Anda")
    # Logo Box
    logo_box = patches.FancyBboxPatch((35, 115), 30, 22, boxstyle="round,pad=0.5",
                                      facecolor="#E8F5E9", edgecolor="#2E7D32", lw=1.5)
    ax.add_patch(logo_box)
    ax.text(50, 126, "NutriView", fontsize=11, fontweight="bold", color="#1B5E20", ha="center")
    ax.text(50, 119, "AI Nutrition Tracker", fontsize=6, color="#2E7D32", ha="center")

    # Input Fields
    ax.text(14, 105, "Email", fontsize=7.5, fontweight="bold", color="#1E293B")
    ibox1 = patches.FancyBboxPatch((14, 93), 72, 9, boxstyle="round,pad=0.3",
                                   facecolor="#FFFFFF", edgecolor="#D1D5DB", lw=1)
    ax.add_patch(ibox1)
    ax.text(18, 97.5, "ahmad.badawi@binainsani.ac.id", fontsize=7, color="#1E293B", va="center")

    ax.text(14, 85, "Kata Sandi", fontsize=7.5, fontweight="bold", color="#1E293B")
    ibox2 = patches.FancyBboxPatch((14, 73), 72, 9, boxstyle="round,pad=0.3",
                                   facecolor="#FFFFFF", edgecolor="#D1D5DB", lw=1)
    ax.add_patch(ibox2)
    ax.text(18, 77.5, "••••••••••••", fontsize=7, color="#1E293B", va="center")

    # Button
    btn = patches.FancyBboxPatch((14, 55), 72, 11, boxstyle="round,pad=0.4",
                                 facecolor="#2E7D32", edgecolor="#1B5E20", lw=1)
    ax.add_patch(btn)
    ax.text(50, 60.5, "MASUK", fontsize=8.5, fontweight="bold", color="#FFFFFF", ha="center", va="center")

    ax.text(50, 42, "Belum punya akun? Daftar di sini", fontsize=7, color="#1976D2", ha="center")
    fig.savefig(os.path.join(OUTPUT_DIR, "screen_login.png"), bbox_inches="tight")
    plt.close(fig)

    # 2. Dashboard Screen
    fig, ax = create_phone_base("Dashboard Nutrisi", "Ringkasan Konsumsi Harian")
    # Calorie Progress Card
    card1 = patches.FancyBboxPatch((10, 88), 80, 52, boxstyle="round,pad=0.6",
                                   facecolor="#FFFFFF", edgecolor="#E5E7EB", lw=1.2)
    ax.add_patch(card1)
    ax.text(15, 133, "Asupan Energi Hari Ini", fontsize=8, fontweight="bold", color="#1E293B")
    ax.text(50, 120, "1.650 / 2.100 kcal", fontsize=12, fontweight="bold", color="#2E7D32", ha="center")
    ax.text(50, 112, "Tersisa 450 kcal untuk mencapai target", fontsize=6.5, color="#64748B", ha="center")

    # Progress bar
    bg_bar = patches.Rectangle((15, 100), 70, 5, facecolor="#E2E8F0")
    fg_bar = patches.Rectangle((15, 100), 55, 5, facecolor="#2E7D32")
    ax.add_patch(bg_bar)
    ax.add_patch(fg_bar)
    ax.text(50, 93, "Persentase Kebutuhan: 78.5%", fontsize=6.5, color="#334155", ha="center")

    # Macros Row
    macros = [
        (12, "Karbohidrat", "195 / 260 g", "#1976D2", "#E3F2FD"),
        (40, "Protein", "78 / 110 g", "#F57C00", "#FFF3E0"),
        (68, "Lemak", "48 / 60 g", "#7B1FA2", "#F3E5F5")
    ]
    for mx, mname, mval, mcol, mbg in macros:
        box = patches.FancyBboxPatch((mx, 58), 22, 24, boxstyle="round,pad=0.3",
                                     facecolor=mbg, edgecolor=mcol, lw=1)
        ax.add_patch(box)
        ax.text(mx+11, 74, mname, fontsize=6.2, fontweight="bold", color=mcol, ha="center")
        ax.text(mx+11, 65, mval, fontsize=6.5, fontweight="bold", color="#1E293B", ha="center")

    # Recent Meals Section
    ax.text(12, 50, "Catatan Makan Hari Ini", fontsize=8, fontweight="bold", color="#1E293B")
    mcard = patches.FancyBboxPatch((10, 24), 80, 22, boxstyle="round,pad=0.4",
                                   facecolor="#FFFFFF", edgecolor="#E5E7EB", lw=1)
    ax.add_patch(mcard)
    ax.text(15, 38, "Makan Siang (12:30)", fontsize=7.2, fontweight="bold", color="#1E293B")
    ax.text(15, 30, "Ayam Goreng (150g) + Nasi Putih (200g)", fontsize=6.5, color="#475569")
    ax.text(85, 38, "650 kcal", fontsize=7.5, fontweight="bold", color="#2E7D32", ha="right")
    fig.savefig(os.path.join(OUTPUT_DIR, "screen_dashboard.png"), bbox_inches="tight")
    plt.close(fig)

    # 3. Detection Confirmation & Portion Input Screen
    fig, ax = create_phone_base("Konfirmasi Porsi", "Hasil Deteksi Model YOLO26n")
    # Image placeholder with Bounding Box
    img_box = patches.FancyBboxPatch((12, 88), 76, 52, boxstyle="round,pad=0.5",
                                     facecolor="#E2E8F0", edgecolor="#94A3B8", lw=1)
    ax.add_patch(img_box)
    ax.text(50, 122, "[ Preview Foto Makanan ]", fontsize=7.5, color="#64748B", ha="center")

    # Bounding box overlay
    bbox = patches.Rectangle((25, 95), 45, 38, facecolor="none", edgecolor="#DC2626", lw=2, linestyle="-")
    ax.add_patch(bbox)
    # BBox tag
    tag = patches.Rectangle((25, 128), 35, 6, facecolor="#DC2626")
    ax.add_patch(tag)
    ax.text(27, 131, "Ayam Goreng (91%)", fontsize=6, fontweight="bold", color="#FFFFFF")

    # Detected details
    card2 = patches.FancyBboxPatch((10, 48), 80, 36, boxstyle="round,pad=0.5",
                                   facecolor="#FFFFFF", edgecolor="#E5E7EB", lw=1.2)
    ax.add_patch(card2)
    ax.text(15, 76, "Makanan Terdeteksi: Ayam Goreng", fontsize=7.5, fontweight="bold", color="#1E293B")
    ax.text(15, 68, "Status: Mapped ke Database Nutrisi", fontsize=6.5, color="#16A34A")
    ax.text(15, 60, "Masukkan Porsi Konsumsi (gram):", fontsize=7, color="#334155")

    pbox = patches.FancyBboxPatch((15, 50), 30, 8, boxstyle="round,pad=0.2",
                                  facecolor="#F8FAFC", edgecolor="#2E7D32", lw=1.5)
    ax.add_patch(pbox)
    ax.text(30, 54, "150 gram", fontsize=7.5, fontweight="bold", color="#1E293B", ha="center", va="center")

    # Calculated nutrition preview
    ax.text(50, 54, "= 390.0 kcal | Prot: 34.5g", fontsize=6.8, color="#2E7D32", va="center")

    # Save button
    sbtn = patches.FancyBboxPatch((10, 26), 80, 11, boxstyle="round,pad=0.4",
                                  facecolor="#2E7D32", edgecolor="#1B5E20", lw=1)
    ax.add_patch(sbtn)
    ax.text(50, 31.5, "SIMPAN KE CATATAN MAKAN", fontsize=7.5, fontweight="bold", color="#FFFFFF", ha="center", va="center")

    fig.savefig(os.path.join(OUTPUT_DIR, "screen_detection_confirm.png"), bbox_inches="tight")
    plt.close(fig)

    # 4. Meal History Screen
    fig, ax = create_phone_base("Riwayat Makan", "Log Konsumsi Harian")
    # Date Picker Bar
    dp = patches.FancyBboxPatch((10, 132), 80, 9, boxstyle="round,pad=0.3",
                                facecolor="#FFFFFF", edgecolor="#CBD5E1", lw=1)
    ax.add_patch(dp)
    ax.text(20, 136.5, "Hari Ini, 16 Oktober 2026", fontsize=7, fontweight="bold", color="#1E293B", va="center")
    ax.text(80, 136.5, "[ Kalender ▾ ]", fontsize=6.5, color="#1976D2", ha="right", va="center")

    meals = [
        (100, "Sarapan (07:15)", "Nasi Goreng Telur (200g)", "420 kcal", "Prot: 14g | Karbo: 52g | Lemak: 18g"),
        (68, "Makan Siang (12:45)", "Nasi Putih (150g) + Ayam Goreng (150g)", "585 kcal", "Prot: 38g | Karbo: 43g | Lemak: 27g"),
        (36, "Camilan Sore (16:30)", "Pisang / Banana (120g)", "105 kcal", "Prot: 1.3g | Karbo: 27g | Lemak: 0.4g")
    ]
    for y_pos, m_type, m_items, m_cal, m_macros in meals:
        mc = patches.FancyBboxPatch((10, y_pos), 80, 26, boxstyle="round,pad=0.5",
                                    facecolor="#FFFFFF", edgecolor="#E2E8F0", lw=1)
        ax.add_patch(mc)
        ax.text(15, y_pos+19, m_type, fontsize=7.2, fontweight="bold", color="#1E293B")
        ax.text(85, y_pos+19, m_cal, fontsize=7.5, fontweight="bold", color="#2E7D32", ha="right")
        ax.text(15, y_pos+11, m_items, fontsize=6.8, color="#334155")
        ax.text(15, y_pos+4, m_macros, fontsize=6, color="#64748B")

    fig.savefig(os.path.join(OUTPUT_DIR, "screen_meal_history.png"), bbox_inches="tight")
    plt.close(fig)

    print("All screen illustrations generated successfully!")

if __name__ == "__main__":
    generate_screens()
