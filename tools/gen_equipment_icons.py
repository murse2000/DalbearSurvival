"""Equipment slot icons: armor, weapons interface, rings and necklace."""
from __future__ import annotations

import os

from PIL import Image

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


def icon_helmet() -> Image.Image:
    img = base()
    A.ellipse(img, (8, 7, 24, 24), C["steel"])
    A.ellipse(img, (9, 8, 23, 22), C["steel_l"])
    A.rect(img, (8, 17, 24, 23), C["steel_d"])
    A.rect(img, (10, 18, 22, 21), C["ink2"])
    A.line(img, [(12, 19), (20, 19)], C["mint"])
    A.line(img, [(16, 7), (16, 12)], C["steel_l"])
    A.pixel(img, 16, 5, C["gold_l"])
    A.line(img, [(8, 23), (24, 23)], C["gold_d"])
    return A.finish(img, 32, 32)


def icon_gloves() -> Image.Image:
    img = base()
    A.rrect(img, (7, 10, 24, 25), C["brown"], 3)
    A.rrect(img, (8, 11, 23, 23), C["brown_d"], 2)
    A.rect(img, (9, 14, 22, 16), C["gold_d"])
    for x in (10, 14, 18, 22):
        A.line(img, [(x, 9), (x, 13)], C["cream2"])
        A.pixel(img, x, 8, C["cream"])
    A.rect(img, (10, 20, 21, 22), C["gold"])
    A.pixel(img, 16, 21, C["gold_l"])
    return A.finish(img, 32, 32)


def icon_chest() -> Image.Image:
    img = base()
    A.poly(img, [(7, 11), (12, 8), (20, 8), (25, 11), (23, 24), (9, 24)], C["steel"])
    A.poly(img, [(9, 12), (13, 10), (19, 10), (23, 12), (21, 22), (11, 22)], C["steel_l"])
    A.rect(img, (13, 11, 19, 23), C["gold_d"])
    A.rect(img, (14, 13, 18, 21), C["gold"])
    A.line(img, [(16, 14), (16, 20)], C["gold_l"])
    A.line(img, [(9, 16), (12, 16)], C["mint"])
    A.line(img, [(20, 16), (23, 16)], C["mint"])
    return A.finish(img, 32, 32)


def icon_pants() -> Image.Image:
    img = base()
    A.rect(img, (9, 8, 23, 13), C["steel_d"])
    A.rect(img, (11, 8, 21, 11), C["steel"])
    A.poly(img, [(10, 13), (16, 13), (15, 25), (9, 25)], C["steel"])
    A.poly(img, [(16, 13), (22, 13), (23, 25), (17, 25)], C["steel_l"])
    A.line(img, [(16, 14), (16, 23)], C["steel_d"])
    A.rect(img, (9, 23, 15, 25), C["gold_d"])
    A.rect(img, (17, 23, 23, 25), C["gold_d"])
    A.pixel(img, 12, 18, C["mint"])
    A.pixel(img, 20, 18, C["mint"])
    return A.finish(img, 32, 32)


def icon_boots() -> Image.Image:
    img = base()
    A.rrect(img, (9, 7, 17, 22), C["brown"], 2)
    A.poly(img, [(14, 16), (23, 20), (24, 25), (9, 25), (9, 21)], C["brown_d"])
    A.rect(img, (9, 24, 24, 26), C["gold_d"])
    A.rect(img, (10, 9, 16, 11), C["gold"])
    A.pixel(img, 13, 10, C["gold_l"])
    A.line(img, [(18, 21), (22, 22)], C["cream2"])
    return A.finish(img, 32, 32)


def icon_cape() -> Image.Image:
    img = base()
    A.poly(img, [(11, 7), (21, 7), (25, 26), (7, 26)], C["purple_d"])
    A.poly(img, [(12, 9), (20, 9), (22, 24), (10, 24)], C["purple"])
    A.line(img, [(16, 10), (16, 23)], C["purple_l"])
    A.line(img, [(10, 25), (22, 25)], C["gold_d"])
    A.pixel(img, 9, 25, C["gold"])
    A.pixel(img, 23, 25, C["gold"])
    A.pixel(img, 16, 6, C["moon"])
    return A.finish(img, 32, 32)


def icon_ring() -> Image.Image:
    img = base()
    A.ellipse(img, (9, 9, 23, 25), C["gold_d"])
    A.ellipse(img, (11, 11, 21, 23), (30, 42, 64))
    A.ellipse(img, (12, 10, 20, 18), C["gold"])
    A.ellipse(img, (14, 8, 18, 13), C["mint"])
    A.pixel(img, 16, 9, C["mint"])
    A.pixel(img, 16, 12, C["white"])
    A.pixel(img, 9, 19, C["gold_l"])
    A.pixel(img, 22, 20, C["gold_l"])
    return A.finish(img, 32, 32)


def icon_necklace() -> Image.Image:
    img = base()
    A.arc(img, (7, 6, 25, 23), 15, 165, C["gold"], 2)
    for x, y in ((9, 11), (13, 16), (19, 16), (23, 11)):
        A.pixel(img, x, y, C["gold_l"])
    A.poly(img, [(13, 17), (19, 17), (16, 25)], C["gold_d"])
    A.ellipse(img, (13, 18, 19, 24), C["mint"])
    A.pixel(img, 16, 19, C["white"])
    A.pixel(img, 16, 22, C["mint"])
    return A.finish(img, 32, 32)


def main():
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(PREVIEW, exist_ok=True)
    icons = {
        "icon_equip_helmet": icon_helmet(),
        "icon_equip_gloves": icon_gloves(),
        "icon_equip_chest": icon_chest(),
        "icon_equip_pants": icon_pants(),
        "icon_equip_boots": icon_boots(),
        "icon_equip_cape": icon_cape(),
        "icon_equip_ring": icon_ring(),
        "icon_equip_necklace": icon_necklace(),
    }
    for name, img in icons.items():
        A.save(img, os.path.join(OUT, name + ".png"))
    A.contact(list(icons.items()), os.path.join(PREVIEW, "equipment_icons.png"), scale=4, cols=4)
    print("equipment icons done")


if __name__ == "__main__":
    main()
