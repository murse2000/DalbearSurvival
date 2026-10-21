"""Ability icons: dash and ultimate."""
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
    A.arc(img, (3, 3, 29, 29), 200, 340, C["mint_d"], 1)
    return img


def icon_dash() -> Image.Image:
    img = base()
    # motion lines
    for y, ln in ((12, 7), (17, 10), (22, 6)):
        A.line(img, [(4, y), (4 + ln, y)], C["mint"])
        A.pixel(img, 4 + ln, y - 1, C["ghost_l"])
    # bear paw
    A.ellipse(img, (13, 13, 23, 24), C["cream"])
    A.ellipse(img, (14, 16, 22, 23), C["cream2"])
    A.ellipse(img, (15, 17, 19, 21), C["brown"])
    for x, y in ((13, 9), (18, 7), (23, 10)):
        A.ellipse(img, (x - 2, y - 2, x + 2, y + 2), C["cream"])
        A.pixel(img, x, y, C["pink"])
    A.line(img, [(24, 24), (28, 20)], C["gold"])
    A.pixel(img, 28, 19, C["gold_l"])
    return A.finish(img, 32, 32)


def icon_ultimate() -> Image.Image:
    img = base()
    # moon
    A.ellipse(img, (9, 4, 25, 20), C["moon"])
    A.ellipse(img, (15, 2, 28, 15), (30, 42, 64))
    A.ellipse(img, (12, 8, 15, 11), C["cream2"])
    A.ellipse(img, (19, 13, 21, 15), C["cream2"])
    # beam
    A.poly(img, [(14, 15), (21, 15), (24, 28), (11, 28)], C["gold_d"])
    A.poly(img, [(15, 16), (20, 16), (22, 27), (13, 27)], C["gold"])
    A.rect(img, (16, 17, 19, 26), C["gold_l"])
    # impact
    for x, y in ((8, 27), (16, 29), (24, 26)):
        A.line(img, [(x - 2, y), (x + 2, y)], C["mint"])
        A.line(img, [(x, y - 2), (x, y + 1)], C["mint"])
    # sparkles
    A.pixel(img, 7, 7, C["gold_l"])
    A.pixel(img, 27, 17, C["mint"])
    A.pixel(img, 25, 7, C["white"])
    return A.finish(img, 32, 32)


def main():
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(PREVIEW, exist_ok=True)
    icons = {"icon_dash": icon_dash(), "icon_ultimate": icon_ultimate()}
    for name, img in icons.items():
        A.save(img, os.path.join(OUT, name + ".png"))
    A.contact(list(icons.items()), os.path.join(PREVIEW, "ability_icons.png"), scale=5, cols=2)
    print("ability icons done")


if __name__ == "__main__":
    main()
