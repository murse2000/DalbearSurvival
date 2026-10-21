"""Projectiles, pickups, particles and all UI icons."""
from __future__ import annotations

import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter

import art_lib as A
from art_lib import C, ellipse, rect, rrect, poly, line, arc, pixel

FX_OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "art", "fx")
UI_OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "art", "ui")
PREVIEW = os.path.join(os.path.dirname(__file__), "preview")


# ------------------------------------------------------------------ fx
def moon_bolt() -> Image.Image:
    img = A.new(18, 16)
    # trail
    poly(img, [(0, 8), (5, 5), (5, 11)], C["gold_d"])
    poly(img, [(2, 8), (6, 6), (6, 10)], C["gold"])
    # crescent bullet
    ellipse(img, (5, 2, 17, 14), C["gold_d"])
    ellipse(img, (6, 3, 14, 13), C["gold"])
    ellipse(img, (7, 3, 13, 9), C["gold_l"])
    ellipse(img, (9, 4, 15, 12), C["cream3"])
    ellipse(img, (10, 4, 14, 8), C["white"])
    # sparkle
    line(img, [(16, 3), (16, 5)], C["mint"])
    line(img, [(15, 4), (17, 4)], C["mint"])
    return A.finish(img, 18, 16)


def satellite() -> Image.Image:
    img = A.new(22, 22)
    # panels
    rrect(img, (0, 8, 7, 15), C["gray_d"], 1)
    rrect(img, (1, 9, 6, 14), C["gold_d"], 1)
    line(img, [(3, 9), (3, 14)], C["ink2"])
    rrect(img, (15, 8, 22, 15), C["gray_d"], 1)
    rrect(img, (16, 9, 21, 14), C["gold_d"], 1)
    line(img, [(18, 9), (18, 14)], C["ink2"])
    # body
    rrect(img, (7, 6, 15, 17), C["ink"], 2)
    rrect(img, (8, 7, 14, 16), C["teal"], 1)
    rrect(img, (9, 8, 13, 12), C["mint_d"], 1)
    # eye/core
    ellipse(img, (9, 8, 13, 12), C["mint"])
    pixel(img, 10, 9, C["white"])
    # thruster
    rect(img, (9, 16, 13, 18), C["gold"])
    poly(img, [(9, 18), (13, 18), (11, 22)], C["gold_d"])
    poly(img, [(10, 18), (12, 18), (11, 21)], C["white"])
    # antenna
    line(img, [(11, 6), (11, 3)], C["gray_l"])
    pixel(img, 11, 2, C["coral"])
    return A.finish(img, 22, 22)


def pulse_ring(size=192) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = img.load()
    c = size / 2
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - c + 0.5, y - c + 0.5) / c
            if 0.62 < d < 1.0:
                t = (d - 0.62) / 0.38
                a = int(255 * (1 - abs(t - 0.55) / 0.55) ** 1.4) if t < 1 else 0
                a = max(0, a)
                col = (180, 250, 230) if t > 0.5 else (110, 200, 230)
                px[x, y] = col + (a,)
    d = ImageDraw.Draw(img)
    d.ellipse([c - 2, c - 2, c + 2, c + 2], fill=(255, 255, 240, 150))
    return img


def laser_beam(w=96, h=24) -> Image.Image:
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    c = h / 2
    for y in range(h):
        dy = abs(y - c + 0.5) / c
        a = int(255 * max(0.0, 1.0 - dy) ** 1.6)
        for x in range(w):
            fade = min(1.0, x / 10, (w - x) / 14)
            aa = int(a * (0.35 + 0.65 * fade))
            if aa > 0:
                col = (235, 255, 245) if dy < 0.35 else (120, 236, 210)
                px[x, y] = col + (aa,)
    d = ImageDraw.Draw(img)
    d.rectangle([0, int(c) - 1, w, int(c) + 1], fill=(255, 255, 255, 210))
    return img.filter(ImageFilter.GaussianBlur(0.8))


def spark() -> Image.Image:
    img = A.new(20, 20)
    poly(img, [(9, 0), (11, 0), (12, 8), (20, 9), (20, 11), (12, 11), (11, 20),
               (9, 20), (8, 11), (0, 11), (0, 9), (8, 8)], C["gold"])
    poly(img, [(9, 3), (11, 3), (11, 9), (17, 10), (11, 10), (11, 17), (9, 17),
               (9, 10), (3, 10), (9, 9)], C["white"])
    pixel(img, 10, 9, C["gold_l"])
    return A.finish(img, 20, 20, outline=False)


