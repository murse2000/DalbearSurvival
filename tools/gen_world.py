"""Earth-at-night world art: seamless grass, forest props, alien invasion
debris, ground decals and the title screen illustration."""
from __future__ import annotations

import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter

import art_lib as A
from art_lib import C, ellipse, rect, rrect, poly, line, arc, pixel

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "art", "world")
UI_OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "art", "ui")
PREVIEW = os.path.join(os.path.dirname(__file__), "preview")
W, H = 1280, 720


# ------------------------------------------------------------------ ground
def ground(size=512) -> Image.Image:
    rng = random.Random(20261021)
    base = (33, 61, 55)
    img = Image.new("RGBA", (size, size), base + (255,))
    d = ImageDraw.Draw(img)

    def wrap_ellipse(box, color, width=0):
        for ox in (-size, 0, size):
            for oy in (-size, 0, size):
                d.ellipse([box[0] + ox, box[1] + oy, box[2] + ox, box[3] + oy],
                          fill=color if width == 0 else None,
                          outline=color if width else None, width=width)

    # low-contrast mossy patches, no big repeating "camo" blobs
    for _ in range(90):
        x, y = rng.randrange(size), rng.randrange(size)
        rx, ry = rng.randrange(14, 58), rng.randrange(10, 38)
        shade = rng.choice([(31, 58, 52, 255), (35, 64, 57, 255), (30, 56, 51, 255),
                            (36, 67, 59, 255)])
        wrap_ellipse((x - rx, y - ry, x + rx, y + ry), shade)
    # fine stipple
    for _ in range(15000):
        x, y = rng.randrange(size), rng.randrange(size)
        c = rng.choice([(38, 69, 61), (36, 66, 59), (29, 55, 50), (43, 78, 67),
                        (46, 83, 71), (31, 60, 54)])
        d.point((x, y), fill=c + (255,))
    # grass tufts (wrapped) — sparse: the MultiMesh decor adds foreground detail
    tuft_count = int(170 * (size / 512.0) ** 2)
    for _ in range(tuft_count):
        x, y = rng.randrange(size), rng.randrange(size)
        c = rng.choice([(45, 82, 69), (39, 74, 63), (51, 92, 75), (35, 66, 58)])
        for dx, dy, h in ((-2, 0, 2), (0, 1, 3), (2, 0, 2)):
            for ox in (-size, 0, size):
                for oy in (-size, 0, size):
                    d.line([(x + dx + ox, y + oy), (x + dx + ox + 1, y + oy - h)],
                           fill=c + (255,), width=1)
    # clover clusters
    for _ in range(int(60 * (size / 512.0) ** 2)):
        x, y = rng.randrange(size), rng.randrange(size)
        c = (45, 85, 67)
        for ox in (-size, 0, size):
            for oy in (-size, 0, size):
                for dx, dy in ((0, 0), (2, 0), (1, 1), (1, -1)):
                    d.point((x + dx + ox, y + dy + oy), fill=c + (255,))
    # tiny flowers / seeds
    for _ in range(int(80 * (size / 512.0) ** 2)):
        x, y = rng.randrange(size), rng.randrange(size)
        c = rng.choice([(226, 214, 163), (170, 214, 186), (214, 165, 164), (192, 224, 205)])
        for ox in (-size, 0, size):
            for oy in (-size, 0, size):
                d.point((x + ox, y + oy), fill=c + (255,))
    # small stones
    for _ in range(int(30 * (size / 512.0) ** 2)):
        x, y = rng.randrange(size), rng.randrange(size)
        c = (66, 78, 80)
        for ox in (-size, 0, size):
            for oy in (-size, 0, size):
                d.ellipse([x + ox, y + oy, x + ox + 3, y + oy + 2], fill=c + (255,))
    return img


