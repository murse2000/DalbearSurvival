"""Friend bear palette variants from the base player sheet."""
from __future__ import annotations

import os

from PIL import Image

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "art", "char")
PREVIEW = os.path.join(os.path.dirname(__file__), "preview")

# Exact palette colours used by gen_characters.py.
CREAM = (243, 230, 207)
CREAM2 = (222, 200, 170)
CREAM3 = (255, 246, 233)
BROWN = (164, 116, 82)
CORAL = (232, 102, 88)
CORAL_D = (178, 66, 66)
GOLD = (255, 208, 108)
PINK = (238, 156, 152)

VARIANTS = {
    "friend_star": {
        CREAM: (205, 228, 250),
        CREAM2: (156, 188, 222),
        CREAM3: (240, 249, 255),
        BROWN: (98, 128, 174),
        CORAL: (70, 105, 198),
        CORAL_D: (43, 68, 146),
        GOLD: (255, 226, 112),
        PINK: (246, 174, 194),
    },
    "friend_frost": {
        CREAM: (211, 240, 247),
        CREAM2: (162, 205, 220),
        CREAM3: (250, 255, 255),
        BROWN: (88, 130, 150),
        CORAL: (72, 197, 207),
        CORAL_D: (38, 135, 156),
        GOLD: (184, 248, 255),
        PINK: (196, 228, 238),
    },
    "friend_ember": {
        CREAM: (249, 216, 172),
        CREAM2: (218, 167, 115),
        CREAM3: (255, 241, 214),
        BROWN: (148, 78, 49),
        CORAL: (244, 120, 48),
        CORAL_D: (178, 58, 28),
        GOLD: (255, 219, 78),
        PINK: (255, 154, 134),
    },
    "friend_shade": {
        CREAM: (151, 145, 174),
        CREAM2: (103, 98, 134),
        CREAM3: (199, 194, 222),
        BROWN: (68, 58, 100),
        CORAL: (119, 78, 178),
        CORAL_D: (73, 43, 119),
        GOLD: (172, 140, 255),
        PINK: (179, 118, 190),
    },
}


def variant(base: Image.Image, mapping: dict) -> Image.Image:
    src = base.load()
    out = base.copy()
    dst = out.load()
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = src[x, y]
            if a == 0:
                continue
            rgb = (r, g, b)
            if rgb in mapping:
                nr, ng, nb = mapping[rgb]
                dst[x, y] = (nr, ng, nb, a)
    return out


def add_emblem(img: Image.Image, color: tuple[int, int, int]) -> None:
    """Small forehead emblem on the four front-facing frames."""
    p = img.load()
    for col in range(4):
        ox = col * 32
        # Three-pixel rune diamond above the eyes.
        for x, y in ((15, 7), (16, 6), (17, 7), (16, 8)):
            px, py = ox + x, y
            if p[px, py][3] > 0:
                p[px, py] = (*color, 255)


def main():
    base = Image.open(os.path.join(OUT, "player_sheet.png")).convert("RGBA")
    os.makedirs(PREVIEW, exist_ok=True)
    for name, mapping in VARIANTS.items():
        img = variant(base, mapping)
        emblem = mapping.get(GOLD, (255, 238, 178))
        add_emblem(img, emblem)
        img.save(os.path.join(OUT, name + ".png"))
    print("friend sheets done")


if __name__ == "__main__":
    main()
