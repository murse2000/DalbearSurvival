"""Alien invasion enemy art: xeno blob, drone, grey raider, plasma jelly,
battle mech, mothership, energy orbs."""
from __future__ import annotations

import math
import os

from PIL import Image, ImageDraw, ImageFilter

import art_lib as A
from art_lib import C, ellipse, rect, rrect, poly, line, arc, pixel

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "art", "char")
PREVIEW = os.path.join(os.path.dirname(__file__), "preview")


def xeno_blob() -> Image.Image:
    img = A.new(28, 26)
    # antennae
    line(img, [(9, 11), (6, 5), (5, 3)], C["mint_d"], 1)
    line(img, [(19, 11), (22, 5), (23, 3)], C["mint_d"], 1)
    ellipse(img, (3, 1, 7, 5), C["mint"])
    ellipse(img, (21, 1, 25, 5), C["mint"])
    pixel(img, 5, 2, C["white"])
    pixel(img, 23, 2, C["white"])
    # body
    ellipse(img, (3, 8, 25, 24), C["slime_d"])
    ellipse(img, (3, 7, 25, 23), C["slime"])
    rect(img, (5, 16, 23, 23), C["slime"])
    ellipse(img, (4, 16, 24, 25), C["slime_d"])
    ellipse(img, (7, 10, 16, 14), C["slime_l"])
    ellipse(img, (18, 12, 22, 15), C["slime_l"])
    # alien eyes
    ellipse(img, (8, 12, 13, 19), C["ink"])
    ellipse(img, (15, 12, 20, 19), C["ink"])
    ellipse(img, (9, 13, 11, 16), C["mint"])
    ellipse(img, (17, 13, 19, 16), C["mint"])
    pixel(img, 9, 13, C["white"])
    pixel(img, 17, 13, C["white"])
    # grin
    line(img, [(11, 21), (14, 23), (17, 21)], C["ink"])
    rect(img, (12, 22, 13, 23), C["bone"])
    rect(img, (15, 22, 16, 23), C["bone"])
    # spots
    ellipse(img, (6, 17, 8, 19), C["slime_l"])
    ellipse(img, (21, 17, 23, 20), C["slime_l"])
    arc(img, (5, 8, 23, 21), 200, 250, C["slime_l"], 1)
    return A.finish(img, 28, 26)


def drone(frame: int = 0) -> Image.Image:
    img = A.new(34, 26)
    # hull
    ellipse(img, (1, 8, 33, 23), C["gray_d"])
    ellipse(img, (2, 9, 32, 21), C["gray"])
    ellipse(img, (6, 11, 28, 20), C["gray_l"])
    ellipse(img, (9, 12, 25, 19), C["gray"])
    # rim lights
    for i, (x, y) in enumerate(((4, 13), (8, 19), (17, 21), (26, 19), (30, 13))):
        on = (frame + i) % 2 == 0
        ellipse(img, (x - 1, y - 1, x + 2, y + 2), C["mint"] if on else C["mint_d"])
    # dome
    ellipse(img, (11, 2, 23, 13), C["teal_d"])
    ellipse(img, (12, 3, 22, 12), C["teal"])
    ellipse(img, (14, 4, 18, 7), C["mint"])
    ellipse(img, (15, 5, 17, 6), C["white"])
    # antenna
    line(img, [(17, 3), (17, 0)], C["gray_l"])
    pixel(img, 17, 0, C["coral"])
    # panel lines
    line(img, [(3, 11), (8, 15)], C["gray_d"])
    line(img, [(31, 11), (26, 15)], C["gray_d"])
    line(img, [(12, 20), (22, 20)], C["gray_d"])
    return A.finish(img, 34, 26)