def crop_circle(variant=0) -> Image.Image:
    size = 256
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    rng = random.Random(44 + variant)
    c = size // 2
    rings = [(108, 10, (26, 46, 42, 110)), (86, 3, (58, 98, 82, 80)),
             (72, 7, (26, 46, 42, 95)), (46, 2, (58, 98, 82, 70))]
    for r, w, color in rings:
        d.arc([c - r, c - r, c + r, c + r], 0, 360, fill=color, width=w)
    # flattened crop spokes
    for i in range(10 + variant * 3):
        a = i * math.tau / (10 + variant * 3) + variant * 0.3
        r1, r2 = 46, 106
        d.line([(c + math.cos(a) * r1, c + math.sin(a) * r1),
                (c + math.cos(a + 0.16) * r2, c + math.sin(a + 0.16) * r2)],
               fill=(70, 112, 90, 55), width=3)
    # alien glyph in the middle
    if variant == 0:
        d.arc([c - 30, c - 30, c + 30, c + 30], 200, 340, fill=(120, 190, 150, 120), width=3)
        d.line([(c - 18, c + 14), (c, c - 22), (c + 18, c + 14)], fill=(120, 190, 150, 120), width=3)
        d.line([(c - 10, c + 8), (c + 10, c + 8)], fill=(120, 190, 150, 120), width=3)
    else:
        for i in range(3):
            r = 22 + i * 12
            d.arc([c - r, c - r, c + r, c + r], 90 + i * 40, 330 + i * 10,
                  fill=(120, 190, 150, 100), width=2)
    img = img.filter(ImageFilter.GaussianBlur(0.7))
    return img


def scorch(variant=0) -> Image.Image:
    size = 160
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = img.load()
    rng = random.Random(7 + variant)
    c = size / 2
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - c, y - c) / (size / 2)
            if d < 1:
                a = int(90 * (1 - d) ** 1.7)
                g = int(60 * max(0.0, 0.45 - d))
                px[x, y] = (8 + g, 18 + g, 16 + g, a)
    d = ImageDraw.Draw(img)
    for i in range(12):
        a = i * math.tau / 12 + rng.random() * 0.3
        r1, r2 = size * 0.18, size * (0.28 + rng.random() * 0.18)
        d.line([(c + math.cos(a) * r1, c + math.sin(a) * r1),
                (c + math.cos(a) * r2, c + math.sin(a) * r2)],
               fill=(20, 42, 36, 90), width=2)
    # greenish alien residue
    d.arc([c - 50, c - 50, c + 50, c + 50], 20, 160, fill=(90, 160, 120, 70), width=3)
    return img


# ------------------------------------------------------------------ props
def pine(seed=0) -> Image.Image:
    rng = random.Random(seed * 99 + 3)
    w, h = 64, 100
    img = A.new(w, h)
    # trunk + roots
    rrect(img, (28, 78, 36, 95), C["wood_d"], 1)
    line(img, [(30, 80), (30, 93)], C["wood"])
    line(img, [(29, 94), (24, 97)], C["wood_d"], 2)
    line(img, [(35, 94), (40, 97)], C["wood_d"], 2)
    # tiers
    tiers = [(6, 84, 34, 54, 58, 84), (10, 68, 32, 36, 54, 68), (14, 50, 32, 18, 50, 50)]
    for i, (x1, y1, xm, yt, x2, y2) in enumerate(tiers):
        poly(img, [(x1, y2), (xm, yt), (x2, y2)], C["leaf_d"])
        poly(img, [(x1 + 4, y2 - 2), (xm, yt + 8), (xm, y2 - 4)], C["leaf"])
        poly(img, [(xm, yt + 8), (x2 - 4, y2 - 2), (xm, y2 - 4)], C["leaf_d"])
        # moonlit rim + branch notches
        line(img, [(x1 + 2, y2 - 1), (xm, yt + 2)], C["leaf_l"])
        line(img, [(xm, yt + 2), (xm + 1, yt + 12)], C["leaf_l"])
        for j in range(3):
            yy = y2 - 6 - j * 5
            lx = x1 + 5 + j * 3
            line(img, [(lx, yy), (lx + 5, yy - 2)], C["leaf"])
            rx = x2 - 5 - j * 3
            line(img, [(rx, yy), (rx - 5, yy - 2)], C["leaf_d"])
    # stars / fireflies in the tree
    for _ in range(3):
        x = rng.randrange(20, 44)
        y = rng.randrange(40, 70)
        pixel(img, x, y, C["gold"])
    return A.finish(img, w, h)


def broadleaf(seed=0) -> Image.Image:
    w, h = 76, 88
    img = A.new(w, h)
    rrect(img, (33, 66, 43, 84), C["wood_d"], 1)
    line(img, [(36, 68), (36, 82)], C["wood"])
    clumps = [
        (10, 24, 48, 62, C["leaf_d"]),
        (26, 8, 64, 46, C["leaf"]),
        (42, 20, 70, 58, C["leaf_d"]),
        (18, 34, 52, 70, C["leaf"]),
        (30, 26, 56, 52, C["leaf_l"]),
    ]
    for x1, y1, x2, y2, c in clumps:
        ellipse(img, (x1, y1, x2, y2), c)
    # leaf highlights
    for x, y in ((30, 20), (20, 34), (40, 42), (50, 28), (24, 52)):
        ellipse(img, (x, y, x + 8, y + 4), C["leaf_l"])
    # hanging vines
    line(img, [(16, 56), (14, 70), (17, 78)], C["leaf_d"], 1)
    line(img, [(58, 50), (61, 62), (59, 72)], C["leaf_d"], 1)
    # berries
    for x, y in ((30, 30), (46, 24), (22, 44), (50, 48)):
        pixel(img, x, y, C["coral"])
    return A.finish(img, w, h)


