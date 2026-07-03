#!/usr/bin/env python3
"""Generate README banner PNGs (GitHub-reliable, no external CDN)."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "assets"
WIDTH, HEIGHT = 1200, 220


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def gradient_bg(w: int, h: int) -> Image.Image:
    img = Image.new("RGB", (w, h))
    px = img.load()
    for y in range(h):
        t = y / max(h - 1, 1)
        r = lerp(1, 26, t)
        g = lerp(36, 74, t)
        b = lerp(86, 138, t)
        for x in range(w):
            tx = x / max(w - 1, 1)
            r2 = lerp(r, 0, tx * 0.15)
            g2 = lerp(g, 201, tx * 0.12)
            b2 = lerp(b, 167, tx * 0.12)
            px[x, y] = (r2, g2, b2)
    return img


def pick_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
    ]
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def draw_banner() -> None:
    ASSETS.mkdir(parents=True, exist_ok=True)
    img = gradient_bg(WIDTH, HEIGHT)
    draw = ImageDraw.Draw(img)

    # Accent bar
    draw.rounded_rectangle((80, HEIGHT - 18, WIDTH - 80, HEIGHT - 10), radius=4, fill=(0, 201, 167))

    title_font = pick_font(56, bold=True)
    sub_font = pick_font(24)
    tag_font = pick_font(20)

    draw.text((WIDTH // 2, 72), "PowerShell Paradise", fill=(240, 246, 255), font=title_font, anchor="mm")
    draw.text((WIDTH // 2, 128), "Discover  ·  Learn  ·  Stay Current", fill=(94, 169, 255), font=sub_font, anchor="mm")
    draw.text((WIDTH // 2, 168), "Your daily PowerShell repository newsfeed", fill=(184, 212, 240), font=tag_font, anchor="mm")

    img.save(ASSETS / "banner.png", optimize=True)
    print(f"Wrote {ASSETS / 'banner.png'}")


if __name__ == "__main__":
    draw_banner()
