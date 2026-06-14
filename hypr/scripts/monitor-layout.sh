#!/bin/bash
set -euo pipefail

MONITORS=$(hyprctl monitors -j)
LAPTOP=$(echo "$MONITORS" | jq -r '.[] | select(.name | startswith("eDP-")) | .name' | head -n 1)

[ -z "$LAPTOP" ] && exit 0

LAPTOP_WIDTH=$(echo "$MONITORS" | jq -r --arg name "$LAPTOP" '.[] | select(.name == $name) | .width')
LAPTOP_HEIGHT=$(echo "$MONITORS" | jq -r --arg name "$LAPTOP" '.[] | select(.name == $name) | .height')
LAPTOP_REFRESH=$(echo "$MONITORS" | jq -r --arg name "$LAPTOP" '.[] | select(.name == $name) | .refreshRate | round')

hyprctl keyword monitor "$LAPTOP,${LAPTOP_WIDTH}x${LAPTOP_HEIGHT}@${LAPTOP_REFRESH},0x0,1"

echo "$MONITORS" | jq -r --arg laptop "$LAPTOP" '.[] | select(.name != $laptop) | .name' | while read -r EXTERNAL; do
    [ -z "$EXTERNAL" ] && continue
    WIDTH=$(echo "$MONITORS" | jq -r --arg name "$EXTERNAL" '.[] | select(.name == $name) | .width')
    HEIGHT=$(echo "$MONITORS" | jq -r --arg name "$EXTERNAL" '.[] | select(.name == $name) | .height')
    REFRESH=$(echo "$MONITORS" | jq -r --arg name "$EXTERNAL" '.[] | select(.name == $name) | .refreshRate | round')

    hyprctl keyword monitor "$EXTERNAL,${WIDTH}x${HEIGHT}@${REFRESH},${LAPTOP_WIDTH}x0,1"
    LAPTOP_WIDTH=$((LAPTOP_WIDTH + WIDTH))
done