def grey_alien() -> Image.Image:
    img = A.new(28, 38)
    # legs
    line(img, [(11, 30), (9, 35), (10, 37)], C["purple_dd"], 3)
    line(img, [(17, 30), (19, 35), (18, 37)], C["purple_dd"], 3)
    rect(img, (7, 35, 11, 37), C["gray_d"])
    rect(img, (17, 35, 21, 37), C["gray_d"])
    # suit
    rrect(img, (8, 18, 20, 32), C["purple_dd"], 2)
    rrect(img, (9, 19, 19, 29), C["purple_d"])
    line(img, [(10, 29), (18, 29)], C["ink"])
    rect(img, (13, 21, 16, 24), C["mint"])
    rect(img, (14, 22, 15, 23), C["white"])
    # collar
    rect(img, (10, 18, 18, 20), C["gray_l"])
    rect(img, (12, 19, 16, 20), C["ink"])
    # arms
    line(img, [(9, 20), (5, 25), (4, 29)], C["gray"], 2)
    line(img, [(19, 20), (23, 24), (22, 27)], C["gray"], 2)
    rect(img, (2, 27, 6, 30), C["gray_l"])
    # ray gun
    rrect(img, (19, 23, 27, 27), C["gray_d"], 1)
    rect(img, (22, 26, 24, 29), C["gray"])
    rect(img, (24, 24, 27, 26), C["mint"])
    rect(img, (21, 24, 24, 25), C["gray_l"])
    # big head
    ellipse(img, (6, 1, 22, 19), C["gray"])
    ellipse(img, (7, 2, 21, 18), C["gray_l"])
    ellipse(img, (9, 4, 19, 15), C["gray"])
    # eyes
    poly(img, [(8, 9), (13, 7), (13, 13), (9, 13)], C["ink"])
    poly(img, [(20, 9), (15, 7), (15, 13), (19, 13)], C["ink"])
    pixel(img, 9, 9, C["mint"])
    pixel(img, 18, 9, C["mint"])
    # mouth + nostrils
    line(img, [(12, 16), (14, 17), (16, 16)], C["gray_d"])
    pixel(img, 11, 15, C["gray_d"])
    pixel(img, 17, 15, C["gray_d"])
    # head shine
    arc(img, (8, 2, 20, 14), 200, 260, C["white"], 1)
    return A.finish(img, 28, 38)


def plasma_jelly() -> Image.Image:
    img = A.new(30, 36)
    # tentacles
    line(img, [(7, 20), (6, 27), (8, 33), (6, 35)], C["purple_d"], 2)
    line(img, [(12, 22), (11, 29), (13, 34)], C["purple"], 1)
    line(img, [(18, 22), (19, 29), (17, 34)], C["purple"], 1)
    line(img, [(23, 20), (24, 27), (22, 33), (24, 35)], C["purple_d"], 2)
    # bell
    ellipse(img, (4, 3, 26, 25), C["purple_dd"])
    ellipse(img, (4, 2, 26, 24), C["purple"])
    ellipse(img, (5, 10, 25, 24), C["purple_dd"])
    rect(img, (6, 16, 24, 23), C["purple"])
    ellipse(img, (5, 17, 25, 25), C["purple_dd"])
    # inner glow + core
    ellipse(img, (11, 9, 19, 19), C["purple_l"])
    ellipse(img, (12, 11, 18, 18), C["mint"])
    ellipse(img, (14, 13, 16, 16), C["white"])
    # face spots
    ellipse(img, (9, 13, 11, 16), C["ink2"])
    ellipse(img, (19, 13, 21, 16), C["ink2"])
    pixel(img, 9, 13, C["mint"])
    pixel(img, 19, 13, C["mint"])
    # rim + speckles
    arc(img, (5, 3, 25, 22), 190, 250, C["ghost_l"], 1)
    ellipse(img, (7, 5, 9, 7), C["ghost_l"])
    ellipse(img, (21, 7, 23, 9), C["ghost_l"])
    ellipse(img, (15, 21, 17, 23), C["mint_d"])
    return A.finish(img, 30, 36)


