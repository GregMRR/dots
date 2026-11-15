#!/bin/bash
# Toggle mirroring of the laptop screen (eDP-1) on HDMI-A-1.
# The Lua config rejects `hyprctl keyword`, so this uses `hyprctl eval`.
# hl.monitor() keeps fields from earlier calls, so clear `mirror` explicitly.

MIRROR=$(hyprctl monitors all -j | jq -r '.[] | select(.name == "HDMI-A-1") | .mirrorOf')

if [ -n "$MIRROR" ] && [ "$MIRROR" != "none" ]; then
  hyprctl eval 'hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto-up", scale = "1", mirror = "" })'
else
  hyprctl eval 'hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto-up", scale = "1", mirror = "eDP-1" })'
fi
