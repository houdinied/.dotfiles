#!/bin/bash
set -u

pgrep -x waybar >/dev/null && exit 0

if command -v hyprctl >/dev/null 2>&1; then
    hyprctl dispatch exec waybar >/dev/null 2>&1 && exit 0
fi

setsid waybar >/dev/null 2>&1 &
