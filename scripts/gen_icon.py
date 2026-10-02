"""Generate RescataPet EC app icon as 512x512 PNG using Pillow."""
from PIL import Image, ImageDraw, ImageFont
import math, sys, os

W = 512
img = Image.new('RGBA', (W, W), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Rounded rectangle background (orange gradient simulated as solid)
# Using the primary brand color EA580C
bg_color = (234, 88, 12)  # #EA580C
# Draw rounded rect
r = 108
draw.rounded_rectangle([0, 0, W-1, W-1], radius=r, fill=bg_color)

# Add a lighter overlay on top-left for gradient feel
overlay = Image.new('RGBA', (W, W), (0, 0, 0, 0))
od = ImageDraw.Draw(overlay)
for i in range(W):
    alpha = int(60 * (1 - i / W))  # fades from top
    od.line([(0, i), (W, i)], fill=(255, 180, 100, alpha))
# Clip overlay to rounded rect
mask = Image.new('L', (W, W), 0)
md = ImageDraw.Draw(mask)
md.rounded_rectangle([0, 0, W-1, W-1], radius=r, fill=255)
overlay.putalpha(Image.composite(overlay.split()[3], Image.new('L', (W, W), 0), mask))
img = Image.alpha_composite(img, overlay)
draw = ImageDraw.Draw(img)

# Draw paw print (white) centered
cx, cy_base = W // 2, 230

def draw_ellipse(center_x, center_y, rx, ry, angle_deg=0):
    """Draw a rotated filled ellipse."""
    ew, eh = rx * 2, ry * 2
    ellipse_img = Image.new('RGBA', (ew + 4, eh + 4), (0, 0, 0, 0))
    ed = ImageDraw.Draw(ellipse_img)
    ed.ellipse([2, 2, ew + 2, eh + 2], fill=(255, 255, 255, 245))
    if angle_deg != 0:
        ellipse_img = ellipse_img.rotate(-angle_deg, expand=True, resample=Image.BICUBIC)
    pw, ph = ellipse_img.size
    pos = (center_x - pw // 2, center_y - ph // 2)
    img.paste(ellipse_img, pos, ellipse_img)

# Main pad
draw_ellipse(cx, cy_base + 52, 62, 50)
# Top-left toe
draw_ellipse(cx - 58, cy_base - 18, 28, 34, -12)
# Top-right toe
draw_ellipse(cx + 58, cy_base - 18, 28, 34, 12)
# Inner-left toe
draw_ellipse(cx - 22, cy_base - 52, 24, 30, -5)
# Inner-right toe
draw_ellipse(cx + 22, cy_base - 52, 24, 30, 5)

# Location pin at bottom-right
pin_cx, pin_cy = 340, 345
draw = ImageDraw.Draw(img)
# Pin body (teardrop-ish using circle + triangle)
pin_r = 22
draw.ellipse([pin_cx - pin_r, pin_cy - pin_r - 6, pin_cx + pin_r, pin_cy + pin_r - 6],
             fill=(255, 255, 255, 230))
draw.polygon([(pin_cx - 14, pin_cy + 8), (pin_cx, pin_cy + 34), (pin_cx + 14, pin_cy + 8)],
             fill=(255, 255, 255, 230))
# Inner dot (orange)
draw.ellipse([pin_cx - 8, pin_cy - 12, pin_cx + 8, pin_cy + 4], fill=bg_color)

# Text "RESCATA" at bottom
try:
    font = ImageFont.truetype("arial.ttf", 42)
except:
    try:
        font = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 42)
    except:
        font = ImageFont.load_default()
draw.text((W // 2, 452), "RESCATA", fill=(255, 255, 255, 240), font=font, anchor="mm")

# Save
out = os.path.join(os.path.dirname(__file__), '..', 'rescatapet_mobile', 'assets', 'app_icon_512.png')
img.save(out, 'PNG')
print(f"Icon saved to {out}")
# Also save a copy for the android adaptive icon foreground (should be on transparent bg but
# for a simple approach the full icon works)
print("Done!")
