"""Procedural art for the ten new fronts.

This intentionally creates new silhouettes and palettes rather than tinting or
recombining the existing enemies.  Outputs:
  assets/art/char/new_enemy_*.png       (20)
  assets/art/char/new_mini_*.png        (10)
  assets/art/char/new_boss_*.png        (10)
  assets/art/world/ground_*.png         (10)

Stage thumbnails are composed separately by `gen_stage_thumbs.py` so they can
reuse the relic and boss art in a scene.
"""
from __future__ import annotations

import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter

import art_lib as A
from art_lib import C

ROOT = os.path.join(os.path.dirname(__file__), "..")
CHAR = os.path.join(ROOT, "assets", "art", "char")
WORLD = os.path.join(ROOT, "assets", "art", "world")
UI = os.path.join(ROOT, "assets", "art", "ui")
PREVIEW = os.path.join(os.path.dirname(__file__), "preview")

# id, display palette, accent, shape family
NEW = [
    ("dune_stalker", (194, 126, 68), (255, 188, 82), 0),
    ("sand_spitter", (210, 170, 92), (255, 220, 120), 9),
    ("frost_wisp", (150, 214, 235), (190, 245, 255), 2),
    ("ice_crab", (130, 188, 212), (170, 240, 255), 1),
    ("mire_lurker", (126, 154, 78), (178, 226, 92), 15),
    ("toxic_moth", (152, 186, 84), (210, 255, 102), 4),
    ("rust_hound", (156, 112, 84), (235, 160, 92), 10),
    ("cog_sentry", (150, 156, 164), (230, 208, 112), 14),
    ("moon_knight", (156, 148, 204), (218, 202, 255), 16),
    ("astral_seer", (122, 112, 190), (190, 160, 255), 5),
    ("abyss_jaw", (92, 70, 132), (180, 86, 205), 3),
    ("deep_larva", (104, 92, 144), (178, 132, 220), 17),
    ("solar_flare", (226, 122, 48), (255, 214, 82), 18),
    ("magma_wing", (198, 78, 44), (255, 142, 50), 4),
    ("maze_weaver", (122, 104, 178), (196, 150, 255), 8),
    ("prism_eye", (92, 118, 178), (120, 220, 255), 5),
    ("orbit_drone", (90, 154, 176), (114, 244, 242), 7),
    ("void_cutter", (96, 68, 154), (188, 82, 255), 13),
    ("dawn_herald", (216, 176, 94), (255, 242, 166), 11),
    ("light_eater", (188, 132, 68), (255, 210, 96), 19),
]

MINI = [
    ("dune_queen", (194, 108, 54), (255, 176, 66), 0),
    ("frost_colossus", (120, 176, 204), (180, 245, 255), 1),
    ("mire_mother", (104, 146, 68), (174, 232, 82), 2),
    ("iron_executor", (132, 140, 154), (238, 198, 92), 3),
    ("citadel_guardian", (140, 124, 198), (218, 184, 255), 4),
    ("trench_devourer", (82, 62, 126), (170, 74, 204), 5),
    ("solar_tyrant", (218, 100, 42), (255, 202, 70), 6),
    ("maze_oracle", (112, 96, 178), (196, 142, 255), 7),
    ("orbit_breaker", (76, 142, 168), (110, 238, 240), 8),
    ("dawn_seraph", (214, 166, 82), (255, 238, 152), 9),
]

BOSSES = [
    ("boss_dune", (214, 92, 42), (255, 172, 56), 0),
    ("boss_frost", (94, 156, 196), (160, 238, 255), 1),
    ("boss_mire", (92, 142, 62), (172, 232, 76), 2),
    ("boss_ruins", (116, 126, 142), (236, 186, 74), 3),
    ("boss_citadel", (122, 104, 188), (204, 166, 255), 4),
    ("boss_trench", (70, 50, 112), (156, 58, 196), 5),
    ("boss_solar", (222, 78, 30), (255, 198, 50), 6),
    ("boss_maze", (94, 74, 166), (176, 120, 255), 7),
    ("boss_orbit", (58, 128, 154), (90, 232, 238), 8),
    ("boss_dawn", (204, 144, 58), (255, 226, 112), 9),
]

