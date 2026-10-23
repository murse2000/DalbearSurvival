"""Icons for the four evolved weapons."""
from __future__ import annotations

import math
import os

from PIL import Image, ImageDraw

import art_lib as A
from art_lib import C

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "art", "ui")
PREVIEW = os.path.join(os.path.dirname(__file__), "preview")


def base() -> Image.Image:
    img = A.new(32, 32)
    A.ellipse(img, (3, 3, 29, 29), C["teal_d"])
    A.ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    A.arc(img, (3, 3, 29, 29), 200, 340, C["gold_d"], 1)
    return img


def icon_barrage() -> Image.Image:
    img = base()
    # crescent
    A.ellipse(img, (5, 5, 19, 21), C["gold"])
    A.ellipse(img, (9, 4, 22, 19), (30, 42, 64))
    # three falling meteors
    for i, x in enumerate((10, 17, 24)):
        y = 12 + i * 2
        A.line(img, [(x, y), (x + 2, y + 7)], C["gold_l"], 1)
        A.ellipse(img, (x - 1, y + 6, x + 4, y + 10), C["gold"])
        A.pixel(img, x + 1, y + 8, C["white"])
    # impacts
    for x, y in ((9, 27), (18, 27), (26, 25)):
        A.line(img, [(x - 2, y), (x + 2, y)], C["mint"])
        A.line(img, [(x, y - 2), (x, y + 2)], C["mint"])
    return A.finish(img, 32, 32)


def icon_orbit() -> Image.Image:
    img = base()
    # orbit ring
    A.arc(img, (4, 8, 28, 24), 0, 360, C["mint_d"], 1)
    A.arc(img, (8, 12, 24, 20), 0, 360, C["gold_d"], 1)
    # 6 satellites
    for i in range(6):
        a = math.tau * i / 6
        x = 16 + math.cos(a) * 12
        y = 16 + math.sin(a) * 6.5
        A.ellipse(img, (x - 2, y - 2, x + 2, y + 2), C["gold"])
        A.pixel(img, x, y - 1, C["white"])
    # core
    A.ellipse(img, (12, 12, 20, 20), C["teal_d"])
    A.ellipse(img, (13, 13, 19, 19), C["mint"])
    A.ellipse(img, (15, 15, 17, 17), C["white"])
    # chain lightning
    A.line(img, [(22, 8), (26, 11), (24, 14), (28, 17)], C["mint"], 1)
    A.pixel(img, 28, 17, C["white"])
    return A.finish(img, 32, 32)


def icon_gravity() -> Image.Image:
    img = base()
    # vortex rings
    for r, c in ((11, C["purple_dd"]), (8, C["purple"]), (5, C["hive_l"])):
        A.arc(img, (16 - r, 16 - r, 16 + r, 16 + r), 30, 320, c, 2)
    # central void
    A.ellipse(img, (12, 12, 20, 20), C["ink"])
    A.ellipse(img, (14, 14, 18, 18), C["purple_dd"])
    # inward arrows
    for a in (0, 120, 240):
        rad = math.radians(a)
        x = 16 + math.cos(rad) * 15
        y = 16 + math.sin(rad) * 15
        A.line(img, [(x, y), (16 + math.cos(rad) * 8, 16 + math.sin(rad) * 8)], C["mint"], 1)
        # arrow head
        A.pixel(img, 16 + math.cos(rad + 0.35) * 8, 16 + math.sin(rad + 0.35) * 8, C["mint"])
        A.pixel(img, 16 + math.cos(rad - 0.35) * 8, 16 + math.sin(rad - 0.35) * 8, C["mint"])
    return A.finish(img, 32, 32)


def icon_nebula() -> Image.Image:
    img = base()
    # three slashes
    beams = [
        ((4, 26), (28, 6), C["gold"]),
        ((3, 19), (25, 3), C["mint"]),
        ((7, 30), (29, 13), C["purple"]),
    ]
    for (x1, y1), (x2, y2), c in beams:
        A.line(img, [(x1, y1), (x2, y2)], C["ink"], 3)
        A.line(img, [(x1, y1), (x2, y2)], c, 1)
    # star at the crossing
    A.poly(img, [(22, 6), (24, 10), (28, 12), (24, 14), (22, 18), (20, 14),
                 (16, 12), (20, 10)], C["gold_l"])
    A.ellipse(img, (20, 10, 24, 14), C["white"])
    return A.finish(img, 32, 32)


