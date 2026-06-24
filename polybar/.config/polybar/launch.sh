#!/usr/bin/env bash

readonly POLYBAR_CONFIG="$HOME/.config/polybar/config.ini"
readonly LAPTOP_OUTPUT="eDP"

kill_existing_polybar() {
  killall -q polybar
  while pgrep -u "$UID" -x polybar > /dev/null
    do sleep 1
  done
}

find_active_external_output() {
  xrandr --query \
    | grep " connected [0-9]" \
    | awk '{print $1}' \
    | grep -v "^${LAPTOP_OUTPUT}$" \
    | head -1
}

launch_polybar() {
  local active_external_output
  active_external_output=$(find_active_external_output)

  if [ -n "$active_external_output" ]
    then MONITOR="$active_external_output" polybar --config="$POLYBAR_CONFIG" monitor &
    return
  fi

  MONITOR="$LAPTOP_OUTPUT" polybar --config="$POLYBAR_CONFIG" laptop &
}

kill_existing_polybar
launch_polybar
