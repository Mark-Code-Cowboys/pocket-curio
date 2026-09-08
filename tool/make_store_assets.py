#!/usr/bin/env python3
"""Builds every store graphic from the icon art and the raw screenshots.

    python3 tool/make_store_assets.py

Inputs
  assets/icon/icon.png, icon_foreground.png   (tool/make_icon.py)
  docs/store-assets/raw/phone/NN-name.png     1080×2400 (Pixel 7 class)
  docs/store-assets/raw/tablet/NN-name.png    2064×2752 (13" iPad class)

Outputs (docs/store-assets/)
  store-icon-512.png              Play hi-res icon, 32-bit PNG
  app-store-icon-1024.png         App Store icon, no alpha
  feature-graphic.png             Play feature graphic, 1024×500
  play/phone/                     captioned 1080×2400
  play/tablet-10/                 raw 2064×2752 (3:4, within Play's range)
  app-store/iphone-6.9/           captioned 1320×2868
  app-store/iphone-6.5/           captioned 1284×2778
  app-store/ipad-13/              raw 2064×2752

Captions come from docs/play-store-listing.md — keep CAPTIONS in step.
"""
from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
from make_icon import CREAM, VIOLET, draw_tag  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "docs" / "store-assets"
RAW = ASSETS / "raw"

VIOLET_DEEP = (0x5C, 0x37, 0x60, 255)
VIOLET_RGB = VIOLET[:3]
CREAM_RGB = CREAM[:3]
BEZEL = (0x2A, 0x22, 0x2B)

BLACK = "/usr/share/fonts/noto/NotoSans-Black.ttf"
BOLD = "/usr/share/fonts/noto/NotoSans-Bold.ttf"
MEDIUM = "/usr/share/fonts/noto/NotoSans-Medium.ttf"

# Screenshot order tells the product story (play-store-listing.md).
CAPTIONS = {
    "01-collection-grid": "The shelf you can carry.",
    "02-map": "Watch the world fill in.",
    "03-shelf-scan": "One photo of the whole fridge.\nBox each one. Done.",
    "04-memory": "Who gave it to you.\nThe trip. The day.",
    "05-composer": "Photo, place, done.\nUnder ten seconds.",
    "06-collections-home": "One phone. Everyone’s shelf.",
    "07-shelf-review": "Reads what’s printed.\nYou check the spelling.",
}


def font(path: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(path, size)


def gradient(size: tuple[int, int], top: tuple, bottom: tuple) -> Image.Image:
    """Vertical gradient, top colour to bottom colour."""
    w, h = size
    strip = Image.new("RGB", (1, h))
    px = strip.load()
    for y in range(h):
        t = y / max(h - 1, 1)
        px[0, y] = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
    return strip.resize((w, h))


def tag_mark(size: int) -> Image.Image:
    """The luggage-tag mark alone, transparent, drawn at `size` px."""
    big = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    draw_tag(big, 1.0)
    return big.resize((size, size), Image.LANCZOS)


# --- icons -----------------------------------------------------------------

def icons() -> None:
    icon = Image.open(ROOT / "assets" / "icon" / "icon.png").convert("RGBA")
    icon.resize((512, 512), Image.LANCZOS).save(ASSETS / "store-icon-512.png")
    icon.convert("RGB").save(ASSETS / "app-store-icon-1024.png")


# --- feature graphic -------------------------------------------------------

def feature_graphic() -> None:
    w, h = 1024, 500
    img = gradient((w, h), VIOLET_RGB, VIOLET_DEEP[:3]).convert("RGBA")
    # Ghost place-dots echoing the mark, blended on a separate layer.
    rings = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    rd = ImageDraw.Draw(rings)
    for cx, cy, r, width in ((1010, 500, 290, 40), (1010, 500, 170, 26), (60, -30, 160, 30)):
        rd.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(255, 255, 255, 20), width=width)
    img.alpha_composite(rings)
    img.alpha_composite(tag_mark(400), (20, 50))
    d = ImageDraw.Draw(img)
    x, right = 420, 984

    def fit(path: str, size: int, text: str) -> ImageFont.FreeTypeFont:
        f = font(path, size)
        while d.textlength(text, font=f) > right - x:
            size -= 2
            f = font(path, size)
        return f

    title = "Pocket Curio"
    d.text((x, 118), title, font=fit(BLACK, 96, title), fill=CREAM)
    line1 = "A souvenir is a place + a memory."
    d.text((x + 4, 258), line1, font=fit(MEDIUM, 40, line1), fill=(0xE8, 0xDC, 0xE9, 255))
    line2 = "Photograph the shelf. Watch the map fill in."
    d.text((x + 4, 322), line2, font=fit(BOLD, 30, line2), fill=(0xD9, 0xCB, 0xDA, 255))
    img.convert("RGB").save(ASSETS / "feature-graphic.png")


