#!/usr/bin/env bash
#
# audio-switch.sh - Audio device switcher for i3wm
# Switches between Fifine microphone and AirPods with Japanese notifications
#
# Usage: audio-switch.sh {fifine|airpods|toggle}

set -euo pipefail

# Device identifiers
readonly FIFINE="alsa_output.usb-FIFINE_Microphones_FIFINE_K690_Microphone\
_REV1.1-00.analog-stereo"
readonly AIRPODS_CARD="bluez_card.14_7A_E4_DD_CA_26"
readonly AIRPODS_PROFILE="a2dp-sink"
readonly SOUNDS="${HOME}/.config/i3/sounds"

# Check if AirPods device exists in PipeWire
device_exists() {
    pactl list sinks short | grep -q "bluez_output.14"
}

# Get the current AirPods sink name
get_airpods_sink() {
    pactl list sinks short \
        | grep "bluez_output.14" \
        | awk '{print $2}' \
        | head -1
}

# Switch audio output to specified device and move all streams
switch_audio() {
    local device="$1"
    
    # Set default sink
    pactl set-default-sink "$device"
    
    # Move all playing streams to new device
    while IFS= read -r stream; do
        pactl move-sink-input "$stream" "$device" 2>/dev/null || true
    done < <(pactl list sink-inputs short | awk '{print $1}')
}

# Play notification sound
play_sound() {
    local sound_file="$1"
    mpv --no-video "${SOUNDS}/${sound_file}" &>/dev/null &
}

# Send desktop notification
send_notification() {
    local message="$1"
    notify-send "オーディオ" "$message"
}

# Activate AirPods with A2DP profile
activate_airpods() {
    # Force A2DP profile for high-quality audio
    pactl set-card-profile "$AIRPODS_CARD" "$AIRPODS_PROFILE" \
        2>/dev/null || {
        send_notification "AirPodsプロファイル設定エラー"
        return 1
    }
    
    sleep 0.5
    
    local airpods_sink
    airpods_sink=$(get_airpods_sink)
    
    if [[ -z "$airpods_sink" ]]; then
        send_notification "イヤホンが接続されていません (╥﹏╥)"
        play_sound "airpods-error.mp3"
        return 1
    fi
    
    switch_audio "$airpods_sink"
    send_notification "イヤホンに接続しました ♪(´▽｀)"
    play_sound "airpods-connected.mp3"
}

# Main command handler
main() {
    local command="${1:-}"
    
    case "$command" in
        fifine)
            switch_audio "$FIFINE"
            send_notification "マイクに接続しました (✿◠‿◠)"
            play_sound "mic-connected.mp3"
            ;;
        
        airpods)
            if device_exists; then
                activate_airpods
            else
                send_notification "イヤホンが接続されていません (╥﹏╥)"
                play_sound "airpods-error.mp3"
            fi
            ;;
        
        toggle)
            local current
            current=$(pactl get-default-sink)
            
            if [[ "$current" == *"FIFINE"* ]]; then
                if device_exists; then
                    activate_airpods
                else
                    send_notification \
                        "イヤホンが接続されていません (╥﹏╥)"
                    play_sound "airpods-error.mp3"
                fi
            else
                switch_audio "$FIFINE"
                send_notification "マイクに接続しました (✿◠‿◠)"
                play_sound "mic-connected.mp3"
            fi
            ;;
        
        *)
            echo "Usage: $0 {fifine|airpods|toggle}" >&2
            exit 1
            ;;
    esac
}

main "$@"
