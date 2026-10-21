"""Expansion assets: Hive and Ship stages, new aliens, the Hive Queen,
new props, acid orbs and stage-select thumbnails."""
from __future__ import annotations

import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter

import art_lib as A
from art_lib import C, ellipse, rect, rrect, poly, line, arc, pixel

CHAR = os.path.join(os.path.dirname(__file__), "..", "assets", "art", "char")
FX = os.path.join(os.path.dirname(__file__), "..", "assets", "art", "fx")
WORLD = os.path.join(os.path.dirname(__file__), "..", "assets", "art", "world")
UI = os.path.join(os.path.dirname(__file__), "..", "assets", "art", "ui")
PREVIEW = os.path.join(os.path.dirname(__file__), "preview")


# ---------------------------------------------------------------- enemies
def spitter() -> Image.Image:
    img = A.new(36, 36)
    # legs
    for pts in ([(12, 26), (4, 33)], [(16, 28), (11, 35)], [(23, 28), (28, 35)],
                [(26, 25), (34, 31)]):
        line(img, pts, C["hive_d"], 2)
    # acid sac
    ellipse(img, (8, 3, 24, 18), C["acid_dd"])
    ellipse(img, (9, 4, 23, 17), C["acid_d"])
    ellipse(img, (11, 6, 20, 14), C["acid"])
    ellipse(img, (13, 7, 17, 10), C["ghost_l"])
    ellipse(img, (8, 14, 12, 19), C["acid_d"])
    # body
    ellipse(img, (9, 14, 27, 31), C["hive_d"])
    ellipse(img, (10, 15, 26, 29), C["purple_d"])
    ellipse(img, (12, 17, 22, 25), C["hive"])
    # spines
    poly(img, [(11, 15), (8, 10), (14, 14)], C["hive_l"])
    poly(img, [(16, 14), (15, 8), (20, 14)], C["hive_l"])
    # head + snout
    ellipse(img, (18, 13, 31, 27), C["hive_d"])
    ellipse(img, (20, 15, 30, 26), C["purple"])
    poly(img, [(27, 18), (36, 20), (36, 24), (27, 25)], C["acid_dd"])
    rect(img, (32, 20, 35, 23), C["acid"])
    ellipse(img, (23, 17, 26, 20), C["gold"])
    rect(img, (24, 17, 25, 18), C["ink"])
    # acid drips
    ellipse(img, (12, 16, 14, 20), C["acid"])
    ellipse(img, (19, 24, 21, 28), C["acid_d"])
    line(img, [(12, 6), (18, 4)], C["ghost_l"])
    return A.finish(img, 36, 36)


def bomber() -> Image.Image:
    img = A.new(32, 30)
    # legs
    for x, dx in ((7, -3), (11, -2), (16, 0), (21, 2), (25, 3)):
        line(img, [(x, 24), (x + dx, 29)], C["hive_d"], 2)
    # body
    ellipse(img, (4, 8, 28, 29), C["flesh_d"])
    ellipse(img, (5, 7, 27, 27), C["hive"])
    ellipse(img, (8, 13, 24, 27), C["flesh_d"])
    # glowing sac
    ellipse(img, (10, 3, 22, 17), C["orange_d"])
    ellipse(img, (11, 4, 21, 16), C["orange"])
    ellipse(img, (13, 6, 18, 11), C["gold_l"])
    line(img, [(15, 4), (17, 10), (14, 13)], C["ink"])
    line(img, [(19, 6), (18, 12)], C["ink"])
    # fuse
    line(img, [(16, 3), (18, 0)], C["steel_l"])
    pixel(img, 18, 0, C["gold"])
    # eyes
    ellipse(img, (8, 18, 10, 21), C["red"])
    ellipse(img, (22, 18, 24, 21), C["red"])
    pixel(img, 9, 18, C["gold_l"])
    pixel(img, 22, 18, C["gold_l"])
    # shell ridges
    arc(img, (6, 8, 26, 27), 200, 340, C["purple"], 1)
    return A.finish(img, 32, 30)


def burrower() -> Image.Image:
    img = A.new(36, 32)
    # dirt ring
    ellipse(img, (2, 24, 34, 32), C["brown_d"])
    ellipse(img, (5, 26, 31, 31), C["hive_d"])
    # segmented neck
    rect(img, (15, 14, 23, 29), C["hive_d"])
    for y in (16, 20, 24):
        ellipse(img, (13, y, 25, y + 4), C["flesh_d"])
        line(img, [(14, y + 1), (24, y + 1)], C["hive"], 1)
    # head
    ellipse(img, (8, 2, 28, 22), C["hive_d"])
    ellipse(img, (10, 3, 26, 20), C["purple_d"])
    ellipse(img, (12, 5, 24, 17), C["hive"])
    # armor plate
    poly(img, [(12, 4), (18, 1), (25, 5), (23, 10), (14, 10)], C["flesh"])
    # mandibles
    poly(img, [(9, 15), (1, 21), (8, 22)], C["bone"])
    poly(img, [(27, 15), (35, 21), (28, 22)], C["bone"])
    # eyes
    rect(img, (12, 12, 15, 16), C["acid"])
    rect(img, (21, 12, 24, 16), C["acid"])
    pixel(img, 13, 12, C["white"])
    pixel(img, 22, 12, C["white"])
    line(img, [(10, 6), (14, 4)], C["hive_l"])
    return A.finish(img, 36, 32)


