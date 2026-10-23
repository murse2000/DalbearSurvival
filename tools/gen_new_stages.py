"""Tinted stage thumbnails for the Ashen Rift and Far Side fronts."""
from __future__ import annotations

import os

from PIL import Image

ROOT = os.path.join(os.path.dirname(__file__), "..")
UI = os.path.join(ROOT, "assets", "art", "ui")
WORLD = os.path.join(ROOT, "assets", "art", "world")


def tinted(src: str, out: str, tint: tuple[int, int, int], strength: float) -> None:
    img = Image.open(os.path.join(UI, src)).convert("RGBA")
    shade = Image.new("RGBA", img.size, (*tint, int(255 * strength)))
    img = Image.alpha_composite(img, shade)
    # Keep the dark UI contrast and make the new front readable.
    img = Image.blend(img, Image.new("RGBA", img.size, (12, 8, 16, 255)), 0.10)
    img.save(os.path.join(UI, out))


def tinted_world(src: str, out: str, tint: tuple[int, int, int], strength: float) -> None:
    img = Image.open(os.path.join(WORLD, src)).convert("RGBA")
    shade = Image.new("RGBA", img.size, (*tint, int(255 * strength)))
    img = Image.alpha_composite(img, shade)
    img.save(os.path.join(WORLD, out))


def main() -> None:
    tinted("stage_hive.png", "stage_crater.png", (150, 45, 18), 0.42)
    tinted("stage_ship.png", "stage_void.png", (70, 24, 130), 0.48)
    tinted_world("relic_citadel_a.png", "relic_mirror_a.png", (60, 190, 230), 0.42)
    tinted_world("relic_citadel_b.png", "relic_mirror_b.png", (110, 220, 250), 0.38)
    tinted_world("relic_maze_a.png", "relic_chrono_a.png", (210, 164, 70), 0.42)
    tinted_world("relic_maze_b.png", "relic_chrono_b.png", (245, 205, 110), 0.38)
    tinted_world("relic_trench_a.png", "relic_grave_a.png", (90, 54, 150), 0.42)
    tinted_world("relic_trench_b.png", "relic_grave_b.png", (140, 100, 210), 0.38)
    tinted_world("relic_dawn_a.png", "relic_heart_a.png", (190, 70, 100), 0.40)
    tinted_world("relic_dawn_b.png", "relic_heart_b.png", (240, 128, 150), 0.36)
    tinted_world("relic_orbit_a.png", "relic_genesis_a.png", (210, 160, 65), 0.40)
    tinted_world("relic_orbit_b.png", "relic_genesis_b.png", (250, 220, 140), 0.36)
    print("new stage thumbnails done")


if __name__ == "__main__":
    main()
