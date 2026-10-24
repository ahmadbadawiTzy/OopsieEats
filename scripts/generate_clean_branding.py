import os
import math
from PIL import Image, ImageDraw

def cubic_bezier(p0, p1, p2, p3, steps=100):
    pts = []
    for i in range(steps + 1):
        t = i / steps
        u = 1.0 - t
        x = (u**3)*p0[0] + 3*(u**2)*t*p1[0] + 3*u*(t**2)*p2[0] + (t**3)*p3[0]
        y = (u**3)*p0[1] + 3*(u**2)*t*p1[1] + 3*u*(t**2)*p2[1] + (t**3)*p3[1]
        pts.append((x, y))
    return pts

def render_apple_icon(canvas_size, is_foreground_only=False, is_monochrome=False, fit=0.51):
    super_size = canvas_size * 4
    scale = super_size / 512.0
    
    if is_foreground_only or is_monochrome:
        img = Image.new("RGBA", (super_size, super_size), (0, 0, 0, 0))
    else:
        img = Image.new("RGBA", (super_size, super_size), (0xFB, 0xF9, 0xF4, 0xFF))
        
    draw = ImageDraw.Draw(img)
    
    cx = super_size * 0.49
    cy = super_size * 0.53
    r = 135 * scale * (fit / 0.65)
    
    c_ink = (0x11, 0x11, 0x11, 0xFF)
    c_lime = (0xCC, 0xFF, 0x00, 0xFF)
    c_leaf = (0x16, 0xA3, 0x4A, 0xFF)
    c_white = (0xFF, 0xFF, 0xFF, 0xFF)
    
    if is_monochrome:
        c_lime = (0x11, 0x11, 0x11, 0xFF)
        c_leaf = (0x11, 0x11, 0x11, 0xFF)
    
    stroke_r = int(round(7.5 * scale * (fit / 0.65)))
    shadow_off = int(round(13 * scale * (fit / 0.65)))
    
    top_notch = (cx, cy - r * 0.65)
    p_tl_crest = (cx - r * 0.60, cy - r * 0.95)
    p_ml_cheek = (cx - r * 1.05, cy - r * 0.15)
    p_bl_waist = (cx - r * 0.85, cy + r * 0.60)
    p_bl_lobe  = (cx - r * 0.35, cy + r * 0.96)
    bottom_notch = (cx, cy + r * 0.82)
    p_br_lobe  = (cx + r * 0.35, cy + r * 0.96)
    p_mr_waist = (cx + r * 0.85, cy + r * 0.60)
    p_mr_cheek = (cx + r * 1.05, cy - r * 0.15)
    p_tr_crest = (cx + r * 0.60, cy - r * 0.95)

    curves = [
        cubic_bezier(top_notch, (cx - r*0.20, cy - r*0.90), (cx - r*0.45, cy - r*0.98), p_tl_crest),
        cubic_bezier(p_tl_crest, (cx - r*0.85, cy - r*0.90), (cx - r*1.05, cy - r*0.60), p_ml_cheek),
        cubic_bezier(p_ml_cheek, (cx - r*1.05, cy + r*0.25), (cx - r*0.95, cy + r*0.40), p_bl_waist),
        cubic_bezier(p_bl_waist, (cx - r*0.75, cy + r*0.82), (cx - r*0.55, cy + r*0.96), p_bl_lobe),
        cubic_bezier(p_bl_lobe, (cx - r*0.20, cy + r*0.96), (cx - r*0.08, cy + r*0.84), bottom_notch),
        cubic_bezier(bottom_notch, (cx + r*0.08, cy + r*0.84), (cx + r*0.20, cy + r*0.96), p_br_lobe),
        cubic_bezier(p_br_lobe, (cx + r*0.55, cy + r*0.96), (cx + r*0.75, cy + r*0.82), p_mr_waist),
        cubic_bezier(p_mr_waist, (cx + r*0.95, cy + r*0.40), (cx + r*1.05, cy + r*0.25), p_mr_cheek),
        cubic_bezier(p_mr_cheek, (cx + r*1.05, cy - r*0.60), (cx + r*0.85, cy - r*0.90), p_tr_crest),
        cubic_bezier(p_tr_crest, (cx + r*0.45, cy - r*0.98), (cx + r*0.20, cy - r*0.90), top_notch),
    ]

    apple_pts = []
    for c in curves:
        apple_pts.extend(c[:-1])

    stem_base = (cx - r * 0.02, cy - r * 0.62)
    stem_c1   = (cx - r * 0.10, cy - r * 0.95)
    stem_c2   = (cx - r * 0.22, cy - r * 1.15)
    stem_tip  = (cx - r * 0.18, cy - r * 1.25)
    stem_curve = cubic_bezier(stem_base, stem_c1, stem_c2, stem_tip, steps=50)

    leaf_base = (cx + r * 0.05, cy - r * 0.72)
    leaf_tip  = (cx + r * 0.78, cy - r * 1.25)
    leaf_top = cubic_bezier(leaf_base, (cx + r * 0.16, cy - r * 1.20), (cx + r * 0.48, cy - r * 1.38), leaf_tip, steps=50)
    leaf_bot = cubic_bezier(leaf_tip, (cx + r * 0.65, cy - r * 0.90), (cx + r * 0.32, cy - r * 0.68), leaf_base, steps=50)
    leaf_pts = leaf_top[:-1] + leaf_bot[:-1]

    # 1. Hard Offset Shadow
    if not is_monochrome:
        for p in stem_curve:
            draw.ellipse((p[0] + shadow_off - stroke_r*1.1, p[1] + shadow_off - stroke_r*1.1,
                          p[0] + shadow_off + stroke_r*1.1, p[1] + shadow_off + stroke_r*1.1), fill=c_ink)
        leaf_shadow = [(p[0] + shadow_off, p[1] + shadow_off) for p in leaf_pts]
        draw.polygon(leaf_shadow, fill=c_ink)
        for p in leaf_shadow:
            draw.ellipse((p[0] - stroke_r, p[1] - stroke_r, p[0] + stroke_r, p[1] + stroke_r), fill=c_ink)
        apple_shadow = [(p[0] + shadow_off, p[1] + shadow_off) for p in apple_pts]
        draw.polygon(apple_shadow, fill=c_ink)
        for p in apple_shadow:
            draw.ellipse((p[0] - stroke_r, p[1] - stroke_r, p[0] + stroke_r, p[1] + stroke_r), fill=c_ink)

    # 2. Stem
    for p in stem_curve:
        draw.ellipse((p[0] - stroke_r*1.1, p[1] - stroke_r*1.1,
                      p[0] + stroke_r*1.1, p[1] + stroke_r*1.1), fill=c_ink)

    # 3. Leaf
    draw.polygon(leaf_pts, fill=c_leaf)
    for p in leaf_pts:
        draw.ellipse((p[0] - stroke_r, p[1] - stroke_r, p[0] + stroke_r, p[1] + stroke_r), fill=c_ink)
    draw.polygon(leaf_pts, fill=c_leaf)

    # 4. Apple Body
    draw.polygon(apple_pts, fill=c_lime)
    for p in apple_pts:
        draw.ellipse((p[0] - stroke_r, p[1] - stroke_r, p[0] + stroke_r, p[1] + stroke_r), fill=c_ink)
    draw.polygon(apple_pts, fill=c_lime)

    # 5. Editorial White Highlight Arc
    if not is_monochrome:
        hl_p0 = (cx - r * 0.55, cy - r * 0.55)
        hl_c1 = (cx - r * 0.82, cy - r * 0.28)
        hl_c2 = (cx - r * 0.82, cy + r * 0.12)
        hl_p3 = (cx - r * 0.60, cy + r * 0.40)
        hl_pts = cubic_bezier(hl_p0, hl_c1, hl_c2, hl_p3, steps=40)
        for p in hl_pts:
            draw.ellipse((p[0] - stroke_r * 0.85, p[1] - stroke_r * 0.85,
                          p[0] + stroke_r * 0.85, p[1] + stroke_r * 0.85), fill=c_white)

    return img.resize((canvas_size, canvas_size), Image.Resampling.LANCZOS)