def brute() -> Image.Image:
    img = A.new(58, 58)
    # legs
    rrect(img, (10, 40, 23, 55), C["hive_d"], 3)
    rrect(img, (35, 40, 48, 55), C["hive_d"], 3)
    rect(img, (7, 52, 17, 56), C["purple_d"])
    rect(img, (41, 52, 51, 56), C["purple_d"])
    # torso
    ellipse(img, (9, 15, 49, 47), C["hive_d"])
    ellipse(img, (12, 17, 46, 44), C["purple_d"])
    ellipse(img, (17, 20, 41, 41), C["hive"])
    # chest armor
    poly(img, [(18, 20), (29, 16), (40, 20), (38, 32), (29, 36), (20, 32)], C["bone_d"])
    poly(img, [(20, 21), (29, 18), (38, 21), (36, 30), (29, 33), (22, 30)], C["bone"])
    line(img, [(23, 24), (35, 24)], C["bone_d"])
    line(img, [(25, 27), (33, 27)], C["acid_d"])
    # lower arms
    poly(img, [(12, 27), (1, 34), (4, 41), (14, 35)], C["purple_d"])
    poly(img, [(46, 27), (57, 34), (54, 41), (44, 35)], C["purple_d"])
    poly(img, [(1, 33), (0, 27), (5, 32)], C["bone"])
    poly(img, [(57, 33), (58, 27), (53, 32)], C["bone"])
    # upper arms
    polygon = [(9, 20), (0, 12), (3, 5), (13, 16)]
    poly(img, polygon, C["hive_d"])
    poly(img, [(49, 20), (58, 12), (55, 5), (45, 16)], C["hive_d"])
    for x, y in ((1, 5), (57, 5)):
        poly(img, [(x - 2, y + 3), (x, y - 3), (x + 3, y + 2)], C["bone"])
    # head
    ellipse(img, (21, 4, 39, 24), C["hive_d"])
    ellipse(img, (23, 5, 37, 22), C["purple_d"])
    ellipse(img, (25, 7, 35, 18), C["hive"])
    rect(img, (25, 10, 28, 14), C["coral"])
    rect(img, (32, 10, 35, 14), C["coral"])
    pixel(img, 26, 10, C["gold_l"])
    pixel(img, 33, 10, C["gold_l"])
    # tusks + horns
    poly(img, [(24, 18), (22, 25), (27, 20)], C["bone"])
    poly(img, [(36, 18), (38, 25), (33, 20)], C["bone"])
    poly(img, [(23, 5), (19, 0), (27, 3)], C["bone_d"])
    poly(img, [(37, 5), (41, 0), (33, 3)], C["bone_d"])
    # moss / acid veins
    ellipse(img, (11, 32, 17, 38), C["acid_dd"])
    line(img, [(14, 34), (18, 36), (20, 41)], C["acid"], 1)
    line(img, [(44, 23), (41, 29)], C["acid_d"], 1)
    return A.finish(img, 58, 58)


def sentinel() -> Image.Image:
    img = A.new(48, 48)
    # thruster glow
    ellipse(img, (13, 35, 35, 46), C["circuit"])
    ellipse(img, (17, 37, 31, 46), C["steel_d"])
    # side cannons
    rrect(img, (0, 23, 12, 32), C["steel_d"], 2)
    rrect(img, (36, 23, 48, 32), C["steel_d"], 2)
    rect(img, (1, 25, 8, 28), C["steel"])
    rect(img, (40, 25, 47, 28), C["steel"])
    rect(img, (0, 27, 2, 30), C["coral"])
    rect(img, (46, 27, 48, 30), C["coral"])
    # hull
    ellipse(img, (5, 13, 43, 39), C["steel_d"])
    ellipse(img, (6, 14, 42, 38), C["steel"])
    ellipse(img, (11, 17, 37, 35), C["hive_d"])
    ellipse(img, (14, 19, 34, 33), C["purple_dd"])
    # eye
    ellipse(img, (18, 19, 30, 33), C["ink"])
    ellipse(img, (20, 21, 28, 31), C["coral"])
    ellipse(img, (22, 23, 26, 29), C["gold_l"])
    rect(img, (23, 24, 25, 27), C["ink"])
    # dome
    ellipse(img, (17, 6, 31, 20), C["steel_d"])
    ellipse(img, (18, 7, 30, 19), C["steel_l"])
    ellipse(img, (20, 9, 28, 15), C["circuit"])
    line(img, [(24, 6), (24, 1)], C["steel_l"])
    pixel(img, 24, 1, C["coral"])
    # panels
    for a in (0, 120, 240):
        rad = math.radians(a)
        x = 24 + math.cos(rad) * 19
        y = 26 + math.sin(rad) * 12
        ellipse(img, (x - 2, y - 2, x + 2, y + 2), C["circuit"])
    line(img, [(12, 16), (18, 22)], C["steel_l"])
    line(img, [(36, 16), (30, 22)], C["steel_l"])
    return A.finish(img, 48, 48)


def phase_hunter() -> Image.Image:
    img = A.new(30, 40)
    # cloak
    poly(img, [(8, 7), (22, 7), (26, 22), (23, 30), (20, 26), (22, 38),
               (15, 31), (8, 38), (10, 26), (5, 30), (4, 22)], C["hive_d"])
    poly(img, [(9, 8), (21, 8), (24, 21), (21, 27), (18, 23), (19, 33),
               (15, 28), (11, 33), (12, 23), (8, 27), (6, 21)], C["purple_dd"])
    line(img, [(7, 10), (5, 24)], C["purple"])
    line(img, [(23, 10), (25, 24)], C["purple"])
    # head / hood
    ellipse(img, (10, 2, 20, 14), C["purple_dd"])
    ellipse(img, (11, 3, 19, 13), C["purple"])
    ellipse(img, (12, 7, 18, 13), C["ink2"])
    rect(img, (13, 8, 15, 10), C["mint"])
    rect(img, (16, 8, 18, 10), C["mint"])
    # blades
    line(img, [(7, 18), (0, 10)], C["mint"], 2)
    line(img, [(7, 18), (0, 10)], C["ghost_l"], 1)
    line(img, [(23, 18), (30, 10)], C["mint"], 2)
    line(img, [(23, 18), (30, 10)], C["ghost_l"], 1)
    # legs
    line(img, [(13, 32), (11, 39)], C["hive_d"], 2)
    line(img, [(17, 32), (19, 39)], C["hive_d"], 2)
    # phase sparks
    pixel(img, 2, 24, C["mint"])
    pixel(img, 28, 27, C["mint"])
    arc(img, (11, 3, 20, 15), 200, 280, C["ghost_l"], 1)
    return A.finish(img, 30, 40)


