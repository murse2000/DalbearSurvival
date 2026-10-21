"""Procedural audio: chiptune-ish SFX and a seamless 64s moon-defense loop."""
from __future__ import annotations

import math
import os
import subprocess
import wave

import numpy as np

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
SR = 44100

rng = np.random.default_rng(7)


# ------------------------------------------------------------------ helpers
def t_axis(dur, sr=SR):
    return np.arange(int(dur * sr), dtype=np.float32) / sr


def env_ad(n, attack=0.005, decay=0.2, power=2.0):
    a = max(1, int(attack * SR))
    out = np.ones(n, dtype=np.float32)
    if a < n:
        out[:a] = np.linspace(0, 1, a, dtype=np.float32)
    d = np.linspace(0, 1, max(1, n - a), dtype=np.float32)
    out[a:] = np.exp(-d * decay * 8) * (1 - d) ** power
    return out


def sine(freq, dur, sr=SR):
    t = t_axis(dur, sr)
    return np.sin(2 * np.pi * freq * t).astype(np.float32)


def sweep(f0, f1, dur, kind="sine", sr=SR):
    t = t_axis(dur, sr)
    freq = np.linspace(f0, f1, len(t), dtype=np.float32)
    phase = 2 * np.pi * np.cumsum(freq) / sr
    if kind == "sine":
        return np.sin(phase).astype(np.float32)
    if kind == "saw":
        return (2 * (phase / (2 * np.pi) % 1) - 1).astype(np.float32)
    if kind == "square":
        return np.sign(np.sin(phase)).astype(np.float32)
    if kind == "tri":
        return (2 * np.abs(2 * (phase / (2 * np.pi) % 1) - 1) - 1).astype(np.float32)
    raise ValueError(kind)


def noise(dur, sr=SR):
    return rng.standard_normal(int(dur * sr)).astype(np.float32)


def lowpass(x, cutoff, sr=SR):
    # one-pole
    a = math.exp(-2 * math.pi * cutoff / sr)
    y = np.empty_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc = (1 - a) * v + a * acc
        y[i] = acc
    return y


def lowpass_fft(x, cutoff, sr=SR):
    spec = np.fft.rfft(x)
    freqs = np.fft.rfftfreq(len(x), 1 / sr)
    spec *= 1 / (1 + (freqs / cutoff) ** 4)
    return np.fft.irfft(spec, n=len(x)).astype(np.float32)


def highpass_fft(x, cutoff, sr=SR):
    spec = np.fft.rfft(x)
    freqs = np.fft.rfftfreq(len(x), 1 / sr)
    spec *= (freqs / cutoff) ** 4 / (1 + (freqs / cutoff) ** 4)
    return np.fft.irfft(spec, n=len(x)).astype(np.float32)


def add(buf, sig, at, gain=1.0):
    i = int(at * SR)
    if i >= len(buf):
        return
    n = min(len(sig), len(buf) - i)
    buf[i:i + n] += sig[:n] * gain


def note(midi):
    return 440.0 * 2 ** ((midi - 69) / 12)


