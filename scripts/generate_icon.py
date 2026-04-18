# ABOUTME: Generates Gasolina app icon PNG files for Android and iOS platforms
# ABOUTME: Draws a fuel gauge with needle in dark automotive style, matching the splash screen

import math
import os
import sys

try:
    from PIL import Image, ImageDraw
except ImportError:
    print("Pillow not found. Installing...")
    os.system(f"{sys.executable} -m pip install Pillow")
    from PIL import Image, ImageDraw


# ── Color palette (matches splash screen) ────────────────────────────────────

BG_TOP    = (10, 15, 30)
BG_BOTTOM = (19, 27, 53)
WHITE     = (255, 255, 255, 255)
ORANGE    = (255, 152, 0, 255)
AMBER     = (255, 193, 7, 255)
GREEN     = (76, 175, 80, 255)
TRACK_CLR = (255, 255, 255, 25)
GLASS     = (79, 195, 247, 100)


def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(4))


def draw_rounded_rect_mask(draw, size, radius):
    """Return a mask image with a rounded rectangle."""
    mask = Image.new("L", (size, size), 0)
    md = ImageDraw.Draw(mask)
    md.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return mask


def draw_thick_arc(draw, cx, cy, radius, arc_w, start_deg, end_deg, color, steps=200):
    """Simulate a thick arc by drawing many thin wedge-like lines."""
    for i in range(steps + 1):
        angle = math.radians(start_deg + (end_deg - start_deg) * i / steps)
        r_inner = radius - arc_w / 2
        r_outer = radius + arc_w / 2
        x0 = cx + r_inner * math.cos(angle)
        y0 = cy + r_inner * math.sin(angle)
        x1 = cx + r_outer * math.cos(angle)
        y1 = cy + r_outer * math.sin(angle)
        draw.line([(x0, y0), (x1, y1)], fill=color, width=max(1, int(arc_w / steps * 3)))


