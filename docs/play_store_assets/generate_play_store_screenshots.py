#!/usr/bin/env python3
"""
OopsieEats - Google Play Store Promotional Visual Assets Generator
Overkill Neo-Brutalism Style - 1080x1920 (9:16 Portrait)
Authentic Physical Device Screenshots (Redmi 12 / Android 15)
Author: Senior Creative Director & Flutter QA Specialist
"""

import os
from PIL import Image, ImageDraw, ImageFont

# Base Directories
BASE_DIR = '/home/ahmadbadawi/Documents/CodinganKu/Flutter/OopsieEats/docs/play_store_assets'
RAW_DIR = os.path.join(BASE_DIR, 'raw')
FINAL_DIR = os.path.join(BASE_DIR, 'final')
PREVIEW_DIR = os.path.join(BASE_DIR, 'preview')

os.makedirs(FINAL_DIR, exist_ok=True)
os.makedirs(PREVIEW_DIR, exist_ok=True)

# Typography Paths
FONT_HEAVY = '/usr/share/fonts/opentype/fira/FiraSans-Heavy.otf'
FONT_BOLD = '/usr/share/fonts/opentype/fira/FiraSans-Bold.otf'
FONT_SEMIBOLD = '/usr/share/fonts/opentype/fira/FiraSans-SemiBold.otf'
FONT_MEDIUM = '/usr/share/fonts/opentype/fira/FiraSans-Medium.otf'
FONT_BOOK = '/usr/share/fonts/opentype/fira/FiraSans-Book.otf'

# Brand Color Palette
INK = (17, 17, 17, 255)            # Pitch black #111111
WHITE = (255, 255, 255, 255)
LIME = (204, 255, 0, 255)          # Acid Lime #CCFF00
HAZARD = (255, 214, 0, 255)        # Hazard Yellow #FFD600
COBALT = (29, 78, 216, 255)        # Deep Cobalt #1D4ED8
CYAN = (6, 182, 212, 255)          # Mint Cyan #06B6D4
TANGERINE = (255, 107, 0, 255)     # Tangerine #FF6B00
LILAC = (196, 181, 253, 255)       # Bio Lilac #C4B5FD
EMERALD = (22, 163, 74, 255)       # Emerald Green #16A34A

def draw_star(draw, cx, cy, size=16, fill=INK):
    """Draws a clean Neo-Brutalist 4-point sparkle/star."""
    half = size / 2.0
    narrow = size / 6.0
    points = [
        (cx, cy - half),
        (cx + narrow, cy - narrow),
        (cx + half, cy),
        (cx + narrow, cy + narrow),
        (cx, cy + half),
        (cx - narrow, cy + narrow),
        (cx - half, cy),
        (cx - narrow, cy - narrow),
    ]
    draw.polygon(points, fill=fill)

def draw_bolt(draw, cx, cy, size=18, fill=INK):
    """Draws a sharp Neo-Brutalist lightning bolt."""
    s = size / 20.0
    pts = [
        (cx + 2*s, cy - 10*s),
        (cx - 7*s, cy + 1*s),
        (cx - 1*s, cy + 1*s),
        (cx - 3*s, cy + 10*s),
        (cx + 7*s, cy - 1*s),
        (cx + 1*s, cy - 1*s)
    ]
    draw.polygon(pts, fill=fill)

def draw_target(draw, cx, cy, size=18, fill=INK):
    """Draws a precision target / crosshair icon."""
    r = size / 2.0
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], outline=fill, width=2)
    draw.ellipse([cx - r/2.5, cy - r/2.5, cx + r/2.5, cy + r/2.5], fill=fill)