GROUND = [
    ("ground_dunes", (146, 82, 52), (214, 142, 68), "crack"),
    ("ground_frost", (76, 106, 132), (146, 200, 224), "ice"),
    ("ground_mire", (64, 92, 58), (126, 168, 66), "spore"),
    ("ground_ruins", (70, 78, 88), (140, 132, 92), "circuit"),
    ("ground_citadel", (68, 54, 98), (132, 104, 188), "rune"),
    ("ground_trench", (46, 38, 74), (108, 60, 146), "tendril"),
    ("ground_sunspot", (118, 48, 28), (224, 106, 38), "flare"),
    ("ground_maze", (54, 46, 92), (126, 86, 190), "maze"),
    ("ground_orbit", (38, 66, 78), (80, 176, 184), "orbit"),
    ("ground_dawn", (102, 72, 42), (220, 158, 70), "rays"),
]

def _palette(base, accent):
    return {
        "base": base,
        "dark": tuple(max(0, int(v * 0.55)) for v in base),
        "light": tuple(min(255, int(v * 1.28 + 28)) for v in base),
        "accent": accent,
        "accent_d": tuple(max(0, int(v * 0.65)) for v in accent),
        "white": (250, 246, 230),
    }


def enemy_art(family: int, palette: dict, size: int = 40) -> Image.Image:
    img = A.new(size, size)
    b = size / 40.0
    cx = size * 0.5
    cy = size * 0.55
    p = palette
    def e(box, color):
        A.ellipse(img, tuple(int(v * b) for v in box), color)
    def line(pts, color, w=1):
        A.line(img, [(int(x * b), int(y * b)) for x, y in pts], color, max(1, int(w * b)))
    def poly(pts, color):
        A.poly(img, [(int(x * b), int(y * b)) for x, y in pts], color)

    if family == 0:  # insect
        for i in range(4):
            line([(13, 20 + i * 4), (3, 17 + i * 7)], p["dark"], 2)
            line([(27, 20 + i * 4), (37, 17 + i * 7)], p["dark"], 2)
        e((10, 9, 30, 34), p["base"])
        e((14, 13, 26, 29), p["light"])
        e((16, 16, 19, 19), p["accent"])
        e((22, 16, 25, 19), p["accent"])
        line([(20, 10), (17, 3)], p["dark"], 2)
        line([(20, 10), (24, 3)], p["dark"], 2)
    elif family == 1:  # crab
        e((8, 15, 32, 33), p["base"])
        e((4, 10, 15, 20), p["light"])
        e((25, 10, 36, 20), p["light"])
        for i in range(3):
            line([(8, 24 + i * 3), (1, 29 + i * 3)], p["dark"], 2)
            line([(32, 24 + i * 3), (39, 29 + i * 3)], p["dark"], 2)
        e((15, 13, 19, 17), p["accent"])
        e((22, 13, 26, 17), p["accent"])
    elif family == 2:  # wisp
        poly([(20, 2), (30, 16), (27, 28), (20, 38), (13, 28), (10, 16)], p["base"])
        poly([(20, 8), (25, 18), (22, 30), (18, 30), (15, 18)], p["light"])
        e((17, 16, 20, 20), p["accent"])
        e((21, 16, 24, 20), p["accent"])
        line([(8, 26), (14, 24)], p["accent"], 2)
        line([(26, 24), (32, 26)], p["accent"], 2)
    elif family == 3:  # serpent
        for i in range(6):
            x = 8 + i * 5
            y = 28 - math.sin(i * 0.9) * 10
            e((x - 5, y - 5, x + 5, y + 5), p["base"] if i % 2 else p["light"])
        e((30, 4, 39, 13), p["base"])
        e((33, 6, 36, 9), p["accent"])
    elif family == 4:  # moth
        poly([(18, 16), (3, 5), (5, 24), (15, 27)], p["dark"])
        poly([(22, 16), (37, 5), (35, 24), (25, 27)], p["dark"])
        poly([(18, 17), (8, 10), (10, 23), (16, 25)], p["light"])
        poly([(22, 17), (32, 10), (30, 23), (24, 25)], p["light"])
        e((15, 12, 25, 31), p["base"])
        e((18, 14, 20, 17), p["accent"])
        e((23, 14, 25, 17), p["accent"])
    elif family == 5:  # eye
        e((6, 8, 34, 34), p["dark"])
        e((10, 12, 30, 30), p["base"])
        e((14, 16, 26, 28), p["light"])
        e((18, 19, 22, 25), p["accent_d"])
        e((19, 20, 21, 23), p["white"])
        for a in range(0, 360, 45):
            rad = math.radians(a)
            line([(20 + math.cos(rad) * 12, 20 + math.sin(rad) * 12),
                  (20 + math.cos(rad) * 19, 20 + math.sin(rad) * 19)], p["accent"], 1)
    elif family == 6:  # crystal
        poly([(20, 2), (31, 14), (26, 35), (14, 35), (9, 14)], p["base"])
        poly([(20, 5), (27, 15), (23, 31), (17, 31), (13, 15)], p["light"])
        poly([(20, 8), (23, 15), (20, 27), (17, 15)], p["accent"])
        line([(20, 2), (20, 35)], p["white"], 1)
    elif family == 7:  # machine
        A.rect(img, (int(10 * b), int(9 * b), int(30 * b), int(30 * b)), p["dark"])
        A.rect(img, (int(12 * b), int(11 * b), int(28 * b), int(27 * b)), p["base"])
        e((16, 15, 24, 23), p["accent_d"])
        e((18, 17, 22, 21), p["accent"])
        for x in (9, 31):
            line([(x, 20), (x + (-6 if x < 20 else 6), 27)], p["dark"], 2)
        line([(20, 6), (20, 1)], p["accent"], 2)
    elif family == 8:  # plant
        line([(20, 35), (20, 18)], p["dark"], 3)
        for a in (-1.2, -0.4, 0.4, 1.2):
            line([(20, 20), (20 + math.sin(a) * 14, 20 - math.cos(a) * 14)], p["base"], 2)
            e((20 + math.sin(a) * 14 - 4, 20 - math.cos(a) * 14 - 4,
               20 + math.sin(a) * 14 + 4, 20 - math.cos(a) * 14 + 4), p["light"])
        e((15, 8, 25, 19), p["accent_d"])
        e((18, 11, 22, 15), p["accent"])
    elif family == 9:  # orb
        e((5, 5, 35, 35), p["dark"])
        e((8, 8, 32, 32), p["base"])
        e((12, 12, 28, 28), p["light"])
        e((16, 16, 24, 24), p["accent_d"])
        A.arc(img, (int(3 * b), int(17 * b), int(37 * b), int(25 * b)), 10, 340, p["accent"], 1)
    elif family == 10:  # hound
        e((8, 16, 31, 31), p["base"])
        e((25, 7, 38, 21), p["light"])
        e((32, 11, 36, 15), p["accent"])
        for x in (11, 26):
            line([(x, 29), (x - 2, 37)], p["dark"], 3)
        poly([(8, 19), (2, 12), (5, 24)], p["dark"])
        e((16, 18, 20, 21), p["accent"])
    elif family == 11:  # jelly
        A.ellipse(img, (int(8 * b), int(8 * b), int(32 * b), int(27 * b)), p["base"])
        A.ellipse(img, (int(11 * b), int(10 * b), int(29 * b), int(24 * b)), p["light"])
        for i in range(5):
            line([(12 + i * 4, 24), (11 + i * 4 + math.sin(i) * 3, 36)], p["accent_d"], 2)
        e((15, 15, 18, 19), p["accent"])
        e((22, 15, 25, 19), p["accent"])
    elif family == 12:  # beetle
        e((10, 12, 30, 31), p["dark"])
        e((12, 14, 28, 29), p["base"])
        line([(20, 13), (20, 29)], p["dark"], 2)
        e((14, 8, 26, 15), p["light"])
        e((17, 10, 19, 13), p["accent"])
        for x in (7, 33):
            line([(x, 19), (x + (-5 if x < 20 else 5), 26)], p["dark"], 2)
    elif family == 13:  # wraith
        poly([(20, 2), (33, 18), (28, 37), (20, 31), (12, 37), (7, 18)], p["dark"])
        poly([(20, 6), (28, 19), (25, 31), (20, 27), (15, 31), (12, 19)], p["base"])
        e((16, 15, 19, 19), p["accent"])
        e((22, 15, 25, 19), p["accent"])
        line([(14, 27), (10, 35)], p["accent"], 2)
        line([(26, 27), (30, 35)], p["accent"], 2)
    elif family == 14:  # turret
        e((8, 20, 32, 34), p["dark"])
        e((11, 22, 29, 31), p["base"])
        e((16, 12, 24, 22), p["light"])
        e((18, 14, 22, 18), p["accent"])
        line([(20, 14), (20, 2)], p["dark"], 4)
        line([(20, 5), (28, 2)], p["accent"], 2)
    elif family == 15:  # parasite
        for x, y, s in ((12, 13, 7), (27, 17, 8), (16, 28, 6), (29, 30, 5)):
            e((x - s, y - s, x + s, y + s), p["base"])
            e((x - 2, y - 2, x + 2, y + 2), p["accent"])
            line([(x, y + s), (x - 2, y + s + 5)], p["dark"], 1)
    elif family == 16:  # knight
        e((11, 11, 29, 34), p["dark"])
        e((13, 13, 27, 31), p["base"])
        e((15, 15, 25, 23), p["light"])
        line([(20, 16), (20, 22)], p["accent"], 2)
        line([(13, 23), (27, 23)], p["accent"], 1)
        line([(20, 28), (20, 35)], p["accent"], 2)
        for x in (13, 27):
            line([(x, 31), (x + (-4 if x < 20 else 4), 37)], p["dark"], 2)
    elif family == 17:  # worm
        for i in range(7):
            x = 7 + i * 4.5
            y = 22 + math.sin(i * 0.8) * 7
            e((x - 5, y - 5, x + 5, y + 5), p["base"] if i % 2 else p["light"])
        e((31, 14, 39, 22), p["base"])
        e((34, 16, 37, 20), p["accent"])
    elif family == 18:  # star
        pts = []
        for i in range(16):
            a = -math.pi / 2 + i * math.pi / 8
            r = 18 if i % 2 == 0 else 8
            pts.append((20 + math.cos(a) * r, 20 + math.sin(a) * r))
        poly(pts, p["dark"])
        pts2 = []
        for i in range(16):
            a = -math.pi / 2 + i * math.pi / 8
            r = 14 if i % 2 == 0 else 6
            pts2.append((20 + math.cos(a) * r, 20 + math.sin(a) * r))
        poly(pts2, p["accent"])
        e((18, 18, 22, 22), p["white"])
    else:  # titan
        e((7, 8, 33, 35), p["dark"])
        e((10, 11, 30, 32), p["base"])
        e((14, 14, 26, 25), p["light"])
        e((16, 16, 19, 20), p["accent"])
        e((21, 16, 24, 20), p["accent"])
        line([(10, 27), (4, 37)], p["dark"], 3)
        line([(30, 27), (36, 37)], p["dark"], 3)

    return A.finish(img, size, size)