def splitter() -> Image.Image:
    img = A.new(36, 34)
    ellipse(img, (2, 10, 19, 32), C["purple_dd"])
    ellipse(img, (13, 3, 31, 27), C["hive_d"])
    ellipse(img, (21, 11, 35, 33), C["purple_dd"])
    ellipse(img, (4, 11, 17, 29), C["purple"])
    ellipse(img, (15, 5, 29, 25), C["flesh"])
    ellipse(img, (23, 12, 33, 30), C["purple"])
    # nuclei
    ellipse(img, (12, 13, 18, 20), C["acid_d"])
    ellipse(img, (13, 14, 17, 19), C["acid"])
    ellipse(img, (23, 17, 29, 24), C["acid_d"])
    ellipse(img, (24, 18, 28, 23), C["acid"])
    # eyes
    rect(img, (8, 17, 10, 20), C["ink"])
    rect(img, (15, 11, 17, 14), C["ink"])
    rect(img, (27, 14, 29, 17), C["ink"])
    pixel(img, 8, 17, C["mint"])
    pixel(img, 15, 11, C["mint"])
    pixel(img, 27, 14, C["mint"])
    # seams
    line(img, [(16, 8), (14, 16), (17, 23)], C["hive"])
    line(img, [(24, 9), (22, 16)], C["hive_l"])
    arc(img, (4, 11, 18, 30), 200, 300, C["ghost_l"], 1)
    return A.finish(img, 36, 34)


def queen() -> Image.Image:
    img = A.new(116, 116)
    # abdomen + egg sacs
    ellipse(img, (22, 54, 96, 112), C["hive_d"])
    ellipse(img, (26, 58, 92, 108), C["flesh_d"])
    ellipse(img, (32, 63, 86, 104), C["hive"])
    for cx, cy, rx, ry in ((44, 70, 13, 16), (62, 76, 14, 18), (78, 68, 11, 15)):
        ellipse(img, (cx - rx, cy - ry, cx + rx, cy + ry), C["acid_dd"])
        ellipse(img, (cx - rx + 2, cy - ry + 2, cx + rx - 2, cy + ry - 2), C["acid_d"])
        ellipse(img, (cx - 5, cy - 6, cx + 4, cy + 3), C["acid"])
        ellipse(img, (cx - 2, cy - 4, cx + 2, cy), C["ghost_l"])
    # chitin plates
    for y in (84, 94, 102):
        arc(img, (30, y - 18, 90, y + 16), 200, 340, C["purple"], 2)
    # spines
    for x in (30, 44, 58, 72, 86):
        poly(img, [(x, 60), (x + 5, 48), (x + 8, 61)], C["hive_l"])
    # thorax
    ellipse(img, (32, 30, 86, 80), C["hive_d"])
    ellipse(img, (36, 32, 82, 76), C["purple_d"])
    ellipse(img, (42, 34, 76, 62), C["hive"])
    line(img, [(50, 40), (48, 62)], C["acid_dd"], 1)
    line(img, [(66, 40), (68, 62)], C["acid_dd"], 1)
    # arms
    for sx, ex, ey in ((34, 6, 58), (82, 110, 56), (38, 12, 84), (78, 104, 86)):
        poly(img, [(sx, 46), (ex, ey), (ex + (4 if ex < sx else -4), ey + 10),
                   (sx + (6 if ex < sx else -6), 58)], C["hive_d"])
        poly(img, [(ex - 4, ey + 2), (ex + 2, ey - 4), (ex + 5, ey + 6)], C["bone_d"])
    # head / crown
    ellipse(img, (38, 4, 80, 46), C["hive_d"])
    ellipse(img, (41, 6, 77, 43), C["purple_d"])
    ellipse(img, (45, 9, 73, 38), C["hive"])
    for x, h in ((42, 12), (50, 20), (58, 24), (66, 20), (74, 12)):
        poly(img, [(x, 10), (x + 3, 10 - h), (x + 7, 9)], C["bone_d"])
        poly(img, [(x + 1, 10), (x + 3, 12 - h * 0.65), (x + 6, 10)], C["bone"])
    # eyes
    for x, y in ((48, 18), (58, 14), (68, 18), (52, 26), (64, 26)):
        ellipse(img, (x - 4, y - 4, x + 4, y + 4), C["ink"])
        ellipse(img, (x - 3, y - 3, x + 3, y + 3), C["coral"])
        rect(img, (x - 1, y - 2, x + 1, y + 2), C["ink2"])
        pixel(img, x - 2, y - 2, C["gold_l"])
    # mandibles + acid mouth
    poly(img, [(44, 34), (30, 48), (44, 44)], C["bone_d"])
    poly(img, [(74, 34), (88, 48), (74, 44)], C["bone_d"])
    ellipse(img, (53, 34, 67, 45), C["ink2"])
    ellipse(img, (55, 35, 65, 43), C["acid_dd"])
    for x in (57, 61):
        rect(img, (x, 35, x + 2, 41), C["acid"])
    # glow / rim
    arc(img, (40, 5, 78, 44), 200, 280, C["ghost_l"], 1)
    line(img, [(30, 58), (22, 72)], C["hive_l"])
    line(img, [(88, 58), (96, 72)], C["hive_l"])
    return A.finish(img, 116, 116)


def acid_orb() -> Image.Image:
    img = A.new(18, 18)
    ellipse(img, (2, 2, 16, 16), C["acid_dd"])
    ellipse(img, (3, 3, 15, 15), C["acid_d"])
    ellipse(img, (5, 5, 13, 13), C["acid"])
    ellipse(img, (6, 6, 10, 10), C["ghost_l"])
    pixel(img, 7, 6, C["white"])
    for x, y in ((2, 9), (15, 8), (9, 1), (9, 16)):
        pixel(img, x, y, C["acid_d"])
    return A.finish(img, 18, 18)


