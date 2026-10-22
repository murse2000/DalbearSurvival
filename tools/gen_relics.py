"""Generate two unique destructible relics for each new front."""
from __future__ import annotations

import math
import os

from PIL import Image, ImageDraw

import art_lib as A

ROOT = os.path.join(os.path.dirname(__file__), "..")
WORLD = os.path.join(ROOT, "assets", "art", "world")

MAPS = [
    ("dunes", (146, 82, 52), (238, 160, 78)),
    ("frost", (76, 106, 132), (166, 226, 245)),
    ("mire", (64, 92, 58), (146, 206, 82)),
    ("ruins", (70, 78, 88), (198, 156, 82)),
    ("citadel", (68, 54, 98), (176, 132, 244)),
    ("trench", (46, 38, 74), (138, 74, 176)),
    ("sunspot", (118, 48, 28), (255, 132, 48)),
    ("maze", (54, 46, 92), (154, 104, 228)),
    ("orbit", (38, 66, 78), (88, 210, 214)),
    ("dawn", (102, 72, 42), (255, 190, 92)),
]


def pal(base, accent):
    return {
        "base": base,
        "dark": tuple(int(v * 0.5) for v in base),
        "light": tuple(min(255, int(v * 1.3 + 22)) for v in base),
        "accent": accent,
        "accent_d": tuple(int(v * 0.6) for v in accent),
        "white": (248, 242, 224),
    }


def relic(family: int, p: dict) -> Image.Image:
    s = A.SS
    img = Image.new("RGBA", (64 * s, 64 * s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    def poly(pts, col):
        d.polygon([(int(x * s), int(y * s)) for x, y in pts], fill=(*col, 255))

    def line(pts, col, w=2):
        d.line([(int(x * s), int(y * s)) for x, y in pts], fill=(*col, 255), width=max(1, int(w * s)))

    def e(box, col):
        d.ellipse(tuple(int(v * s) for v in box), fill=(*col, 255))

    if family == 0:  # sandstone spire
        poly([(32, 4), (44, 18), (40, 56), (24, 56), (20, 18)], p["base"])
        poly([(32, 8), (38, 20), (34, 52), (27, 52), (24, 20)], p["light"])
        line([(32, 8), (32, 52)], p["accent"], 2)
        e((26, 56, 42, 62), p["dark"])
    elif family == 1:  # ice shards
        for x, h, c in ((22, 32, p["base"]), (32, 46, p["light"]), (42, 28, p["base"])):
            poly([(x, 62 - h), (x + 8, 62 - h + 10), (x + 4, 62), (x - 6, 62)], c)
            line([(x, 62 - h), (x + 2, 58)], p["accent"], 1)
        e((16, 56, 48, 62), p["dark"])
    elif family == 2:  # toxic pod
        line([(32, 62), (32, 34)], p["dark"], 5)
        e((12, 10, 52, 48), p["base"])
        e((18, 16, 46, 42), p["light"])
        e((25, 22, 39, 36), p["accent_d"])
        e((28, 25, 36, 33), p["accent"])
        for x in (18, 32, 46):
            line([(x, 44), (x + (x - 32) * 0.3, 58)], p["accent"], 2)
    elif family == 3:  # broken machine
        d.rectangle((14 * s, 22 * s, 50 * s, 58 * s), fill=(*p["dark"], 255))
        d.rectangle((18 * s, 26 * s, 46 * s, 52 * s), fill=(*p["base"], 255))
        e((25, 30, 39, 44), p["accent_d"])
        e((28, 33, 36, 41), p["accent"])
        line([(32, 22), (32, 4)], p["accent"], 3)
        line([(32, 8), (44, 14)], p["accent"], 2)
        for x in (10, 54):
            line([(x, 34), (x + (-6 if x < 32 else 6), 48)], p["dark"], 3)
    elif family == 4:  # rune monolith
        poly([(22, 4), (42, 4), (46, 58), (18, 58)], p["base"])
        poly([(26, 8), (38, 8), (40, 54), (24, 54)], p["light"])
        line([(32, 14), (32, 50)], p["accent"], 2)
        line([(26, 24), (38, 24)], p["accent"], 2)
        line([(26, 38), (38, 38)], p["accent"], 2)
        e((28, 30, 36, 38), p["accent_d"])
    elif family == 5:  # abyss coral
        e((20, 50, 44, 62), p["dark"])
        for a in (-1.1, -0.5, 0.1, 0.7, 1.2):
            x = 32 + math.sin(a) * 20
            y = 48 - math.cos(a) * 40
            line([(32, 50), (x, y)], p["base"], 5)
            e((x - 5, y - 5, x + 5, y + 5), p["accent"])
            line([(x, y), (x + math.sin(a) * 8, y - 8)], p["light"], 2)
    elif family == 6:  # solar shard
        pts = []
        for i in range(16):
            a = -math.pi / 2 + i * math.pi / 8
            r = 30 if i % 2 == 0 else 13
            pts.append((32 + math.cos(a) * r, 32 + math.sin(a) * r))
        poly(pts, p["base"])
        pts2 = []
        for i in range(16):
            a = -math.pi / 2 + i * math.pi / 8
            r = 22 if i % 2 == 0 else 9
            pts2.append((32 + math.cos(a) * r, 32 + math.sin(a) * r))
        poly(pts2, p["accent"])
        e((27, 27, 37, 37), p["white"])
    elif family == 7:  # prism
        poly([(32, 3), (50, 22), (42, 56), (22, 56), (14, 22)], p["dark"])
        poly([(32, 8), (44, 24), (37, 50), (27, 50), (20, 24)], p["base"])
        poly([(32, 14), (38, 25), (32, 44), (26, 25)], p["accent"])
        line([(32, 3), (32, 56)], p["white"], 1)
    elif family == 8:  # orbital wreck
        e((8, 26, 56, 50), p["dark"])
        e((12, 28, 52, 46), p["base"])
        e((22, 30, 42, 42), p["accent_d"])
        e((26, 32, 38, 40), p["accent"])
        line([(12, 34), (2, 26)], p["light"], 2)
        line([(52, 34), (62, 26)], p["light"], 2)
        for x in (22, 42):
            line([(x, 46), (x - 4, 60)], p["dark"], 2)
    else:  # dawn statue
        poly([(22, 54), (42, 54), (38, 12), (26, 12)], p["base"])
        e((16, 4, 48, 28), p["light"])
        e((23, 10, 41, 22), p["accent_d"])
        e((28, 14, 36, 20), p["accent"])
        line([(32, 28), (32, 52)], p["accent"], 2)
        e((14, 54, 50, 62), p["dark"])

    return A.finish(img, 64, 64)


def main():
    os.makedirs(WORLD, exist_ok=True)
    for i, (name, base, accent) in enumerate(MAPS):
        p = pal(base, accent)
        A.save(relic(i, p), os.path.join(WORLD, "relic_%s_a.png" % name))
        A.save(relic((i + 5) % 10, p), os.path.join(WORLD, "relic_%s_b.png" % name))
    print("relics done")


if __name__ == "__main__":
    main()
