"""Icons for the four new Moonlight skills."""
from __future__ import annotations

import math
import os

from PIL import Image

import art_lib as A
from art_lib import C

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "art", "ui")
PREVIEW = os.path.join(os.path.dirname(__file__), "preview")


def base(accent) -> Image.Image:
    img = A.new(32, 32)
    A.ellipse(img, (3, 3, 29, 29), C["teal_d"])
    A.ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    A.arc(img, (3, 3, 29, 29), 200, 340, accent, 1)
    return img


def icon_meteor() -> Image.Image:
    img = base(C["orange_d"])
    # falling meteor streak
    for i in range(8):
        x = 25 - i * 2
        y = 5 + i * 2
        A.pixel(img, x, y, C["gold_l"] if i < 3 else C["orange"])
        if i % 2 == 0:
            A.pixel(img, x + 1, y, C["orange_d"])
    A.ellipse(img, (12, 15, 22, 25), C["orange"])
    A.ellipse(img, (14, 17, 20, 23), C["gold_l"])
    A.ellipse(img, (16, 19, 18, 21), C["white"])
    # impact rays
    for x, y in ((8, 27), (16, 29), (24, 27)):
        A.line(img, [(x - 2, y), (x + 2, y)], C["gold"])
        A.line(img, [(x, y - 2), (x, y + 1)], C["gold_l"])
    A.pixel(img, 8, 8, C["gold_l"])
    A.pixel(img, 27, 23, C["orange"])
    return A.finish(img, 32, 32)


def icon_chain() -> Image.Image:
    img = base(C["purple_d"])
    # main jagged bolt
    pts = [(6, 4), (13, 13), (9, 14), (20, 26), (17, 16), (24, 15)]
    A.line(img, pts, C["ink"], 4)
    A.line(img, pts, C["mint"], 2)
    for i, p in enumerate(pts):
        if i in (1, 3, 5):
            A.pixel(img, p[0], p[1], C["white"])
    # side arcs
    A.line(img, [(4, 18), (10, 20), (7, 25), (12, 28)], C["purple_l"], 1)
    A.line(img, [(22, 7), (27, 10), (24, 14)], C["mint"], 1)
    A.pixel(img, 5, 17, C["white"])
    A.pixel(img, 28, 10, C["white"])
    return A.finish(img, 32, 32)


def icon_singularity() -> Image.Image:
    img = base(C["purple_d"])
    for r, c, w in ((13, C["purple_dd"], 2), (10, C["purple"], 2),
                    (7, C["purple_l"], 1)):
        A.arc(img, (16 - r, 16 - r, 16 + r, 16 + r), 25, 325, c, w)
    A.ellipse(img, (11, 11, 21, 21), C["ink"])
    A.ellipse(img, (14, 14, 18, 18), C["purple_dd"])
    A.pixel(img, 16, 16, C["white"])
    # inward arrows
    for a in (0, 120, 240):
        rad = math.radians(a)
        x = 16 + math.cos(rad) * 14
        y = 16 + math.sin(rad) * 14
        A.line(img, [(x, y), (16 + math.cos(rad) * 8, 16 + math.sin(rad) * 8)],
               C["mint"], 1)
        A.pixel(img, 16 + math.cos(rad + 0.35) * 8, 16 + math.sin(rad + 0.35) * 8, C["mint"])
        A.pixel(img, 16 + math.cos(rad - 0.35) * 8, 16 + math.sin(rad - 0.35) * 8, C["mint"])
    return A.finish(img, 32, 32)


def icon_blades() -> Image.Image:
    img = base(C["gold_d"])
    # two crescent blades crossed in an X
    A.line(img, [(7, 26), (23, 7)], C["ink"], 5)
    A.line(img, [(25, 26), (9, 7)], C["ink"], 5)
    A.line(img, [(8, 26), (23, 8)], C["gold"], 3)
    A.line(img, [(9, 25), (22, 9)], C["gold_l"], 1)
    A.line(img, [(24, 26), (9, 8)], C["gold"], 3)
    A.line(img, [(23, 25), (10, 9)], C["gold_l"], 1)
    # curved tips
    A.poly(img, [(23, 8), (28, 4), (25, 11)], C["gold_l"])
    A.poly(img, [(9, 8), (4, 4), (7, 11)], C["gold_l"])
    # pommels and glints
    A.ellipse(img, (5, 24, 9, 28), C["orange"])
    A.ellipse(img, (23, 24, 27, 28), C["orange"])
    for x, y in ((4, 12), (28, 19), (14, 29), (18, 3)):
        A.pixel(img, x, y, C["white"])
    A.pixel(img, 17, 16, C["white"])
    return A.finish(img, 32, 32)


def main():
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(PREVIEW, exist_ok=True)
    icons = {
        "icon_meteor": icon_meteor(),
        "icon_chain": icon_chain(),
        "icon_singularity": icon_singularity(),
        "icon_blades": icon_blades(),
    }
    for name, img in icons.items():
        A.save(img, os.path.join(OUT, name + ".png"))
    A.contact(list(icons.items()), os.path.join(PREVIEW, "new_weapon_icons.png"),
              scale=4, cols=4)
    print("new weapon icons done")


if __name__ == "__main__":
    main()