def dead_tree() -> Image.Image:
    w, h = 56, 84
    img = A.new(w, h)
    line(img, [(28, 78), (28, 30)], C["wood_d"], 5)
    line(img, [(28, 78), (26, 80)], C["wood_d"], 3)
    branches = [((28, 48), (12, 30)), ((28, 40), (44, 20)), ((27, 34), (18, 16)),
                ((29, 56), (45, 44)), ((13, 30), (8, 18)), ((44, 20), (48, 8))]
    for (x1, y1), (x2, y2) in branches:
        line(img, [(x1, y1), (x2, y2)], C["wood_d"], 3)
        line(img, [(x1, y1), (x2, y2)], C["wood"], 1)
    line(img, [(28, 76), (28, 34)], C["wood"], 1)
    return A.finish(img, w, h)


def bush(seed=0) -> Image.Image:
    w, h = 38, 28
    img = A.new(w, h)
    blobs = [(2, 10, 20, 26), (12, 4, 32, 24), (22, 9, 36, 26), (8, 14, 28, 27)]
    for x1, y1, x2, y2 in blobs:
        ellipse(img, (x1, y1, x2, y2), C["leaf_d"])
    ellipse(img, (5, 8, 23, 20), C["leaf"])
    ellipse(img, (14, 5, 30, 18), C["leaf"])
    ellipse(img, (20, 12, 34, 22), C["leaf_d"])
    ellipse(img, (8, 9, 16, 14), C["leaf_l"])
    if seed:
        for x, y in ((11, 16), (24, 12), (29, 19)):
            pixel(img, x, y, C["coral"])
    return A.finish(img, w, h)


def rock(seed=0) -> Image.Image:
    w, h = 34, 26
    img = A.new(w, h)
    if seed == 0:
        pts = [(4, 20), (2, 14), (9, 7), (20, 4), (30, 10), (32, 19), (25, 24), (10, 24)]
    else:
        pts = [(3, 18), (7, 9), (17, 3), (28, 7), (32, 15), (28, 23), (12, 25)]
    poly(img, pts, C["gray_d"])
    poly(img, [(6, 17), (10, 9), (20, 6), (27, 10), (18, 15)], C["gray"])
    poly(img, [(9, 10), (16, 7), (21, 9), (14, 12)], C["gray_l"])
    line(img, [(22, 14), (29, 18)], C["gray_d"])
    line(img, [(12, 18), (17, 20), (23, 18)], C["gray"])
    # moss
    ellipse(img, (6, 16, 14, 21), C["leaf_d"])
    ellipse(img, (24, 19, 31, 23), C["leaf"])
    return A.finish(img, w, h)


def alien_crystal() -> Image.Image:
    w, h = 34, 34
    img = A.new(w, h)
    # base
    ellipse(img, (5, 25, 29, 33), C["teal_d"])
    ellipse(img, (8, 26, 26, 32), C["teal"])
    shards = [
        [(9, 27), (7, 16), (12, 6), (15, 20), (14, 28)],
        [(15, 27), (16, 10), (22, 2), (24, 18), (22, 28)],
        [(23, 28), (23, 18), (28, 12), (30, 23), (29, 29)],
    ]
    for pts in shards:
        poly(img, pts, C["mint_d"])
    poly(img, [(10, 25), (9, 17), (12, 9), (13, 20)], C["mint"])
    poly(img, [(17, 26), (18, 12), (22, 5), (21, 20)], C["mint"])
    poly(img, [(24, 27), (25, 20), (28, 15), (28, 24)], C["mint_d"])
    line(img, [(11, 19), (11, 13)], C["ghost_l"])
    line(img, [(19, 16), (20, 10)], C["ghost_l"])
    pixel(img, 8, 12, C["white"])
    pixel(img, 26, 10, C["mint"])
    return A.finish(img, w, h)