def write_wav(path, data, sr=SR):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if data.ndim == 1:
        data = np.stack([data, data], axis=1)
    data = np.clip(data, -1, 1)
    pcm = (data * 32767).astype("<i2")
    with wave.open(path, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(pcm.tobytes())


def normalize(x, peak=0.9):
    m = float(np.max(np.abs(x)))
    if m < 1e-6:
        return x
    return (x / m * peak).astype(np.float32)


def bell(freq, dur=0.5, gain=1.0):
    t = t_axis(dur)
    e = env_ad(len(t), 0.003, 0.9, 1.2)
    s = (np.sin(2 * np.pi * freq * t) * 1.0
         + np.sin(2 * np.pi * freq * 2.01 * t) * 0.35
         + np.sin(2 * np.pi * freq * 3.02 * t) * 0.15)
    return (s * e * gain).astype(np.float32)


# ------------------------------------------------------------------ sfx
def sfx_shoot():
    t = t_axis(0.12)
    s = sweep(1350, 620, 0.12, "sine") * env_ad(len(t), 0.002, 1.4)
    spark = highpass_fft(noise(0.12), 3000) * env_ad(len(t), 0.001, 2.0, 1.5) * 0.12
    return normalize(s * 0.35 + spark, 0.7)


def sfx_hit():
    t = t_axis(0.1)
    thump = sweep(220, 70, 0.1, "sine") * env_ad(len(t), 0.001, 1.2)
    n = lowpass_fft(noise(0.1), 1800) * env_ad(len(t), 0.001, 1.8)
    return normalize(thump * 0.5 + n * 0.25, 0.7)


def sfx_kill():
    t = t_axis(0.24)
    n = lowpass_fft(noise(0.24), 1200) * env_ad(len(t), 0.004, 1.0)
    down = sweep(620, 160, 0.24, "sine") * env_ad(len(t), 0.002, 0.9) * 0.4
    return normalize(n * 0.35 + down, 0.7)


def sfx_pickup():
    buf = np.zeros(int(0.16 * SR), dtype=np.float32)
    add(buf, bell(note(88), 0.08, 0.5), 0.0, 0.7)
    add(buf, bell(note(95), 0.1, 0.4), 0.045, 0.6)
    return normalize(buf, 0.5)


def sfx_heal():
    buf = np.zeros(int(0.5 * SR), dtype=np.float32)
    for i, m in enumerate((72, 76, 79, 84)):
        add(buf, bell(note(m), 0.4, 0.4), i * 0.05, 0.5)
    return normalize(buf, 0.55)


def sfx_hurt():
    t = t_axis(0.3)
    s = sweep(220, 80, 0.3, "saw") * env_ad(len(t), 0.005, 1.0) * 0.35
    n = lowpass_fft(noise(0.3), 900) * env_ad(len(t), 0.002, 1.2) * 0.3
    return normalize(s + n, 0.75)


def sfx_levelup():
    buf = np.zeros(int(1.5 * SR), dtype=np.float32)
    for i, m in enumerate((69, 72, 76, 81, 84)):
        add(buf, bell(note(m), 0.8, 0.5), i * 0.075, 0.5)
    t = t_axis(1.2)
    shimmer = (np.sin(2 * np.pi * note(96) * t) + np.sin(2 * np.pi * note(100) * t)) * 0.04
    shimmer *= np.sin(np.pi * t / 1.2) ** 2
    add(buf, shimmer, 0.15)
    return normalize(buf, 0.6)


def sfx_click():
    t = t_axis(0.05)
    s = sweep(1100, 900, 0.05, "square") * env_ad(len(t), 0.001, 2.0)
    return normalize(s, 0.3)


def sfx_laser():
    t = t_axis(0.3)
    s = sweep(2000, 300, 0.3, "saw") * env_ad(len(t), 0.002, 1.0) * 0.3
    s = lowpass_fft(s, 2600)
    zap = highpass_fft(noise(0.3), 2500) * env_ad(len(t), 0.001, 2.0) * 0.1
    return normalize(s + zap, 0.6)


def sfx_pulse():
    t = t_axis(0.5)
    n = lowpass_fft(noise(0.5), 700) * env_ad(len(t), 0.01, 0.8)
    s = sweep(300, 60, 0.5, "sine") * env_ad(len(t), 0.01, 0.6) * 0.5
    return normalize(n * 0.3 + s, 0.7)


def sfx_boss():
    dur = 1.8
    t = t_axis(dur)
    base = 48 + 8 * np.sin(2 * np.pi * 0.8 * t)
    phase = 2 * np.pi * np.cumsum(base) / SR
    s = (np.sin(phase) + 0.5 * np.sign(np.sin(phase * 2))) * env_ad(len(t), 0.15, 0.6, 1.5)
    n = lowpass_fft(noise(dur), 400) * env_ad(len(t), 0.3, 0.5) * 0.4
    return normalize(s * 0.4 + n, 0.8)


def sfx_victory():
    buf = np.zeros(int(3.2 * SR), dtype=np.float32)
    for i, m in enumerate((69, 72, 76, 81, 84, 88)):
        add(buf, bell(note(m), 1.2, 0.45), i * 0.16, 0.5)
    t = t_axis(2.4)
    pad = (np.sin(2 * np.pi * note(57) * t) + np.sin(2 * np.pi * note(64) * t) +
           np.sin(2 * np.pi * note(69) * t)) * 0.06
    pad *= np.sin(np.pi * t / 2.4) ** 1.5
    add(buf, pad, 0.4)
    return normalize(buf, 0.65)


def sfx_gameover():
    buf = np.zeros(int(3.4 * SR), dtype=np.float32)
    for i, m in enumerate((64, 60, 57, 52, 45)):
        add(buf, bell(note(m), 1.4, 0.5), i * 0.3, 0.5)
    return normalize(buf, 0.6)


def sfx_dash():
    dur = 0.26
    t = t_axis(dur)
    n = highpass_fft(noise(dur), 900) * env_ad(len(t), 0.005, 1.4, 1.2)
    whoosh = n * 0.3
    swoosh = sweep(300, 1250, dur, "sine") * env_ad(len(t), 0.01, 1.8) * 0.12
    return normalize(whoosh + swoosh, 0.55)


def sfx_ultimate():
    dur = 2.0
    t = t_axis(dur)
    boom = sweep(95, 32, dur, "sine") * env_ad(len(t), 0.005, 0.55, 1.3) * 0.8
    rumble = lowpass_fft(noise(dur), 700) * env_ad(len(t), 0.01, 0.5, 1.4) * 0.35
    f = 280 + 1100 * (t / dur)
    phase = 2 * np.pi * np.cumsum(f) / SR
    shimmer = np.sin(phase).astype(np.float32) * env_ad(len(t), 0.4, 0.2, 1.5) * 0.12
    buf = np.zeros(int(2.8 * SR), dtype=np.float32)
    add(buf, boom + rumble + shimmer, 0.0)
    for i, m in enumerate((57, 69, 76, 81)):
        add(buf, bell(note(m), 1.0, 0.4), 0.05 + i * 0.045, 0.45)
    return normalize(buf, 0.75)


# ------------------------------------------------------------------ music
def music() -> np.ndarray:
    bpm = 90.0
    beat = 60.0 / bpm
    bar = beat * 4
    bars = 24
    total = bar * bars
    tail = 2.0
    n = int((total + tail) * SR)
    pad_l = np.zeros(n, dtype=np.float32)
    pad_r = np.zeros(n, dtype=np.float32)
    arp = np.zeros(n, dtype=np.float32)
    mel = np.zeros(n, dtype=np.float32)
    bass = np.zeros(n, dtype=np.float32)
    drums = np.zeros(n, dtype=np.float32)

    # Am - F - C - G, one bar each
    progression = [
        (45, [57, 60, 64, 69]),
        (41, [53, 57, 60, 65]),
        (48, [55, 60, 64, 67]),
        (43, [55, 59, 62, 67]),
    ]
    melody = [
        (0, 1.5, 76, 0.9), (0, 2.75, 79, 0.7), (0, 3.5, 81, 1.2),
        (1, 0.5, 72, 0.8), (1, 1.75, 74, 0.6), (1, 3.0, 76, 1.4),
        (2, 1.0, 79, 0.8), (2, 2.5, 76, 0.7),
        (3, 1.25, 74, 1.0), (3, 2.75, 72, 0.7), (3, 3.5, 69, 1.4),
    ]
    for b in range(bars):
        cycle = b % 4
        root, chord = progression[cycle]
        at = b * bar
        # pad (two detuned voices per note, spread)
        for j, m in enumerate(chord):
            dur = bar * 1.05
            t = t_axis(dur)
            f = note(m)
            vib = 1 + 0.0025 * np.sin(2 * np.pi * 0.23 * t + j)
            det = 1 + (j - 1.5) * 0.0015
            sig = (np.sin(2 * np.pi * f * det * t * vib)
                   + np.sin(2 * np.pi * f * 1.005 * t) * 0.5
                   + np.sin(2 * np.pi * f * 0.997 * t) * 0.5)
            e = env_ad(len(t), 0.5, 0.35, 1.3)
            e[-int(0.4 * SR):] *= np.linspace(1, 0, int(0.4 * SR))
            sig = lowpass_fft(sig.astype(np.float32), 900)
            sig *= e * 0.032
            add(pad_l, sig, at, 1.0 + (0.12 if j % 2 == 0 else -0.1))
            add(pad_r, sig, at, 1.0 - (0.12 if j % 2 == 0 else -0.1))
        # bass
        t = t_axis(bar * 0.95)
        f = note(root)
        bs = (np.sin(2 * np.pi * f * t) + 0.3 * np.sin(2 * np.pi * f * 2 * t))
        bs *= env_ad(len(t), 0.02, 0.5, 1.2) * 0.085
        add(bass, bs.astype(np.float32), at)
        # arpeggio, 8th notes
        tones = chord + [chord[0] + 12]
        pattern = [0, 1, 2, 3, 2, 1, 3, 2]
        for k, idx in enumerate(pattern):
            m = tones[idx % len(tones)]
            bdur = 0.3
            tt = t_axis(bdur)
            s = (np.sin(2 * np.pi * note(m + 12) * tt) * 0.7
                 + np.sin(2 * np.pi * note(m + 24) * tt) * 0.15)
            s *= env_ad(len(tt), 0.004, 1.8, 1.4) * 0.035
            pan = 0.5 + 0.35 * math.sin(k * 1.7 + b)
            add(arp, s.astype(np.float32), at + k * beat / 2)
        # drums
        for k in range(4):
            # kick on every beat, softer on 2/4
            kt = t_axis(0.28)
            kf = 95 * np.exp(-kt * 18) + 42
            ph = 2 * np.pi * np.cumsum(kf) / SR
            kick = np.sin(ph) * env_ad(len(kt), 0.001, 1.2, 2.2)
            add(drums, kick.astype(np.float32), at + k * beat,
                0.16 if k in (0, 2) else 0.10)
            # hat on offbeats
            ht = t_axis(0.06)
            hat = highpass_fft(noise(0.06), 6000) * env_ad(len(ht), 0.001, 2.5, 2)
            add(drums, hat, at + k * beat + beat / 2, 0.05)
        if b % 8 == 7:
            # soft fill / snare
            for k in (2, 3):
                st = t_axis(0.18)
                sn = highpass_fft(noise(0.18), 1500) * env_ad(len(st), 0.001, 1.3, 1.5)
                add(drums, sn, at + k * beat, 0.05)
        # melody
        for (mb, mbeat, mm, mdur) in melody:
            if mb != cycle:
                continue
            tt = t_axis(mdur)
            s = (np.sin(2 * np.pi * note(mm) * tt) * 0.7
                 + np.sin(2 * np.pi * note(mm + 12) * tt) * 0.2)
            s *= env_ad(len(tt), 0.01, 1.2, 1.2) * 0.075
            add(mel, s.astype(np.float32), at + mbeat * beat)

    # wind bed and distant pulse
    wind = lowpass_fft(noise(total), 500) * 0.012
    add(pad_l, wind, 0.0, 0.7)
    add(pad_r, wind, 0.0, 0.7)

    # reverb (stereo, generated IR)
    def make_ir(seed, dur=2.2):
        r = np.random.default_rng(seed)
        n = int(dur * SR)
        t = np.arange(n) / SR
        ir = r.standard_normal(n) * np.exp(-t * 2.6)
        ir = lowpass_fft(ir.astype(np.float32), 3500)
        ir[: int(0.018 * SR)] *= np.linspace(0, 1, int(0.018 * SR))
        return (ir / np.max(np.abs(ir))).astype(np.float32)

    def reverb_st(x, wet=0.3):
        irL = make_ir(11)
        irR = make_ir(12)
        size = len(x) + len(irL)
        nfft = 1 << (size - 1).bit_length()
        XL = np.fft.rfft(x, nfft)
        yL = np.fft.irfft(XL * np.fft.rfft(irL, nfft), nfft)[: len(x)]
        yR = np.fft.irfft(XL * np.fft.rfft(irR, nfft), nfft)[: len(x)]
        return (yL * wet).astype(np.float32), (yR * wet).astype(np.float32)

    wet_pad = reverb_st(pad_l * 0.7 + pad_r * 0.3, 0.5)
    wet_mel = reverb_st(mel, 0.65)
    wet_arp = reverb_st(arp, 0.45)
    L = pad_l + bass + drums + arp * 0.55 + mel + wet_pad[0] + wet_mel[0] + wet_arp[0]
    R = pad_r + bass + drums * 0.95 + arp * 0.45 + mel * 0.95 + wet_pad[1] + wet_mel[1] + wet_arp[1]

    # wrap reverb tail into the loop start, trim to exact length
    nloop = int(total * SR)
    ntail = n - nloop
    L[:ntail] += L[nloop:]
    R[:ntail] += R[nloop:]
    L = L[:nloop]
    R = R[:nloop]
    # remove DC and soft clip
    st = np.stack([L, R], axis=1)
    st = st - st.mean(axis=0, keepdims=True)
    st = np.tanh(st * 0.9)
    st = np.stack([highpass_fft(st[:, 0], 42), highpass_fft(st[:, 1], 42)], axis=1)
    st = st / max(1e-6, np.max(np.abs(st))) * 0.58
    return st.astype(np.float32)


def main():
    os.makedirs(OUT, exist_ok=True)
    sfx = {
        "shoot": sfx_shoot(),
        "hit": sfx_hit(),
        "kill": sfx_kill(),
        "pickup": sfx_pickup(),
        "heal": sfx_heal(),
        "hurt": sfx_hurt(),
        "levelup": sfx_levelup(),
        "click": sfx_click(),
        "laser": sfx_laser(),
        "pulse": sfx_pulse(),
        "boss": sfx_boss(),
        "victory": sfx_victory(),
        "gameover": sfx_gameover(),
        "dash": sfx_dash(),
        "ultimate": sfx_ultimate(),
    }
    for name, data in sfx.items():
        write_wav(os.path.join(OUT, name + ".wav"), data)
    print("sfx done")

    m = music()
    wav_path = os.path.join(OUT, "music_loop.wav")
    write_wav(wav_path, m)
    print("music rendered", m.shape, "peak", float(np.max(np.abs(m))))
    ogg_path = os.path.join(OUT, "music_loop.ogg")
    subprocess.run([
        "ffmpeg", "-y", "-loglevel", "error", "-i", wav_path,
        "-c:a", "libvorbis", "-q:a", "4", ogg_path
    ], check=True)
    os.remove(wav_path)
    print("music ogg done", os.path.getsize(ogg_path))


if __name__ == "__main__":
    main()
