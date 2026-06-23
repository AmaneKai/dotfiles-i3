#!/usr/bin/env bash

THEME="$HOME/.config/rofi/rose-pine.rasi"
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

# ── Check bluetooth power state ───────────────────────────────
power=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

# ── Power toggle ──────────────────────────────────────────────
echo "─────  󰂯  BLUETOOTH  ─────###header###" >> "$TMPFILE"
if [[ "$power" == "yes" ]]; then
    echo "⏻   Turn Bluetooth Off###power###off" >> "$TMPFILE"
else
    echo "⏻   Turn Bluetooth On###power###on" >> "$TMPFILE"
fi

# ── Devices (only if powered on) ──────────────────────────────
if [[ "$power" == "yes" ]]; then
    echo "─────  󰂯  DEVICES  ───────###header###" >> "$TMPFILE"

    while IFS= read -r line; do
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d' ' -f3-)
        [[ -z "$name" ]] && name="$mac"

        connected=$(bluetoothctl info "$mac" | grep "Connected:" | awk '{print $2}')

        if [[ "$connected" == "yes" ]]; then
            echo "󰂱  ${name} (connected)###disconnect###${mac}" >> "$TMPFILE"
        else
            echo "󰂯  ${name}###connect###${mac}" >> "$TMPFILE"
        fi
    done < <(bluetoothctl devices | grep "Device")

    echo "─────  󰂲  SCAN  ──────────###header###" >> "$TMPFILE"
    echo "󰂯  Scan for new devices###scan###" >> "$TMPFILE"
fi

# ── Active indices for headers ────────────────────────────────
idx=0
active_indices=""
while IFS= read -r line; do
    [[ "$line" == *"###header###"* ]] && active_indices+="${idx},"
    ((idx++))
done < "$TMPFILE"
active_indices="${active_indices%,}"

# ── Show rofi ─────────────────────────────────────────────────
rofi_args=(-dmenu -i -p "bluetooth" -theme "$THEME" -format i)
[[ -n "$active_indices" ]] && rofi_args+=(-a "$active_indices")

chosen=$(awk -F'###' '{print $1}' "$TMPFILE" | rofi "${rofi_args[@]}")
[[ -z "$chosen" ]] && exit 0

full=$(awk "NR==$((chosen+1))" "$TMPFILE")
action=$(echo "$full" | awk -F'###' '{print $2}')
value=$(echo "$full" | awk -F'###' '{print $3}')

[[ "$action" == "header" ]] && exit 0

# ── Apply ─────────────────────────────────────────────────────
case "$action" in
    power)
        if [[ "$value" == "on" ]]; then
            bluetoothctl power on
            notify-send "󰂯 Bluetooth" "Turned on"
            sleep 1
            bash "$0"
        else
            bluetoothctl power off
            notify-send "󰂯 Bluetooth" "Turned off"
        fi
        ;;
    connect)
        notify-send "󰂯 Bluetooth" "Connecting..."
        if bluetoothctl connect "$value"; then
            name=$(bluetoothctl info "$value" | grep "Name:" | sed 's/.*Name: //')
            notify-send "󰂱 Bluetooth" "Connected to ${name}"
        else
            notify-send "󰂯 Bluetooth" "Failed to connect"
        fi
        ;;
    disconnect)
        name=$(bluetoothctl info "$value" | grep "Name:" | sed 's/.*Name: //')
        bluetoothctl disconnect "$value"
        notify-send "󰂯 Bluetooth" "Disconnected from ${name}"
        ;;
    scan)
        notify-send "󰂯 Bluetooth" "Scanning for 10 seconds..."
        bluetoothctl --timeout 10 scan on
        bash "$0"
        ;;
esac