def crate() -> Image.Image:
    w, h = 32, 28
    img = A.new(w, h)
    rrect(img, (2, 5, 30, 26), C["gray_d"], 2)
    rrect(img, (3, 6, 29, 24), C["gray"], 1)
    rrect(img, (5, 8, 27, 22), C["gray_l"], 1)
    # straps
    rect(img, (2, 12, 30, 14), C["gray_d"])
    rect(img, (14, 5, 18, 26), C["gray_d"])
    # moon emblem
    ellipse(img, (17, 8, 24, 15), C["ink2"])
    ellipse(img, (18, 9, 23, 14), C["gold"])
    ellipse(img, (20, 9, 24, 13), C["gray_l"])
    # corner bolts
    for x, y in ((5, 8), (27, 8), (5, 22), (27, 22)):
        pixel(img, x, y, C["gold_d"])
    # hazard tag
    rect(img, (6, 17, 11, 21), C["gold"])
    rect(img, (7, 18, 10, 20), C["ink"])
    return A.finish(img, w, h)


def crashed_saucer() -> Image.Image:
    w, h = 76, 44
    img = A.new(w, h)
    # dirt mound
    ellipse(img, (4, 30, 72, 44), C["brown_d"])
    ellipse(img, (10, 32, 66, 43), C["brown"])
    ellipse(img, (22, 34, 54, 42), C["grass_d"])
    # broken hull
    ellipse(img, (10, 14, 66, 38), C["gray_d"])
    ellipse(img, (12, 16, 64, 34), C["gray"])
    ellipse(img, (18, 20, 58, 32), C["gray_l"])
    # missing chunk + smoke stains
    poly(img, [(56, 18), (66, 16), (62, 30), (52, 28)], C["ink2"])
    ellipse(img, (20, 20, 30, 28), C["ink2"])
    ellipse(img, (20, 21, 28, 27), C["purple_dd"])
    arc(img, (14, 18, 60, 34), 200, 340, C["ghost_l"], 1)
    # dome shard
    ellipse(img, (34, 8, 52, 24), C["teal_d"])
    ellipse(img, (36, 10, 50, 22), C["teal"])
    line(img, [(41, 11), (43, 18)], C["ghost_l"])
    # green residue + plants reclaiming it
    ellipse(img, (12, 30, 22, 37), C["mint_d"])
    ellipse(img, (56, 31, 66, 38), C["mint_d"])
    for x, y in ((30, 36), (46, 35), (38, 38)):
        line(img, [(x, y), (x + 1, y - 5)], C["leaf"])
    return A.finish(img, w, h)


def barricade() -> Image.Image:
    w, h = 46, 24
    img = A.new(w, h)
    line(img, [(8, 20), (12, 8)], C["gray_d"], 2)
    line(img, [(38, 20), (34, 8)], C["gray_d"], 2)
    rrect(img, (2, 4, 44, 14), C["gray_d"], 1)
    rrect(img, (3, 5, 43, 13), C["gold_d"], 1)
    for i in range(6):
        x = 5 + i * 7
        poly(img, [(x, 13), (x + 4, 5), (x + 7, 5), (x + 3, 13)], C["ink"])
    line(img, [(2, 9), (44, 9)], C["gold_l"])
    pixel(img, 6, 6, C["coral"])
    pixel(img, 40, 6, C["coral"])
    return A.finish(img, w, h)


def warning_sign() -> Image.Image:
    w, h = 26, 34
    img = A.new(w, h)
    line(img, [(13, 32), (13, 14)], C["gray_d"], 2)
    poly(img, [(2, 14), (24, 14), (13, 1)], C["gold_d"])
    poly(img, [(4, 13), (22, 13), (13, 3)], C["gold"])
    rect(img, (12, 6, 14, 10), C["ink"])
    rect(img, (12, 11, 14, 13), C["ink"])
    # alien eye etched
    ellipse(img, (18, 15, 24, 20), C["mint_d"])
    return A.finish(img, w, h)


def alien_mushroom() -> Image.Image:
    w, h = 18, 18
    img = A.new(w, h)
    rect(img, (8, 10, 11, 16), C["cream"])
    rect(img, (8, 14, 11, 16), C["cream2"])
    ellipse(img, (2, 4, 16, 12), C["purple_d"])
    ellipse(img, (2, 3, 16, 11), C["mint_d"])
    ellipse(img, (4, 4, 14, 9), C["mint"])
    ellipse(img, (6, 4, 10, 7), C["ghost_l"])
    pixel(img, 12, 6, C["white"])
    pixel(img, 5, 8, C["white"])
    return A.finish(img, w, h)


