"""Small pixel-art helper library built on Pillow.

Everything is drawn at SS-times resolution and box-downsampled to the target
size, then colour-mapped to a fixed palette.  A 1px outline is added last,
which gives the hand-placed pixel-art look without needing hand placement.
"""
from __future__ import annotations

import math
import os
import random
from PIL import Image, ImageDraw, ImageFilter

SS = 4

# ---------------------------------------------------------------- palette
INK = (17, 19, 28)

PALETTE = {
    "ink": INK,
    "ink2": (35, 39, 54),
    "cream": (243, 230, 207),
    "cream2": (222, 200, 170),
    "cream3": (255, 246, 233),
    "bear": (238, 221, 194),
    "bear_sh": (205, 178, 146),
    "brown": (164, 116, 82),
    "brown_d": (110, 74, 56),
    "coral": (232, 102, 88),
    "coral_d": (178, 66, 66),
    "pink": (238, 156, 152),
    "gold": (255, 208, 108),
    "gold_d": (216, 156, 62),
    "gold_l": (255, 238, 178),
    "moon": (219, 236, 255),
    "moon2": (166, 200, 240),
    "mist": (206, 224, 232),
    "mint": (140, 226, 186),
    "mint_d": (74, 152, 124),
    "teal": (52, 104, 92),
    "teal_d": (32, 64, 58),
    "grass": (40, 78, 68),
    "grass_l": (56, 104, 88),
    "grass_d": (28, 54, 50),
    "grass_dd": (22, 44, 42),
    "purple": (158, 128, 204),
    "purple_d": (104, 80, 152),
    "purple_dd": (68, 52, 104),
    "purple_l": (198, 174, 234),
    "slime": (130, 204, 130),
    "slime_l": (178, 232, 160),
    "slime_d": (82, 148, 96),
    "bone": (232, 230, 212),
    "bone_d": (184, 180, 156),
    "ghost": (176, 214, 220),
    "ghost_d": (118, 166, 180),
    "ghost_l": (222, 242, 244),
    "red": (226, 84, 76),
    "red_d": (160, 50, 56),
    "white": (250, 250, 246),
    "gray": (150, 156, 164),
    "gray_d": (96, 102, 114),
    "gray_l": (196, 202, 208),
    "wood": (128, 94, 64),
    "wood_d": (84, 60, 46),
    "wood_l": (166, 128, 88),
    "leaf": (58, 110, 90),
    "leaf_d": (38, 78, 66),
    "leaf_l": (86, 146, 112),
    "orange": (240, 160, 90),
    "orange_d": (190, 108, 62),
    "hive": (86, 52, 100),
    "hive_d": (54, 34, 68),
    "hive_l": (128, 82, 146),
    "flesh": (168, 86, 118),
    "flesh_d": (118, 54, 84),
    "acid": (148, 240, 152),
    "acid_d": (72, 168, 110),
    "acid_dd": (42, 108, 82),
    "steel": (78, 94, 118),
    "steel_d": (42, 54, 72),
    "steel_l": (118, 136, 158),
    "circuit": (104, 226, 208),
    "magenta": (204, 96, 190),
}

C = PALETTE


def col(name_or_rgb):
    if isinstance(name_or_rgb, str):
        return PALETTE[name_or_rgb]
    if len(name_or_rgb) == 3:
        return name_or_rgb + (255,)
    return name_or_rgb


# ---------------------------------------------------------------- canvas
def new(w: int, h: int) -> Image.Image:
    return Image.new("RGBA", (w * SS, h * SS), (0, 0, 0, 0))


def _s(v):
    return v * SS


def ellipse(img, box, color):
    ImageDraw.Draw(img).ellipse([_s(box[0]), _s(box[1]), _s(box[2]), _s(box[3])], fill=col(color))


def rect(img, box, color):
    ImageDraw.Draw(img).rectangle([_s(box[0]), _s(box[1]), _s(box[2]), _s(box[3])], fill=col(color))


def rrect(img, box, color, radius=2):
    ImageDraw.Draw(img).rounded_rectangle(
        [_s(box[0]), _s(box[1]), _s(box[2]), _s(box[3])], radius=_s(radius), fill=col(color)
    )


def poly(img, pts, color):
    ImageDraw.Draw(img).polygon([(_s(x), _s(y)) for x, y in pts], fill=col(color))


def line(img, pts, color, width=1):
    ImageDraw.Draw(img).line(
        [(_s(x), _s(y)) for x, y in pts], fill=col(color), width=max(1, int(_s(width))), joint="curve"
    )


def arc(img, box, start, end, color, width=1):
    ImageDraw.Draw(img).arc(
        [_s(box[0]), _s(box[1]), _s(box[2]), _s(box[3])],
        start=start,
        end=end,
        fill=col(color),
        width=max(1, int(_s(width))),
    )


