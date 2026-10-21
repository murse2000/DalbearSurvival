"""Generates the character sprites (player bear, enemies, boss) and shadows."""
from __future__ import annotations

import math
import os
import random

from PIL import Image

import art_lib as A
from art_lib import C, ellipse, rect, rrect, poly, line, arc, pixel

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "art", "char")
PREVIEW = os.path.join(os.path.dirname(__file__), "preview")

PLAYER_W, PLAYER_H = 32, 36


# ------------------------------------------------------------------ player
def bear_frame(direction: str, f: int) -> Image.Image:
    """direction: front / side / back, f: 0..3 walk frame."""
    img = A.new(PLAYER_W, PLAYER_H)
    bob = 1 if f in (1, 3) else 0
    yoff = -bob
    stride = [0, 2, 0, -2][f]
    tail_sway = [0, 1, 0, -1][f]

    if direction == "front":
        lift_l = 1 if f == 1 else 0
        lift_r = 1 if f == 3 else 0
        # legs
        rrect(img, (11, 28 + yoff + lift_l, 15, 34), C["cream2"], 2)
        rrect(img, (17, 28 + yoff + lift_r, 21, 34), C["cream2"], 2)
        ellipse(img, (11, 31 + lift_l, 15, 34), C["brown"])
        ellipse(img, (17, 31 + lift_r, 21, 34), C["brown"])
        # body
        ellipse(img, (9, 17 + yoff, 23, 31 + yoff), C["cream"])
        ellipse(img, (12, 21 + yoff, 20, 30 + yoff), C["cream3"])
        ellipse(img, (9, 25 + yoff, 23, 32 + yoff), C["cream2"])
        ellipse(img, (12, 22 + yoff, 20, 29 + yoff), C["cream3"])
        # arms
        ellipse(img, (5, 18 + yoff, 10, 27 + yoff), C["cream"])
        ellipse(img, (22, 18 + yoff, 27, 27 + yoff), C["cream"])
        ellipse(img, (6, 24 + yoff, 10, 27 + yoff), C["cream2"])
        ellipse(img, (22, 24 + yoff, 26, 27 + yoff), C["cream2"])
        # head
        ellipse(img, (7, 4 + yoff, 25, 22 + yoff), C["cream"])
        # ears
        ellipse(img, (7, 2 + yoff, 13, 8 + yoff), C["cream"])
        ellipse(img, (19, 2 + yoff, 25, 8 + yoff), C["cream"])
        ellipse(img, (8, 3 + yoff, 12, 7 + yoff), C["brown"])
        ellipse(img, (20, 3 + yoff, 24, 7 + yoff), C["brown"])
        ellipse(img, (9, 4 + yoff, 11, 6 + yoff), C["pink"])
        ellipse(img, (21, 4 + yoff, 23, 6 + yoff), C["pink"])
        # muzzle
        ellipse(img, (12, 13 + yoff, 20, 20 + yoff), C["cream3"])
        ellipse(img, (15, 14 + yoff, 17, 17 + yoff), C["ink"])
        line(img, [(16, 17 + yoff), (16, 18 + yoff)], C["ink"])
        # eyes
        rect(img, (10, 10 + yoff, 12, 13 + yoff), C["ink"])
        rect(img, (20, 10 + yoff, 22, 13 + yoff), C["ink"])
        pixel(img, 10.5, 10.5, C["white"])
        pixel(img, 20.5, 10.5, C["white"])
        # cheeks
        rect(img, (8, 14 + yoff, 9, 15 + yoff), C["pink"])
        rect(img, (23, 14 + yoff, 24, 15 + yoff), C["pink"])
        # scarf
        rrect(img, (8, 18 + yoff, 24, 23 + yoff), C["ink"], 1)
        rrect(img, (9, 19 + yoff, 23, 22 + yoff), C["coral"], 1)
        rrect(img, (6, 21 + yoff, 11, 26 + yoff), C["ink"], 2)
        rrect(img, (7, 22 + yoff, 10, 25 + yoff), C["coral_d"], 1)
        poly(img, [(7, 24 + yoff), (4 + tail_sway, 30 + yoff), (9, 28 + yoff)],
             C["coral"])
        poly(img, [(7, 25 + yoff), (6 + tail_sway, 29 + yoff), (9, 27 + yoff)],
             C["coral_d"])
        pixel(img, 8, 23 + yoff, C["gold"])
        # moon badge on the scarf
        ellipse(img, (18, 19 + yoff, 23, 24 + yoff), C["ink"])
        ellipse(img, (19, 20 + yoff, 22, 23 + yoff), C["gold"])
        ellipse(img, (20, 20 + yoff, 23, 23 + yoff), C["coral"])
        # rim light
        line(img, [(10, 5 + yoff), (15, 4 + yoff)], C["cream3"])

    elif direction == "side":
        # jetpack (behind)
        rrect(img, (5, 19 + yoff, 10, 28 + yoff), C["ink"], 2)
        rrect(img, (6, 20 + yoff, 9, 27 + yoff), C["teal"], 1)
        rrect(img, (6, 22 + yoff, 9, 23 + yoff), C["gold_d"], 1)
        rect(img, (6, 27 + yoff, 9, 29 + yoff), C["gold"])
        # tail
        ellipse(img, (5, 20 + yoff, 10, 27 + yoff), C["cream"])
        ellipse(img, (7, 22 + yoff, 10, 26 + yoff), C["cream3"])
        # legs
        rrect(img, (12 + stride, 28 + yoff, 16 + stride, 34), C["cream2"], 2)
        rrect(img, (18 - stride, 28 + yoff, 22 - stride, 34), C["cream2"], 2)
        ellipse(img, (12 + stride, 31, 16 + stride, 34), C["brown"])
        ellipse(img, (18 - stride, 31, 22 - stride, 34), C["brown"])
        # body
        ellipse(img, (8, 17 + yoff, 23, 31 + yoff), C["cream"])
        ellipse(img, (9, 25 + yoff, 22, 32 + yoff), C["cream2"])
        ellipse(img, (11, 21 + yoff, 19, 29 + yoff), C["cream3"])
        # arm
        ellipse(img, (14, 19 + yoff, 19, 28 + yoff), C["cream"])
        ellipse(img, (15, 24 + yoff, 19, 28 + yoff), C["cream2"])
        # head
        ellipse(img, (10, 5 + yoff, 26, 21 + yoff), C["cream"])
        ellipse(img, (22, 12 + yoff, 29, 19 + yoff), C["cream3"])
        ellipse(img, (26, 14 + yoff, 28, 17 + yoff), C["ink"])
        # ear
        ellipse(img, (10, 2 + yoff, 16, 8 + yoff), C["cream"])
        ellipse(img, (11, 3 + yoff, 15, 7 + yoff), C["brown"])
        ellipse(img, (12, 4 + yoff, 14, 6 + yoff), C["pink"])
        # eye + brow
        rect(img, (21, 10 + yoff, 23, 13 + yoff), C["ink"])
        pixel(img, 21.5, 10.5, C["white"])
        line(img, [(20, 9 + yoff), (23, 9 + yoff)], C["cream2"])
        # scarf
        rrect(img, (11, 18 + yoff, 25, 23 + yoff), C["ink"], 1)
        rrect(img, (12, 19 + yoff, 24, 22 + yoff), C["coral"], 1)
        rrect(img, (13, 21 + yoff, 17, 27 + yoff), C["ink"], 2)
        rrect(img, (14, 22 + yoff, 16, 26 + yoff), C["coral_d"], 1)
        poly(img, [(14, 22 + yoff), (8 + tail_sway, 24 + yoff), (9 + tail_sway, 28 + yoff),
                   (16, 25 + yoff)], C["coral"])
        poly(img, [(14, 24 + yoff), (10 + tail_sway, 25 + yoff), (10 + tail_sway, 27 + yoff),
                   (15, 26 + yoff)], C["coral_d"])
        pixel(img, 15, 23 + yoff, C["gold"])
        line(img, [(13, 6 + yoff), (18, 5 + yoff)], C["cream3"])
        # jetpack nozzle glow
        rect(img, (7, 28 + yoff, 9, 30 + yoff), C["mint"])

    else:  # back
        lift_l = 1 if f == 1 else 0
        lift_r = 1 if f == 3 else 0
        rrect(img, (11, 28 + yoff + lift_l, 15, 34), C["cream2"], 2)
        rrect(img, (17, 28 + yoff + lift_r, 21, 34), C["cream2"], 2)
        ellipse(img, (11, 31 + lift_l, 15, 34), C["brown"])
        ellipse(img, (17, 31 + lift_r, 21, 34), C["brown"])
        ellipse(img, (9, 17 + yoff, 23, 31 + yoff), C["cream"])
        ellipse(img, (9, 25 + yoff, 23, 32 + yoff), C["cream2"])
        ellipse(img, (12, 22 + yoff, 20, 29 + yoff), C["cream3"])
        # jetpack on the back
        rrect(img, (12, 21 + yoff, 20, 30 + yoff), C["ink"], 2)
        rrect(img, (13, 22 + yoff, 19, 29 + yoff), C["teal"], 2)
        rect(img, (14, 24 + yoff, 18, 25 + yoff), C["gold_d"])
        rect(img, (13, 28 + yoff, 15, 30 + yoff), C["gold"])
        rect(img, (17, 28 + yoff, 19, 30 + yoff), C["gold"])
        line(img, [(13, 22 + yoff), (18, 21 + yoff)], C["gold_d"])
        ellipse(img, (5, 18 + yoff, 10, 27 + yoff), C["cream"])
        ellipse(img, (22, 18 + yoff, 27, 27 + yoff), C["cream"])
        ellipse(img, (6, 24 + yoff, 10, 27 + yoff), C["cream2"])
        ellipse(img, (22, 24 + yoff, 26, 27 + yoff), C["cream2"])
        ellipse(img, (7, 4 + yoff, 25, 22 + yoff), C["cream"])
        ellipse(img, (7, 2 + yoff, 13, 8 + yoff), C["cream"])
        ellipse(img, (19, 2 + yoff, 25, 8 + yoff), C["cream"])
        ellipse(img, (8, 3 + yoff, 12, 7 + yoff), C["brown"])
        ellipse(img, (20, 3 + yoff, 24, 7 + yoff), C["brown"])
        ellipse(img, (9, 4 + yoff, 11, 6 + yoff), C["pink"])
        ellipse(img, (21, 4 + yoff, 23, 6 + yoff), C["pink"])
        # scarf from behind + little satchel
        rrect(img, (8, 18 + yoff, 24, 23 + yoff), C["ink"], 1)
        rrect(img, (9, 19 + yoff, 23, 22 + yoff), C["coral"], 1)
        rrect(img, (9, 20 + yoff, 15, 27 + yoff), C["coral"])
        rrect(img, (10, 22 + yoff, 14, 26 + yoff), C["coral_d"])
        poly(img, [(12, 25 + yoff), (11 + tail_sway, 31 + yoff), (16, 28 + yoff)], C["coral"])
        pixel(img, 12, 23 + yoff, C["gold"])
        line(img, [(10, 5 + yoff), (15, 4 + yoff)], C["cream3"])
        line(img, [(13, 12 + yoff), (16, 14 + yoff), (19, 12 + yoff)], C["cream2"])

    return A.finish(img, PLAYER_W, PLAYER_H)