def gem(variant=0) -> Image.Image:
    palette = [
        ((126, 202, 255), (74, 140, 214), (210, 240, 255)),
        ((128, 236, 178), (64, 158, 120), (216, 255, 232)),
        ((198, 150, 255), (120, 84, 190), (238, 222, 255)),
    ][variant]
    main, dark, light = palette
    img = A.new(14, 16)
    poly(img, [(7, 1), (13, 6), (7, 15), (1, 6)], dark)
    poly(img, [(7, 2), (12, 6), (7, 13), (2, 6)], main)
    poly(img, [(7, 2), (7, 13), (2, 6)], light)
    poly(img, [(7, 2), (12, 6), (7, 6)], (255, 255, 255))
    line(img, [(4, 6), (7, 10)], dark)
    return A.finish(img, 14, 16)


def heart() -> Image.Image:
    img = A.new(16, 15)
    ellipse(img, (1, 2, 8, 9), C["red"])
    ellipse(img, (8, 2, 15, 9), C["red"])
    poly(img, [(2, 7), (14, 7), (8, 14)], C["red"])
    ellipse(img, (3, 3, 7, 7), C["pink"])
    ellipse(img, (9, 3, 12, 6), C["red_d"])
    return A.finish(img, 16, 15)


def orb(color=C["purple"]) -> Image.Image:
    img = A.new(16, 16)
    ellipse(img, (3, 3, 13, 13), C["purple_dd"])
    ellipse(img, (4, 4, 12, 12), C["red_d"])
    ellipse(img, (6, 6, 10, 10), C["red"])
    pixel(img, 7, 6, C["gold_l"])
    return A.finish(img, 16, 16)


def glow(size=64, color=(255, 255, 255)) -> Image.Image:
    return A.radial(size, color, (0, 0, 0), 2.0)


def firefly() -> Image.Image:
    img = Image.new("RGBA", (10, 10), (0, 0, 0, 0))
    px = img.load()
    for y in range(10):
        for x in range(10):
            d = math.hypot(x - 4.5, y - 4.5) / 5
            a = int(230 * max(0.0, 1 - d) ** 2)
            if a:
                px[x, y] = (255, 236, 170, a)
    return img


def fog(w=512, h=180) -> Image.Image:
    rng = random.Random(9)
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    for _ in range(28):
        x = rng.randrange(-80, w)
        y = rng.randrange(0, h - 20)
        rx = rng.randrange(60, 200)
        ry = rng.randrange(12, 42)
        d.ellipse([x, y, x + rx, y + ry], fill=(170, 210, 210, 14))
    return img.filter(ImageFilter.GaussianBlur(10))


def level_ring(size=220) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = img.load()
    c = size / 2
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - c + 0.5, y - c + 0.5) / c
            a = 0
            col = (255, 230, 150)
            if 0.78 < d < 0.98:
                a = int(255 * (1 - abs(d - 0.88) / 0.10) ** 1.2)
            if 0.64 < d < 0.70:
                a = max(a, 150)
                col = (255, 255, 230)
            if a > 0:
                px[x, y] = col + (a,)
    return img


# ------------------------------------------------------------------ icons
def icon_base(w=32, h=32):
    return A.new(w, h)


def icon_moon_shot():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), C["night"] if "night" in C else (30, 42, 64))
    # crescent
    ellipse(img, (5, 7, 23, 26), C["gold"])
    ellipse(img, (10, 6, 27, 25), (30, 42, 64))
    # bolt
    poly(img, [(18, 9), (25, 16), (20, 16), (24, 23), (15, 16), (20, 16)], C["moon"])
    line(img, [(22, 22), (27, 22)], C["mint"])
    line(img, [(25, 20), (25, 24)], C["mint"])
    return A.finish(img, 32, 32)


def icon_satellite():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    rrect(img, (1, 12, 9, 19), C["gold_d"], 1)
    rrect(img, (23, 12, 31, 19), C["gold_d"], 1)
    line(img, [(5, 12), (5, 19)], C["ink"])
    line(img, [(27, 12), (27, 19)], C["ink"])
    rrect(img, (11, 9, 21, 23), C["ink"], 2)
    rrect(img, (12, 10, 20, 22), C["teal"])
    ellipse(img, (14, 12, 18, 17), C["mint"])
    pixel(img, 15, 13, C["white"])
    poly(img, [(14, 22), (18, 22), (16, 29)], C["gold"])
    line(img, [(16, 9), (16, 5)], C["gray_l"])
    pixel(img, 16, 4, C["coral"])
    return A.finish(img, 32, 32)


def icon_pulse():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    for r, c in ((10, C["mint"]), (7, C["ghost_l"])):
        arc(img, (16 - r, 16 - r, 16 + r, 16 + r), 0, 360, c, 2)
    ellipse(img, (13, 13, 19, 19), C["white"])
    for a in range(0, 360, 90):
        x = 16 + math.cos(math.radians(a)) * 12
        y = 16 + math.sin(math.radians(a)) * 12
        pixel(img, x, y, C["gold"])
    return A.finish(img, 32, 32)


