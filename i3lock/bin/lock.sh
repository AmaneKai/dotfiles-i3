#!/usr/bin/env bash

readonly LOCK_IMAGE="/tmp/lock_screen.png"
readonly LOCK_GENERATOR="$HOME/.config/i3/scripts/lock-gen.py"

[ ! -f "$LOCK_GENERATOR" ] && notify-send "Lock" "Lock screen generator not found" && exit 1

python3 "$LOCK_GENERATOR" "$LOCK_IMAGE"

i3lock \
  --image "$LOCK_IMAGE" \
  --clock \
  --time-str="%H:%M" \
  --date-str="%A, %B %d" \
  --time-font="JetBrainsMono Nerd Font" \
  --date-font="JetBrainsMono Nerd Font" \
  --time-size=36 \
  --date-size=14 \
  --time-color=e0def4ff \
  --date-color=6e6a86ff \
  --ring-color=9ccfd855 \
  --ringver-color=c4a7e7ff \
  --ringwrong-color=eb6f92ff \
  --inside-color=1f1d2ecc \
  --insidever-color=1f1d2ecc \
  --insidewrong-color=1f1d2eee \
  --line-color=9ccfd830 \
  --keyhl-color=9ccfd8ff \
  --bshl-color=eb6f92ff \
  --separator-color=26233aff \
  --verif-color=c4a7e7ff \
  --wrong-color=eb6f92ff \
  --verif-text="..." \
  --wrong-text="x" \
  --verif-font="JetBrainsMono Nerd Font" \
  --wrong-font="JetBrainsMono Nerd Font" \
  --radius=95 \
  --ring-width=5 \
  --indicator

rm -f "$LOCK_IMAGE"