def player_sheet():
    rows = []
    for direction in ("front", "side", "back"):
        for f in range(4):
            rows.append(bear_frame(direction, f))
    return A.make_sheet(rows, PLAYER_W, PLAYER_H, cols=4)


# ------------------------------------------------------------------ enemies
def slime() -> Image.Image:
    img = A.new(26, 22)
    # body
    ellipse(img, (3, 7, 23, 21), C["slime_d"])
    ellipse(img, (3, 6, 23, 20), C["slime"])
    rect(img, (4, 14, 22, 20), C["slime"])
    ellipse(img, (4, 15, 22, 21), C["slime_d"])
    ellipse(img, (7, 9, 16, 13), C["slime_l"])
    ellipse(img, (17, 11, 21, 14), C["slime_l"])
    # drips
    ellipse(img, (2, 16, 6, 22), C["slime"])
    ellipse(img, (21, 15, 24, 21), C["slime_d"])
    # face
    rect(img, (8, 11, 11, 16), C["ink"])
    rect(img, (15, 11, 18, 16), C["ink"])
    pixel(img, 8.5, 11.5, C["white"])
    pixel(img, 15.5, 11.5, C["white"])
    line(img, [(11, 17), (13, 19), (15, 17)], C["ink"])
    # moon rim
    arc(img, (5, 7, 21, 19), 200, 250, C["slime_l"], 1)
    return A.finish(img, 26, 22)


