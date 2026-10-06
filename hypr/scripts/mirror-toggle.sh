#!/bin/bash

STATE_FILE="/tmp/mirror_toggle"
CURRENT=$(cat "$STATE_FILE" 2>/dev/null)

if [ "$CURRENT" = "mirrored" ]; then
  hyprctl keyword monitor "HDMI-A-1,disable"
  hyprctl keyword monitor "HDMI-A-1,preferred,auto-up,1"
  echo "unmirrored" >"$STATE_FILE"
else
  hyprctl keyword monitor "HDMI-A-1,preferred,auto-up,1,mirror,eDP-1"
  echo "mirrored" >"$STATE_FILE"
fi