def create_icon(size=1024):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))

    # ── Gradient background ───────────────────────────────────────────────
    bg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg)
    for y in range(size):
        t = y / size
        r = int(BG_TOP[0] + (BG_BOTTOM[0] - BG_TOP[0]) * t)
        g = int(BG_TOP[1] + (BG_BOTTOM[1] - BG_TOP[1]) * t)
        b = int(BG_TOP[2] + (BG_BOTTOM[2] - BG_TOP[2]) * t)
        bg_draw.line([(0, y), (size - 1, y)], fill=(r, g, b, 255))

    # Apply rounded-rectangle mask (same corner radius ratio as Android adaptive icons)
    corner_r = int(size * 0.22)
    mask = draw_rounded_rect_mask(bg_draw, size, corner_r)
    bg.putalpha(mask)
    img.paste(bg, (0, 0), bg)

    draw = ImageDraw.Draw(img)

    # ── Gauge geometry ────────────────────────────────────────────────────
    cx = size * 0.50
    cy = size * 0.54          # slightly below center for visual balance
    gauge_r = size * 0.30
    arc_w   = size * 0.075

    START_DEG = 135.0         # 135° = lower-left
    SWEEP_DEG = 270.0         # full sweep
    FUEL      = 0.68          # needle position (68% full)

    # Track (background arc)
    draw_thick_arc(draw, cx, cy, gauge_r, arc_w,
                   START_DEG, START_DEG + SWEEP_DEG, TRACK_CLR)

    # Colored fill arc — green → amber → orange gradient
    fill_segments = 60
    fill_end = START_DEG + SWEEP_DEG * FUEL
    for i in range(fill_segments):
        t_seg = i / fill_segments
        if t_seg >= FUEL:
            break
        seg_start = START_DEG + SWEEP_DEG * t_seg
        seg_end   = START_DEG + SWEEP_DEG * ((i + 1) / fill_segments)

        # Interpolate color
        norm = t_seg / FUEL
        if norm < 0.5:
            color = lerp_color((*GREEN[:3], 255), (*AMBER[:3], 255), norm * 2)
        else:
            color = lerp_color((*AMBER[:3], 255), (*ORANGE[:3], 255), (norm - 0.5) * 2)

        draw_thick_arc(draw, cx, cy, gauge_r, arc_w, seg_start, seg_end, color, steps=6)

    # ── Needle ────────────────────────────────────────────────────────────
    needle_angle = math.radians(START_DEG + SWEEP_DEG * FUEL)
    needle_len   = gauge_r * 0.72
    n_x = cx + needle_len * math.cos(needle_angle)
    n_y = cy + needle_len * math.sin(needle_angle)
    draw.line([(cx, cy), (n_x, n_y)], fill=WHITE, width=int(size * 0.022))

    # Pivot circle
    piv_r = int(size * 0.038)
    draw.ellipse(
        [cx - piv_r, cy - piv_r, cx + piv_r, cy + piv_r],
        fill=WHITE,
    )
    inner_r = int(size * 0.022)
    draw.ellipse(
        [cx - inner_r, cy - inner_r, cx + inner_r, cy + inner_r],
        fill=BG_BOTTOM + (255,),
    )

    # ── Fuel drop below gauge ─────────────────────────────────────────────
    drop_cx   = cx
    drop_tip  = cy + gauge_r * 0.55     # top point of drop
    drop_bot  = cy + gauge_r * 0.98     # widest point / bottom
    drop_hw   = size * 0.065            # half-width

    drop_poly = [
        (drop_cx,           drop_tip),
        (drop_cx + drop_hw, drop_tip + (drop_bot - drop_tip) * 0.60),
        (drop_cx + drop_hw * 0.72, drop_bot),
        (drop_cx - drop_hw * 0.72, drop_bot),
        (drop_cx - drop_hw, drop_tip + (drop_bot - drop_tip) * 0.60),
    ]
    # Glow
    glow_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_img)
    for expand in range(12, 0, -1):
        alpha = int(20 * (1 - expand / 12))
        expanded = [(x + math.cos(math.atan2(y - drop_bot, x - drop_cx)) * expand,
                     y + math.sin(math.atan2(y - drop_bot, x - drop_cx)) * expand)
                    for (x, y) in drop_poly]
        glow_draw.polygon(expanded, fill=(255, 152, 0, alpha))
    img = Image.alpha_composite(img, glow_img)
    draw = ImageDraw.Draw(img)

    draw.polygon(drop_poly, fill=(255, 152, 0, 230))
    # Highlight on drop
    hi_x = drop_cx - drop_hw * 0.28
    hi_y = drop_tip + (drop_bot - drop_tip) * 0.28
    hi_r = drop_hw * 0.22
    draw.ellipse(
        [hi_x - hi_r, hi_y - hi_r, hi_x + hi_r, hi_y + hi_r],
        fill=(255, 255, 255, 80),
    )

    # ── E / F tick labels ────────────────────────────────────────────────
    label_r = gauge_r * 1.20
    for label_text, angle_deg in [("E", START_DEG - 2), ("F", START_DEG + SWEEP_DEG + 2)]:
        a = math.radians(angle_deg)
        lx = cx + label_r * math.cos(a)
        ly = cy + label_r * math.sin(a)
        font_size = int(size * 0.055)
        # Draw label as simple text-like shape (circle placeholder for 'E'/'F')
        # Use PIL default font since system fonts vary
        draw.ellipse(
            [lx - font_size // 2, ly - font_size // 2,
             lx + font_size // 2, ly + font_size // 2],
            fill=(255, 255, 255, 0),  # transparent — just a guide
        )
        try:
            from PIL import ImageFont
            font = ImageFont.truetype("arialbd.ttf", font_size)
        except Exception:
            try:
                font = ImageFont.truetype("arial.ttf", font_size)
            except Exception:
                font = ImageFont.load_default(font_size)
        draw.text((lx - font_size // 3, ly - font_size // 2),
                  label_text, fill=(255, 255, 255, 100), font=font)

    # ── Outer glow ring ───────────────────────────────────────────────────
    for glow_offset in range(8, 0, -2):
        alpha = int(12 * glow_offset)
        draw.arc(
            [cx - gauge_r - glow_offset, cy - gauge_r - glow_offset,
             cx + gauge_r + glow_offset, cy + gauge_r + glow_offset],
            start=START_DEG, end=START_DEG + SWEEP_DEG * FUEL,
            fill=(255, 152, 0, alpha),
            width=int(arc_w + glow_offset * 2),
        )

    return img


# ── Output sizes ──────────────────────────────────────────────────────────────

ANDROID_SIZES = {
    "mipmap-mdpi":    48,
    "mipmap-hdpi":    72,
    "mipmap-xhdpi":   96,
    "mipmap-xxhdpi":  144,
    "mipmap-xxxhdpi": 192,
}


def save_icons(base_img, project_dir):
    # Android launcher icons
    android_res = os.path.join(project_dir, "android", "app", "src", "main", "res")
    for folder, px in ANDROID_SIZES.items():
        out_dir = os.path.join(android_res, folder)
        os.makedirs(out_dir, exist_ok=True)
        resized = base_img.resize((px, px), Image.LANCZOS)
        # Flatten alpha onto the background color for Android PNG
        flat = Image.new("RGB", (px, px), BG_TOP)
        flat.paste(resized, (0, 0), resized)
        flat.save(os.path.join(out_dir, "ic_launcher.png"), "PNG")
        print(f"  Android {folder}: {px}×{px}px")

    # Reference asset (1024×1024, transparent background)
    assets_dir = os.path.join(project_dir, "assets", "icon")
    os.makedirs(assets_dir, exist_ok=True)
    base_img.save(os.path.join(assets_dir, "app_icon.png"), "PNG")
    print(f"  Reference icon: assets/icon/app_icon.png (1024×1024)")


if __name__ == "__main__":
    script_dir  = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.dirname(script_dir)

    print("Generating Gasolina app icon...")
    icon = create_icon(1024)
    save_icons(icon, project_dir)
    print("Done.")