def bat(frame: int) -> Image.Image:
    img = A.new(30, 22)
    up = 0 if frame == 0 else 4
    # wings (behind body)
    left = [(13, 11), (9, 7 - up), (4, 3 - up), (5, 8 - up), (1, 7 - up),
            (4, 12 - up), (0, 12 - up), (5, 16), (10, 14), (13, 15)]
    right = [(17, 11), (21, 7 - up), (26, 3 - up), (25, 8 - up), (29, 7 - up),
             (26, 12 - up), (30, 12 - up), (25, 16), (20, 14), (17, 15)]
    poly(img, left, C["purple_d"])
    poly(img, right, C["purple_d"])
    # membrane ribs
    line(img, [(13, 11), (5, 8 - up)], C["purple"])
    line(img, [(17, 11), (25, 8 - up)], C["purple"])
    line(img, [(13, 13), (4, 12 - up)], C["purple"])
    line(img, [(17, 13), (26, 12 - up)], C["purple"])
    # body + head
    ellipse(img, (11, 8, 19, 19), C["purple"])
    ellipse(img, (12, 12, 18, 19), C["purple_d"])
    ellipse(img, (13, 5, 19, 12), C["purple"])
    # ears
    poly(img, [(12, 7), (13, 1), (16, 5)], C["purple"])
    poly(img, [(18, 7), (17, 1), (14, 5)], C["purple"])
    # eyes
    rect(img, (12, 8, 13, 10), C["gold"])
    rect(img, (17, 8, 18, 10), C["gold"])
    pixel(img, 12, 8, C["ink"])
    pixel(img, 17, 8, C["ink"])
    # fangs
    rect(img, (13, 11, 14, 12), C["white"])
    rect(img, (17, 11, 18, 12), C["white"])
    line(img, [(15, 5), (16, 6)], C["purple_l"])
    return A.finish(img, 30, 22)


