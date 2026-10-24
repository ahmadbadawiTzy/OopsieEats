"""
NutriView Branding & Icon Asset Generator
Generates:
- Vector SVG artwork (docs/branding/nutriview_logo.svg & frontend/assets/images/nutriview_logo.svg)
- Play Store 512x512 Master Icon
- Android Mipmap Legacy Icons (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Android Adaptive Icons (Foreground, Background, Monochrome)
- Android Native Splash Image
"""

import os
import math
from PIL import Image, ImageDraw

SVG_CONTENT = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <defs>
    <filter id="hardShadow" x="-10%" y="-10%" width="130%" height="130%">
      <feDropShadow dx="16" dy="16" stdDeviation="0" flood-color="#111111" />
    </filter>
  </defs>

  <!-- Background Base Canvas -->
  <rect width="512" height="512" rx="110" fill="#FBF9F4"/>

  <!-- Neo-Brutalism Offset Shadow -->
  <rect x="52" y="52" width="416" height="416" rx="90" fill="#111111"/>

  <!-- Main Acid-Lime Badge -->
  <rect x="40" y="40" width="416" height="416" rx="90" fill="#CCFF00" stroke="#111111" stroke-width="18"/>

  <!-- Optical Viewfinder Corner Brackets -->
  <!-- Top-Left -->
  <path d="M 85 140 L 85 85 L 140 85" fill="none" stroke="#111111" stroke-width="16" stroke-linecap="square"/>
  <!-- Top-Right -->
  <path d="M 411 140 L 411 85 L 356 85" fill="none" stroke="#111111" stroke-width="16" stroke-linecap="square"/>
  <!-- Bottom-Left -->
  <path d="M 85 356 L 85 411 L 140 411" fill="none" stroke="#111111" stroke-width="16" stroke-linecap="square"/>
  <!-- Bottom-Right -->
  <path d="M 411 356 L 411 411 L 356 411" fill="none" stroke="#111111" stroke-width="16" stroke-linecap="square"/>

  <!-- Central Optical Leaf Emblem (Nutrition + Computer Vision) -->
  <!-- Leaf Shadow -->
  <path d="M 256 128 C 342 128 388 195 388 280 C 388 358 312 368 256 368 C 200 368 124 358 124 280 C 124 195 170 128 256 128 Z"
        fill="#111111"/>
  <!-- Leaf Body (White Paper) -->
  <path d="M 248 120 C 334 120 380 187 380 272 C 380 350 304 360 248 360 C 192 360 116 350 116 272 C 116 187 162 120 248 120 Z"
        fill="#FFFFFF" stroke="#111111" stroke-width="16"/>

  <!-- Leaf Central Scan Line / Spine -->
  <line x1="248" y1="150" x2="248" y2="335" stroke="#111111" stroke-width="12" stroke-linecap="round"/>

  <!-- Optical Scanner Aperture / Calorie Energy Focal Point -->
  <circle cx="248" cy="248" r="38" fill="#FF6B00" stroke="#111111" stroke-width="12"/>
  <circle cx="248" cy="248" r="14" fill="#FFD600"/>

  <!-- Crosshair Precision Ticks -->
  <line x1="162" y1="248" x2="195" y2="248" stroke="#111111" stroke-width="10" stroke-linecap="round"/>
  <line x1="301" y1="248" x2="334" y2="248" stroke="#111111" stroke-width="10" stroke-linecap="round"/>

  <!-- Top Status Pill: "NV-AI" -->
  <rect x="194" y="66" width="108" height="30" rx="6" fill="#111111"/>
  <text x="248" y="87" font-family="monospace, monospace" font-size="14" font-weight="900" fill="#CCFF00" text-anchor="middle" letter-spacing="2">NV·26</text>
