from PIL import Image, ImageDraw, ImageFilter
import os, math

BASE = os.path.join(os.path.dirname(__file__), "..", "assets")
OUT = os.path.join(BASE, "..", "icon.png")
S = 4
W = 128


def main():
    img = Image.new("RGBA", (W * S, W * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # rounded dark badge
    d.rounded_rectangle([6 * S, 6 * S, 122 * S, 122 * S], radius=24 * S,
                        fill=(16, 26, 42, 255), outline=(255, 208, 108, 255), width=3 * S)
    # night gradient circles
    d.ellipse([16 * S, 16 * S, 112 * S, 112 * S], fill=(22, 38, 54, 255))
    d.ellipse([24 * S, 24 * S, 104 * S, 104 * S], fill=(28, 54, 66, 255))
    # moon glow
    glow = Image.new("RGBA", (W * S, W * S), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    for r in range(48, 8, -4):
        gd.ellipse([92 * S - r * S, 36 * S - r * S, 92 * S + r * S, 36 * S + r * S],
                   fill=(220, 235, 255, 5))
    glow = glow.filter(ImageFilter.GaussianBlur(8))
    img.alpha_composite(glow)
    d.ellipse([76 * S, 18 * S, 108 * S, 50 * S], fill=(228, 240, 255, 255))
    d.ellipse([84 * S, 24 * S, 106 * S, 46 * S], fill=(240, 246, 255, 255))
    for cx, cy, cr in ((88, 30, 4), (97, 38, 3), (84, 41, 2)):
        d.ellipse([cx * S, cy * S, (cx + cr) * S, (cy + cr) * S], fill=(208, 222, 242, 255))
    # stars
    for x, y in ((28, 22), (40, 36), (24, 58), (36, 78), (18, 90), (58, 18), (108, 72)):
        d.rectangle([x * S, y * S, (x + 1) * S, (y + 1) * S], fill=(255, 226, 150, 220))
    # bear head
    sheet = Image.open(os.path.join(BASE, "art", "char", "player_sheet.png")).convert("RGBA")
    head = sheet.crop((4, 0, 28, 30))  # first frame: head + scarf
    head = head.resize((head.width * 11, head.height * 11), Image.NEAREST)
    img.alpha_composite(head, (int(64 * S - head.width / 2), int(82 * S - head.height / 2)))
    # small moon badge on the scarf
    d.ellipse([55 * S, 88 * S, 65 * S, 99 * S], fill=(255, 208, 108, 255))
    d.ellipse([59 * S, 88 * S, 69 * S, 99 * S], fill=(232, 102, 88, 255))
    img = img.resize((W, W), Image.BOX)
    # quantize-ish cleanup
    img.save(OUT)
    print("icon saved", OUT)


if __name__ == "__main__":
    main()
