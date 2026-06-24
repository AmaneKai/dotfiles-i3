#!/usr/bin/env python3

import os
import sys
import subprocess
from PIL import Image, ImageFilter

SCREENSHOT_PATH = "/tmp/lock_screenshot.png"
ROSE_PINE_BASE = (25, 23, 36, 165)


def take_screenshot(output_path: str) -> None:
  subprocess.run(["maim", output_path], capture_output=True)


def apply_blur(image: Image.Image, radius: int = 28) -> Image.Image:
  return image.filter(ImageFilter.GaussianBlur(radius=radius))


def apply_dark_tint(image: Image.Image, tint_color: tuple) -> Image.Image:
  tint_layer = Image.new("RGBA", image.size, tint_color)
  return Image.alpha_composite(image, tint_layer)


def apply_vignette(image: Image.Image) -> Image.Image:
  try:
    import numpy as np

    width, height = image.size
    y_coords, x_coords = np.mgrid[:height, :width]
    distance = np.sqrt(
      ((x_coords - width / 2) / (width / 2)) ** 2
      + ((y_coords - height / 2) / (height / 2)) ** 2
    )
    alpha = np.clip(distance * 120, 0, 110).astype(np.uint8)
    zeros = np.zeros((height, width), np.uint8)
    vignette_layer = Image.fromarray(
      np.stack([zeros, zeros, zeros, alpha], axis=2), "RGBA"
    )
    return Image.alpha_composite(image, vignette_layer)
  except ImportError:
    return image


def generate_lock_screen(output_path: str) -> None:
  take_screenshot(SCREENSHOT_PATH)

  image = Image.open(SCREENSHOT_PATH).convert("RGBA")
  image = apply_blur(image)
  image = apply_dark_tint(image, ROSE_PINE_BASE)
  image = apply_vignette(image)
  image.convert("RGB").save(output_path)

  os.remove(SCREENSHOT_PATH)


def main() -> None:
  output_path = sys.argv[1] if len(sys.argv) > 1 else "/tmp/lock_final.png"
  generate_lock_screen(output_path)


if __name__ == "__main__":
  main()