def battle_mech() -> Image.Image:
    img = A.new(48, 48)
    # reverse-joint legs
    line(img, [(17, 29), (11, 35), (14, 43)], C["gray_d"], 4)
    line(img, [(31, 29), (37, 35), (34, 43)], C["gray_d"], 4)
    line(img, [(17, 29), (11, 35)], C["gray_l"], 1)
    line(img, [(31, 29), (37, 35)], C["gray_l"], 1)
    rect(img, (9, 42, 17, 46), C["gray_d"])
    rect(img, (31, 42, 39, 46), C["gray_d"])
    rect(img, (10, 43, 14, 45), C["gray_l"])
    rect(img, (34, 43, 38, 45), C["gray_l"])
    # hip
    rrect(img, (14, 26, 34, 33), C["gray_d"], 2)
    # torso
    rrect(img, (11, 13, 37, 31), C["ink"])
    rrect(img, (12, 14, 36, 30), C["gray_d"])
    rrect(img, (14, 15, 34, 28), C["gray"])
    rrect(img, (16, 16, 32, 24), C["gray_l"])
    # chest vents + core
    line(img, [(18, 18), (18, 22)], C["gray_d"])
    line(img, [(21, 18), (21, 22)], C["gray_d"])
    ellipse(img, (22, 18, 28, 26), C["ink2"])
    ellipse(img, (23, 19, 27, 25), C["mint_d"])
    ellipse(img, (24, 20, 26, 24), C["mint"])
    # purple alien sigil
    line(img, [(15, 26), (19, 24), (23, 26)], C["purple"])
    line(img, [(25, 26), (29, 24), (33, 26)], C["purple"])
    # shoulder pods
    rrect(img, (3, 15, 12, 27), C["ink"], 2)
    rrect(img, (4, 16, 11, 26), C["gray_d"])
    rrect(img, (5, 17, 10, 21), C["gray"])
    rect(img, (6, 24, 9, 27), C["mint_d"])
    rrect(img, (36, 15, 45, 27), C["ink"], 2)
    rrect(img, (37, 16, 44, 26), C["gray_d"])
    rrect(img, (38, 17, 43, 21), C["gray"])
    rect(img, (39, 24, 42, 27), C["mint_d"])
    # cannon barrels
    rect(img, (6, 28, 9, 33), C["gray_d"])
    rect(img, (39, 28, 42, 33), C["gray_d"])
    rect(img, (7, 32, 8, 33), C["coral"])
    rect(img, (40, 32, 41, 33), C["coral"])
    # head / visor
    rrect(img, (17, 4, 31, 15), C["ink"], 2)
    rrect(img, (18, 5, 30, 14), C["gray"])
    rrect(img, (19, 7, 29, 12), C["gray_d"])
    rect(img, (20, 8, 28, 11), C["red"])
    rect(img, (21, 8, 23, 10), C["gold_l"])
    line(img, [(24, 4), (24, 1)], C["gray_l"])
    pixel(img, 24, 1, C["mint"])
    # panel details
    line(img, [(14, 16), (14, 27)], C["gray_l"])
    line(img, [(34, 16), (34, 27)], C["gray_d"])
    line(img, [(17, 28), (31, 28)], C["gray_l"])
    return A.finish(img, 48, 48)


