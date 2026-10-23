"""Compose the ten new front thumbnails from the in-game art.

The first five campaign thumbnails are scene compositions (ground, props,
enemies and the bear).  The new fronts get the same treatment here instead of a
flat gradient: each one layers its own ground tile, relics, boss, two of its
enemies and the bear under a themed sky.

Outputs: assets/art/ui/stage_<front>.png  (480x270)
"""
from __future__ import annotations

import math
import os
import random

from PIL import Image, ImageDraw

import art_lib as A

ROOT = os.path.join(os.path.dirname(__file__), "..")
CHAR = os.path.join(ROOT, "assets", "art", "char")
WORLD = os.path.join(ROOT, "assets", "art", "world")
UI = os.path.join(ROOT, "assets", "art", "ui")
PREVIEW = os.path.join(os.path.dirname(__file__), "preview")

W, H = 960, 540
HORIZON = 168

# front, base, accent, skyline, celestial, boss suffix, enemies
STAGES = [
    ("dunes", (158, 74, 40), (255, 188, 82), "dune", "sun", "dune",
     ["dune_stalker", "sand_spitter"]),
    ("frost", (54, 96, 132), (190, 240, 255), "spikes", "moon", "frost",
     ["frost_wisp", "ice_crab"]),
    ("mire", (54, 88, 52), (176, 236, 96), "trees", "haze", "mire",
     ["mire_lurker", "toxic_moth"]),
    ("ruins", (58, 66, 78), (226, 170, 92), "towers", "none", "ruins",
     ["rust_hound", "cog_sentry"]),
    ("citadel", (54, 40, 88), (192, 148, 255), "spires", "moon", "citadel",
     ["moon_knight", "astral_seer"]),
    ("trench", (34, 26, 58), (150, 78, 200), "stalactites", "none", "trench",
     ["abyss_jaw", "deep_larva"]),
    ("sunspot", (100, 38, 22), (255, 148, 52), "flares", "sun", "solar",
     ["solar_flare", "magma_wing"]),
    ("maze", (42, 34, 80), (168, 122, 255), "walls", "moon", "maze",
     ["maze_weaver", "prism_eye"]),
    ("orbit", (26, 48, 60), (96, 232, 232), "none", "planet", "orbit",
     ["orbit_drone", "void_cutter"]),
    ("dawn", (82, 54, 30), (255, 200, 104), "gate", "dawn", "dawn",
     ["dawn_herald", "light_eater"]),
    ("mirror", (56, 96, 118), (170, 244, 255), "walls", "moon", "mirror",
     ["mirror_wisp", "glass_hound"]),
    ("chrono", (88, 72, 48), (238, 200, 122), "towers", "planet", "chrono",
     ["chrono_moth", "time_warden"]),
    ("grave", (48, 40, 78), (174, 140, 240), "stalactites", "none", "grave",
     ["grave_larva", "star_corpse"]),
    ("heart", (78, 48, 64), (255, 176, 190), "spires", "moon", "heart",
     ["moon_priest", "heart_guard"]),
    ("genesis", (116, 88, 48), (255, 250, 212), "gate", "dawn", "genesis",
     ["genesis_seraph", "first_dawn"]),
]

# front -> horizontal placement of the boss, kept clear of the celestial body
BOSS_X = {"dunes": 550, "frost": 520, "mire": 600, "ruins": 610,
          "citadel": 520, "trench": 600, "sunspot": 540, "maze": 520,
          "orbit": 500, "dawn": 716, "mirror": 560, "chrono": 600,
          "grave": 520, "heart": 600, "genesis": 690}


def _open(path: str) -> Image.Image:
    return Image.open(path).convert("RGBA")


def _scale(img: Image.Image, factor: float) -> Image.Image:
    return img.resize((max(1, int(img.width * factor)),
                       max(1, int(img.height * factor))), Image.NEAREST)


def _tint(color, factor: float, alpha: int = 255):
    return (min(255, int(color[0] * factor)),
            min(255, int(color[1] * factor)),
            min(255, int(color[2] * factor)), alpha)


def _glow(size: int, color, alpha: int) -> Image.Image:
    g = A.radial(size, color, (0, 0, 0), 2.0)
    g.putalpha(g.getchannel("A").point(lambda v: int(v * alpha / 255)))
    return g