def icon_galaxy() -> Image.Image:
    img = base()
    # crescent
    A.ellipse(img, (5, 5, 19, 21), C["gold"])
    A.ellipse(img, (9, 4, 22, 19), (30, 42, 64))
    # violet meteor shower with pull rings
    for i, (x, y) in enumerate(((20, 6), (25, 10), (17, 12), (23, 18))):
        A.line(img, [(x - 3, y - 3), (x, y)], C["purple_l"], 1)
        A.ellipse(img, (x - 2, y - 2, x + 2, y + 2), C["purple"] if i % 2 else C["gold"])
        A.pixel(img, x, y - 1, C["white"])
    A.arc(img, (8, 14, 28, 30), 30, 300, C["purple"], 1)
    A.arc(img, (12, 18, 24, 26), 30, 300, C["gold_d"], 1)
    return A.finish(img, 32, 32)


def icon_life() -> Image.Image:
    img = base()
    # heart
    A.ellipse(img, (8, 8, 16, 16), C["mint"])
    A.ellipse(img, (16, 8, 24, 16), C["mint"])
    A.poly(img, [(8, 13), (16, 24), (24, 13)], C["mint"])
    A.ellipse(img, (11, 11, 14, 14), C["white"])
    # circuit lightning
    A.line(img, [(22, 5), (18, 14), (22, 16), (17, 27)], C["acid"], 2)
    A.pixel(img, 18, 14, C["white"])
    A.pixel(img, 22, 16, C["white"])
    # plus
    A.line(img, [(6, 24), (11, 24)], C["mint_d"], 1)
    A.line(img, [(8, 22), (8, 26)], C["mint_d"], 1)
    return A.finish(img, 32, 32)


def icon_dash() -> Image.Image:
    img = base()
    # comet core
    A.ellipse(img, (14, 10, 24, 20), C["purple_dd"])
    A.ellipse(img, (15, 11, 23, 19), C["purple"])
    A.ellipse(img, (17, 13, 21, 17), C["white"])
    # speed tail
    for i, y in enumerate((12, 16, 20)):
        A.line(img, [(13, y), (4 + i, y + 2)], C["purple_l"], 2 if i == 1 else 1)
    # orbit ring + sparks
    A.arc(img, (6, 8, 30, 26), 200, 340, C["mint"], 1)
    A.pixel(img, 27, 8, C["mint"])
    A.pixel(img, 29, 12, C["white"])
    return A.finish(img, 32, 32)


def icon_tempest() -> Image.Image:
    img = base()
    # three crescents in a spin
    for i in range(3):
        a = math.tau * i / 3
        cx = 16 + math.cos(a) * 8
        cy = 16 + math.sin(a) * 8
        A.arc(img, (cx - 7, cy - 7, cx + 7, cy + 7), 200, 340, C["gold"], 2)
        A.pixel(img, cx + 4, cy - 4, C["white"])
    # heart in the middle
    A.ellipse(img, (12, 12, 17, 17), C["mint"])
    A.ellipse(img, (16, 12, 20, 17), C["mint"])
    A.poly(img, [(12, 15), (16, 21), (20, 15)], C["mint"])
    A.pixel(img, 15, 14, C["white"])
    # wind arcs
    A.arc(img, (2, 4, 30, 30), 20, 120, C["mint_d"], 1)
    A.arc(img, (2, 4, 30, 30), 200, 300, C["mint_d"], 1)
    return A.finish(img, 32, 32)


def main():
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(PREVIEW, exist_ok=True)
    icons = {
        "icon_evo_barrage": icon_barrage(),
        "icon_evo_orbit": icon_orbit(),
        "icon_evo_gravity": icon_gravity(),
        "icon_evo_nebula": icon_nebula(),
        "icon_evo_galaxy": icon_galaxy(),
        "icon_evo_life": icon_life(),
        "icon_evo_dash": icon_dash(),
        "icon_evo_tempest": icon_tempest(),
    }
    for name, img in icons.items():
        A.save(img, os.path.join(OUT, name + ".png"))
    A.contact(list(icons.items()), os.path.join(PREVIEW, "evo_icons.png"), scale=4, cols=4)
    print("evolution icons done")


if __name__ == "__main__":
    main()
