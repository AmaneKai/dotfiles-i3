#!/bin/bash

# i3lock with blurred screenshot background

# Take a screenshot
scrot /tmp/screen_locked.png

# Blur the screenshot
convert /tmp/screen_locked.png -blur 0x5 /tmp/screen_locked_blurred.png

# Lock the screen with the blurred screenshot
i3lock -i /tmp/screen_locked_blurred.png

# Optional: Remove temporary files
rm /tmp/screen_locked.png /tmp/screen_locked_blurred.png