def mothership() -> Image.Image:
    img = A.new(112, 112)
    cy = 58
    # outer hull
    ellipse(img, (4, 26, 108, 92), C["ink"])
    ellipse(img, (6, 28, 106, 90), C["gray_d"])
    ellipse(img, (12, 32, 100, 86), C["purple_dd"])
    # hull panels
    for i in range(12):
        a = math.radians(i * 30)
        x = 56 + math.cos(a) * 47
        y = 59 + math.sin(a) * 28
        ellipse(img, (x - 3, y - 2, x + 3, y + 2), C["gray"])
    # inner disc
    ellipse(img, (22, 36, 90, 84), C["gray_d"])
    ellipse(img, (26, 38, 86, 80), C["gray"])
    ellipse(img, (34, 41, 78, 75), C["gray_l"])
    # rim lights
    for i in range(10):
        a = math.radians(i * 36 + 18)
        x = 56 + math.cos(a) * 44
        y = 59 + math.sin(a) * 25
        ellipse(img, (x - 2, y - 2, x + 2, y + 2), C["mint"] if i % 2 == 0 else C["gold"])
    # lower ring shadows
    arc(img, (16, 34, 96, 86), 20, 160, C["ink2"], 2)
    arc(img, (20, 36, 92, 84), 20, 160, C["purple_d"], 1)
    # dome
    ellipse(img, (36, 18, 76, 62), C["ink"])
    ellipse(img, (38, 20, 74, 60), C["purple_dd"])
    ellipse(img, (41, 22, 71, 57), C["purple"])
    ellipse(img, (44, 24, 68, 54), C["purple_d"])
    # giant eye
    ellipse(img, (47, 30, 65, 48), C["ink"])
    ellipse(img, (49, 32, 63, 46), C["mint_d"])
    ellipse(img, (51, 34, 61, 44), C["mint"])
    rect(img, (54, 35, 58, 43), C["ink2"])
    rect(img, (55, 36, 57, 38), C["gold_l"])
    ellipse(img, (51, 34, 57, 38), C["white"])
    # dome shine
    arc(img, (42, 22, 70, 54), 200, 250, C["ghost_l"], 2)
    line(img, [(45, 24), (52, 21)], C["white"])
    # antennae
    line(img, [(48, 20), (44, 8), (46, 4)], C["gray_l"], 1)
    line(img, [(64, 20), (68, 9), (66, 5)], C["gray_l"], 1)
    ellipse(img, (44, 2, 48, 6), C["coral"])
    ellipse(img, (64, 3, 68, 7), C["mint"])
    # bottom beam ports
    for x in (40, 56, 72):
        ellipse(img, (x - 4, 79, x + 4, 85), C["ink2"])
        ellipse(img, (x - 3, 80, x + 3, 84), C["mint_d"])
        ellipse(img, (x - 2, 81, x + 2, 83), C["mint"])
    # spikes
    for i in range(8):
        a = math.radians(i * 45 + 22.5)
        x = 56 + math.cos(a) * 52
        y = 59 + math.sin(a) * 33
        x2 = 56 + math.cos(a) * 58
        y2 = 59 + math.sin(a) * 38
        line(img, [(x, y), (x2, y2)], C["gray_d"], 2)
    return A.finish(img, 112, 112)


def energy_orb() -> Image.Image:
    img = A.new(18, 18)
    ellipse(img, (3, 3, 15, 15), C["mint_d"])
    ellipse(img, (4, 4, 14, 14), C["mint"])
    ellipse(img, (6, 6, 12, 12), C["ghost_l"])
    ellipse(img, (7, 7, 10, 10), C["white"])
    line(img, [(1, 9), (3, 9)], C["mint_d"])
    line(img, [(15, 9), (17, 9)], C["mint_d"])
    line(img, [(9, 1), (9, 3)], C["mint_d"])
    line(img, [(9, 15), (9, 17)], C["mint_d"])
    return A.finish(img, 18, 18)


def beam(width=96, height=320) -> Image.Image:
    """Soft alien tractor/attack beam, vertical gradient."""
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    px = img.load()
    for y in range(height):
        t = y / (height - 1)
        fade = (1.0 - t) ** 0.6
        for x in range(width):
            nx = abs(x - width / 2) / (width / 2)
            edge = max(0.0, 1.0 - nx) ** 1.5
            a = int(150 * fade * edge)
            if a > 0:
                px[x, y] = (140, 240, 200, a)
    # bright core
    d = ImageDraw.Draw(img)
    for x in range(int(width * 0.42), int(width * 0.58)):
        d.line([(x, 0), (x, height)], fill=(220, 255, 240, 120))
    return img.filter(ImageFilter.GaussianBlur(1.2))


def boss_aura() -> Image.Image:
    return A.radial(160, (120, 230, 190), (0, 0, 0), 2.6)


def main():
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(PREVIEW, exist_ok=True)
    items = {
        "enemy_slime": xeno_blob(),
        "enemy_bat_0": drone(0),
        "enemy_bat_1": drone(1),
        "enemy_skeleton": grey_alien(),
        "enemy_ghost": plasma_jelly(),
        "enemy_stump": battle_mech(),
        "enemy_boss": mothership(),
        "enemy_orb": energy_orb(),
        "boss_beam": beam(),
        "boss_aura": boss_aura(),
    }
    for name, img in items.items():
        A.save(img, os.path.join(OUT, name + ".png"))
    A.save(A.make_sheet([drone(0), drone(1)], 34, 26, cols=2),
           os.path.join(OUT, "enemy_bat_sheet.png"))
    A.contact(list(items.items()), os.path.join(PREVIEW, "aliens.png"), scale=4, cols=4)
    print("aliens done")


if __name__ == "__main__":
    main()