def render_clean_status_bar(draw, width=1080, height=115, bg_color=(251, 249, 244, 255)):
    """Renders a pristine 09:41 mobile status bar with wifi, 5G, and full battery."""
    draw.rectangle([0, 0, width, height], fill=bg_color)
    
    # Time 09:41
    time_font = ImageFont.truetype(FONT_BOLD, 36)
    draw.text((75, 46), "09:41", font=time_font, fill=INK)
    
    # Right-side icons
    # Battery icon (outer box + tip + level)
    bx, by = 925, 52
    draw.rounded_rectangle([bx, by, bx + 64, by + 32], radius=6, outline=INK, width=3)
    draw.rectangle([bx + 64, by + 10, bx + 68, by + 22], fill=INK)
    draw.rounded_rectangle([bx + 4, by + 4, bx + 52, by + 28], radius=3, fill=INK)
    
    # 5G label
    net_font = ImageFont.truetype(FONT_BOLD, 24)
    draw.text((865, 52), "5G", font=net_font, fill=INK)
    
    # Wifi icon
    wx, wy = 815, 52
    draw.ellipse([wx + 11, wy + 21, wx + 17, wy + 27], fill=INK)
    draw.arc([wx + 5, wy + 13, wx + 23, wy + 31], start=210, end=330, fill=INK, width=3)
    draw.arc([wx - 1, wy + 5, wx + 29, wy + 35], start=210, end=330, fill=INK, width=3)

def sanitize_screenshot(slide_index, raw_img):
    """Sanitizes personal data and ensures 100% authentic brand consistency."""
    img = raw_img.copy().convert('RGBA')
    draw = ImageDraw.Draw(img)
    
    # Clean status bar for all screens
    render_clean_status_bar(draw, 1080, 115, (251, 249, 244, 255))
    
    if slide_index == 1:
        # 1. Mask avatar and replace with OE brand badge
        draw.rectangle([90, 395, 220, 525], fill=(255, 255, 255, 255))
        draw.rounded_rectangle([96, 400, 212, 516], radius=24, fill=LIME, outline=INK, width=5)
        oe_font = ImageFont.truetype(FONT_HEAVY, 48)
        draw.text((122, 432), "OE", font=oe_font, fill=INK)
        
        # 2. Mask 'Halo, Ahmad Badawi' and replace with 'Halo, Sahabat Sehat!'
        # Aligned precisely with 'Yuk' (starts at X = 261)
        draw.rectangle([236, 415, 750, 480], fill=(255, 255, 255, 255))
        greet_font = ImageFont.truetype(FONT_BOLD, 44)
        draw.text((261, 422), "Halo, Sahabat Sehat!", font=greet_font, fill=INK)
        
    elif slide_index == 4:
        # Authentic meal history: keep real screen with single meal card untouched
        pass
        
    elif slide_index == 5:
        # 1. Mask email in recess pill: 'Akun: abadawibadawi000@gmail.com'
        # Envelope icon ends at X: 170. Wipe starts safely at X: 175 to protect the icon completely!
        draw.rectangle([175, 620, 750, 680], fill=(240, 236, 225, 255))
        email_font = ImageFont.truetype(FONT_MEDIUM, 28)
        draw.text((192, 634), "Akun: user@oopsieeats.app", font=email_font, fill=(74, 74, 74, 255))
        
        # 2. Mask name field inside input box: 'Ahmad Badawi' -> 'Pengguna OopsieEats'
        draw.rectangle([230, 960, 750, 1030], fill=(255, 255, 255, 255))
        name_font = ImageFont.truetype(FONT_BOLD, 42)
        draw.text((245, 974), "Pengguna OopsieEats", font=name_font, fill=INK)
        
    elif slide_index == 6:
        # 1. Mask author 'Tim Gizi NutriView' -> 'Tim Gizi OopsieEats'
        draw.rectangle([140, 1335, 480, 1390], fill=(255, 255, 255, 255))
        author_font = ImageFont.truetype(FONT_MEDIUM, 30)
        draw.text((150, 1344), "Tim Gizi OopsieEats", font=author_font, fill=(74, 74, 74, 255))
        
    return img

