#!/usr/bin/env bash

# 1. Kill any existing polybar instances
killall -q polybar

# 2. Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# 3. Detect if HDMI-1 is active (Look for a resolution like 1920x1080)
if xrandr | grep "HDMI-1 connected" | grep -q "[0-9]x[0-9]"; then
    # HDMI is plugged in and active
    polybar monitor &
else
    # HDMI is gone or inactive, use laptop bar
    polybar laptop &
fi
