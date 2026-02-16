#!/bin/bash

FIFINE="alsa_output.usb-FIFINE_Microphones_FIFINE_K690_Microphone_REV1.1-00.analog-stereo"
AIRPODS="bluez_output.14:7A:E4:DD:CA:26"
SOUNDS="$HOME/.config/i3/sounds"

pactl subscribe | grep --line-buffered "sink" | while read -r event; do
    if ! pactl list sinks short | grep -q "$AIRPODS"; then
        current=$(pactl get-default-sink)
        if [[ "$current" == *"bluez"* ]] || [[ "$current" == "$AIRPODS" ]]; then
            sleep 1
            pactl set-default-sink "$FIFINE" 2>/dev/null
            pactl list sink-inputs short | awk '{print $1}' | while read stream; do 
                pactl move-sink-input "$stream" "$FIFINE" 2>/dev/null
            done
            notify-send "オーディオ" "イヤホン切断されました (｡•́︿•̀｡)"
            mpv --no-video "$SOUNDS/airpods-disconnected.mp3" &>/dev/null &
        fi
    fi
done