def create_floating_sticker(text, icon_type, bg_color, text_color=INK, border_color=INK, rotation=0):
    """Creates a tactile Neo-Brutalist sticker with crisp vector icon, solid shadow, and rotation."""
    font = ImageFont.truetype(FONT_BOLD, 23)
    bbox = font.getbbox(text)
    text_w = bbox[2] - bbox[0]
    
    icon_w = 30
    w = text_w + icon_w + 36
    h = 46
    
    pad = 28
    img = Image.new('RGBA', (w + pad * 2, h + pad * 2), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    cx = pad
    cy = pad
    # Solid 5px offset shadow
    d.rounded_rectangle([cx + 5, cy + 5, cx + w + 5, cy + h + 5], radius=10, fill=border_color)
    # Sticker pill
    d.rounded_rectangle([cx, cy, cx + w, cy + h], radius=10, fill=bg_color, outline=border_color, width=3)
    
    # Draw vector icon
    icon_center_x = cx + 20
    icon_center_y = cy + h // 2
    if icon_type == 'bolt':
        draw_bolt(d, icon_center_x, icon_center_y, size=19, fill=text_color)
    elif icon_type == 'star':
        draw_star(d, icon_center_x, icon_center_y, size=17, fill=text_color)
    elif icon_type == 'target':
        draw_target(d, icon_center_x, icon_center_y, size=17, fill=text_color)
    
    # Text
    d.text((cx + icon_w + 12, cy + 10), text, font=font, fill=text_color)
    
    if rotation != 0:
        img = img.rotate(rotation, expand=True, resample=Image.Resampling.BICUBIC)
    
    return img

def render_slide(config):
    """Renders a single 1080x1920 Play Store promotional screenshot."""
    canvas = Image.new('RGB', (1080, 1920), config['bg_canvas'])
    draw = ImageDraw.Draw(canvas)
    
    # 1. Subtle Neo-Brutalist decorative dot matrix in top right
    dot_color = config.get('dot_color', (225, 221, 212))
    for dx in range(840, 1030, 24):
        for dy in range(60, 240, 24):
            draw.ellipse([dx, dy, dx + 4, dy + 4], fill=dot_color)
            
    # Micro geometric sparkle
    draw_star(draw, 980, 310, size=20, fill=config['badge_bg'])
    
    # 2. Header Badge Chip
    chip_font = ImageFont.truetype(FONT_BOLD, 21)
    chip_text = config['badge_text']
    chip_bbox = chip_font.getbbox(chip_text)
    chip_w = chip_bbox[2] - chip_bbox[0] + 48
    chip_h = 42
    chip_x = 70
    chip_y = 65
    
    # Chip shadow & body
    draw.rounded_rectangle([chip_x + 5, chip_y + 5, chip_x + chip_w + 5, chip_y + chip_h + 5], radius=8, fill=INK)
    draw.rounded_rectangle([chip_x, chip_y, chip_x + chip_w, chip_y + chip_h], radius=8, fill=config['badge_bg'], outline=INK, width=3)
    draw_star(draw, chip_x + 20, chip_y + 21, size=12, fill=config.get('badge_star_color', INK))
    draw.text((chip_x + 32, chip_y + 9), chip_text, font=chip_font, fill=config.get('badge_text_color', INK))
    
    # 3. Main Headline
    title_font = ImageFont.truetype(FONT_HEAVY, 52)
    h_lines = config['headline']
    draw.text((70, 130), h_lines[0], font=title_font, fill=INK)
    draw.text((70, 198), h_lines[1], font=title_font, fill=INK)
    
    # 4. Supporting Copy
    desc_font = ImageFont.truetype(FONT_BOOK, 23)
    s_lines = config['subtitle']
    draw.text((70, 280), s_lines[0], font=desc_font, fill=(74, 74, 74))
    draw.text((70, 314), s_lines[1], font=desc_font, fill=(74, 74, 74))
    
    # 5. Load and Sanitize Physical Device Screenshot
    raw_path = os.path.join(RAW_DIR, config['raw_file'])
    raw_img = Image.open(raw_path)
    clean_screen = sanitize_screenshot(config['slide_num'], raw_img)
    
    # 6. Smartphone Mockup Framing
    phone_w = 860
    phone_x = (1080 - phone_w) // 2 # 110
    phone_y = 395
    phone_h = 1920 - phone_y + 70 # Extends slightly past bottom edge
    bezel = 16
    screen_w = phone_w - (bezel * 2) # 828
    screen_x = phone_x + bezel
    screen_y = phone_y + bezel
    
    # Scale screenshot to fit inside chassis
    scale = screen_w / 1080.0
    scaled_h = int(2460 * scale)
    scaled_screen = clean_screen.resize((screen_w, scaled_h), Image.Resampling.LANCZOS)
    
    # Draw Chassis Hard Shadow
    draw.rounded_rectangle(
        [phone_x + 10, phone_y + 10, phone_x + phone_w + 10, phone_y + phone_h + 10],
        radius=50,
        fill=INK
    )
    
    # Draw Chassis Bezel Body (Deep Titanium Graphite)
    draw.rounded_rectangle(
        [phone_x, phone_y, phone_x + phone_w, phone_y + phone_h],
        radius=50,
        fill=(22, 22, 24),
        outline=INK,
        width=6
    )
    
    # Inner Screen Mask for rounded corners
    screen_crop_h = phone_h - bezel
    screen_crop = scaled_screen.crop((0, 0, screen_w, screen_crop_h))
    
    mask = Image.new('L', (screen_w, screen_crop_h), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, screen_w, screen_crop_h + 40], radius=34, fill=255)
    
    canvas.paste(screen_crop, (screen_x, screen_y), mask)
    
    # Front Camera Punch Hole
    cam_x = 1080 // 2
    cam_y = screen_y + 24
    draw.ellipse([cam_x - 12, cam_y - 12, cam_x + 12, cam_y + 12], fill=(10, 10, 10), outline=(35, 35, 35), width=2)
    draw.ellipse([cam_x - 4, cam_y - 4, cam_x + 1, cam_y + 1], fill=(55, 65, 95))
    
    # 7. Signature Floating Tactile Sticker (Placed with breathing room in header zone)
    st = config['sticker']
    st_img = create_floating_sticker(
        st['text'],
        st.get('icon', 'bolt'),
        st['bg'],
        st.get('fg', INK),
        st.get('border', INK),
        st.get('rot', 0)
    )
    canvas.paste(st_img, (st['x'], st['y']), st_img)
        
    return canvas