def _sky(base, accent, celestial: str) -> Image.Image:
    img = Image.new("RGBA", (W, H), (12, 14, 24, 255))
    d = ImageDraw.Draw(img)
    top = _tint(base, 0.22)
    for y in range(HORIZON + 2):
        t = y / float(HORIZON + 2)
        c = (int(top[0] * (1 - t) + base[0] * 0.62 * t),
             int(top[1] * (1 - t) + base[1] * 0.62 * t),
             int(top[2] * (1 - t) + base[2] * 0.62 * t))
        d.line((0, y, W, y), fill=(*c, 255))

    rng = random.Random(base[0] * 131 + base[1])
    for _ in range(46):
        x, y = rng.randrange(W), rng.randrange(HORIZON - 20)
        a = rng.randrange(40, 150)
        d.point((x, y), fill=(*accent, a))

    if celestial == "sun":
        cx, cy, r = 748, 78, 54
        img.alpha_composite(_glow(360, accent, 95), (cx - 180, cy - 180))
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(*accent, 255))
        d.ellipse((cx - r + 10, cy - r + 10, cx + r - 10, cy + r - 10),
                  fill=(min(255, accent[0] + 20), min(255, accent[1] + 30),
                        min(255, accent[2] + 40), 255))
    elif celestial == "moon":
        cx, cy, r = 756, 82, 46
        img.alpha_composite(_glow(300, accent, 78), (cx - 150, cy - 150))
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(*accent, 245))
        d.ellipse((cx - r + 9, cy - r + 9, cx + r - 9, cy + r - 9),
                  fill=_tint(accent, 0.72, 255))
        for i in range(5):
            px = cx - 22 + i * 11
            py = cy - 14 + (i % 3) * 12
            d.ellipse((px, py, px + 9, py + 7), fill=_tint(accent, 0.55, 120))
    elif celestial == "planet":
        cx, cy, r = 740, 92, 56
        img.alpha_composite(_glow(340, accent, 85), (cx - 170, cy - 170))
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=_tint(accent, 0.55, 255))
        d.ellipse((cx - r + 12, cy - r + 12, cx + r - 12, cy + r - 12),
                  fill=(*accent, 235))
        d.ellipse((cx - r - 34, cy - 12, cx + r + 34, cy + 12),
                  outline=(*accent, 200), width=4)
    elif celestial == "dawn":
        cx, cy, r = W // 2, HORIZON + 8, 96
        img.alpha_composite(_glow(520, accent, 115), (cx - 260, cy - 260))
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(*accent, 210))
        for i in range(14):
            a = math.radians(-180 + i * (180 / 13.0))
            d.line((cx + math.cos(a) * 110, cy + math.sin(a) * 110,
                    cx + math.cos(a) * 210, cy + math.sin(a) * 210),
                   fill=(*accent, 55), width=3)
    elif celestial == "haze":
        img.alpha_composite(_glow(560, accent, 70), (150, -120))
        img.alpha_composite(_glow(420, accent, 46), (620, 110))
    return img


def _skyline(img: Image.Image, base, kind: str) -> None:
    d = ImageDraw.Draw(img)
    rng = random.Random(base[0] * 17 + HORIZON)
    far = _tint(base, 0.34)
    near = _tint(base, 0.46)
    if kind == "stalactites":
        far = _tint(base, 0.62)
        near = _tint(base, 0.5)
    if kind == "dune":
        d.polygon([(0, HORIZON), (150, HORIZON - 26), (330, HORIZON),
                   (520, HORIZON - 34), (700, HORIZON), (860, HORIZON - 20),
                   (W, HORIZON)], fill=far)
        d.polygon([(0, HORIZON), (220, HORIZON - 14), (460, HORIZON),
                   (660, HORIZON - 18), (W, HORIZON)], fill=near)
    elif kind == "spikes":
        for i in range(14):
            x = i * 76 + rng.randrange(-18, 18)
            h = rng.randrange(18, 64)
            d.polygon([(x - 18, HORIZON), (x, HORIZON - h), (x + 18, HORIZON)], fill=far)
    elif kind == "trees":
        for i in range(9):
            x = i * 112 + rng.randrange(-26, 26)
            h = rng.randrange(52, 104)
            d.line((x, HORIZON, x + rng.randrange(-12, 12), HORIZON - h),
                   fill=far, width=7)
            for j in range(3):
                bx = x + rng.randrange(-26, 26)
                by = HORIZON - h * (0.45 + j * 0.2)
                d.line((x, by + 14, bx, by - 12), fill=far, width=4)
    elif kind == "towers":
        for i in range(7):
            x = i * 146 + rng.randrange(0, 40)
            h = rng.randrange(40, 110)
            wd = rng.randrange(26, 52)
            d.rectangle((x, HORIZON - h, x + wd, HORIZON), fill=far)
            d.rectangle((x + 6, HORIZON - h + 8, x + 14, HORIZON - h + 22), fill=near)
    elif kind == "spires":
        for i in range(8):
            x = i * 128 + rng.randrange(-10, 30)
            h = rng.randrange(70, 150)
            d.polygon([(x - 22, HORIZON), (x, HORIZON - h), (x + 22, HORIZON)], fill=far)
            d.line((x, HORIZON - h, x, HORIZON - h + 28), fill=near, width=3)
    elif kind == "stalactites":
        for i in range(16):
            x = i * 64 + rng.randrange(-16, 16)
            h = rng.randrange(24, 78)
            d.polygon([(x - 14, 0), (x + 14, 0), (x, h)], fill=far)
        for i in range(8):
            x = i * 132 + rng.randrange(-18, 18)
            h = rng.randrange(20, 54)
            d.polygon([(x - 18, HORIZON), (x, HORIZON - h), (x + 18, HORIZON)], fill=near)
    elif kind == "flares":
        for i in range(10):
            x = i * 102 + rng.randrange(-20, 20)
            h = rng.randrange(26, 76)
            d.polygon([(x - 20, HORIZON), (x, HORIZON - h), (x + 20, HORIZON)], fill=far)
            d.line((x, HORIZON - h, x + rng.randrange(-16, 16), HORIZON - h - 26),
                   fill=(*_tint(base, 0.55)[:3], 160), width=3)
    elif kind == "walls":
        for i in range(11):
            x = i * 92
            h = 30 + (i % 4) * 14
            d.rectangle((x, HORIZON - h, x + 70, HORIZON), fill=far)
            d.rectangle((x + 8, HORIZON - h + 8, x + 62, HORIZON - h + 12), fill=near)
    elif kind == "gate":
        d.rectangle((126, HORIZON - 138, 186, HORIZON), fill=far)
        d.rectangle((W - 186, HORIZON - 138, W - 126, HORIZON), fill=far)
        d.arc((126, HORIZON - 236, W - 126, HORIZON - 20), 180, 360,
              fill=far, width=16)