def skeleton() -> Image.Image:
    img = A.new(28, 36)
    # tattered cape
    poly(img, [(8, 13), (20, 13), (22, 25), (19, 23), (23, 30), (15, 27),
               (12, 34), (10, 27), (4, 31), (7, 23), (5, 25)], C["purple_dd"])
    line(img, [(9, 15), (8, 24)], C["purple_d"])
    line(img, [(19, 15), (20, 24)], C["purple_d"])
    # legs
    line(img, [(11, 25), (9, 33)], C["bone_d"], 2)
    line(img, [(17, 25), (19, 33)], C["bone_d"], 2)
    rect(img, (6, 32, 10, 34), C["bone"])
    rect(img, (18, 32, 22, 34), C["bone"])
    # pelvis / spine / ribs
    ellipse(img, (11, 23, 17, 28), C["bone_d"])
    line(img, [(14, 14), (14, 25)], C["bone"], 2)
    for i, y in enumerate((16, 19, 22)):
        arc(img, (8 - i, y - 2, 20 + i, y + 3), 200, 340, C["bone"], 1)
    # arms
    line(img, [(9, 16), (5, 22), (7, 26)], C["bone_d"], 2)
    line(img, [(19, 16), (23, 20), (22, 25)], C["bone_d"], 2)
    # sword
    line(img, [(23, 27), (26, 10)], C["gray_d"], 3)
    line(img, [(23, 27), (26, 10)], C["gray_l"], 1)
    line(img, [(21, 23), (26, 25)], C["brown"], 2)
    rect(img, (22, 25, 24, 27), C["brown_d"])
    # skull
    ellipse(img, (8, 2, 20, 15), C["bone"])
    rect(img, (9, 10, 19, 15), C["bone"])
    ellipse(img, (10, 6, 14, 10), C["ink"])
    ellipse(img, (16, 6, 20, 10), C["ink"])
    pixel(img, 11, 7, C["mint"])
    pixel(img, 17, 7, C["mint"])
    poly(img, [(13, 10), (15, 10), (14, 12)], C["ink"])
    for x in (10, 12, 14, 16, 18):
        line(img, [(x, 12), (x, 14)], C["ink"])
    # rim light
    line(img, [(9, 3), (13, 2)], C["white"])
    arc(img, (9, 2, 20, 15), 200, 260, C["white"], 1)
    return A.finish(img, 28, 36)


