# Third-party notices

This project uses the following third-party assets. Full license texts are kept
next to the assets and linked below.

## 1. Kenney Particle Pack 1.1 — CC0 1.0 Universal

- Author: Kenney Vleugels (Kenney.nl)
- Source: https://kenney.nl/assets/particle-pack
- License: Creative Commons Zero 1.0 (public domain dedication)
- Local license: `assets/particles/LICENSE_kenney.txt`
- Files used: selected PNG particle textures in `assets/particles/`
  (star, spark, flare, magic, circle, smoke, muzzle, slash, dirt, symbol,
  trace, twirl, light, flame).
- Modifications: downscaled to 128px and tinted at runtime; no other changes.

CC0 1.0 summary: The author waived all copyright and related rights. The assets
may be used in personal and commercial projects without attribution.

## 2. Galmuri11 — SIL Open Font License 1.1

- Author: Lee Minseo (quiple@quiple.dev)
- Source: https://github.com/quiple/galmuri
- License: SIL Open Font License, Version 1.1
- Local license: `assets/fonts/OFL.md`
- File: `assets/fonts/Galmuri11.ttf`
- Use: Korean/Latin pixel UI font.

The font is used as-is, not sold by itself, and is embedded in the game. The
reserved font name(s) of the original are not modified.

## 3. Godot Engine 4.7.1 — MIT License

- Copyright: Godot Engine contributors / Juan Linietsky, Ariel Manzur
- Source: https://godotengine.org
- License: MIT
- The exported game embeds the Godot runtime. See the Godot license for details.

## 4. Lit - 2D Lighting Engine 1.1.7 — MIT License

- Author: Shawn Deprey (Fading Lantern Games)
- Source: https://github.com/shawndeprey/lit
- Godot Asset Library: https://godotengine.org/asset-library/asset/5303
- License: MIT
- Local license: `addons/lit/LICENSE`
- Use: Forward+ desktop 2D lighting, shadows and light bursts.
- Modifications: integrated as a runtime dependency; no source changes to the addon.

The addon is used under the MIT license. The Android build uses the game's native
`CanvasModulate` / `PointLight2D` fallback because Lit requires Forward+.

## 5. Project-original assets

All other art, audio, game code and text were created for this project
(2026, dalbear.com) and are original works. They are not derived from any
third-party game or franchise.

- Character/enemy/world/UI/title art: `assets/art/`
- Chapter-stage enemy variants: `assets/art/char/chapter_enemies/` (200 generated sprites)
- Generated music and SFX: `assets/audio/`
- Gacha summon rays, vignette and cues: `assets/art/fx/gacha_rays.png`,
  `assets/art/fx/gacha_vignette.png`, `assets/audio/gacha_charge.wav`,
  `assets/audio/gacha_impact.wav`, `assets/audio/gacha_legendary.wav`
- Generation tools: `tools/` (Python/Pillow/NumPy)
- Chapter enemy generator: `tools/gen_chapter_enemies.py`

## 6. Kenney UI Pack - Pixel Adventure

- Author: Kenney (Kenney.nl)
- Source: https://kenney.nl/assets/ui-pack-pixel-adventure
- License: Creative Commons CC0 1.0 Universal
- Local license: `assets/ui/pixel_adventure/LICENSE.txt`
- Use: selected button and panel border tiles in `assets/ui/pixel_adventure/`
- Modifications: colors remapped to the game's navy/gold palette and converted
  to 9-slice UI styles.

CC0 1.0 waives copyright and related rights. Attribution is not required and is
included here as a courtesy.