def _ground(base, accent, front: str) -> Image.Image:
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    g = _open(os.path.join(WORLD, "ground_%s.png" % front))
    g = g.resize((W, H - HORIZON), Image.LANCZOS)
    img.alpha_composite(g, (0, HORIZON))
    shade = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shade)
    for y in range(HORIZON, H):
        t = (y - HORIZON) / float(H - HORIZON)
        sd.line((0, y, W, y), fill=(5, 6, 12, int(18 + t * 92)))
    img.alpha_composite(shade)
    d = ImageDraw.Draw(img)
    rng = random.Random(base[1] * 31 + base[0])
    for _ in range(30):
        x = rng.randrange(W)
        y = rng.randrange(HORIZON + 10, H - 10)
        d.line((x, y, x + rng.randrange(-30, 31), y + rng.randrange(-5, 6)),
               fill=(*accent, rng.randrange(24, 70)), width=1)
    return img


def _paste(img: Image.Image, path: str, factor: float, x: int, y: int,
           flip: bool = False) -> None:
    if not os.path.exists(path):
        return
    s = _scale(_open(path), factor)
    if flip:
        s = s.transpose(Image.FLIP_LEFT_RIGHT)
    img.alpha_composite(s, (x - s.width // 2, y - s.height))


def _vignette(img: Image.Image) -> None:
    ov = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    for i in range(70):
        d.rectangle((i, i, W - i, H - i), outline=(3, 4, 8, 3))
    img.alpha_composite(ov)


def thumbnail(front: str, base, accent, skyline: str, celestial: str,
              boss: str, enemies) -> Image.Image:
    img = _sky(base, accent, celestial)
    _skyline(img, base, skyline)
    img.alpha_composite(_ground(base, accent, front), (0, 0))

    # Boss dominating the back line.
    bx = BOSS_X.get(front, 600)
    img.alpha_composite(_glow(300, accent, 62), (bx - 150, -30))
    _paste(img, os.path.join(CHAR, "new_boss_%s.png" % boss), 2.3, bx, 268)

    # Scenery relics.
    _paste(img, os.path.join(WORLD, "relic_%s_a.png" % front), 2.3, 104, 352)
    _paste(img, os.path.join(WORLD, "relic_%s_b.png" % front), 1.8, 320, 398)
    _paste(img, os.path.join(WORLD, "relic_%s_a.png" % front), 1.5, 858, 330, True)

    # Two of the front's own monsters.
    _paste(img, os.path.join(CHAR, "new_enemy_%s.png" % enemies[0]), 2.6, 236, 452)
    _paste(img, os.path.join(CHAR, "new_enemy_%s.png" % enemies[1]), 2.4, 784, 486)

    # The bear, foreground centre.
    shadow = A.shadow((120, 30), 120)
    img.alpha_composite(shadow, (416, 494))
    sheet = _open(os.path.join(CHAR, "player_sheet.png"))
    bear = sheet.crop((0, 0, 32, 36))
    bear = bear.resize((96, 108), Image.NEAREST)
    img.alpha_composite(bear, (428, 396))

    # Foreground haze.
    fog = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    fd = ImageDraw.Draw(fog)
    fd.rectangle((0, H - 64, W, H), fill=(*_tint(accent, 0.5)[:3], 22))
    img.alpha_composite(fog)
    _vignette(img)
    return img.resize((480, 270), Image.LANCZOS)


def main() -> None:
    os.makedirs(UI, exist_ok=True)
    os.makedirs(PREVIEW, exist_ok=True)
    preview = []
    for front, base, accent, skyline, celestial, boss, enemies in STAGES:
        art = thumbnail(front, base, accent, skyline, celestial, boss, enemies)
        A.save(art, os.path.join(UI, "stage_%s.png" % front))
        preview.append((front, art))
    A.contact(preview, os.path.join(PREVIEW, "stage_thumbs_new.png"), scale=1, cols=2)
    print("new stage thumbnails done")


if __name__ == "__main__":
    main()
