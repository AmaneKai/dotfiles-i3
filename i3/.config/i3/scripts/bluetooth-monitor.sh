#!/bin/bash

SOUNDS="/usr/share/sounds/freedesktop/stereo"

# Monitor Bluetooth connections via dbus
dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path_namespace='/org/bluez'" 2>/dev/null | 
while read -r line; do
    if echo "$line" | grep -q "Connected.*true"; then
        # Bluetooth device connected
        mpv --no-video "$SOUNDS/device-added.oga" &>/dev/null &
    elif echo "$line" | grep -q "Connected.*false"; then
        # Bluetooth device disconnected
        mpv --no-video "$SOUNDS/device-removed.oga" &>/dev/null &
    fi
done