# ---------------------------------------------------------------- grounds
def hive_ground(size=512) -> Image.Image:
    rng = random.Random(771)
    base = (38, 25, 43)
    img = Image.new("RGBA", (size, size), base + (255,))
    d = ImageDraw.Draw(img)

    def wrap(fn):
        for ox in (-size, 0, size):
            for oy in (-size, 0, size):
                fn(ox, oy)

    for _ in range(70):
        x, y = rng.randrange(size), rng.randrange(size)
        rx, ry = rng.randrange(16, 70), rng.randrange(12, 48)
        col = rng.choice([(44, 28, 49, 255), (34, 22, 39, 255), (48, 32, 55, 255),
                          (42, 26, 46, 255)])
        wrap(lambda ox, oy, x=x, y=y, rx=rx, ry=ry, col=col:
             d.ellipse([x - rx + ox, y - ry + oy, x + rx + ox, y + ry + oy], fill=col))
    for _ in range(13000):
        x, y = rng.randrange(size), rng.randrange(size)
        c = rng.choice([(47, 30, 54), (33, 21, 38), (56, 37, 64), (29, 19, 34),
                        (60, 42, 65)])
        d.point((x, y), fill=c + (255,))
    # veins
    for _ in range(44):
        x, y = rng.randrange(size), rng.randrange(size)
        pts = [(x, y)]
        for j in range(rng.randint(3, 7)):
            x += rng.randint(-12, 12)
            y += rng.randint(-12, 12)
            pts.append((x, y))
        col = rng.choice([(92, 46, 86, 255), (72, 40, 78, 255), (120, 58, 106, 255)])
        wrap(lambda ox, oy, pts=pts, col=col: d.line([(px + ox, py + oy) for px, py in pts],
                                                    fill=col, width=1))
    # acid pools
    for _ in range(16):
        x, y = rng.randrange(size), rng.randrange(size)
        rx, ry = rng.randrange(4, 14), rng.randrange(3, 8)
        wrap(lambda ox, oy, x=x, y=y, rx=rx, ry=ry:
             d.ellipse([x - rx + ox, y - ry + oy, x + rx + ox, y + ry + oy],
                       fill=(58, 104, 74, 150)))
        wrap(lambda ox, oy, x=x, y=y:
             d.ellipse([x - 2 + ox, y - 1 + oy, x + 2 + ox, y + 1 + oy],
                       fill=(116, 196, 126, 170)))
    # pores / holes
    for _ in range(55):
        x, y = rng.randrange(size), rng.randrange(size)
        r = rng.randint(2, 4)
        wrap(lambda ox, oy, x=x, y=y, r=r:
             d.ellipse([x - r + ox, y - r + oy, x + r + ox, y + r + oy],
                       fill=(30, 18, 34, 185)))
        wrap(lambda ox, oy, x=x, y=y, r=r:
             d.arc([x - r + ox, y - r + oy, x + r + ox, y + r + oy], 200, 340,
                   fill=(96, 58, 104, 180), width=1))
    # bone flecks + spore dots
    for _ in range(120):
        x, y = rng.randrange(size), rng.randrange(size)
        c = rng.choice([(142, 132, 118), (82, 190, 136), (104, 226, 208)])
        wrap(lambda ox, oy, x=x, y=y, c=c: d.point((x + ox, y + oy), fill=c + (255,)))
    return img


def ship_ground(size=512) -> Image.Image:
    rng = random.Random(902)
    img = Image.new("RGBA", (size, size), (27, 37, 51, 255))
    d = ImageDraw.Draw(img)
    cell = 64
    # plate grid
    for py in range(0, size, cell):
        for px in range(0, size, cell):
            shade = rng.choice([(30, 41, 56, 255), (28, 38, 52, 255), (33, 45, 60, 255)])
            d.rectangle([px + 1, py + 1, px + cell - 2, py + cell - 2], fill=shade)
            d.line([(px, py), (px + cell, py)], fill=(18, 25, 36, 255), width=2)
            d.line([(px, py), (px, py + cell)], fill=(18, 25, 36, 255), width=2)
            d.line([(px + 2, py + 2), (px + cell - 3, py + 2)], fill=(47, 62, 80, 255), width=1)
            # rivets
            for rx, ry in ((px + 6, py + 6), (px + cell - 8, py + 6),
                           (px + 6, py + cell - 8), (px + cell - 8, py + cell - 8)):
                d.point((rx, ry), fill=(71, 86, 104, 255))
    # service strips
    for py in (128, 320, 480):
        d.rectangle([0, py, size, py + 3], fill=(21, 30, 43, 255))
        d.line([(0, py + 3), (size, py + 3)], fill=(50, 70, 84, 255), width=1)
    # circuit traces (wrapped by repeated drawing)
    for _ in range(34):
        x = rng.randrange(size)
        y = rng.randrange(size)
        length = rng.randrange(18, 70)
        horiz = rng.random() < 0.6
        col = rng.choice([(63, 132, 132, 160), (86, 90, 150, 140), (70, 166, 156, 130)])
        for ox in (-size, 0, size):
            for oy in (-size, 0, size):
                if horiz:
                    d.line([(x + ox, y + oy), (x + length + ox, y + oy)], fill=col, width=1)
                    d.point((x + length + ox, y + oy), fill=(150, 230, 220, 120))
                else:
                    d.line([(x + ox, y + oy), (x + ox, y + length + oy)], fill=col, width=1)
                    d.point((x + ox, y + length + oy), fill=(150, 230, 220, 120))
    # vents / grates
    for _ in range(20):
        x, y = rng.randrange(size), rng.randrange(size)
        for ox in (-size, 0, size):
            for oy in (-size, 0, size):
                d.rectangle([x + ox, y + oy, x + 18 + ox, y + 8 + oy], fill=(20, 28, 40, 255))
                for k in range(3):
                    d.line([(x + 3 + ox, y + 2 + k * 2 + oy),
                            (x + 15 + ox, y + 2 + k * 2 + oy)], fill=(52, 66, 84, 255), width=1)
    # scratches
    for _ in range(80):
        x, y = rng.randrange(size), rng.randrange(size)
        ln = rng.randint(3, 12)
        d.line([(x, y), (x + ln, y + rng.choice([-1, 0, 1]))], fill=(43, 56, 73, 180), width=1)
    # sparse hazard paint
    for _ in range(10):
        x, y = rng.randrange(size), rng.randrange(size)
        d.rectangle([x, y, x + 22, y + 4], fill=(78, 66, 40, 90))
    return img