# Configuration for all 6 Slides
SLIDES_CONFIG = [
    {
        'slide_num': 1,
        'filename': '01_hero.png',
        'raw_file': '01_home_dashboard.png',
        'bg_canvas': (251, 249, 244), # Warm editorial off-white #FBF9F4
        'dot_color': (226, 222, 212),
        'badge_bg': LIME,
        'badge_text': 'OOPSIEEATS · SMART NUTRITION',
        'headline': ['Pantau Kalori,', 'Bangun Pola Sehat'],
        'subtitle': [
            'Dashboard gizi interaktif real-time. Hitung target',
            'harianmu dengan presisi dan visual yang menyenangkan.'
        ],
        'sticker': {'text': 'REAL-TIME SYNC', 'icon': 'bolt', 'bg': HAZARD, 'rot': 4, 'x': 680, 'y': 250}
    },
    {
        'slide_num': 2,
        'filename': '02_ai_scanner.png',
        'raw_file': '02_ai_scanner_modes.png',
        'bg_canvas': (244, 252, 230), # Soft pale lime
        'dot_color': (218, 235, 195),
        'badge_bg': HAZARD,
        'badge_text': 'AI INSTANT DETECTION',
        'headline': ['Pindai Makanan', 'Dalam Hitungan Detik'],
        'subtitle': [
            'Model AI on-device cepat & akurat tanpa internet.',
            'Didukung ribuan data gizi resmi Kemenkes RI (TKPI).'
        ],
        'sticker': {'text': '100% OFFLINE AI', 'icon': 'bolt', 'bg': CYAN, 'rot': -4, 'x': 680, 'y': 250}
    },
    {
        'slide_num': 3,
        'filename': '03_nutrition_analysis.png',
        'raw_file': '03_nutrition_analysis.png',
        'bg_canvas': (238, 248, 252), # Soft pale cyan/sky
        'dot_color': (205, 230, 240),
        'badge_bg': CYAN,
        'badge_text': 'ACCURATE MACROS',
        'headline': ['Pahami Setiap', 'Asupan Nutrisi'],
        'subtitle': [
            'Analisis otomatis kalori, protein, karbohidrat,',
            'dan lemak lengkap dengan estimasi berat per porsi.'
        ],
        'sticker': {'text': 'PORTION ANALYSIS', 'icon': 'target', 'bg': LIME, 'rot': 4, 'x': 670, 'y': 250}
    },
    {
        'slide_num': 4,
        'filename': '04_meal_history.png',
        'raw_file': '04_meal_history.png',
        'bg_canvas': (245, 240, 255), # Soft bio lilac tint
        'dot_color': (225, 215, 245),
        'badge_bg': LILAC,
        'badge_text': 'DAILY MEAL JOURNAL',
        'headline': ['Catatan Makan', 'Lengkap & Teratur'],
        'subtitle': [
            'Dokumentasikan perjalanan makan harianmu dengan',
            'kartu foto makanan, waktu makan, dan total kalori.'
        ],
        'sticker': {'text': 'TIMELINE HARIAN', 'icon': 'bolt', 'bg': HAZARD, 'rot': -4, 'x': 680, 'y': 250}
    },
    {
        'slide_num': 5,
        'filename': '05_personal_profile.png',
        'raw_file': '05_personal_profile.png',
        'bg_canvas': (255, 245, 238), # Soft warm creamsicle
        'dot_color': (245, 220, 205),
        'badge_bg': TANGERINE,
        'badge_star_color': WHITE,
        'badge_text_color': WHITE,
        'badge_text': 'DETERMINISTIC SCIENCE',
        'headline': ['Dihitung Khusus', 'Sesuai Tubuhmu'],
        'subtitle': [
            'Kalkulasi BMR & TDEE ilmiah rumus Mifflin-St Jeor',
            'berbasis usia, berat, tinggi, dan intensitas fisik.'
        ],
        'sticker': {'text': 'MIFFLIN-ST JEOR', 'icon': 'target', 'bg': LIME, 'rot': 4, 'x': 680, 'y': 250}
    },
    {
        'slide_num': 6,
        'filename': '06_nutrition_articles.png',
        'raw_file': '06_nutrition_articles.png',
        'bg_canvas': (235, 250, 242), # Soft fresh mint
        'dot_color': (200, 235, 215),
        'badge_bg': EMERALD,
        'badge_star_color': WHITE,
        'badge_text_color': WHITE,
        'badge_text': 'NUTRITION KNOWLEDGE',
        'headline': ['Wawasan Gizi &', 'Panduan Pola Hidup'],
        'subtitle': [
            'Kurasi artikel kesehatan berbasis bukti medis dari',
            'ahli gizi tepercaya untuk gaya hidup yang seimbang.'
        ],
        'sticker': {'text': 'EVIDENCE-BASED', 'icon': 'star', 'bg': HAZARD, 'rot': -4, 'x': 680, 'y': 250}
    }
]