def icon_laser():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    line(img, [(5, 22), (27, 10)], C["mint_d"], 4)
    line(img, [(5, 22), (27, 10)], C["ghost_l"], 2)
    line(img, [(5, 22), (27, 10)], C["white"], 1)
    poly(img, [(4, 25), (9, 24), (6, 20)], C["gold"])
    line(img, [(23, 8), (25, 5)], C["mint"])
    line(img, [(25, 8), (24, 12)], C["mint"])
    return A.finish(img, 32, 32)


def icon_boots():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    rrect(img, (9, 6, 15, 20), C["brown"], 2)
    rrect(img, (18, 10, 24, 20), C["brown"], 2)
    rrect(img, (7, 18, 18, 24), C["brown"], 2)
    rrect(img, (16, 20, 26, 26), C["brown"], 2)
    rect(img, (9, 20, 17, 22), C["brown_d"])
    rect(img, (18, 22, 25, 23), C["brown_d"])
    poly(img, [(8, 24), (12, 24), (10, 29)], C["gold"])
    poly(img, [(17, 26), (21, 26), (19, 30)], C["gold"])
    line(img, [(4, 14), (7, 14)], C["mint"])
    line(img, [(3, 18), (6, 18)], C["mint"])
    return A.finish(img, 32, 32)


def icon_core():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    poly(img, [(16, 3), (27, 10), (27, 22), (16, 29), (5, 22), (5, 10)], C["gray_d"])
    poly(img, [(16, 5), (25, 11), (25, 21), (16, 27), (7, 21), (7, 11)], C["teal"])
    poly(img, [(18, 8), (12, 17), (16, 17), (14, 24), (21, 15), (17, 15)], C["gold"])
    return A.finish(img, 32, 32)


def icon_coolant():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    for a in (0, 60, 120):
        rad = math.radians(a)
        dx, dy = math.cos(rad) * 10, math.sin(rad) * 10
        line(img, [(16 - dx, 16 - dy), (16 + dx, 16 + dy)], C["moon"], 2)
        for s in (-1, 1):
            bx = 16 + s * dx * 0.7
            by = 16 + s * dy * 0.7
            line(img, [(bx, by), (bx - dy * 0.3, by + dx * 0.3)], C["moon"], 1)
    ellipse(img, (14, 14, 18, 18), C["white"])
    return A.finish(img, 32, 32)


def icon_heart():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    ellipse(img, (6, 8, 17, 20), C["red_d"])
    ellipse(img, (15, 8, 26, 20), C["red_d"])
    poly(img, [(7, 16), (25, 16), (16, 28)], C["red_d"])
    ellipse(img, (7, 9, 17, 19), C["red"])
    ellipse(img, (15, 9, 25, 19), C["red"])
    poly(img, [(8, 15), (24, 15), (16, 26)], C["red"])
    ellipse(img, (9, 11, 13, 15), C["pink"])
    line(img, [(20, 12), (22, 12)], C["gold"])
    return A.finish(img, 32, 32)


def icon_magnet():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    arc(img, (7, 5, 25, 23), 180, 360, C["gray_l"], 7)
    rect(img, (7, 14, 12, 25), C["gray_l"])
    rect(img, (20, 14, 25, 25), C["gray_l"])
    rect(img, (7, 22, 12, 27), C["coral"])
    rect(img, (20, 22, 25, 27), C["moon"])
    arc(img, (9, 7, 23, 21), 180, 360, C["gray"], 2)
    return A.finish(img, 32, 32)


def icon_star():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    pts = []
    for i in range(10):
        a = math.radians(-90 + i * 36)
        r = 12 if i % 2 == 0 else 5
        pts.append((16 + math.cos(a) * r, 16 + math.sin(a) * r))
    poly(img, pts, C["gold_d"])
    pts_in = []
    for i in range(10):
        a = math.radians(-90 + i * 36)
        r = 10 if i % 2 == 0 else 4
        pts_in.append((16 + math.cos(a) * r, 16 + math.sin(a) * r))
    poly(img, pts_in, C["gold"])
    ellipse(img, (14, 14, 18, 18), C["white"])
    return A.finish(img, 32, 32)


def icon_armor():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    poly(img, [(16, 4), (26, 8), (25, 19), (16, 28), (7, 19), (6, 8)], C["gray_d"])
    poly(img, [(16, 6), (24, 9), (23, 18), (16, 25), (9, 18), (8, 9)], C["gray_l"])
    poly(img, [(16, 9), (16, 22), (12, 17)], C["gray"])
    line(img, [(11, 12), (21, 12)], C["gold"])
    line(img, [(11, 16), (21, 16)], C["gold"])
    return A.finish(img, 32, 32)