def flower(seed=0) -> Image.Image:
    w, h = 12, 12
    img = A.new(w, h)
    line(img, [(6, 11), (6, 6)], C["leaf"], 1)
    if seed == 0:
        for dx, dy in ((0, -2), (-2, 0), (2, 0), (0, 2)):
            ellipse(img, (5 + dx, 5 + dy, 7 + dx, 7 + dy), C["white"])
        pixel(img, 6, 6, C["gold"])
    elif seed == 1:
        for dx, dy in ((0, -2), (-2, 0), (2, 0), (0, 2)):
            ellipse(img, (5 + dx, 4 + dy, 7 + dx, 6 + dy), C["pink"])
        pixel(img, 6, 5, C["cream3"])
    else:
        ellipse(img, (4, 3, 8, 7), C["mint"])
        pixel(img, 6, 5, C["gold"])
    return A.finish(img, w, h)


def grass_tuft(seed=0) -> Image.Image:
    w, h = 14, 12
    img = A.new(w, h)
    c = [C["leaf"], C["leaf_l"], C["teal"]][seed % 3]
    for x, dx, hh in ((4, -2, 6), (7, 0, 9), (10, 2, 5), (6, -3, 4)):
        line(img, [(x, 11), (x + dx, 11 - hh)], c, 1)
    return A.finish(img, w, h)


def pebble(seed=0) -> Image.Image:
    w, h = 10, 7
    img = A.new(w, h)
    ellipse(img, (1, 2, 8, 6), C["gray_d"])
    ellipse(img, (2, 2, 7, 4), C["gray"])
    return A.finish(img, w, h)


def fallen_log() -> Image.Image:
    w, h = 48, 22
    img = A.new(w, h)
    rrect(img, (2, 8, 44, 20), C["wood_d"], 4)
    rrect(img, (4, 9, 42, 17), C["wood"], 3)
    ellipse(img, (39, 7, 47, 20), C["wood_l"])
    ellipse(img, (41, 10, 45, 17), C["wood_d"])
    ellipse(img, (43, 12, 45, 15), C["brown"])
    line(img, [(8, 11), (30, 11)], C["wood_l"])
    line(img, [(10, 15), (24, 15)], C["brown_d"])
    # moss + shroom
    ellipse(img, (8, 7, 20, 12), C["leaf"])
    ellipse(img, (12, 6, 18, 10), C["leaf_l"])
    rect(img, (33, 7, 35, 10), C["cream2"])
    ellipse(img, (31, 4, 37, 8), C["mint_d"])
    return A.finish(img, w, h)