def generate_svg():
    return """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <!-- Background Canvas -->
  <rect width="512" height="512" fill="#FBF9F4"/>

  <!-- Master Group with Optical Center -->
  <g transform="translate(251, 271)">
    <!-- 1. Hard Offset Drop Shadow (+13, +13) -->
    <g transform="translate(13, 13)">
      <!-- Stem Shadow -->
      <path d="M -2,-66 C -11,-101 -23,-122 -19,-132" fill="none" stroke="#111111" stroke-width="20" stroke-linecap="round"/>
      <!-- Leaf Shadow -->
      <path d="M 5,-76 C 17,-127 51,-146 83,-132 C 69,-95 34,-72 5,-76 Z" fill="#111111" stroke="#111111" stroke-width="15" stroke-linejoin="round"/>
      <!-- Apple Shadow -->
      <path d="M 0,-69 C -21,-95 -48,-104 -64,-101 C -90,-95 -111,-64 -111,-16 C -111,26 -101,42 -90,64 C -80,87 -58,102 -37,102 C -21,102 -8,89 0,87 C 8,89 21,102 37,102 C 58,102 80,87 90,64 C 101,42 111,26 111,-16 C 111,-64 90,-95 64,-101 C 48,-104 21,-95 0,-69 Z" fill="#111111" stroke="#111111" stroke-width="15" stroke-linejoin="round"/>
    </g>

    <!-- 2. Stem -->
    <path d="M -2,-66 C -11,-101 -23,-122 -19,-132" fill="none" stroke="#111111" stroke-width="20" stroke-linecap="round"/>

    <!-- 3. Leaf -->
    <path d="M 5,-76 C 17,-127 51,-146 83,-132 C 69,-95 34,-72 5,-76 Z" fill="#16A34A" stroke="#111111" stroke-width="15" stroke-linejoin="round"/>

    <!-- 4. Apple Body -->
    <path d="M 0,-69 C -21,-95 -48,-104 -64,-101 C -90,-95 -111,-64 -111,-16 C -111,26 -101,42 -90,64 C -80,87 -58,102 -37,102 C -21,102 -8,89 0,87 C 8,89 21,102 37,102 C 58,102 80,87 90,64 C 101,42 111,26 111,-16 C 111,-64 90,-95 64,-101 C 48,-104 21,-95 0,-69 Z" fill="#CCFF00" stroke="#111111" stroke-width="15" stroke-linejoin="round"/>

    <!-- 5. Editorial Graphic Highlight -->
    <path d="M -58,-58 C -87,-30 -87,13 -64,42" fill="none" stroke="#FFFFFF" stroke-width="13" stroke-linecap="round"/>
  </g>
</svg>
"""