def icon_nano():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    ellipse(img, (9, 8, 23, 24), C["mint_d"])
    ellipse(img, (10, 9, 22, 22), C["mint"])
    line(img, [(16, 9), (16, 22)], C["mint_d"], 1)
    line(img, [(10, 16), (22, 16)], C["mint_d"], 1)
    rect(img, (15, 12, 18, 21), C["white"])
    rect(img, (12, 15, 21, 18), C["white"])
    rect(img, (15, 13, 17, 20), C["ghost_l"])
    return A.finish(img, 32, 32)


def icon_alien():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    ellipse(img, (7, 5, 25, 26), C["slime"])
    poly(img, [(7, 9), (3, 3), (10, 6)], C["slime"])
    poly(img, [(25, 9), (29, 3), (22, 6)], C["slime"])
    ellipse(img, (10, 10, 15, 19), C["ink"])
    ellipse(img, (17, 10, 22, 19), C["ink"])
    pixel(img, 11, 11, C["mint"])
    pixel(img, 18, 11, C["mint"])
    line(img, [(13, 21), (16, 23), (19, 21)], C["ink"])
    return A.finish(img, 32, 32)


def icon_clock():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    ellipse(img, (5, 5, 27, 27), C["ink"])
    ellipse(img, (7, 7, 25, 25), C["gold"])
    ellipse(img, (9, 9, 23, 23), C["cream"])
    line(img, [(16, 16), (16, 10)], C["ink"], 2)
    line(img, [(16, 16), (21, 19)], C["ink"], 2)
    ellipse(img, (15, 15, 17, 17), C["coral"])
    return A.finish(img, 32, 32)


def icon_moon():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    ellipse(img, (7, 5, 25, 27), C["moon"])
    ellipse(img, (13, 3, 29, 23), (30, 42, 64))
    pixel(img, 10, 9, C["cream"])
    pixel(img, 9, 14, C["cream"])
    pixel(img, 12, 19, C["cream"])
    return A.finish(img, 32, 32)


def icon_trophy():
    img = icon_base()
    ellipse(img, (3, 3, 29, 29), C["teal_d"])
    ellipse(img, (5, 5, 27, 27), (30, 42, 64))
    rrect(img, (10, 5, 22, 17), C["gold_d"], 2)
    rrect(img, (11, 6, 21, 15), C["gold"], 2)
    arc(img, (4, 7, 12, 16), 90, 270, C["gold"], 2)
    arc(img, (20, 7, 28, 16), 270, 90, C["gold"], 2)
    rect(img, (15, 16, 17, 22), C["gold_d"])
    rrect(img, (10, 21, 22, 25), C["brown"], 1)
    rect(img, (12, 24, 20, 26), C["gray_d"])
    ellipse(img, (15, 9, 18, 12), C["gold_l"])
    return A.finish(img, 32, 32)


def main():
    os.makedirs(FX_OUT, exist_ok=True)
    os.makedirs(UI_OUT, exist_ok=True)
    os.makedirs(PREVIEW, exist_ok=True)

    fx = {
        "moon_bolt": moon_bolt(),
        "satellite": satellite(),
        "pulse_ring": pulse_ring(),
        "laser_beam": laser_beam(),
        "spark": spark(),
        "gem_0": gem(0),
        "gem_1": gem(1),
        "gem_2": gem(2),
        "heart": heart(),
        "orb": orb(),
        "level_ring": level_ring(),
        "glow": glow(64),
        "glow_gold": glow(64, (255, 214, 130)),
        "glow_green": glow(64, (140, 240, 200)),
        "firefly": firefly(),
        "fog": fog(),
    }
    for name, img in fx.items():
        A.save(img, os.path.join(FX_OUT, name + ".png"))

    icons = {
        "icon_moon_shot": icon_moon_shot(),
        "icon_satellite": icon_satellite(),
        "icon_pulse": icon_pulse(),
        "icon_laser": icon_laser(),
        "icon_boots": icon_boots(),
        "icon_core": icon_core(),
        "icon_coolant": icon_coolant(),
        "icon_heart": icon_heart(),
        "icon_magnet": icon_magnet(),
        "icon_star": icon_star(),
        "icon_armor": icon_armor(),
        "icon_nano": icon_nano(),
        "icon_alien": icon_alien(),
        "icon_clock": icon_clock(),
        "icon_moon": icon_moon(),
        "icon_trophy": icon_trophy(),
    }
    for name, img in icons.items():
        A.save(img, os.path.join(UI_OUT, name + ".png"))

    A.contact(list(fx.items()), os.path.join(PREVIEW, "fx.png"), scale=3, cols=5)
    A.contact(list(icons.items()), os.path.join(PREVIEW, "icons.png"), scale=4, cols=5)
    print("fx + icons done")


if __name__ == "__main__":
    main()