# ---------------------------------------------------------------- props
def hive_egg() -> Image.Image:
    img = A.new(32, 42)
    ellipse(img, (3, 34, 29, 42), C["hive_d"])
    for x in (3, 10, 23, 30):
        line(img, [(x, 36), (x + (2 if x < 15 else -2), 41)], C["hive"], 2)
    ellipse(img, (6, 4, 26, 38), C["hive_d"])
    ellipse(img, (7, 5, 25, 36), C["flesh_d"])
    ellipse(img, (9, 8, 23, 32), C["flesh"])
    line(img, [(16, 6), (15, 20), (18, 33)], C["acid_dd"], 2)
    line(img, [(16, 6), (15, 20), (18, 33)], C["acid"], 1)
    ellipse(img, (12, 13, 18, 22), C["acid_d"])
    ellipse(img, (13, 14, 17, 19), C["acid"])
    for x, y in ((10, 15), (22, 20), (11, 27), (21, 30)):
        poly(img, [(x, y), (x - 4, y + 2), (x, y + 4)], C["hive_l"])
    arc(img, (8, 7, 24, 35), 200, 280, C["pink"], 1)
    return A.finish(img, 32, 42)


def hive_coral() -> Image.Image:
    img = A.new(46, 56)
    ellipse(img, (8, 48, 38, 56), C["hive_d"])
    branches = [
        [(23, 50), (20, 34), (14, 22), (9, 12)],
        [(23, 48), (26, 32), (34, 20), (38, 8)],
        [(23, 46), (18, 30), (20, 16)],
        [(28, 42), (36, 32), (40, 28)],
    ]
    for pts in branches:
        line(img, pts, C["hive_d"], 5)
        line(img, pts, C["purple"], 3)
        line(img, pts, C["hive_l"], 1)
    for x, y in ((9, 12), (38, 8), (20, 16), (40, 28)):
        ellipse(img, (x - 3, y - 3, x + 3, y + 3), C["acid_d"])
        ellipse(img, (x - 2, y - 2, x + 2, y + 2), C["acid"])
    for x, y in ((20, 36), (27, 30), (32, 38)):
        pixel(img, x, y, C["acid"])
    ellipse(img, (14, 44, 32, 51), C["hive_l"])
    return A.finish(img, 46, 56)


def hive_pod() -> Image.Image:
    img = A.new(30, 40)
    line(img, [(15, 40), (15, 22)], C["hive_d"], 4)
    line(img, [(15, 28), (8, 34)], C["hive"], 2)
    line(img, [(15, 30), (23, 36)], C["hive"], 2)
    ellipse(img, (5, 4, 25, 25), C["hive_d"])
    ellipse(img, (6, 5, 24, 24), C["flesh_d"])
    ellipse(img, (8, 7, 22, 22), C["flesh"])
    ellipse(img, (12, 9, 18, 21), C["acid_dd"])
    line(img, [(15, 9), (15, 20)], C["acid"], 1)
    for x, y in ((9, 10), (21, 13), (10, 19)):
        pixel(img, x, y, C["acid"])
    poly(img, [(8, 6), (4, 1), (12, 4)], C["hive_l"])
    poly(img, [(22, 6), (26, 1), (18, 4)], C["hive_l"])
    return A.finish(img, 30, 40)


def hive_spike() -> Image.Image:
    img = A.new(42, 86)
    poly(img, [(8, 84), (17, 68), (14, 40), (19, 12), (25, 2), (29, 30),
               (33, 60), (38, 84)], C["hive_d"])
    poly(img, [(13, 82), (20, 65), (18, 38), (22, 13), (25, 8), (28, 36),
               (32, 66), (34, 82)], C["bone_d"])
    line(img, [(22, 14), (22, 68)], C["bone"], 2)
    for y in (30, 45, 58):
        line(img, [(18, y), (26, y - 4)], C["acid_d"], 1)
    ellipse(img, (11, 80, 34, 86), C["hive"])
    ellipse(img, (15, 82, 30, 86), C["hive_l"])
    return A.finish(img, 42, 86)


def hive_mound() -> Image.Image:
    img = A.new(56, 38)
    ellipse(img, (4, 16, 52, 34), C["hive_d"])
    ellipse(img, (6, 14, 50, 31), C["flesh_d"])
    ellipse(img, (12, 10, 44, 28), C["hive"])
    ellipse(img, (16, 12, 40, 26), C["flesh"])
    for x, y, r in ((18, 20, 3), (30, 17, 4), (38, 23, 2), (24, 26, 2)):
        ellipse(img, (x - r, y - r, x + r, y + r), C["hive_d"])
        pixel(img, x, y - 1, C["acid"])
    for x in (10, 46):
        poly(img, [(x, 26), (x + (4 if x < 28 else -4), 13), (x + (6 if x < 28 else -6), 27)], C["hive_l"])
    return A.finish(img, 56, 38)