def ghost() -> Image.Image:
    img = A.new(28, 34)
    # cloak silhouette
    poly(img, [(8, 8), (10, 3), (14, 1), (19, 3), (22, 8), (22, 20), (24, 25),
               (20, 24), (21, 31), (17, 28), (14, 33), (11, 28), (7, 31),
               (8, 24), (5, 25), (7, 18)], C["ghost_d"])
    poly(img, [(9, 9), (11, 5), (14, 3), (18, 5), (20, 9), (20, 20), (21, 23),
               (18, 22), (19, 28), (16, 25), (14, 29), (12, 24), (9, 27),
               (10, 21), (7, 22), (8, 17)], C["ghost"])
    # hood shadow + face
    ellipse(img, (9, 6, 19, 18), C["ink2"])
    ellipse(img, (11, 8, 17, 16), C["ghost_l"])
    rect(img, (11, 10, 13, 13), C["ink"])
    rect(img, (15, 10, 17, 13), C["ink"])
    pixel(img, 11.5, 10.5, C["mint"])
    pixel(img, 15.5, 10.5, C["mint"])
    line(img, [(12, 15), (14, 16), (16, 15)], C["ghost_d"])
    # arms
    ellipse(img, (4, 15, 8, 20), C["ghost"])
    ellipse(img, (20, 15, 24, 20), C["ghost"])
    # tail shading
    line(img, [(10, 22), (11, 27)], C["ghost_d"], 1)
    line(img, [(17, 22), (16, 26)], C["ghost_d"], 1)
    arc(img, (10, 4, 21, 19), 200, 260, C["ghost_l"], 1)
    return A.finish(img, 28, 34)


def stump_golem() -> Image.Image:
    img = A.new(48, 48)
    # roots
    poly(img, [(12, 38), (2, 46), (14, 44)], C["wood_d"])
    poly(img, [(34, 38), (46, 46), (33, 44)], C["wood_d"])
    poly(img, [(18, 40), (12, 47), (25, 44)], C["wood"])
    # trunk body
    rrect(img, (11, 12, 37, 41), C["wood"], 4)
    rrect(img, (15, 10, 33, 41), C["brown"])
    # bark ridges
    line(img, [(15, 15), (15, 38)], C["wood_d"], 1)
    line(img, [(19, 14), (18, 35)], C["wood_d"], 1)
    line(img, [(31, 16), (32, 37)], C["wood_d"], 1)
    line(img, [(27, 15), (28, 33)], C["wood_l"], 1)
    # arms / branches
    poly(img, [(12, 18), (3, 24), (5, 28), (12, 25)], C["brown"])
    poly(img, [(36, 17), (45, 21), (45, 26), (36, 24)], C["brown"])
    poly(img, [(4, 22), (1, 18), (5, 20)], C["wood_l"])
    poly(img, [(44, 20), (47, 16), (45, 20)], C["wood_l"])
    line(img, [(6, 26), (4, 30)], C["brown_d"], 2)
    line(img, [(42, 24), (44, 29)], C["brown_d"], 2)
    # face hollow
    ellipse(img, (16, 18, 32, 34), C["wood_d"])
    ellipse(img, (18, 20, 30, 33), C["ink2"])
    rect(img, (20, 23, 23, 27), C["orange"])
    rect(img, (26, 23, 29, 27), C["orange"])
    rect(img, (20, 23, 22, 24), C["gold_l"])
    rect(img, (26, 23, 28, 24), C["gold_l"])
    poly(img, [(20, 30), (23, 28), (26, 31), (29, 28), (30, 31), (23, 34)], C["ink"])
    line(img, [(22, 29), (28, 30)], C["orange_d"])
    # moss + mushrooms
    ellipse(img, (10, 11, 20, 18), C["leaf"])
    ellipse(img, (15, 9, 25, 15), C["leaf_l"])
    ellipse(img, (29, 12, 37, 18), C["leaf_d"])
    rect(img, (33, 9, 34, 13), C["cream2"])
    ellipse(img, (31, 7, 37, 11), C["coral"])
    rect(img, (32, 8, 33, 8), C["cream3"])
    # rim light
    line(img, [(13, 14), (12, 34)], C["wood_l"])
    arc(img, (12, 12, 36, 36), 180, 240, C["wood_l"], 1)
    return A.finish(img, 48, 48)