def generate_all_slides():
    """Generates all 6 slides and outputs to docs/play_store_assets/final/."""
    rendered_images = []
    print("=== STARTING OOPSIEEATS PLAY STORE ASSETS GENERATION ===")
    for cfg in SLIDES_CONFIG:
        out_file = os.path.join(FINAL_DIR, cfg['filename'])
        print(f"Rendering Slide {cfg['slide_num']}: {cfg['filename']}...")
        slide_img = render_slide(cfg)
        slide_img.save(out_file, format='PNG', optimize=True)
        rendered_images.append(slide_img)
        print(f"  -> Saved {out_file} (1080x1920)")
    return rendered_images

def generate_campaign_overview(rendered_images):
    """Creates a high-resolution agency campaign deck preview poster."""
    print("Generating Campaign Overview Poster...")
    
    overview_w = 2460
    overview_h = 2860
    
    bg_studio = (18, 18, 20)
    overview = Image.new('RGB', (overview_w, overview_h), bg_studio)
    draw = ImageDraw.Draw(overview)
    
    # Studio Header Background Bar
    draw.rectangle([0, 0, overview_w, 240], fill=(26, 26, 30))
    draw.line([0, 240, overview_w, 240], fill=(45, 45, 52), width=3)
    
    # Top Tag 1: Campaign
    tag_font = ImageFont.truetype(FONT_BOLD, 24)
    draw.rounded_rectangle([80, 45, 520, 85], radius=6, fill=LIME)
    draw.text((95, 52), "✦ GOOGLE PLAY STORE CAMPAIGN", font=tag_font, fill=INK)
    
    # Top Tag 2: Release Candidate
    rc_font = ImageFont.truetype(FONT_BOLD, 22)
    draw.rounded_rectangle([540, 45, 870, 85], radius=6, fill=HAZARD)
    draw.text((555, 54), "RELEASE CANDIDATE 1 (RC1)", font=rc_font, fill=INK)
    
    # Header Title
    head_font = ImageFont.truetype(FONT_HEAVY, 64)
    draw.text((80, 105), "OopsieEats — Promotional Visual Set", font=head_font, fill=WHITE)
    
    # Metadata Right
    meta_font = ImageFont.truetype(FONT_MEDIUM, 22)
    draw.text((1550, 60), "Canvas: 1080 × 1920 px (9:16 Portrait)", font=meta_font, fill=(180, 180, 190))
    draw.text((1550, 95), "Device: Physical Redmi 12 (Android 15)", font=meta_font, fill=(180, 180, 190))
    draw.text((1550, 130), "Design: Overkill Neo-Brutalism System", font=meta_font, fill=LIME)
    
    # Placement Grid: 3 columns x 2 rows
    cell_w = 680
    cell_h = int(1920 * (cell_w / 1080.0)) # 1208 px
    gap_x = 90
    gap_y = 70
    start_x = 80
    start_y = 290
    
    slide_labels = [
        "01 · Real-Time Dashboard",
        "02 · Instant AI Camera",
        "03 · Accurate Macro Breakdown",
        "04 · Daily Meal Journal",
        "05 · Deterministic BMR & TDEE",
        "06 · Nutrition Knowledge"
    ]
    
    label_font = ImageFont.truetype(FONT_BOLD, 22)
    
    for idx, img in enumerate(rendered_images):
        col = idx % 3
        row = idx // 3
        
        pos_x = start_x + col * (cell_w + gap_x)
        pos_y = start_y + row * (cell_h + gap_y + 40)
        
        # Scale slide
        thumb = img.resize((cell_w, cell_h), Image.Resampling.LANCZOS)
        
        # Hard drop shadow behind each slide
        draw.rounded_rectangle(
            [pos_x + 10, pos_y + 10, pos_x + cell_w + 10, pos_y + cell_h + 10],
            radius=20,
            fill=(10, 10, 12)
        )
        # Border around thumb
        draw.rounded_rectangle(
            [pos_x - 3, pos_y - 3, pos_x + cell_w + 3, pos_y + cell_h + 3],
            radius=20,
            fill=(45, 45, 52)
        )
        overview.paste(thumb, (pos_x, pos_y))
        
        # Slide label below thumb
        draw.text((pos_x + 10, pos_y + cell_h + 14), slide_labels[idx], font=label_font, fill=(220, 220, 230))
        
    preview_file = os.path.join(PREVIEW_DIR, 'campaign_overview.png')
    overview.save(preview_file, format='PNG', optimize=True)
    print(f"  -> Saved {preview_file} ({overview_w}x{overview_h})")

if __name__ == '__main__':
    images = generate_all_slides()
    generate_campaign_overview(images)
    print("=== ALL PROMOTIONAL ASSETS GENERATED SUCCESSFULLY ===")