def hive_pillar() -> Image.Image:
    img = A.new(76, 132)
    # roots
    for x, y in ((20, 122), (38, 126), (56, 122)):
        line(img, [(38, 116), (x, y)], C["hive_d"], 6)
    # trunk
    poly(img, [(25, 118), (30, 70), (26, 38), (30, 18), (47, 18), (51, 40),
               (48, 75), (52, 118)], C["hive_d"])
    poly(img, [(28, 116), (33, 70), (29, 40), (33, 22), (44, 22), (47, 42),
               (44, 76), (48, 116)], C["flesh_d"])
    line(img, [(35, 110), (37, 77), (34, 45), (38, 30)], C["hive_l"], 2)
    # luminous veins
    for y in (35, 58, 82, 102):
        line(img, [(31, y), (40, y - 3), (46, y)], C["acid_dd"], 1)
        pixel(img, 40, y - 3, C["acid"])
    # crown
    ellipse(img, (18, 10, 60, 40), C["hive_d"])
    ellipse(img, (20, 12, 58, 38), C["hive"])
    ellipse(img, (26, 16, 52, 34), C["flesh_d"])
    for x, h in ((20, 12), (29, 20), (38, 24), (47, 20), (56, 12)):
        poly(img, [(x, 16), (x + 3, 16 - h), (x + 7, 16)], C["hive"])
        poly(img, [(x + 1, 15), (x + 3, 18 - h * 0.6), (x + 6, 15)], C["hive_l"])
    ellipse(img, (34, 22, 42, 31), C["acid_dd"])
    ellipse(img, (36, 23, 40, 30), C["acid"])
    pixel(img, 38, 24, C["ghost_l"])
    # hanging tendrils
    line(img, [(22, 34), (18, 52), (21, 62)], C["hive"], 2)
    line(img, [(55, 36), (60, 52), (57, 64)], C["hive"], 2)
    return A.finish(img, 76, 132)


def hive_spore() -> Image.Image:
    img = A.new(14, 14)
    for x, y, r in ((7, 6, 4), (4, 9, 2), (10, 9, 3)):
        ellipse(img, (x - r, y - r, x + r, y + r), C["hive"])
    ellipse(img, (5, 3, 10, 8), C["acid_d"])
    pixel(img, 7, 4, C["acid"])
    pixel(img, 4, 11, C["acid"])
    return A.finish(img, 14, 14)


def hive_tendril() -> Image.Image:
    img = A.new(12, 18)
    line(img, [(5, 17), (3, 9), (7, 4)], C["hive_d"], 3)
    line(img, [(5, 17), (3, 9), (7, 4)], C["purple"], 1)
    ellipse(img, (5, 1, 9, 5), C["acid_d"])
    pixel(img, 7, 2, C["acid"])
    pixel(img, 2, 12, C["hive_l"])
    return A.finish(img, 12, 18)


def hive_bone() -> Image.Image:
    img = A.new(12, 10)
    poly(img, [(2, 8), (4, 3), (9, 1), (7, 6)], C["bone_d"])
    line(img, [(4, 7), (8, 2)], C["bone"], 1)
    return A.finish(img, 12, 10)


def ship_wall() -> Image.Image:
    img = A.new(72, 128)
    rrect(img, (2, 4, 70, 126), C["steel_d"], 2)
    rrect(img, (4, 6, 68, 124), C["steel_d"], 1)
    rect(img, (6, 8, 66, 120), C["steel"])
    # panels
    for y in (8, 44, 80):
        rect(img, (6, y, 66, y + 32), C["steel_l"])
        rect(img, (7, y + 1, 65, y + 30), C["steel"])
        line(img, [(8, y + 30), (64, y + 30)], C["steel_d"], 2)
        for x in (10, 62):
            pixel(img, x, y + 4, C["steel_l"])
    # glowing strip + hazard
    rect(img, (8, 34, 64, 39), C["steel_d"])
    rect(img, (10, 35, 62, 37), C["circuit"])
    rect(img, (8, 88, 64, 92), C["steel_d"])
    rect(img, (10, 89, 62, 91), C["magenta"])
    for i in range(6):
        x = 10 + i * 9
        poly(img, [(x, 104), (x + 4, 96), (x + 7, 96), (x + 3, 104)], C["gold_d"])
    rect(img, (8, 112, 64, 120), C["steel_d"])
    for x in (14, 30, 46, 60):
        pixel(img, x, 116, C["coral"])
    # pipes
    line(img, [(6, 62), (30, 62), (30, 74), (66, 74)], C["steel_l"], 3)
    line(img, [(6, 68), (24, 68), (24, 80)], C["steel_d"], 2)
    return A.finish(img, 72, 128)


def ship_pylon() -> Image.Image:
    img = A.new(36, 92)
    rrect(img, (10, 76, 26, 90), C["steel_d"], 2)
    rrect(img, (13, 20, 23, 84), C["steel_d"], 2)
    rrect(img, (14, 22, 22, 82), C["steel"])
    rrect(img, (8, 30, 28, 56), C["steel_d"], 2)
    rrect(img, (9, 31, 27, 55), C["steel_l"])
    rect(img, (13, 34, 23, 52), C["purple_dd"])
    rect(img, (15, 36, 21, 50), C["magenta"])
    rect(img, (16, 38, 20, 46), C["ghost_l"])
    for y in (24, 62, 72):
        line(img, [(12, y), (24, y)], C["circuit"], 1)
    line(img, [(18, 22), (18, 4)], C["steel_l"], 1)
    ellipse(img, (16, 1, 20, 5), C["coral"])
    line(img, [(8, 44), (2, 52), (2, 68)], C["steel_d"], 2)
    line(img, [(28, 44), (34, 52), (34, 68)], C["steel_d"], 2)
    return A.finish(img, 36, 92)


def ship_console() -> Image.Image:
    img = A.new(46, 42)
    poly(img, [(4, 38), (42, 38), (38, 16), (8, 16)], C["steel_d"])
    poly(img, [(6, 35), (40, 35), (36, 18), (10, 18)], C["steel"])
    rect(img, (9, 20, 37, 30), C["ink2"])
    rect(img, (10, 21, 36, 29), C["purple_dd"])
    for i in range(3):
        line(img, [(13, 23 + i * 2), (28 - i * 3, 23 + i * 2)], C["circuit"], 1)
    for i in range(3):
        ellipse(img, (13 + i * 7, 31, 16 + i * 7, 34), C["steel_l"])
    line(img, [(4, 38), (4, 41)], C["steel_d"], 2)
    line(img, [(42, 38), (42, 41)], C["steel_d"], 2)
    return A.finish(img, 46, 42)


