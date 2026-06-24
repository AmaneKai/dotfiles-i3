#!/usr/bin/env bash

killall -q polybar
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 1; done

CFG="/home/amane/.dotfiles-i3/polybar/.config/polybar/config.ini"

if xrandr --query | grep -q "HDMI-A-0 connected [0-9]"; then
    MONITOR=HDMI-A-0 polybar --config="$CFG" monitor &
else
    MONITOR=eDP polybar --config="$CFG" laptop &
fi
