#!/bin/bash

STATE_FILE="/tmp/main_display_toggle"
CURRENT=$(cat "$STATE_FILE" 2>/dev/null)

if [ "$CURRENT" = "disabled" ]; then
  hyprctl keyword monitor "eDP-1,preferred,auto,1"
  hyprctl keyword monitor "HDMI-A-1,disable"
  hyprctl keyword monitor "HDMI-A-1,preferred,auto-up,1"
  echo "enabled" >"$STATE_FILE"
else
  hyprctl keyword monitor "eDP-1,disable"
  echo "disabled" >"$STATE_FILE"
fi
