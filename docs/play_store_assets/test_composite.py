import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# Paths
raw_dir = '/home/ahmadbadawi/Documents/CodinganKu/Flutter/OopsieEats/docs/play_store_assets/raw'
out_path = '/tmp/test_slide_01.png'

# Fonts
FONT_HEAVY = '/usr/share/fonts/opentype/fira/FiraSans-Heavy.otf'
FONT_BOLD = '/usr/share/fonts/opentype/fira/FiraSans-Bold.otf'
FONT_SEMIBOLD = '/usr/share/fonts/opentype/fira/FiraSans-SemiBold.otf'
FONT_REGULAR = '/usr/share/fonts/opentype/fira/FiraSans-Book.otf'

# Colors
C_BG = (251, 249, 244) # Warm canvas #FBF9F4
C_INK = (17, 17, 17)    # #111111
C_WHITE = (255, 255, 255)
C_LIME = (204, 255, 0)  # #CCFF00
C_HAZARD = (255, 214, 0) # #FFD600
C_MUTED = (100, 100, 100)

# Create 1080 x 1920 canvas
canvas = Image.new('RGB', (1080, 1920), C_BG)
draw = ImageDraw.Draw(canvas)

# 1. Subtle decorative background grid / dot pattern or retro accent
# Clean neo-brutalist subtle dotted matrix in upper right
for dx in range(860, 1040, 24):
    for dy in range(60, 240, 24):
        draw.ellipse([dx, dy, dx+4, dy+4], fill=(225, 221, 212))

# 2. Header Badge Chip
chip_font = ImageFont.truetype(FONT_BOLD, 22)
chip_text = "✦ OOPSIEEATS · SMART NUTRITION"
chip_bbox = chip_font.getbbox(chip_text)
chip_w = chip_bbox[2] - chip_bbox[0] + 36
chip_h = 44
chip_x = 70
chip_y = 65

# Chip hard shadow
draw.rounded_rectangle([chip_x + 5, chip_y + 5, chip_x + chip_w + 5, chip_y + chip_h + 5], radius=10, fill=C_INK)
# Chip body
draw.rounded_rectangle([chip_x, chip_y, chip_x + chip_w, chip_y + chip_h], radius=10, fill=C_LIME, outline=C_INK, width=3)
draw.text((chip_x + 18, chip_y + 10), chip_text, font=chip_font, fill=C_INK)

# 3. Main Headline
title_font = ImageFont.truetype(FONT_HEAVY, 52)
line1 = "Pantau Kalori Harian,"
line2 = "Bangun Pola Hidup Sehat"
draw.text((70, 135), line1, font=title_font, fill=C_INK)
draw.text((70, 205), line2, font=title_font, fill=C_INK)

# 4. Supporting Copy
desc_font = ImageFont.truetype(FONT_REGULAR, 23)
desc1 = "Dashboard gizi personal real-time dengan target terukur."
desc2 = "Catat makanan otomatis & pantau nutrisi harian secara cerdas."
draw.text((70, 290), desc1, font=desc_font, fill=(70, 70, 70))
draw.text((70, 325), desc2, font=desc_font, fill=(70, 70, 70))

# 5. Sanitize and prepare raw screenshot
raw_im = Image.open(f'{raw_dir}/01_home_dashboard.png').convert('RGBA')
raw_draw = ImageDraw.Draw(raw_im)

# Clean Status Bar: draw clean status bar background and icons
# Status bar area: Y 0 to 115
raw_draw.rectangle([0, 0, 1080, 115], fill=(251, 249, 244, 255))
sb_font = ImageFont.truetype(FONT_BOLD, 36)
raw_draw.text((80, 48), "09:41", font=sb_font, fill=(17, 17, 17, 255))

# Draw clean battery & wifi on right
# Battery icon
bx, by = 920, 52
raw_draw.rounded_rectangle([bx, by, bx + 64, by + 32], radius=6, outline=(17, 17, 17, 255), width=3)
raw_draw.rectangle([bx + 64, by + 10, bx + 68, by + 22], fill=(17, 17, 17, 255))
raw_draw.rounded_rectangle([bx + 4, by + 4, bx + 50, by + 28], radius=3, fill=(17, 17, 17, 255))
# Wifi arcs / indicator
wx, wy = 860, 52
raw_draw.ellipse([wx + 10, wy + 20, wx + 16, wy + 26], fill=(17, 17, 17, 255))
raw_draw.arc([wx + 4, wy + 12, wx + 22, wy + 30], start=210, end=330, fill=(17, 17, 17, 255), width=3)
raw_draw.arc([wx - 2, wy + 4, wx + 28, wy + 34], start=210, end=330, fill=(17, 17, 17, 255), width=3)

