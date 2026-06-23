#!/usr/bin/env bash

THEME="$HOME/.config/rofi/rose-pine.rasi"
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

# ── Outputs ───────────────────────────────────────────────────
echo "─────  󰕾  OUTPUTS  ─────###header###" >> "$TMPFILE"
while IFS= read -r line; do
    name=$(echo "$line" | awk '{print $2}')
    desc=$(pactl list sinks | grep -A 30 "Name: $name" | grep "Description:" | head -1 | sed 's/.*Description: //')
    [[ -z "$desc" ]] && desc="$name"
    icon="󰕾"; [[ "$name" == *bluez* ]] && icon="󰋋"
    echo "${icon}  ${desc}###sink###${name}" >> "$TMPFILE"
done < <(pactl list sinks short)

# ── Inputs ────────────────────────────────────────────────────
echo "─────  󰍬  INPUTS  ──────###header###" >> "$TMPFILE"
while IFS= read -r line; do
    name=$(echo "$line" | awk '{print $2}')
    [[ "$name" == *monitor* ]] && continue
    desc=$(pactl list sources | grep -A 30 "Name: $name" | grep "Description:" | head -1 | sed 's/.*Description: //')
    [[ -z "$desc" ]] && desc="$name"
    icon="󰍬"; [[ "$name" == *bluez* ]] && icon="󰋎"
    echo "${icon}  ${desc}###source###${name}" >> "$TMPFILE"
done < <(pactl list sources short)

# ── Active indices for headers ────────────────────────────────
idx=0
active_indices=""
while IFS= read -r line; do
    [[ "$line" == *"###header###"* ]] && active_indices+="${idx},"
    ((idx++))
done < "$TMPFILE"
active_indices="${active_indices%,}"

# ── Show rofi ─────────────────────────────────────────────────
rofi_args=(-dmenu -i -p "audio" -theme "$THEME" -format i)
[[ -n "$active_indices" ]] && rofi_args+=(-a "$active_indices")

chosen=$(awk -F'###' '{print $1}' "$TMPFILE" | rofi "${rofi_args[@]}")
[[ -z "$chosen" ]] && exit 0

full=$(awk "NR==$((chosen+1))" "$TMPFILE")
type=$(echo "$full" | awk -F'###' '{print $2}')
device=$(echo "$full" | awk -F'###' '{print $3}')
label=$(echo "$full" | awk -F'###' '{print $1}')

[[ "$type" == "header" || -z "$device" ]] && exit 0

# ── Apply ─────────────────────────────────────────────────────
if [[ "$type" == "sink" ]]; then
    pactl set-default-sink "$device"
    pactl list sink-inputs short | awk '{print $1}' | while read -r s; do
        pactl move-sink-input "$s" "$device" 2>/dev/null || true
    done
    notify-send "󰕾 Output" "$label"
else
    pactl set-default-source "$device"
    pactl list source-outputs short | awk '{print $1}' | while read -r s; do
        pactl move-source-output "$s" "$device" 2>/dev/null || true
    done
    notify-send "󰍬 Input" "$label"
fi