# --- captioned screenshots -------------------------------------------------

def framed(shot: Image.Image, caption: str, size: tuple[int, int]) -> Image.Image:
    """Caption on top, the screenshot in a bezelled frame below."""
    w, h = size
    img = gradient((w, h), VIOLET_RGB, VIOLET_DEEP[:3]).convert("RGBA")
    d = ImageDraw.Draw(img)

    # Caption block: two lines max, sized to the width.
    lines = caption.split("\n")
    fsize = int(w * 0.068)
    f = font(BLACK, fsize)
    while max(d.textlength(l, font=f) for l in lines) > w * 0.86:
        fsize -= 2
        f = font(BLACK, fsize)
    line_h = int(fsize * 1.25)
    top = int(h * 0.055)
    for i, line in enumerate(lines):
        tw = d.textlength(line, font=f)
        d.text(((w - tw) / 2, top + i * line_h), line, font=f, fill=CREAM)
    cap_bottom = top + len(lines) * line_h + int(h * 0.035)

    # Frame: fill what's left, keep the shot's aspect, bleed off the bottom.
    bezel = int(w * 0.02)
    radius = int(w * 0.07)
    avail_w = int(w * 0.84)
    scale = avail_w / shot.width
    sw, sh = avail_w, int(shot.height * scale)
    sx = (w - sw) // 2
    sy = cap_bottom + bezel
    shot_r = shot.resize((sw, sh), Image.LANCZOS)

    # Drop shadow.
    shadow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle(
        [sx - bezel, sy - bezel + 18, sx + sw + bezel, sy + sh + bezel + 18],
        radius=radius, fill=(0, 0, 0, 110),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(int(w * 0.02)))
    img.alpha_composite(shadow)

    # Bezel then the screenshot with rounded corners.
    d = ImageDraw.Draw(img)
    d.rounded_rectangle(
        [sx - bezel, sy - bezel, sx + sw + bezel, sy + sh + bezel],
        radius=radius, fill=BEZEL + (255,),
    )
    mask = Image.new("L", (sw, sh), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, sw, sh], radius=radius - bezel, fill=255)
    img.paste(shot_r, (sx, sy), mask)
    return img.convert("RGB")


def screenshots() -> None:
    phone_targets = {
        ASSETS / "play" / "phone": (1080, 2400),
        ASSETS / "app-store" / "iphone-6.9": (1320, 2868),
        ASSETS / "app-store" / "iphone-6.5": (1284, 2778),
    }
    for out in phone_targets:
        out.mkdir(parents=True, exist_ok=True)
    for raw in sorted((RAW / "phone").glob("*.png")):
        caption = CAPTIONS.get(raw.stem)
        if caption is None:
            raise SystemExit(f"no caption for {raw.name} — add it to CAPTIONS")
        shot = Image.open(raw).convert("RGB")
        for out, size in phone_targets.items():
            framed(shot, caption, size).save(out / raw.name, optimize=True)

    # Tablet: raw shots, PNG without alpha, in both stores' folders.
    for out in (ASSETS / "play" / "tablet-10", ASSETS / "app-store" / "ipad-13"):
        out.mkdir(parents=True, exist_ok=True)
        for raw in sorted((RAW / "tablet").glob("*.png")):
            Image.open(raw).convert("RGB").save(out / raw.name, optimize=True)


def main() -> None:
    ASSETS.mkdir(parents=True, exist_ok=True)
    icons()
    feature_graphic()
    screenshots()
    for p in sorted(ASSETS.rglob("*.png")):
        if "raw" in p.parts:
            continue
        im = Image.open(p)
        print(f"{p.relative_to(ASSETS)}  {im.size[0]}×{im.size[1]}  {im.mode}  {p.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
