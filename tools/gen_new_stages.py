"""Tinted stage thumbnails for the Ashen Rift and Far Side fronts."""
from __future__ import annotations

import os

from PIL import Image

ROOT = os.path.join(os.path.dirname(__file__), "..")
UI = os.path.join(ROOT, "assets", "art", "ui")


def tinted(src: str, out: str, tint: tuple[int, int, int], strength: float) -> None:
    img = Image.open(os.path.join(UI, src)).convert("RGBA")
    shade = Image.new("RGBA", img.size, (*tint, int(255 * strength)))
    img = Image.alpha_composite(img, shade)
    # Keep the dark UI contrast and make the new front readable.
    img = Image.blend(img, Image.new("RGBA", img.size, (12, 8, 16, 255)), 0.10)
    img.save(os.path.join(UI, out))


def main() -> None:
    tinted("stage_hive.png", "stage_crater.png", (150, 45, 18), 0.42)
    tinted("stage_ship.png", "stage_void.png", (70, 24, 130), 0.48)
    print("new stage thumbnails done")


if __name__ == "__main__":
    main()
