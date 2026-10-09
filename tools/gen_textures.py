"""
RONIM texture generator.

Writes the NVG tube masks and monocular reticles as PNG into tools/textures/, then converts
them to PAA into addons/main/data/ with HEMTT.

Run from the repository root:  python tools/gen_textures.py
Needs: numpy, Pillow, hemtt on PATH.

Binocular/quad masks are 2048x1024 (2:1), monocular masks 1024x1024 (1:1, only the tube's
own box is covered, the other eye keeps the real view). The mask control always keeps the
texture's pixel aspect, so tubes stay circular on any screen. Black = blocked, transparent = tube.
Reticles are 256x256 white on transparent; the game tints them.
"""
import os
import subprocess

import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "tools", "textures")
OUT = os.path.join(ROOT, "addons", "main", "data")

W, H = 2048, 1024
EDGE = 0.03       # soft edge width, fraction of texture height
VIGNETTE = 0.16   # inner darkening band, fraction of tube radius
VIGNETTE_MAX = 0.55


def smoothstep(e0, e1, x):
    t = np.clip((x - e0) / (e1 - e0), 0.0, 1.0)
    return t * t * (3 - 2 * t)


# Shape -> (polygon sides or None, apothem / radius, first vertex angle). Polygon tubes are sized by
# their apothem so every shape fills about the same box as the circle of radius r.
SHAPES = {
    "circle": (None, 1.0, 0.0),
    "square": (4, 0.94, np.pi / 4),
    "roundsquare": ("super", 0.95, 0.0),
    "triangle": (3, 0.58, -np.pi / 2),
    "pentagon": (5, 0.85, -np.pi / 2),
    "hexagon": (6, 0.95, 0.0),
    "octagon": (8, 0.97, np.pi / 8),
}


def tube_alpha(xx, yy, cx, cy, r, shape="circle"):
    """Opacity of the mask for one tube: 0 inside, 1 outside, soft edge and vignette.

    rho = distance / boundary distance in that direction, so 1 is the tube's edge for any shape.
    """
    sides, k, first = SHAPES[shape]
    a = r * k
    if sides in (3, 5):
        cy = cy + (a / np.cos(np.pi / sides) - a) / 2  # odd polygons point up: centre them vertically
    dx, dy = xx - cx, yy - cy
    d = np.sqrt(dx * dx + dy * dy)
    theta = np.arctan2(dy, dx)
    if sides is None:
        boundary = np.full_like(d, r)
    elif sides == "super":
        p = 4.0
        boundary = a / (np.abs(np.cos(theta)) ** p + np.abs(np.sin(theta)) ** p) ** (1 / p)
    else:
        seg = 2 * np.pi / sides
        boundary = a / np.cos(np.mod(theta - first, seg) - seg / 2)
    rho = d / boundary
    edge = smoothstep(1 - EDGE / r, 1, rho)
    vig = smoothstep(1 - VIGNETTE, 1, rho) * VIGNETTE_MAX
    return np.maximum(edge, vig)


def mask(tubes, w, shape="circle"):
    # Coordinates in units of texture height, origin at texture centre
    ys, xs = np.mgrid[0:H, 0:w].astype(np.float32)
    xx = (xs - w / 2 + 0.5) / H
    yy = (ys - H / 2 + 0.5) / H
    alpha = np.ones((H, w), np.float32)
    for cx, cy, r in tubes:
        alpha = np.minimum(alpha, tube_alpha(xx, yy, cx, cy, r, shape))
    rgba = np.zeros((H, w, 4), np.uint8)
    rgba[..., 3] = (alpha * 255).round().astype(np.uint8)
    return Image.fromarray(rgba, "RGBA")


# Written as mask_<tube>_<shape>_ca.paa for every shape. Ellipse/rectangle are the circle/square
# stretched in game (Shape width setting).
MASKS = {
    "mono": (H, [(0.0, 0.0, 0.47)]),
    "bino": (W, [(-0.30, 0.0, 0.42), (0.30, 0.0, 0.42)]),
    "quad": (W, [(-0.27, 0.0, 0.40), (0.27, 0.0, 0.40), (-0.70, 0.02, 0.33), (0.70, 0.02, 0.33)]),
}


def reticle(style):
    n = 256
    s = 4  # supersample
    big = n * s
    ys, xs = np.mgrid[0:big, 0:big].astype(np.float32)
    x = (xs - big / 2 + 0.5) / big   # -0.5..0.5
    y = (ys - big / 2 + 0.5) / big
    a = np.zeros((big, big), np.float32)
    line = 0.012
    if style == "dot":
        a = np.maximum(a, (np.sqrt(x * x + y * y) < 0.035).astype(np.float32))
        ring = np.abs(np.sqrt(x * x + y * y) - 0.30) < line / 1.5
        a = np.maximum(a, ring.astype(np.float32))
    elif style == "cross":
        gap = 0.04
        h = (np.abs(y) < line) & (np.abs(x) > gap) & (np.abs(x) < 0.48)
        v = (np.abs(x) < line) & (np.abs(y) > gap) & (np.abs(y) < 0.48)
        a = np.maximum(a, (h | v).astype(np.float32))
        a = np.maximum(a, (np.sqrt(x * x + y * y) < 0.012).astype(np.float32))
    elif style == "chevron":
        # Apex at centre, legs down-left and down-right, plus a stadia line below
        legs = (np.abs(np.abs(x) - y) < line * 1.4) & (y > 0) & (y < 0.18)
        stem = (np.abs(x) < line) & (y > 0.24) & (y < 0.48)
        a = np.maximum(a, (legs | stem).astype(np.float32))
    elif style == "mildot":
        h = (np.abs(y) < line * 0.7) & (np.abs(x) < 0.48)
        v = (np.abs(x) < line * 0.7) & (np.abs(y) < 0.48)
        a = np.maximum(a, (h | v).astype(np.float32))
        for i in range(1, 5):
            o = i * 0.09
            for dx, dy in ((o, 0), (-o, 0), (0, o), (0, -o)):
                a = np.maximum(a, (np.sqrt((x - dx) ** 2 + (y - dy) ** 2) < 0.018).astype(np.float32))
    img = Image.fromarray((a * 255).round().astype(np.uint8), "L").resize((n, n), Image.LANCZOS)
    rgba = Image.new("RGBA", (n, n), (255, 255, 255, 0))
    rgba.putalpha(img)
    return rgba


def convert(name, img):
    png = os.path.join(SRC, name + ".png")
    paa = os.path.join(OUT, name + ".paa")
    img.save(png)
    subprocess.run(["hemtt", "utils", "paa", "convert", png, paa], check=True)
    print("wrote", os.path.relpath(paa, ROOT))


if __name__ == "__main__":
    os.makedirs(SRC, exist_ok=True)
    os.makedirs(OUT, exist_ok=True)
    for old in ("mask_mono_ca", "mask_bino_ca", "mask_quad_ca"):
        for ext, folder in ((".paa", OUT), (".png", SRC)):
            path = os.path.join(folder, old + ext)
            if os.path.exists(path):
                os.remove(path)
    for tube, (w, tubes) in MASKS.items():
        for shape in SHAPES:
            convert(f"mask_{tube}_{shape}_ca", mask(tubes, w, shape))
    for style in ("dot", "cross", "chevron", "mildot"):
        convert(f"reticle_{style}_ca", reticle(style))
