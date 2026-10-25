"""Generate DALBEAR gacha-only CC0 art/audio assets.

The images are simple procedural light masks so they can be tinted by the
engine. The three WAV files are short synthesized cues used by the summon
screen; no third-party samples are included.
"""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path

from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
FX = ROOT / "assets" / "art" / "fx"
AUDIO = ROOT / "assets" / "audio"
FX.mkdir(parents=True, exist_ok=True)
AUDIO.mkdir(parents=True, exist_ok=True)


def make_rays(size: int = 1024, rays: int = 20) -> None:
    img = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    px = img.load()
    cx = cy = (size - 1) * 0.5
    max_r = size * 0.5
    for y in range(size):
        for x in range(size):
            dx = x - cx
            dy = y - cy
            r = math.hypot(dx, dy) / max_r
            if r >= 1.0:
                continue
            a = math.atan2(dy, dx)
            # Tapered spokes plus delicate secondary rays.
            spoke = max(0.0, math.cos(a * rays)) ** 10
            spoke2 = max(0.0, math.cos(a * (rays * 2) + 0.35)) ** 22
            radial = max(0.0, 1.0 - r) ** 1.8
            edge = max(0.0, min(1.0, (1.0 - r) * 7.0))
            core = max(0.0, 1.0 - r * 5.0) ** 2
            alpha = (spoke * 0.58 + spoke2 * 0.22 + core * 0.55) * radial * edge
            alpha = max(0.0, min(1.0, alpha))
            px[x, y] = (255, 255, 255, int(alpha * 255))
    img = img.filter(ImageFilter.GaussianBlur(1.4))
    img.save(FX / "gacha_rays.png")


def make_vignette(size: int = 512) -> None:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = img.load()
    cx = cy = (size - 1) * 0.5
    for y in range(size):
        for x in range(size):
            r = math.hypot((x - cx) / cx, (y - cy) / cy)
            a = max(0.0, min(1.0, (r - 0.35) / 0.75))
            px[x, y] = (0, 0, 0, int((a ** 1.7) * 210))
    img = img.filter(ImageFilter.GaussianBlur(8))
    img.save(FX / "gacha_vignette.png")


def _write_wav(name: str, samples: list[float], rate: int = 44100) -> None:
    peak = max(1e-9, max(abs(s) for s in samples))
    scale = 0.92 / peak
    data = b"".join(
        struct.pack("<h", int(max(-1.0, min(1.0, s * scale)) * 32767))
        for s in samples
    )
    with wave.open(str(AUDIO / name), "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(rate)
        f.writeframes(data)


def make_charge(duration: float = 2.35, rate: int = 44100) -> None:
    rng = random.Random(20261025)
    n = int(duration * rate)
    out: list[float] = []
    noise = 0.0
    for i in range(n):
        t = i / rate
        u = t / duration
        env = min(1.0, u / 0.08) * (1.0 - u) ** 0.55
        freq = 110.0 * (8.0 ** (u ** 1.5))
        phase = 2.0 * math.pi * (110.0 * duration / (1.5 * math.log(8.0))) * (
            8.0 ** (1.5 * u) - 1.0
        )
        tone = (
            math.sin(phase)
            + 0.42 * math.sin(phase * 2.01 + 0.2)
            + 0.18 * math.sin(phase * 3.99 + 0.7)
            + 0.10 * math.sin(phase * 7.03)
        )
        shimmer = math.sin(2.0 * math.pi * (1260.0 + 500.0 * u) * t) * 0.06
        noise = noise * 0.94 + rng.uniform(-1.0, 1.0) * 0.06
        riser = noise * (0.05 + 0.35 * u ** 2)
        pulse_phase = (t % 0.39) / 0.39
        pulse = math.exp(-pulse_phase * 12.0) * 0.14 * math.sin(2.0 * math.pi * 220.0 * t)
        out.append((tone * 0.23 + shimmer + riser) * env + pulse * env)
    # Final transient that hands over to the impact cue.
    tail = int(0.08 * rate)
    for i in range(tail):
        v = 1.0 - i / tail
        out[-tail + i] += math.sin(2.0 * math.pi * 880.0 * i / rate) * 0.12 * v
    _write_wav("gacha_charge.wav", out, rate)


def make_impact(duration: float = 1.75, rate: int = 44100) -> None:
    rng = random.Random(20261026)
    n = int(duration * rate)
    out: list[float] = []
    for i in range(n):
        t = i / rate
        u = t / duration
        env = math.exp(-t * 2.6)
        sub = math.sin(2.0 * math.pi * (58.0 - 20.0 * min(1.0, t)) * t) * math.exp(-t * 1.8)
        air = rng.uniform(-1.0, 1.0) * math.exp(-t * 12.0) * 0.5
        bell = (
            math.sin(2.0 * math.pi * 523.25 * t) * 0.24
            + math.sin(2.0 * math.pi * 783.99 * t) * 0.15
            + math.sin(2.0 * math.pi * 1046.5 * t) * 0.09
        ) * math.exp(-t * 1.1)
        shimmer = math.sin(2.0 * math.pi * (1560.0 + 360.0 * math.sin(t * 9.0)) * t) * 0.045
        out.append((sub * 0.8 + air * 0.55 + bell + shimmer) * env)
    _write_wav("gacha_impact.wav", out, rate)


def make_legendary(duration: float = 2.3, rate: int = 44100) -> None:
    rng = random.Random(20261027)
    n = int(duration * rate)
    out: list[float] = []
    chord = [261.63, 329.63, 392.0, 523.25, 659.25, 783.99]
    for i in range(n):
        t = i / rate
        u = t / duration
        env = min(1.0, t / 0.025) * (1.0 - u) ** 0.7
        boom = math.sin(2.0 * math.pi * (46.0 + 24.0 * math.exp(-t * 3.0)) * t) * math.exp(-t * 1.2)
        noise = rng.uniform(-1.0, 1.0) * math.exp(-t * 8.0) * 0.65
        shimmer = 0.0
        for j, f in enumerate(chord):
            shimmer += math.sin(2.0 * math.pi * f * t + j * 0.55) * (0.075 / (1.0 + j * 0.4))
        sparkle = math.sin(2.0 * math.pi * (1760.0 + 900.0 * u) * t) * 0.045 * (0.5 + 0.5 * math.sin(t * 18.0))
        out.append((boom * 0.9 + noise * 0.5 + shimmer + sparkle) * env)
    _write_wav("gacha_legendary.wav", out, rate)


if __name__ == "__main__":
    make_rays()
    make_vignette()
    make_charge()
    make_impact()
    make_legendary()
    print("generated gacha_rays.png, gacha_vignette.png and 3 WAV cues")