def boss() -> Image.Image:
    img = A.new(64, 66)
    # jagged shadow mane
    mane = [(10, 30), (4, 22), (10, 20), (8, 12), (16, 14), (16, 6), (24, 10),
            (28, 2), (34, 9), (42, 2), (46, 10), (56, 8), (54, 18), (60, 22),
            (54, 30), (60, 38), (52, 44), (54, 54), (42, 52), (38, 62), (30, 54),
            (22, 62), (18, 52), (8, 54), (12, 42), (4, 38)]
    poly(img, mane, C["purple_dd"])
    # body
    ellipse(img, (14, 32, 50, 62), C["ink2"])
    ellipse(img, (18, 37, 46, 61), C["purple_dd"])
    ellipse(img, (22, 42, 42, 60), C["purple_d"])
    # legs / claws
    rect(img, (16, 52, 24, 62), C["ink2"])
    rect(img, (40, 52, 48, 62), C["ink2"])
    for x in (14, 18, 22, 42, 46, 50):
        poly(img, [(x, 61), (x + 2, 66), (x + 3, 61)], C["bone_d"])
    # arms
    ellipse(img, (6, 38, 18, 56), C["purple_dd"])
    ellipse(img, (46, 38, 58, 56), C["purple_dd"])
    for x in (7, 11, 15, 49, 53, 57):
        poly(img, [(x, 53), (x + 2, 60), (x + 3, 53)], C["bone"])
    # head
    ellipse(img, (17, 12, 47, 40), C["purple_dd"])
    ellipse(img, (20, 15, 44, 38), C["ink2"])
    ellipse(img, (9, 12, 21, 24), C["purple_dd"])
    ellipse(img, (43, 12, 55, 24), C["purple_dd"])
    ellipse(img, (12, 14, 19, 21), C["purple_d"])
    ellipse(img, (45, 14, 52, 21), C["purple_d"])
    # snout
    ellipse(img, (24, 25, 40, 37), C["purple_dd"])
    ellipse(img, (29, 27, 35, 32), C["ink"])
    line(img, [(32, 31), (32, 34)], C["ink"])
    line(img, [(28, 34), (32, 36), (36, 34)], C["ink"])
    # eyes + glow
    ellipse(img, (21, 19, 29, 27), C["red_d"])
    ellipse(img, (35, 19, 43, 27), C["red_d"])
    rect(img, (23, 21, 27, 25), C["red"])
    rect(img, (37, 21, 41, 25), C["red"])
    rect(img, (24, 21, 25, 22), C["gold_l"])
    rect(img, (38, 21, 39, 22), C["gold_l"])
    # fangs
    poly(img, [(27, 35), (29, 42), (31, 35)], C["bone"])
    poly(img, [(34, 35), (36, 42), (38, 35)], C["bone"])
    # moon mark
    arc(img, (29, 16, 37, 24), 90, 300, C["gold"], 1)
    # rim light
    line(img, [(19, 15), (26, 13)], C["purple_l"])
    line(img, [(18, 34), (13, 38)], C["purple"])
    arc(img, (17, 12, 47, 40), 190, 240, C["purple"], 1)
    line(img, [(10, 33), (8, 39)], C["purple_d"])
    return A.finish(img, 64, 66)


def boss_aura() -> Image.Image:
    g = A.radial(96, (122, 88, 190), (0, 0, 0), 2.4)
    img = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
    img.alpha_composite(g)
    return img


def main():
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(PREVIEW, exist_ok=True)

    sheet = player_sheet()
    A.save(sheet, os.path.join(OUT, "player_sheet.png"))
    A.save(A.shadow((30, 11), 120), os.path.join(OUT, "shadow.png"))
    A.save(A.shadow((52, 16), 130), os.path.join(OUT, "shadow_big.png"))

    A.contact(
        [(f"walk front {i}", bear_frame("front", i)) for i in range(4)]
        + [(f"side {i}", bear_frame("side", i)) for i in range(4)]
        + [(f"back {i}", bear_frame("back", i)) for i in range(4)],
        os.path.join(PREVIEW, "bear_frames.png"),
        scale=6,
        cols=4,
    )
    print("characters done")


if __name__ == "__main__":
    main()
