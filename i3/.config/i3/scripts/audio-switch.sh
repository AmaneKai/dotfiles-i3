#!/bin/bash

FIFINE="alsa_output.usb-FIFINE_Microphones_FIFINE_K690_Microphone_REV1.1-00.analog-stereo"
SOUNDS="$HOME/.config/i3/sounds"

device_exists() {
    pactl list sinks short | grep -q "bluez_output.14"
}

get_airpods_sink() {
    pactl list sinks short | grep "bluez_output.14" | awk '{print $2}' | head -1
}

switch_audio() {
    local device=$1
    pactl set-default-sink "$device"
    pactl list sink-inputs short | awk '{print $1}' | while read stream; do 
        pactl move-sink-input "$stream" "$device" 2>/dev/null
    done
}

case "$1" in
    fifine)
        switch_audio "$FIFINE"
        notify-send "オーディオ" "マイクに接続しました (✿◠‿◠)"
        mpv --no-video "$SOUNDS/mic-connected.mp3" &>/dev/null &
        ;;
    airpods)
        if device_exists; then
            # Force A2DP profile ON
            pactl set-card-profile bluez_card.14_7A_E4_DD_CA_26 a2dp-sink 2>/dev/null
            sleep 0.5
            
            AIRPODS=$(get_airpods_sink)
            switch_audio "$AIRPODS"
            notify-send "オーディオ" "イヤホンに接続しました ♪(´▽｀)"
            mpv --no-video "$SOUNDS/airpods-connected.mp3" &>/dev/null &
        else
            notify-send "オーディオ" "イヤホンが接続されていません (╥﹏╥)"
            mpv --no-video "$SOUNDS/airpods-error.mp3" &>/dev/null &
        fi
        ;;
    toggle)
        current=$(pactl get-default-sink)
        if [[ "$current" == *"FIFINE"* ]]; then
            if device_exists; then
                # Force A2DP profile ON
                pactl set-card-profile bluez_card.14_7A_E4_DD_CA_26 a2dp-sink 2>/dev/null
                sleep 0.5
                
                AIRPODS=$(get_airpods_sink)
                switch_audio "$AIRPODS"
                notify-send "オーディオ" "イヤホンに接続しました ♪(´▽｀)"
                mpv --no-video "$SOUNDS/airpods-connected.mp3" &>/dev/null &
            else
                notify-send "オーディオ" "イヤホンが接続されていません (╥﹏╥)"
                mpv --no-video "$SOUNDS/airpods-error.mp3" &>/dev/null &
            fi
        else
            switch_audio "$FIFINE"
            notify-send "オーディオ" "マイクに接続しました (✿◠‿◠)"
            mpv --no-video "$SOUNDS/mic-connected.mp3" &>/dev/null &
        fi
        ;;
esac
