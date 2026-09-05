#!/usr/bin/env python3
"""Generates the launcher icon source art (PIL).

    python3 tool/make_icon.py && dart run flutter_launcher_icons

A cream luggage tag on curio violet — the tag is the souvenir, the
violet dot is the place. Two files: the full icon (opaque, for iOS and
legacy Android) and the foreground alone (transparent, for Android's
adaptive icon, drawn within the safe zone).
"""
from pathlib import Path

from PIL import Image, ImageDraw

VIOLET = (0x7A, 0x4E, 0x7E, 255)
CREAM = (0xF6, 0xF1, 0xE7, 255)
STRING = (0xE0, 0xD6, 0xC4, 255)
SIZE = 1024


def draw_tag(img: Image.Image, scale: float) -> None:
    """Draws the tag centered, scaled to fit within `scale` of the canvas."""
    d = ImageDraw.Draw(img)
    c = SIZE / 2
    w, h = 560 * scale, 340 * scale
    # Tag body, slightly rotated feel via a cut corner on the left.
    left, top = c - w / 2, c - h / 2
    right, bottom = c + w / 2, c + h / 2
    cut = 90 * scale
    body = [
        (left + cut, top),
        (right, top),
        (right, bottom),
        (left + cut, bottom),
        (left, c),
    ]
    d.polygon(body, fill=CREAM)
    # Rounded right corners.
    r = 44 * scale
    d.rounded_rectangle(
        [right - 2 * r, top, right, bottom], radius=r, fill=CREAM
    )
    # Eyelet.
    ex, ey, er = left + cut * 0.85, c, 34 * scale
    d.ellipse([ex - er, ey - er, ex + er, ey + er], fill=VIOLET)
    d.ellipse(
        [ex - er * 0.55, ey - er * 0.55, ex + er * 0.55, ey + er * 0.55],
        fill=CREAM,
    )
    # String loop out of the eyelet.
    d.arc(
        [ex - 170 * scale, ey - 150 * scale, ex + 40 * scale, ey + 60 * scale],
        start=110,
        end=330,
        fill=STRING,
        width=int(22 * scale),
    )
    # The place: a violet dot with a small pin stem.
    px, py, pr = c + 70 * scale, c - 10 * scale, 62 * scale
    d.ellipse([px - pr, py - pr, px + pr, py + pr], fill=VIOLET)
    d.ellipse(
        [px - pr * 0.4, py - pr * 0.4, px + pr * 0.4, py + pr * 0.4],
        fill=CREAM,
    )
    d.polygon(
        [(px - pr * 0.55, py + pr * 0.75), (px + pr * 0.55, py + pr * 0.75),
         (px, py + pr * 1.9)],
        fill=VIOLET,
    )
    # A short "memory" line under the place.
    d.rounded_rectangle(
        [c - 100 * scale, bottom - 70 * scale, c + 240 * scale,
         bottom - 46 * scale],
        radius=12 * scale,
        fill=(0xD9, 0xCB, 0xDA, 255),
    )


def main() -> None:
    out = Path(__file__).resolve().parent.parent / "assets" / "icon"
    out.mkdir(parents=True, exist_ok=True)

    icon = Image.new("RGBA", (SIZE, SIZE), VIOLET)
    draw_tag(icon, 1.0)
    icon.save(out / "icon.png")

    # Adaptive foreground: transparent, artwork inside the inner 66%.
    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw_tag(fg, 0.62)
    fg.save(out / "icon_foreground.png")
    print(f"wrote {out / 'icon.png'} and {out / 'icon_foreground.png'}")


if __name__ == "__main__":
    main()