def mini_art(family: int, palette: dict) -> Image.Image:
    img = enemy_art(family, palette, 64)
    # Crown/aura ring distinguishes the mini boss silhouette.
    ring = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(ring)
    d.ellipse((5, 45, 59, 63), outline=(*palette["accent"], 180), width=2)
    d.arc((12, 2, 52, 24), 200, 340, fill=(*palette["light"], 210), width=2)
    return Image.alpha_composite(img, ring)


def boss_art(family: int, palette: dict) -> Image.Image:
    img = enemy_art(family, palette, 96)
    d = ImageDraw.Draw(img)
    for r, col in ((43, palette["accent_d"]), (36, palette["accent"])):
        d.arc((48 - r, 48 - r, 48 + r, 48 + r), 20, 340, fill=(*col, 150), width=2)
    # large horns
    d.polygon([(16, 25), (4, 2), (24, 14)], fill=(*palette["dark"], 255))
    d.polygon([(80, 25), (92, 2), (72, 14)], fill=(*palette["dark"], 255))
    return img


def ground_art(name: str, base: tuple[int, int, int], accent: tuple[int, int, int],
               motif: str) -> Image.Image:
    rng = random.Random(name)
    size = 512
    img = Image.new("RGBA", (size, size), (*base, 255))
    d = ImageDraw.Draw(img)
    for i in range(1800):
        x = rng.randrange(size)
        y = rng.randrange(size)
        c = tuple(max(0, min(255, v + rng.randrange(-22, 23))) for v in base)
        d.point((x, y), fill=(*c, 255))
    for i in range(18):
        x = rng.randrange(size)
        y = rng.randrange(size)
        r = rng.randrange(20, 110)
        c = tuple(max(0, min(255, v + rng.randrange(-16, 17))) for v in accent)
        d.ellipse((x - r, y - r // 2, x + r, y + r // 2), outline=(*c, 65), width=1)
    for i in range(24):
        x = rng.randrange(size)
        y = rng.randrange(size)
        c = (*accent, rng.randrange(35, 110))
        if motif in ("crack", "flare"):
            d.line((x, y, x + rng.randrange(-80, 81), y + rng.randrange(-50, 51)),
                   fill=c, width=rng.randrange(1, 4))
        elif motif in ("ice", "orbit"):
            d.arc((x - 50, y - 25, x + 50, y + 25), rng.randrange(0, 360),
                  rng.randrange(360, 540), fill=c, width=1)
        elif motif in ("circuit", "maze"):
            d.line((x, y, x + rng.randrange(30, 100), y), fill=c, width=1)
            d.line((x, y, x, y + rng.randrange(20, 80)), fill=c, width=1)
        elif motif in ("rune", "rays"):
            d.ellipse((x - 10, y - 10, x + 10, y + 10), outline=c, width=1)
        elif motif == "tendril":
            d.line((x, y, x + rng.randrange(-40, 41), y + rng.randrange(20, 80)), fill=c, width=2)
        else:
            d.ellipse((x - 3, y - 3, x + 3, y + 3), fill=c)
    return img


def thumb_art(name: str, base: tuple[int, int, int], accent: tuple[int, int, int],
              motif: str) -> Image.Image:
    """Legacy flat thumbnail, kept for reference; not written any more."""
    w, h = 480, 270
    img = Image.new("RGBA", (w, h), (18, 18, 28, 255))
    d = ImageDraw.Draw(img)
    sky_top = tuple(max(0, int(v * 0.45)) for v in base)
    for y in range(h):
        t = y / h
        c = tuple(int(sky_top[i] * (1 - t) + base[i] * t) for i in range(3))
        d.line((0, y, w, y), fill=(*c, 255))
    # moon / planet
    cx, cy, r = (380, 62, 38) if motif != "dawn" else (380, 66, 52)
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(*accent, 70))
    d.ellipse((cx - r + 8, cy - r + 8, cx + r - 8, cy + r - 8), fill=(*accent, 120))
    # horizon and ground strip
    horizon = 150
    d.polygon([(0, horizon), (w, horizon), (w, h), (0, h)], fill=(*base, 255))
    rng = random.Random(name)
    for i in range(26):
        x = rng.randrange(w)
        y = rng.randrange(horizon + 8, h - 8)
        d.line((x, y, x + rng.randrange(-40, 41), y + rng.randrange(-8, 9)),
               fill=(*accent, rng.randrange(25, 80)), width=1)
    # distant silhouettes
    for i in range(9):
        x = rng.randrange(0, w)
        sh = rng.randrange(14, 55)
        d.polygon([(x - 12, horizon), (x, horizon - sh), (x + 12, horizon)],
                  fill=(*tuple(int(v * 0.5) for v in base), 220))
    img = img.filter(ImageFilter.GaussianBlur(0.25))
    return img


def main():
    os.makedirs(CHAR, exist_ok=True)
    os.makedirs(WORLD, exist_ok=True)
    os.makedirs(UI, exist_ok=True)
    os.makedirs(PREVIEW, exist_ok=True)
    for name, base, accent, family in NEW:
        A.save(enemy_art(family, _palette(base, accent)), os.path.join(CHAR, "new_enemy_%s.png" % name))
    for name, base, accent, family in MINI:
        A.save(mini_art(family, _palette(base, accent)), os.path.join(CHAR, "new_mini_%s.png" % name))
    for name, base, accent, family in BOSSES:
        A.save(boss_art(family, _palette(base, accent)), os.path.join(CHAR, "new_boss_%s.png" % name))
    for name, base, accent, motif in GROUND:
        A.save(ground_art(name, base, accent, motif), os.path.join(WORLD, name + ".png"))
    print("new content art done")


if __name__ == "__main__":
    main()