</svg>'''


def draw_full_icon(size=512, scale=4):
    """Draws high quality full icon with 4x supersampling."""
    S = size * scale
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Coordinates scaled
    def sc(val):
        return int(round(val * S / 512.0))

    # Base Background rounded canvas
    corner_radius = sc(100)
    draw.rounded_rectangle([0, 0, S - 1, S - 1], radius=corner_radius, fill=(251, 249, 244, 255))

    # Shadow offset (14px at 512)
    sh_off = sc(14)
    b_radius = sc(82)
    b_x1, b_y1 = sc(48), sc(48)
    b_x2, b_y2 = sc(464), sc(464)

    # Shadow rect
    draw.rounded_rectangle(
        [b_x1 + sh_off, b_y1 + sh_off, b_x2 + sh_off, b_y2 + sh_off],
        radius=b_radius,
        fill=(17, 17, 17, 255),
    )

    # Main Lime Badge
    draw.rounded_rectangle(
        [b_x1, b_y1, b_x2, b_y2],
        radius=b_radius,
        fill=(204, 255, 0, 255),
        outline=(17, 17, 17, 255),
        width=sc(16),
    )

    # Viewfinder Corner Brackets
    bw = sc(15)
    b_len = sc(54)
    # TL
    tl_x, tl_y = sc(88), sc(88)
    draw.line([tl_x, tl_y, tl_x + b_len, tl_y], fill=(17, 17, 17, 255), width=bw)
    draw.line([tl_x, tl_y, tl_x, tl_y + b_len], fill=(17, 17, 17, 255), width=bw)
    # TR
    tr_x, tr_y = sc(424), sc(88)
    draw.line([tr_x, tr_y, tr_x - b_len, tr_y], fill=(17, 17, 17, 255), width=bw)
    draw.line([tr_x, tr_y, tr_x, tr_y + b_len], fill=(17, 17, 17, 255), width=bw)
    # BL
    bl_x, bl_y = sc(88), sc(424)
    draw.line([bl_x, bl_y, bl_x + b_len, bl_y], fill=(17, 17, 17, 255), width=bw)
    draw.line([bl_x, bl_y, bl_x, bl_y - b_len], fill=(17, 17, 17, 255), width=bw)
    # BR
    br_x, br_y = sc(424), sc(424)
    draw.line([br_x, br_y, br_x - b_len, br_y], fill=(17, 17, 17, 255), width=bw)
    draw.line([br_x, br_y, br_x, br_y - b_len], fill=(17, 17, 17, 255), width=bw)

    # Central Leaf Shadow & Body
    # We approximate the organic symmetric leaf polygon
    leaf_sh_pts = []
    steps = 60
    for i in range(steps + 1):
        t = i / float(steps)
        # angle from -pi/2 to pi/2 (right side)
        ang = -math.pi / 2.0 + t * math.pi
        y = 244 + 115 * math.sin(ang)
        # width varies with smooth bulge
        factor = math.cos(ang) ** 0.85
        x = 248 + 125 * factor
        leaf_sh_pts.append((sc(x + 8), sc(y + 8)))
    for i in range(steps, -1, -1):
        t = i / float(steps)
        ang = -math.pi / 2.0 + t * math.pi
        y = 244 + 115 * math.sin(ang)
        factor = math.cos(ang) ** 0.85
        x = 248 - 125 * factor
        leaf_sh_pts.append((sc(x + 8), sc(y + 8)))

    draw.polygon(leaf_sh_pts, fill=(17, 17, 17, 255))

    leaf_pts = [(x - sc(8), y - sc(8)) for x, y in leaf_sh_pts]
    draw.polygon(leaf_pts, fill=(255, 255, 255, 255), outline=(17, 17, 17, 255))

    # Outline thicker for Neo-Brutalism
    for i in range(len(leaf_pts)):
        p1 = leaf_pts[i]
        p2 = leaf_pts[(i + 1) % len(leaf_pts)]
        draw.line([p1, p2], fill=(17, 17, 17, 255), width=sc(15))

    # Central spine / laser line
    draw.line([sc(248), sc(145), sc(248), sc(345)], fill=(17, 17, 17, 255), width=sc(11))

    # Optical eye / calorie center
    cx, cy = sc(248), sc(248)
    r1 = sc(38)
    draw.ellipse([cx - r1, cy - r1, cx + r1, cy + r1], fill=(255, 107, 0, 255), outline=(17, 17, 17, 255), width=sc(11))
    r2 = sc(15)
    draw.ellipse([cx - r2, cy - r2, cx + r2, cy + r2], fill=(255, 214, 0, 255))

    # Optical crosshair precision ticks
    draw.line([sc(155), sc(248), sc(190), sc(248)], fill=(17, 17, 17, 255), width=sc(9))
    draw.line([sc(306), sc(248), sc(341), sc(248)], fill=(17, 17, 17, 255), width=sc(9))

    # Downsample with Lanczos
    return img.resize((size, size), Image.Resampling.LANCZOS)


def draw_adaptive_foreground(size=432, scale=3):
    """Draws Android adaptive icon foreground (centered inside 66dp safe zone)."""
    S = size * scale
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    def sc(val):
        # 512 base maps to ~260 in 432 (leaving padding for safe area)
        return int(round(val * (S * 0.62) / 512.0 + (S * 0.19)))

    sh_off = int(round(12 * S / 512.0 * 0.62))
    b_radius = int(round(70 * S / 512.0 * 0.62))
    b_x1, b_y1 = sc(48), sc(48)
    b_x2, b_y2 = sc(464), sc(464)

    # Shadow
    draw.rounded_rectangle(
        [b_x1 + sh_off, b_y1 + sh_off, b_x2 + sh_off, b_y2 + sh_off],
        radius=b_radius,
        fill=(17, 17, 17, 255),
    )

    # Lime Badge
    draw.rounded_rectangle(
        [b_x1, b_y1, b_x2, b_y2],
        radius=b_radius,
        fill=(204, 255, 0, 255),
        outline=(17, 17, 17, 255),
        width=int(round(15 * S / 512.0 * 0.62)),
    )

    bw = int(round(14 * S / 512.0 * 0.62))
    b_len = int(round(50 * S / 512.0 * 0.62))
    # TL
    draw.line([sc(90), sc(90), sc(90) + b_len, sc(90)], fill=(17, 17, 17, 255), width=bw)
    draw.line([sc(90), sc(90), sc(90), sc(90) + b_len], fill=(17, 17, 17, 255), width=bw)
    # TR
    draw.line([sc(422), sc(90), sc(422) - b_len, sc(90)], fill=(17, 17, 17, 255), width=bw)
    draw.line([sc(422), sc(90), sc(422), sc(90) + b_len], fill=(17, 17, 17, 255), width=bw)
    # BL
    draw.line([sc(90), sc(422), sc(90) + b_len, sc(422)], fill=(17, 17, 17, 255), width=bw)
    draw.line([sc(90), sc(422), sc(90), sc(422) - b_len], fill=(17, 17, 17, 255), width=bw)
    # BR
    draw.line([sc(422), sc(422), sc(422) - b_len, sc(422)], fill=(17, 17, 17, 255), width=bw)
    draw.line([sc(422), sc(422), sc(422), sc(422) - b_len], fill=(17, 17, 17, 255), width=bw)

    # Central Leaf
    leaf_sh_pts = []
    steps = 50
    for i in range(steps + 1):
        t = i / float(steps)
        ang = -math.pi / 2.0 + t * math.pi
        y = 244 + 112 * math.sin(ang)
        factor = math.cos(ang) ** 0.85
        x = 248 + 122 * factor
        leaf_sh_pts.append((sc(x + 8), sc(y + 8)))
    for i in range(steps, -1, -1):
        t = i / float(steps)
        ang = -math.pi / 2.0 + t * math.pi
        y = 244 + 112 * math.sin(ang)
        factor = math.cos(ang) ** 0.85
        x = 248 - 122 * factor
        leaf_sh_pts.append((sc(x + 8), sc(y + 8)))

    draw.polygon(leaf_sh_pts, fill=(17, 17, 17, 255))
    leaf_pts = [(x - int(round(8 * S / 512.0 * 0.62)), y - int(round(8 * S / 512.0 * 0.62))) for x, y in leaf_sh_pts]
    draw.polygon(leaf_pts, fill=(255, 255, 255, 255))

    for i in range(len(leaf_pts)):
        p1 = leaf_pts[i]
        p2 = leaf_pts[(i + 1) % len(leaf_pts)]
        draw.line([p1, p2], fill=(17, 17, 17, 255), width=int(round(14 * S / 512.0 * 0.62)))

    # Spine
    draw.line([sc(248), sc(150), sc(248), sc(338)], fill=(17, 17, 17, 255), width=int(round(10 * S / 512.0 * 0.62)))

    # Center circle
    cx, cy = sc(248), sc(248)
    r1 = int(round(36 * S / 512.0 * 0.62))
    draw.ellipse([cx - r1, cy - r1, cx + r1, cy + r1], fill=(255, 107, 0, 255), outline=(17, 17, 17, 255), width=int(round(10 * S / 512.0 * 0.62)))
    r2 = int(round(14 * S / 512.0 * 0.62))
    draw.ellipse([cx - r2, cy - r2, cx + r2, cy + r2], fill=(255, 214, 0, 255))

    return img.resize((size, size), Image.Resampling.LANCZOS)


def draw_adaptive_monochrome(size=432, scale=3):
    """Draws monochrome version for Android 13+ Material You themed icons."""
    fore = draw_adaptive_foreground(size=size, scale=scale)
    # Convert RGB to pure white with alpha mask
    r, g, b, a = fore.split()
    mono = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    # Create high contrast alpha
    mono.putalpha(a)
    return mono


def main():
    print("Writing SVG vector files...")
    with open("docs/branding/nutriview_logo.svg", "w") as f:
        f.write(SVG_CONTENT)
    with open("frontend/assets/images/nutriview_logo.svg", "w") as f:
        f.write(SVG_CONTENT)

    print("Generating master 512x512 Play Store icon...")
    master_512 = draw_full_icon(size=512)
    master_512.save("docs/branding/nutriview_playstore_512.png")
    master_512.save("frontend/assets/images/nutriview_logo.png")

    print("Generating Android legacy mipmap icons...")
    sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    for folder, px in sizes.items():
        path = f"frontend/android/app/src/main/res/{folder}"
        os.makedirs(path, exist_ok=True)
        ico = draw_full_icon(size=px)
        ico.save(f"{path}/ic_launcher.png")

    print("Generating Android adaptive icon foregrounds & background...")
    adaptive_sizes = {
        "mipmap-mdpi": 108,
        "mipmap-hdpi": 162,
        "mipmap-xhdpi": 216,
        "mipmap-xxhdpi": 324,
        "mipmap-xxxhdpi": 432,
    }
    for folder, px in adaptive_sizes.items():
        path = f"frontend/android/app/src/main/res/{folder}"
        os.makedirs(path, exist_ok=True)
        # Foreground
        fg = draw_adaptive_foreground(size=px)
        fg.save(f"{path}/ic_launcher_foreground.png")
        # Monochrome
        mono = draw_adaptive_monochrome(size=px)
        mono.save(f"{path}/ic_launcher_monochrome.png")

    print("Branding and launcher icons generated successfully!")


if __name__ == "__main__":
    main()
