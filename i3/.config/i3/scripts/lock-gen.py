#!/usr/bin/env python3
import subprocess, sys, os
from PIL import Image, ImageFilter

SCREENSHOT = "/tmp/lock_ss.png"
OUTPUT = sys.argv[1] if len(sys.argv) > 1 else "/tmp/lock_final.png"

subprocess.run(["maim", SCREENSHOT], capture_output=True)
img = Image.open(SCREENSHOT).convert("RGBA")
w, h = img.size

# heavy blur
img = img.filter(ImageFilter.GaussianBlur(radius=28))

# Rose Pine dark tint
img = Image.alpha_composite(img, Image.new("RGBA", (w, h), (25, 23, 36, 165)))

# radial vignette (darker edges, draws focus to center)
try:
    import numpy as np
    Y, X = np.mgrid[:h, :w]
    dist = np.sqrt(((X - w/2)/(w/2))**2 + ((Y - h/2)/(h/2))**2)
    alpha = np.clip(dist * 120, 0, 110).astype(np.uint8)
    zeros = np.zeros((h, w), np.uint8)
    vig = Image.fromarray(np.stack([zeros, zeros, zeros, alpha], axis=2), "RGBA")
    img = Image.alpha_composite(img, vig)
except ImportError:
    pass

img.convert("RGB").save(OUTPUT)
os.remove(SCREENSHOT)