def ship_pod() -> Image.Image:
    img = A.new(38, 62)
    rrect(img, (4, 2, 34, 60), C["steel_d"], 3)
    rrect(img, (6, 4, 32, 58), C["steel"])
    rrect(img, (9, 8, 29, 52), C["purple_dd"], 4)
    rrect(img, (10, 9, 28, 51), C["circuit"])
    rrect(img, (12, 11, 26, 49), C["steel_d"], 3)
    # alien silhouette
    ellipse(img, (15, 18, 23, 30), C["acid_dd"])
    ellipse(img, (16, 19, 22, 28), C["acid"])
    rect(img, (15, 30, 23, 40), C["acid_d"])
    line(img, [(16, 40), (14, 47)], C["acid_d"], 2)
    line(img, [(22, 40), (24, 47)], C["acid_d"], 2)
    pixel(img, 17, 23, C["white"])
    pixel(img, 21, 23, C["white"])
    # frame details
    rect(img, (4, 10, 8, 52), C["steel_l"])
    rect(img, (30, 10, 34, 52), C["steel_l"])
    for y in (14, 34, 54):
        rect(img, (6, y, 32, y + 2), C["steel_d"])
        pixel(img, 7, y, C["magenta"])
    return A.finish(img, 38, 62)


def ship_pipes() -> Image.Image:
    img = A.new(52, 34)
    line(img, [(2, 12), (48, 12)], C["steel_d"], 6)
    line(img, [(2, 12), (48, 12)], C["steel"], 3)
    line(img, [(2, 24), (30, 24), (30, 30), (50, 30)], C["steel_d"], 5)
    line(img, [(2, 24), (30, 24), (30, 30), (50, 30)], C["steel_l"], 2)
    for x in (10, 26, 40):
        ellipse(img, (x - 4, 6, x + 4, 18), C["steel_d"])
        ellipse(img, (x - 3, 7, x + 3, 17), C["steel_l"])
        rect(img, (x - 1, 9, x + 1, 15), C["circuit"])
    for x in (12, 36, 48):
        ellipse(img, (x - 3, 21, x + 3, 27), C["steel_d"])
    return A.finish(img, 52, 34)


def ship_vent() -> Image.Image:
    img = A.new(38, 26)
    rrect(img, (2, 3, 36, 23), C["steel_d"], 2)
    rect(img, (4, 5, 34, 21), C["ink2"])
    for i in range(5):
        line(img, [(5, 7 + i * 3), (33, 7 + i * 3)], C["steel_d"], 1)
        line(img, [(5, 8 + i * 3), (33, 8 + i * 3)], C["steel"], 1)
    line(img, [(8, 3), (8, 23)], C["circuit"], 1)
    line(img, [(30, 3), (30, 23)], C["circuit"], 1)
    return A.finish(img, 38, 26)


def ship_light() -> Image.Image:
    img = A.new(14, 8)
    rect(img, (1, 2, 13, 6), C["steel_d"])
    rect(img, (2, 3, 12, 5), C["circuit"])
    rect(img, (4, 3, 10, 4), C["ghost_l"])
    return A.finish(img, 14, 8)


def ship_bolt() -> Image.Image:
    img = A.new(8, 8)
    ellipse(img, (1, 1, 7, 7), C["steel_d"])
    ellipse(img, (2, 2, 6, 6), C["steel_l"])
    line(img, [(2, 3), (5, 3)], C["ink2"], 1)
    return A.finish(img, 8, 8)


def ship_cable() -> Image.Image:
    img = A.new(22, 12)
    line(img, [(1, 6), (8, 4), (14, 8), (21, 6)], C["steel_d"], 3)
    line(img, [(1, 6), (8, 4), (14, 8), (21, 6)], C["circuit"], 1)
    ellipse(img, (4, 3, 8, 7), C["steel_d"])
    return A.finish(img, 22, 12)


def ship_grate() -> Image.Image:
    img = A.new(18, 14)
    rect(img, (1, 1, 17, 13), C["steel_d"])
    rect(img, (2, 2, 16, 12), C["ink2"])
    for i in range(4):
        line(img, [(3 + i * 4, 3), (3 + i * 4, 11)], C["steel"], 1)
    return A.finish(img, 18, 14)


# ---------------------------------------------------------------- thumbnails
def _tile(img: Image.Image, tile: Image.Image) -> None:
    for y in range(0, img.height, tile.height):
        for x in range(0, img.width, tile.width):
            img.alpha_composite(tile, (x, y))


def _glow(img: Image.Image, pos, radius, color, alpha=90):
    g = A.radial(int(radius * 2), color, (0, 0, 0), 2.2)
    g.putalpha(g.getchannel("A").point(lambda v: int(v * alpha / 255)))
    img.alpha_composite(g, (int(pos[0] - radius), int(pos[1] - radius)))


def _vignette(img: Image.Image) -> None:
    w, h = img.size
    ov = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    for i in range(80):
        d.rectangle([i, i, w - i, h - i], outline=(2, 4, 8, 3))
    img.alpha_composite(ov)


def stage_forest() -> Image.Image:
    bg = Image.open(os.path.join(UI, "title_bg.png")).convert("RGBA")
    thumb = bg.resize((480, 270), Image.LANCZOS)
    ov = Image.new("RGBA", (480, 270), (4, 8, 16, 30))
    thumb.alpha_composite(ov)
    return thumb