def main():
    root = "/home/ahmadbadawi/Documents/CodinganKu/Flutter/NutriView"
    res_dir = os.path.join(root, "frontend/android/app/src/main/res")
    
    # Write SVG files
    svg_content = generate_svg()
    svg_paths = [
        os.path.join(root, "docs/branding/nutriview_logo.svg"),
        os.path.join(root, "frontend/assets/images/nutriview_logo.svg"),
    ]
    for sp in svg_paths:
        os.makedirs(os.path.dirname(sp), exist_ok=True)
        with open(sp, "w", encoding="utf-8") as f:
            f.write(svg_content)
        print(f"Wrote {sp}")

    # 1. Master Play Store 512x512
    playstore_512 = render_apple_icon(512, is_foreground_only=False, fit=0.51)
    playstore_path = os.path.join(root, "docs/branding/nutriview_playstore_512.png")
    playstore_512.save(playstore_path)
    print(f"Wrote {playstore_path}")

    # Densities map
    densities = {
        "mipmap-mdpi": (48, 108),
        "mipmap-hdpi": (72, 162),
        "mipmap-xhdpi": (96, 216),
        "mipmap-xxhdpi": (144, 324),
        "mipmap-xxxhdpi": (192, 432),
    }

    for folder, (legacy_sz, adaptive_sz) in densities.items():
        target_folder = os.path.join(res_dir, folder)
        os.makedirs(target_folder, exist_ok=True)
        
        # Legacy full icon
        legacy_img = render_apple_icon(legacy_sz, is_foreground_only=False, fit=0.51)
        legacy_path = os.path.join(target_folder, "ic_launcher.png")
        legacy_img.save(legacy_path)
        
        # Adaptive foreground
        fg_img = render_apple_icon(adaptive_sz, is_foreground_only=True, fit=0.51)
        fg_path = os.path.join(target_folder, "ic_launcher_foreground.png")
        fg_img.save(fg_path)
        
        # Adaptive monochrome
        mono_img = render_apple_icon(adaptive_sz, is_foreground_only=True, is_monochrome=True, fit=0.51)
        mono_path = os.path.join(target_folder, "ic_launcher_monochrome.png")
        mono_img.save(mono_path)
        
        print(f"Generated {folder}: ic_launcher ({legacy_sz}x{legacy_sz}), foreground & monochrome ({adaptive_sz}x{adaptive_sz})")

    print("\nAll brand and launcher assets generated successfully!")

if __name__ == "__main__":
    main()