# Sanitize Greeting Card:
# Replace "AB" avatar with OopsieEats brand badge
raw_draw.rounded_rectangle([92, 335, 218, 460], radius=24, fill=(204, 255, 0, 255), outline=(17, 17, 17, 255), width=5)
# Draw mini apple or "OE"
oe_font = ImageFont.truetype(FONT_HEAVY, 48)
raw_draw.text((120, 368), "OE", font=oe_font, fill=(17, 17, 17, 255))

# Mask "Halo, Ahmad Badawi"
raw_draw.rectangle([250, 355, 760, 430], fill=(255, 255, 255, 255))
greet_font = ImageFont.truetype(FONT_BOLD, 46)
raw_draw.text((250, 360), "Halo, Sahabat Sehat!", font=greet_font, fill=(17, 17, 17, 255))

# 6. Phone Mockup Dimensions
# Phone chassis
phone_w = 860
phone_x = (1080 - phone_w) // 2 # 110
phone_y = 410
phone_h = 1920 - phone_y + 60 # extends slightly off bottom
bezel = 16
screen_w = phone_w - (bezel * 2) # 828
screen_x = phone_x + bezel
screen_y = phone_y + bezel

# Scale screenshot to screen_w
scale = screen_w / 1080.0
scaled_h = int(2460 * scale)
scaled_screen = raw_im.resize((screen_w, scaled_h), Image.Resampling.LANCZOS)

# Create phone frame with shadow
# Hard shadow
draw.rounded_rectangle(
    [phone_x + 10, phone_y + 10, phone_x + phone_w + 10, phone_y + phone_h + 10],
    radius=48,
    fill=C_INK
)
# Chassis body
draw.rounded_rectangle(
    [phone_x, phone_y, phone_x + phone_w, phone_y + phone_h],
    radius=48,
    fill=(22, 22, 24), # Sleek dark graphite
    outline=C_INK,
    width=6
)

# Screen mask for rounded corners
screen_crop_h = phone_h - bezel
screen_crop = scaled_screen.crop((0, 0, screen_w, screen_crop_h))

mask = Image.new('L', (screen_w, screen_crop_h), 0)
mask_draw = ImageDraw.Draw(mask)
mask_draw.rounded_rectangle([0, 0, screen_w, screen_crop_h + 40], radius=34, fill=255)

canvas.paste(screen_crop, (screen_x, screen_y), mask)

# Front Camera Punch Hole
cam_x = 1080 // 2
cam_y = screen_y + 24
draw.ellipse([cam_x - 12, cam_y - 12, cam_x + 12, cam_y + 12], fill=(12, 12, 12), outline=(30, 30, 30), width=2)
# Tiny camera lens reflex
draw.ellipse([cam_x - 3, cam_y - 3, cam_x + 1, cam_y + 1], fill=(50, 60, 90))

# 7. Add Floating Neo-Brutalist Sticker / Badge
sticker_text = "100% REAL-TIME ⚡"
st_font = ImageFont.truetype(FONT_BOLD, 22)
st_bbox = st_font.getbbox(sticker_text)
st_w = st_bbox[2] - st_bbox[0] + 32
st_h = 44
st_x = 730
st_y = 480

# Sticker shadow & body with angle/rotation!
st_img = Image.new('RGBA', (st_w + 20, st_h + 20), (0, 0, 0, 0))
st_draw = ImageDraw.Draw(st_img)
st_draw.rounded_rectangle([4, 4, st_w + 4, st_h + 4], radius=8, fill=(17, 17, 17, 255))
st_draw.rounded_rectangle([0, 0, st_w, st_h], radius=8, fill=(255, 214, 0, 255), outline=(17, 17, 17, 255), width=3)
st_draw.text((16, 10), sticker_text, font=st_font, fill=(17, 17, 17, 255))

# Rotate sticker by -6 degrees for playful tactile energy
st_rot = st_img.rotate(6, expand=True, resample=Image.Resampling.BICUBIC)
canvas.paste(st_rot, (st_x, st_y), st_rot)

# Save
canvas.save(out_path, format='PNG')
print('Saved', out_path)