def stage_hive() -> Image.Image:
    W, H = 960, 540
    img = Image.new("RGBA", (W, H), (20, 12, 26, 255))
    _tile(img, hive_ground(512))
    # darken edges
    shade = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shade)
    sd.rectangle([0, 0, W, 140], fill=(6, 3, 12, 90))
    sd.rectangle([0, H - 120, W, H], fill=(6, 3, 12, 120))
    img.alpha_composite(shade)
    # big props
    pillar = hive_pillar().resize((76 * 4, 132 * 4), Image.NEAREST)
    coral = hive_coral().resize((46 * 5, 56 * 5), Image.NEAREST)
    egg = hive_egg().resize((32 * 5, 42 * 5), Image.NEAREST)
    mnd = hive_mound().resize((56 * 3, 38 * 3), Image.NEAREST)
    img.alpha_composite(pillar, (-30, 100))
    img.alpha_composite(pillar, (700, 40))
    img.alpha_composite(coral, (120, 300))
    img.alpha_composite(coral, (670, 330))
    img.alpha_composite(egg, (250, 300))
    img.alpha_composite(mnd, (40, 410))
    # queen
    q = queen().resize((116 * 2, 116 * 2), Image.NEAREST)
    img.alpha_composite(q, (520, 100))
    # spitter
    sp = spitter().resize((36 * 3, 36 * 3), Image.NEAREST)
    img.alpha_composite(sp, (180, 180))
    _glow(img, (640, 190), 240, (120, 240, 150), 80)
    _glow(img, (340, 350), 140, (190, 90, 200), 60)
    _vignette(img)
    return img.resize((480, 270), Image.LANCZOS)


def stage_ship() -> Image.Image:
    W, H = 960, 540
    img = Image.new("RGBA", (W, H), (10, 16, 26, 255))
    _tile(img, ship_ground(512))
    shade = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shade)
    sd.rectangle([0, 0, W, 120], fill=(2, 5, 12, 110))
    sd.rectangle([0, H - 110, W, H], fill=(2, 5, 12, 120))
    img.alpha_composite(shade)
    wall = ship_wall().resize((72 * 3, 128 * 3), Image.NEAREST)
    pylon = ship_pylon().resize((36 * 4, 92 * 4), Image.NEAREST)
    pod = ship_pod().resize((38 * 4, 62 * 4), Image.NEAREST)
    console = ship_console().resize((46 * 3, 42 * 3), Image.NEAREST)
    img.alpha_composite(wall, (-20, 40))
    img.alpha_composite(wall, (726, 20))
    img.alpha_composite(pylon, (160, 220))
    img.alpha_composite(pylon, (740, 210))
    img.alpha_composite(pod, (470, 250))
    img.alpha_composite(pod, (540, 270))
    img.alpha_composite(console, (310, 360))
    # sentinel
    sen = sentinel().resize((48 * 4, 48 * 4), Image.NEAREST)
    img.alpha_composite(sen, (260, 110))
    # mothership eye
    ms = Image.open(os.path.join(CHAR, "enemy_boss.png")).convert("RGBA")
    ms = ms.resize((112 * 3, 112 * 3), Image.NEAREST)
    img.alpha_composite(ms, (570, -40))
    _glow(img, (640, 180), 220, (110, 226, 208), 80)
    _glow(img, (400, 300), 160, (204, 96, 190), 55)
    _vignette(img)
    return img.resize((480, 270), Image.LANCZOS)


# ---------------------------------------------------------------- main
def main():
    os.makedirs(CHAR, exist_ok=True)
    os.makedirs(FX, exist_ok=True)
    os.makedirs(WORLD, exist_ok=True)
    os.makedirs(UI, exist_ok=True)
    os.makedirs(PREVIEW, exist_ok=True)

    chars = {
        "enemy_spitter": spitter(),
        "enemy_bomber": bomber(),
        "enemy_burrower": burrower(),
        "enemy_brute": brute(),
        "enemy_sentinel": sentinel(),
        "enemy_phase": phase_hunter(),
        "enemy_splitter": splitter(),
        "enemy_queen": queen(),
        "enemy_orb_acid": acid_orb(),
    }
    for name, im in chars.items():
        A.save(im, os.path.join(CHAR, name + ".png"))

    world = {
        "hive_egg": hive_egg(),
        "hive_coral": hive_coral(),
        "hive_pod": hive_pod(),
        "hive_spike": hive_spike(),
        "hive_mound": hive_mound(),
        "hive_pillar": hive_pillar(),
        "hive_spore": hive_spore(),
        "hive_tendril": hive_tendril(),
        "hive_bone": hive_bone(),
        "ship_wall": ship_wall(),
        "ship_pylon": ship_pylon(),
        "ship_console": ship_console(),
        "ship_pod": ship_pod(),
        "ship_pipes": ship_pipes(),
        "ship_vent": ship_vent(),
        "ship_light": ship_light(),
        "ship_bolt": ship_bolt(),
        "ship_cable": ship_cable(),
        "ship_grate": ship_grate(),
    }
    for name, im in world.items():
        A.save(im, os.path.join(WORLD, name + ".png"))

    A.save(hive_ground(512), os.path.join(WORLD, "ground_hive.png"))
    A.save(ship_ground(512), os.path.join(WORLD, "ground_ship.png"))
    A.save(acid_orb(), os.path.join(FX, "orb_acid.png"))
    A.save(stage_forest(), os.path.join(UI, "stage_forest.png"))
    A.save(stage_hive(), os.path.join(UI, "stage_hive.png"))
    A.save(stage_ship(), os.path.join(UI, "stage_ship.png"))

    A.contact(list(chars.items()), os.path.join(PREVIEW, "expansion_chars.png"), scale=4, cols=5)
    A.contact(list(world.items()), os.path.join(PREVIEW, "expansion_world.png"), scale=3, cols=5)
    A.contact(
        [("stage_forest", stage_forest()), ("stage_hive", stage_hive()), ("stage_ship", stage_ship())],
        os.path.join(PREVIEW, "stage_thumbs.png"),
        scale=2,
        cols=3,
    )
    print("expansion assets done")


if __name__ == "__main__":
    main()
