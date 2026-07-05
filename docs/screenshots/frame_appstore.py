from PIL import Image, ImageDraw, ImageFont

BLUE = (23, 99, 201)            # #1763C9
WHITE = (255, 255, 255)
SUB = (203, 222, 247)           # light tint for subheads

SF = "/System/Library/Fonts/SFNS.ttf"
ARIAL_B = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
ARIAL_R = "/System/Library/Fonts/Supplemental/Arial.ttf"

def font(size, weight):
    try:
        f = ImageFont.truetype(SF, size)
        f.set_variation_by_name(weight)   # 'Semibold' / 'Regular'
        return f
    except Exception:
        return ImageFont.truetype(ARIAL_B if weight != "Regular" else ARIAL_R, size)

def wrap(draw, text, fnt, maxw):
    # Honours explicit "\n" hard breaks, then greedily wraps within each segment.
    lines = []
    for segment in text.split("\n"):
        cur = ""
        for w in segment.split():
            t = (cur + " " + w).strip()
            if draw.textlength(t, font=fnt) <= maxw:
                cur = t
            else:
                if cur: lines.append(cur)
                cur = w
        if cur: lines.append(cur)
    return lines

def line_h(draw, fnt):
    b = draw.textbbox((0, 0), "Ag", font=fnt)
    return b[3] - b[1]

def draw_block(draw, lines, fnt, color, W, cy, lh, gap):
    total = len(lines) * lh + (len(lines) - 1) * gap
    y = cy - total / 2
    for ln in lines:
        w = draw.textlength(ln, font=fnt)
        draw.text((W / 2 - w / 2, y), ln, font=fnt, fill=color)
        y += lh + gap
    return total

def build(src, dst, W, H, headline, subhead, head_px, sub_px, side_frac, bottom_frac, round_corners=True):
    # Scale the screenshot to (1 - 2*side_frac) of the canvas width (aspect preserved),
    # bottom-align it with `bottom_frac` padding below, and let the remaining top space
    # be the blue caption band. No status-bar crop — the captures are already clean.
    img = Image.open(src).convert("RGB")
    box_w = round(W * (1 - 2 * side_frac))
    box_h = round(img.height * box_w / img.width)
    shot = img.resize((box_w, box_h), Image.LANCZOS)
    box_x = round(W * side_frac)
    box_y = H - round(H * bottom_frac) - box_h
    cap_h = box_y                       # top blue band that holds the caption
    canvas = Image.new("RGB", (W, H), BLUE)
    if round_corners:
        # Round the top corners so the screenshot reads as a card on the blue frame.
        # The radius matches the app's own sheet-card corner, so on the iPhone scan
        # sheets the grey wedges outside the card fall outside the mask (showing blue).
        radius = round(box_w * 0.085)
        mask = Image.new("L", (box_w, box_h), 0)
        ImageDraw.Draw(mask).rounded_rectangle(
            [0, 0, box_w - 1, box_h - 1], radius=radius, fill=255, corners=(True, True, False, False)
        )
        canvas.paste(shot, (box_x, box_y), mask)
    else:
        canvas.paste(shot, (box_x, box_y))
    draw = ImageDraw.Draw(canvas)
    maxw = W * 0.84
    hf = font(head_px, "Semibold")
    hlines = wrap(draw, headline, hf, maxw)
    hlh = line_h(draw, hf)
    if subhead:
        sf = font(sub_px, "Regular")
        slines = wrap(draw, subhead, sf, maxw)
        slh = line_h(draw, sf)
        h_block = len(hlines) * hlh + (len(hlines) - 1) * 14
        s_block = len(slines) * slh + (len(slines) - 1) * 10
        between = 36
        total = h_block + between + s_block
        top = cap_h / 2 - total / 2
        hc = top + h_block / 2
        sc = top + h_block + between + s_block / 2
        draw_block(draw, hlines, hf, WHITE, W, hc, hlh, 14)
        draw_block(draw, slines, sf, SUB, W, sc, slh, 10)
    else:
        draw_block(draw, hlines, hf, WHITE, W, cap_h / 2, hlh, 16)
    canvas.save(dst, "PNG")
    print("saved", dst)

heads = [
    "Scan it in your library",
    "See where each one is placed",
    "Scan to find its shelf",
    "Lend it to a friend",
    "Scan to put it back",
]
subs = [
    "Title, author, and cover, found for you",
    "Organized to match your real shelves",
    "Never wonder where a book goes",
    "Always know who has your books",
    "Gets back on the right shelf",
]
files = ["1-scan-to-add", "2-your-library", "3-find-the-shelf", "4-lend-a-book", "5-scan-to-return"]

base = "docs/screenshots"

# iPhone uses a hard line break on shot 2 so it reads "See where each one / is placed".
iphone_heads = list(heads)
iphone_heads[1] = "See where each one\nis placed"

for i, name in enumerate(files):
    # iPad 13" (2064x2752): 5% sides, 0% bottom -> ~21.5% top; squared corners.
    build(f"{base}/ipad-13/{name}.png", f"{base}/appstore/ipad-13/{name}.png",
          2064, 2752, heads[i], subs[i], 108, 58, side_frac=0.05, bottom_frac=0.0, round_corners=False)

    # iPhone 6.7" (1284x2778): 5% sides, 0% bottom -> ~17.7% top; rounded top corners.
    build(f"{base}/iphone-6.9/{name}.png", f"{base}/appstore/iphone-6.7/{name}.png",
          1284, 2778, iphone_heads[i], None, 97, 0, side_frac=0.05, bottom_frac=0.0, round_corners=True)