# ------------------------------------------------------------------ title art
def title_bg() -> Image.Image:
    rng = random.Random(4242)
    img = Image.new("RGBA", (W, H), (7, 10, 22, 255))
    d = ImageDraw.Draw(img)
    # sky gradient
    for y in range(H):
        t = y / H
        col = (int(7 + 18 * t), int(11 + 34 * t), int(25 + 44 * t), 255)
        d.line([(0, y), (W, y)], fill=col)
    # stars
    for _ in range(260):
        x, y = rng.randrange(W), rng.randrange(0, int(H * 0.62))
        b = rng.randrange(140, 255)
        a = rng.randrange(90, 255)
        rad = 1 if rng.random() < 0.9 else 2
        d.ellipse([x, y, x + rad, y + rad], fill=(b, b, min(255, b + 20), a))
    # big moon glow
    glow = Image.new("RGBA", (560, 560), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    for r in range(260, 70, -8):
        alpha = int(3 + 26 * (1 - r / 260) ** 2)
        gd.ellipse([280 - r, 280 - r, 280 + r, 280 + r], fill=(190, 220, 255, alpha))
    img.alpha_composite(glow, (1040 - 280, 150 - 280))
    # moon
    mx, my, mr = 1040, 150, 92
    d.ellipse([mx - mr, my - mr, mx + mr, my + mr], fill=(228, 238, 250, 255))
    d.ellipse([mx - mr + 10, my - mr + 8, mx + mr - 6, my + mr - 4], fill=(238, 245, 255, 255))
    for _ in range(12):
        cx = rng.randint(mx - 60, mx + 50)
        cy = rng.randint(my - 60, my + 55)
        cr = rng.randint(4, 16)
        d.ellipse([cx - cr, cy - cr, cx + cr, cy + cr], fill=(210, 222, 240, 255))
        d.ellipse([cx - cr + 3, cy - cr + 3, cx + cr - 3, cy + cr - 3],
                  fill=(224, 234, 248, 255))
    # UFO fleet silhouettes
    for i, (ux, uy, s) in enumerate(((170, 120, 0.85), (640, 72, 0.62), (900, 250, 0.5),
                                     (430, 42, 0.5), (1110, 320, 0.4))):
        hull = [ux - 62 * s, uy - 11 * s, ux + 62 * s, uy + 11 * s]
        d.ellipse(hull, fill=(22, 28, 42, 245))
        d.arc([ux - 60 * s, uy - 8 * s, ux + 60 * s, uy + 12 * s], 185, 355,
              fill=(96, 156, 176, 120), width=max(1, int(2 * s)))
        d.ellipse([ux - 36 * s, uy - 4 * s, ux + 36 * s, uy + 15 * s], fill=(13, 18, 30, 245))
        d.ellipse([ux - 16 * s, uy - 24 * s, ux + 16 * s, uy + 5 * s], fill=(44, 56, 76, 240))
        d.arc([ux - 14 * s, uy - 22 * s, ux + 14 * s, uy + 3 * s], 190, 320,
              fill=(130, 190, 200, 90), width=1)
        for j in range(3):
            lx = ux - 28 * s + j * 28 * s
            d.ellipse([lx - 3 * s, uy + 1 * s, lx + 3 * s, uy + 7 * s], fill=(120, 236, 184, 235))
        # faint beam
        beam = Image.new("RGBA", (int(110 * s) + 4, int(240 * s) + 4), (0, 0, 0, 0))
        bd = ImageDraw.Draw(beam)
        for yy in range(beam.height):
            t = yy / beam.height
            width = int((7 + 42 * t) * s)
            alpha = int(20 * (1 - t))
            bd.ellipse([beam.width / 2 - width / 2, yy, beam.width / 2 + width / 2, yy + 3],
                       fill=(120, 236, 184, alpha))
        img.alpha_composite(beam, (int(ux - beam.width / 2), int(uy + 10 * s)))

    # giant mothership hanging over the forest, left of the moon
    mx, my = 748, 128
    glow3 = Image.new("RGBA", (460, 460), (0, 0, 0, 0))
    gd3 = ImageDraw.Draw(glow3)
    for r in range(180, 20, -6):
        gd3.ellipse([230 - r, 230 - r * 0.52, 230 + r, 230 + r * 0.52],
                    fill=(90, 220, 175, 2))
    img.alpha_composite(glow3.filter(ImageFilter.GaussianBlur(20)), (mx - 230, my - 190))
    d.ellipse([mx - 126, my - 30, mx + 126, my + 34], fill=(17, 22, 36, 250))
    d.arc([mx - 122, my - 24, mx + 122, my + 36], 185, 355, fill=(96, 166, 186, 120), width=2)
    d.ellipse([mx - 98, my - 8, mx + 98, my + 26], fill=(11, 15, 26, 250))
    d.ellipse([mx - 40, my - 48, mx + 40, my + 8], fill=(34, 40, 62, 248))
    d.ellipse([mx - 33, my - 42, mx + 33, my + 3], fill=(54, 46, 82, 245))
    d.ellipse([mx - 17, my - 32, mx + 17, my - 2], fill=(150, 60, 100, 160))
    d.ellipse([mx - 11, my - 28, mx + 11, my - 6], fill=(236, 110, 130, 200))
    d.ellipse([mx - 5, my - 25, mx + 5, my - 15], fill=(255, 220, 180, 220))
    for i in range(11):
        a = -80 + i * 16
        lx = mx + math.cos(math.radians(a)) * 104
        ly = my + 12 + math.sin(math.radians(a)) * 16
        d.ellipse([lx - 3, ly - 3, lx + 3, ly + 3], fill=(120, 240, 184, 235))
    # huge abduction beam
    bimg = Image.new("RGBA", (300, 380), (0, 0, 0, 0))
    bd = ImageDraw.Draw(bimg)
    for yy in range(380):
        t = yy / 380
        w = int(18 + 110 * t)
        alpha = int(30 * (1 - t) ** 1.3)
        bd.ellipse([150 - w / 2, yy, 150 + w / 2, yy + 5], fill=(126, 236, 186, alpha))
    bimg = bimg.filter(ImageFilter.GaussianBlur(5))
    img.alpha_composite(bimg, (mx - 150, my + 22))
    # distant city skyline
    skyline = Image.new("RGBA", (W, 240), (0, 0, 0, 0))
    sd = ImageDraw.Draw(skyline)
    x = 0
    while x < W:
        bw = rng.randint(18, 52)
        bh = rng.randint(30, 120)
        sd.rectangle([x, 240 - bh, x + bw, 240], fill=(16, 24, 38, 255))
        for wy in range(240 - bh + 10, 230, 18):
            for wx in range(x + 6, x + bw - 6, 14):
                if rng.random() < 0.28:
                    sd.rectangle([wx, wy, wx + 4, wy + 6], fill=(180, 170, 120, 120))
        if rng.random() < 0.2:
            sd.line([(x + bw / 2, 240 - bh), (x + bw / 2, 240 - bh - 24)], fill=(16, 24, 38, 255), width=3)
            sd.ellipse([x + bw / 2 - 2, 240 - bh - 27, x + bw / 2 + 2, 240 - bh - 23],
                       fill=(226, 84, 76, 160))
        x += bw + rng.randint(2, 10)
    img.alpha_composite(skyline, (0, int(H * 0.43)))
    # forest silhouettes (three layers)
    layers = [((10, 23, 34), 0.62, 26, 130), ((13, 32, 38), 0.69, 34, 190), ((9, 20, 26), 0.77, 44, 240)]
    for li, (color, yfrac, spread, height) in enumerate(layers):
        x = -40
        base = int(H * yfrac)
        while x < W + 40:
            tw = rng.randint(24, 58)
            th = rng.randint(height - 40, height)
            pts = [(x, base), (x + tw / 2, base - th), (x + tw, base)]
            d.polygon(pts, fill=color + (255,))
            d.rectangle([x + tw / 2 - 3, base - 8, x + tw / 2 + 3, base], fill=color + (255,))
            x += spread + rng.randint(-8, 12)
    # mid fog
    fog = Image.new("RGBA", (W, 320), (0, 0, 0, 0))
    fd = ImageDraw.Draw(fog)
    for i in range(26):
        x = rng.randint(-100, W)
        y = rng.randint(60, 260)
        rx = rng.randint(120, 320)
        ry = rng.randint(18, 50)
        fd.ellipse([x, y, x + rx, y + ry], fill=(120, 180, 180, 12))
    fog = fog.filter(ImageFilter.GaussianBlur(14))
    img.alpha_composite(fog, (0, int(H * 0.45)))

    # ground plane
    ground_img = ground(256).resize((512, 512), Image.NEAREST)
    plane = Image.new("RGBA", (W, 320), (0, 0, 0, 0))
    for gy in range(0, 320, 512):
        for gx in range(0, W, 512):
            plane.alpha_composite(ground_img, (gx, gy))
    # darken + warm moonlight gradient
    shade = Image.new("RGBA", (W, 320), (0, 0, 0, 0))
    shd = ImageDraw.Draw(shade)
    for y in range(320):
        t = y / 320
        shd.line([(0, y), (W, y)], fill=(8, 14, 24, int(150 - 70 * t)))
    plane.alpha_composite(shade, (0, 0))
    img.alpha_composite(plane, (0, H - 320))
    # grounding shadow line
    d.rectangle([0, H - 320, W, H - 316], fill=(20, 34, 36, 160))

    # framing trees (reuse props, scaled)
    pine1 = pine(1).resize((64 * 3, 100 * 3), Image.NEAREST)
    pine2 = pine(2).resize((64 * 4, 100 * 4), Image.NEAREST)
    broad = broadleaf(0).resize((76 * 3, 88 * 3), Image.NEAREST)
    img.alpha_composite(pine2, (-90, H - 100 * 4 + 30))
    img.alpha_composite(pine1, (1080, H - 100 * 3 + 40))
    img.alpha_composite(broad, (900, H - 88 * 3 + 70))
    img.alpha_composite(pine1, (-40, H - 100 * 3 + 160))

    # hill for the hero
    hill = Image.new("RGBA", (620, 220), (0, 0, 0, 0))
    hd = ImageDraw.Draw(hill)
    hd.ellipse([0, 70, 620, 300], fill=(33, 62, 55, 255))
    hd.ellipse([20, 54, 600, 250], fill=(39, 72, 62, 255))
    hd.ellipse([80, 40, 540, 210], fill=(44, 82, 70, 255))
    for _ in range(220):
        hx, hy = rng.randrange(30, 590), rng.randrange(90, 200)
        if (hx - 310) ** 2 / 290 ** 2 + (hy - 150) ** 2 / 100 ** 2 < 1:
            hd.point((hx, hy), fill=rng.choice([(56, 100, 82), (51, 94, 78), (44, 84, 70)]))
    img.alpha_composite(hill, (640, H - 250))

    # bear hero
    player = A.make_sheet([__import__("gen_characters").bear_frame("front", 0)], 32, 36, cols=1)
    # contact-sheet proof frame includes outline; scale up
    hero = player.resize((32 * 7, 36 * 7), Image.NEAREST)
    img.alpha_composite(hero, (905, H - 36 * 7 - 92))
    # shadow under bear
    sh = A.shadow((52, 16), 150).resize((220, 54), Image.NEAREST)
    img.alpha_composite(sh, (905, H - 92 - 26))

    # lantern / moonstone beside the bear
    lx, ly = 840, H - 120
    d.ellipse([lx - 14, ly - 10, lx + 14, ly + 12], fill=(58, 46, 40, 255))
    d.rectangle([lx - 5, ly - 26, lx + 5, ly + 4], fill=(95, 76, 58, 255))
    d.ellipse([lx - 10, ly - 40, lx + 10, ly - 18], fill=(255, 220, 140, 255))
    d.ellipse([lx - 6, ly - 36, lx + 6, ly - 22], fill=(255, 250, 210, 255))
    glow2 = A.radial(180, (255, 208, 120), (0, 0, 0), 2.2)
    img.alpha_composite(glow2, (lx - 90, ly - 130))
    # small alien drone crashed on the right
    droneimg = __import__("gen_aliens").drone(0).resize((34 * 2, 26 * 2), Image.NEAREST)
    img.alpha_composite(droneimg, (1140, H - 120))

    # foreground grass silhouette + flowers
    fg = Image.new("RGBA", (W, 120), (0, 0, 0, 0))
    fd = ImageDraw.Draw(fg)
    for x in range(0, W, 4):
        hh = rng.randint(6, 26)
        fd.line([(x, 120), (x + rng.randint(-4, 4), 120 - hh)],
                fill=rng.choice([(22, 44, 38, 230), (28, 54, 46, 230)]), width=2)
    fd.rectangle([0, 112, W, 120], fill=(18, 38, 34, 255))
    img.alpha_composite(fg, (0, H - 120))

    # fireflies / spores
    for _ in range(46):
        fx, fy = rng.randint(0, W), rng.randint(int(H * 0.45), H - 40)
        r = rng.choice([1, 1, 2])
        col = rng.choice([(255, 214, 130), (160, 240, 200), (200, 230, 255)])
        d.ellipse([fx - r, fy - r, fx + r, fy + r], fill=col + (220,))

    # vignette
    vig = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    vd = ImageDraw.Draw(vig)
    for i in range(60):
        alpha = 3
        vd.rectangle([i, i, W - i, H - i], outline=(2, 5, 10, alpha))
    return img


def main():
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(UI_OUT, exist_ok=True)
    os.makedirs(PREVIEW, exist_ok=True)

    files = {
        "ground": ground(512),
        "crop_circle_0": crop_circle(0),
        "crop_circle_1": crop_circle(1),
        "scorch_0": scorch(0),
        "scorch_1": scorch(1),
        "tree_pine_0": pine(0),
        "tree_pine_1": pine(1),
        "tree_pine_2": pine(2),
        "tree_broad": broadleaf(0),
        "dead_tree": dead_tree(),
        "bush_0": bush(0),
        "bush_1": bush(1),
        "rock_0": rock(0),
        "rock_1": rock(1),
        "alien_crystal": alien_crystal(),
        "crate": crate(),
        "crashed_saucer": crashed_saucer(),
        "barricade": barricade(),
        "warning_sign": warning_sign(),
        "alien_mushroom": alien_mushroom(),
        "flower_0": flower(0),
        "flower_1": flower(1),
        "flower_2": flower(2),
        "grass_tuft_0": grass_tuft(0),
        "grass_tuft_1": grass_tuft(1),
        "grass_tuft_2": grass_tuft(2),
        "pebble": pebble(0),
        "fallen_log": fallen_log(),
    }
    for name, img in files.items():
        A.save(img, os.path.join(OUT, name + ".png"))

    tb = title_bg()
    A.save(tb, os.path.join(UI_OUT, "title_bg.png"))

    A.contact(list(files.items()), os.path.join(PREVIEW, "world.png"), scale=3, cols=5)
    A.save(tb.resize((W // 2, H // 2), Image.LANCZOS), os.path.join(PREVIEW, "title_half.png"))
    print("world done")


if __name__ == "__main__":
    main()
