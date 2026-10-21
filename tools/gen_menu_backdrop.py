"""Blurred full-bleed backdrop used behind the 16:9 menu safe area."""
from __future__ import annotations

import os

from PIL import Image, ImageEnhance, ImageFilter

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets", "art", "ui")
SOURCE = os.path.join(ROOT, "title_bg.png")
DEST = os.path.join(ROOT, "menu_backdrop.png")


def main():
    im = Image.open(SOURCE).convert("RGB")
    im = im.resize((480, 270), Image.Resampling.LANCZOS)
    im = im.filter(ImageFilter.GaussianBlur(18))
    im = ImageEnhance.Brightness(im).enhance(0.55)
    im = ImageEnhance.Color(im).enhance(0.8)
    im.save(DEST)
    print("menu backdrop done")


if __name__ == "__main__":
    main()