def pixel(img, x, y, color):
    ImageDraw.Draw(img).point((int(x * SS), int(y * SS)), fill=col(color))


# ---------------------------------------------------------------- finishing
def _nearest(rgb, colors):
    best = None
    bestd = 1 << 30
    r, g, b = rgb
    for c in colors:
        d = (c[0] - r) ** 2 + (c[1] - g) ** 2 + (c[2] - b) ** 2
        if d < bestd:
            bestd = d
            best = c
    return best


def finish(img, w, h, outline=True, thresh=96, colors=None, outline_color=None):
    """Downsample, snap to palette, add 1px outline."""
    small = img.resize((w, h), Image.BOX)
    colors = colors or list(PALETTE.values())
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    src = small.load()
    dst = out.load()
    cache = {}
    for y in range(h):
        for x in range(w):
            r, g, b, a = src[x, y]
            if a < thresh:
                dst[x, y] = (0, 0, 0, 0)
            else:
                key = (r // 4, g // 4, b // 4)
                c = cache.get(key)
                if c is None:
                    c = _nearest((r, g, b), colors)
                    cache[key] = c
                dst[x, y] = c + (255,)
    if outline:
        oc = col(outline_color or INK)
        solid = out.copy()
        sp = solid.load()
        for y in range(h):
            for x in range(w):
                if sp[x, y][3] == 0:
                    near = False
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        nx, ny = x + dx, y + dy
                        if 0 <= nx < w and 0 <= ny < h and sp[nx, ny][3] > 0:
                            near = True
                            break
                    if near:
                        dst[x, y] = oc
    return out


def clean(img, passes=1):
    """Remove isolated opaque pixels / pinholes (target resolution)."""
    w, h = img.size
    for _ in range(passes):
        px = img.load()
        kills = []
        for y in range(h):
            for x in range(w):
                if px[x, y][3] == 0:
                    continue
                n = 0
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h and px[nx, ny][3] > 0:
                        n += 1
                if n == 0:
                    kills.append((x, y))
        for x, y in kills:
            px[x, y] = (0, 0, 0, 0)
    return img


def paste_center(sheet, img, cx, cy):
    sheet.alpha_composite(img, (int(cx - img.width / 2), int(cy - img.height / 2)))


def make_sheet(frames, cell_w, cell_h, cols=None):
    n = len(frames)
    cols = cols or n
    rows = (n + cols - 1) // cols
    sheet = Image.new("RGBA", (cell_w * cols, cell_h * rows), (0, 0, 0, 0))
    for i, f in enumerate(frames):
        x = (i % cols) * cell_w
        y = (i // cols) * cell_h
        sheet.alpha_composite(f, (x, y))
    return sheet


# ---------------------------------------------------------------- fx helpers
def radial(size, inner, outer, power=2.0):
    """Smooth radial glow (RGBA)."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = img.load()
    c = size / 2
    for y in range(size):
        for x in range(size):
            d = min(1.0, math.hypot(x - c + 0.5, y - c + 0.5) / c)
            a = max(0.0, 1.0 - d) ** power
            px[x, y] = (inner[0], inner[1], inner[2], int(255 * a))
    return img


def shadow(size=(32, 12), alpha=110):
    w, h = size
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y in range(h):
        for x in range(w):
            nx = (x - w / 2 + 0.5) / (w / 2)
            ny = (y - h / 2 + 0.5) / (h / 2)
            d = nx * nx + ny * ny
            if d < 1.0:
                a = int(alpha * (1.0 - d) ** 0.7)
                px[x, y] = (8, 10, 16, a)
    return img


def save(img, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)


def contact(items, path, scale=3, bg=(26, 30, 42, 255), cols=6, pad=10, label=True):
    """Debug contact sheet."""
    from PIL import ImageFont

    font = ImageFont.load_default()
    cells = []
    maxw = max(i.width for _, i in items) * scale
    maxh = max(i.height for _, i in items) * scale
    cw = maxw + pad * 2
    ch = maxh + pad * 2 + (14 if label else 0)
    rows = (len(items) + cols - 1) // cols
    sheet = Image.new("RGBA", (cw * cols, ch * rows), bg)
    d = ImageDraw.Draw(sheet)
    for idx, (name, img) in enumerate(items):
        x = (idx % cols) * cw
        y = (idx // cols) * ch
        big = img.resize((img.width * scale, img.height * scale), Image.NEAREST)
        # checker-ish dark tile
        d.rectangle([x + pad - 3, y + pad - 3, x + pad + big.width + 2, y + pad + big.height + 2],
                    fill=(36, 42, 58, 255))
        sheet.alpha_composite(big, (x + pad, y + pad))
        if label:
            d.text((x + pad, y + pad + maxh + 2), name, fill=(190, 200, 215, 255), font=font)
    save(sheet, path)
