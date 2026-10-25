"""Generate 200 chapter-stage enemy sprites.

Each chapter has a shared palette / silhouette family; each of its ten stages
gets a recoloured, ornamented variant with a unique crest and rank marks.
Run from the project root: python tools/gen_chapter_enemies.py
"""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "art" / "char"
OUT = SRC / "chapter_enemies"
OUT.mkdir(parents=True, exist_ok=True)

# chapter id, base sprite, dark/mid/light palette, accent
THEMES = [
    ("forest", "enemy_slime.png", "#173122", "#3f7f4d", "#a6dc8e", "#f7d36b"),
    ("hive", "new_enemy_toxic_moth.png", "#291536", "#66358a", "#c184e8", "#f1c05c"),
    ("ship", "enemy_sentinel.png", "#102b35", "#2d7180", "#78d8d5", "#f2c65b"),
    ("crater", "enemy_bomber.png", "#36170f", "#92331c", "#f08b42", "#ffd36b"),
    ("void", "enemy_phase.png", "#1a1238", "#4e2a83", "#a875f1", "#62e2e6"),
    ("dunes", "new_enemy_dune_stalker.png", "#382315", "#9a582c", "#e8a85c", "#f6dc79"),
    ("frost", "new_enemy_frost_wisp.png", "#102b42", "#2a6e94", "#8ad9ee", "#e9fbff"),
    ("mire", "new_enemy_mire_lurker.png", "#1b2d17", "#4f742e", "#a9d95e", "#d4ff78"),
    ("ruins", "new_enemy_rust_hound.png", "#262a2f", "#59636a", "#aab4b7", "#e7b75a"),
    ("citadel", "new_enemy_moon_knight.png", "#261838", "#5e3c7d", "#c39ae8", "#ffd36b"),
    ("trench", "new_enemy_abyss_jaw.png", "#111326", "#363b6b", "#7a83c0", "#62e2e6"),
    ("sunspot", "new_enemy_solar_flare.png", "#3b160b", "#a93b16", "#f4a43f", "#fff08a"),
    ("maze", "new_enemy_maze_weaver.png", "#211837", "#54427c", "#a28bdf", "#e9c8ff"),
    ("orbit", "new_enemy_orbit_drone.png", "#102d33", "#2b7280", "#77d9d2", "#f0c35a"),
    ("dawn", "new_enemy_dawn_herald.png", "#3b2612", "#a8712f", "#f2d078", "#fff6c5"),
    ("mirror", "new_enemy_mirror_wisp.png", "#1a2f38", "#4b7f8f", "#9fe6ee", "#f6e7a1"),
    ("chrono", "new_enemy_chrono_moth.png", "#332514", "#896430", "#e3c06b", "#fff1bd"),
    ("grave", "new_enemy_star_corpse.png", "#211b35", "#51436f", "#a28ec6", "#e5d5ff"),
    ("heart", "new_enemy_heart_guard.png", "#351720", "#8b3344", "#ed8190", "#ffd1d8"),
    ("genesis", "new_enemy_genesis_seraph.png", "#352a14", "#a18335", "#f5df88", "#fffbe0"),
]

SUFFIXES = ["유생", "정찰병", "포식자", "기생체", "수호자", "사냥꾼", "변이체", "전령", "군주", "각성체"]


def hex_rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))


def shift(rgb: tuple[int, int, int], amount: int) -> tuple[int, int, int]:
    return tuple(max(0, min(255, c + amount)) for c in rgb)


def build_variant(base: Image.Image, dark: tuple, mid: tuple, light: tuple, accent: tuple, stage: int) -> Image.Image:
    base = base.convert("RGBA")
    bbox = base.getbbox()
    if bbox:
        base = base.crop(bbox)
    base.thumbnail((40, 40), Image.Resampling.NEAREST)

    # One-pixel dark outline around the silhouette keeps it legible on every map.
    alpha = base.getchannel("A")
    expanded = alpha.filter(ImageFilter.MaxFilter(3))
    outline = Image.new("RGBA", base.size, (dark[0], dark[1], dark[2], 0))
    outline.putalpha(expanded)
    body = ImageOps.colorize(base.convert("L"), black=dark, mid=mid, white=light).convert("RGBA")
    body.putalpha(alpha)
    creature = Image.alpha_composite(outline, body)

    # Stage rank: accent gems/spikes above the creature. More dangerous stages
    # get a wider crest, while the chapter palette stays the same.
    canvas = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    x = (64 - creature.width) // 2
    y = 64 - creature.height - 3
    canvas.alpha_composite(creature, (x, y))
    draw = ImageDraw.Draw(canvas)
    crest_y = max(1, y - 5)
    crest_count = 1 + (stage - 1) % 4
    spread = 4 + stage // 2
    for i in range(crest_count):
        cx = 32 + (i - (crest_count - 1) * 0.5) * spread
        draw.polygon(
            [(cx, crest_y), (cx + 2, crest_y + 4), (cx, crest_y + 7), (cx - 2, crest_y + 4)],
            fill=(*accent, 255),
        )
    # A small rank pips row on the lower left.
    for i in range(stage):
        px = 4 + (i % 5) * 3
        py = 56 + (i // 5) * 3
        draw.point((px, py), fill=(*light, 220))
    # Two bright eyes make the generated silhouette read as a living enemy.
    eye_y = y + max(7, creature.height // 2 - 2)
    eye_x = 32
    draw.rectangle([eye_x - 5, eye_y, eye_x - 3, eye_y + 2], fill=(*accent, 255))
    draw.rectangle([eye_x + 3, eye_y, eye_x + 5, eye_y + 2], fill=(*accent, 255))
    return canvas


def main() -> None:
    for ci, (chapter, sprite, dark_hex, mid_hex, light_hex, accent_hex) in enumerate(THEMES, start=1):
        base = Image.open(SRC / sprite)
        dark, mid, light, accent = map(hex_rgb, (dark_hex, mid_hex, light_hex, accent_hex))
        for stage in range(1, 11):
            # Keep the chapter hue fixed, but brighten each successive stage.
            lift = (stage - 5) * 5
            variant = build_variant(
                base,
                shift(dark, lift // 2),
                shift(mid, lift),
                shift(light, lift // 2),
                shift(accent, lift // 3),
                stage,
            )
            variant.save(OUT / f"ch{ci:02d}_{stage:02d}.png")
    print("generated", len(THEMES) * 10, "chapter-stage enemy sprites")


if __name__ == "__main__":
    main()
