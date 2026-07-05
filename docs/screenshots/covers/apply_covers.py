import numpy as np
from scipy import ndimage
from PIL import Image, ImageFilter

# Map: raw screenshot -> cover image (verified to match the seeded card thumbnails).
JOBS = [
    ("ipad-13/1-scan-to-add.png",    "covers/circe_apple.jpg", False),
    ("ipad-13/3-find-the-shelf.png", "covers/gruffalo_ol.jpg", True),   # low-res -> sharpen
    ("ipad-13/5-scan-to-return.png", "covers/fah_cand0.jpg",   False),
]

T = 30   # luminance <= T counts as scanner black

def build(raw_path, cover_path, sharpen):
    shot = Image.open(raw_path).convert("RGB")
    W, H = shot.size
    arr = np.asarray(shot).astype(np.float32)
    lum = 0.299 * arr[:, :, 0] + 0.587 * arr[:, :, 1] + 0.114 * arr[:, :, 2]

    # Only the black that is CONNECTED to the image border is the scanner background;
    # dark text enclosed by the white card is not, so it is preserved.
    isblack = lum <= T
    lbl, n = ndimage.label(isblack)
    border = np.concatenate([lbl[0, :], lbl[-1, :], lbl[:, 0], lbl[:, -1]])
    bg_labels = np.unique(border)
    bg_labels = bg_labels[bg_labels != 0]
    bgmask = np.isin(lbl, bg_labels)

    # Feather the region edge slightly for a clean composite against the card.
    alpha = ndimage.gaussian_filter(bgmask.astype(np.float32), sigma=1.2)
    alpha = np.clip(alpha, 0.0, 1.0)[:, :, None]

    # Fit-to-height cover -> black bands on the sides.
    cover = Image.open(cover_path).convert("RGB")
    cw = round(cover.width * H / cover.height)
    cover = cover.resize((cw, H), Image.LANCZOS)
    if sharpen:
        cover = cover.filter(ImageFilter.UnsharpMask(radius=2.2, percent=110, threshold=2))
    bg = Image.new("RGB", (W, H), (0, 0, 0))
    bg.paste(cover, ((W - cw) // 2, 0))
    bg_arr = np.asarray(bg).astype(np.float32)

    out = arr * (1 - alpha) + bg_arr * alpha
    Image.fromarray(np.clip(out, 0, 255).astype(np.uint8)).save(raw_path, "PNG")
    print("composited", raw_path, "band", (W - cw) // 2, "px each side")

for raw, cover, sh in JOBS:
    build(raw, cover, sh)
