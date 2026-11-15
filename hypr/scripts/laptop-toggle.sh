#!/bin/bash
# Toggle the laptop screen (eDP-1) on/off.
# The Lua config rejects `hyprctl keyword`, so this uses `hyprctl eval`.
# hl.monitor() keeps fields from earlier calls, so set `disabled` explicitly.

DISABLED=$(hyprctl monitors all -j | jq -r '.[] | select(.name == "eDP-1") | .disabled')

if [ "$DISABLED" = "true" ]; then
  hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = "1", disabled = false })'
  hyprctl eval 'hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto-up", scale = "1" })'
else
  hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })'
fi
