#!/bin/bash

MONITOR_INFO=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true)')
[ -z "$MONITOR_INFO" ] && MONITOR_INFO=$(hyprctl monitors -j | jq -r '.[0]')

ACTIVE_MONITOR=$(echo "$MONITOR_INFO" | jq -r '.name')
WIDTH=$(echo "$MONITOR_INFO" | jq -r '.width')
HEIGHT=$(echo "$MONITOR_INFO" | jq -r '.height')
REFRESH_RATE=$(echo "$MONITOR_INFO" | jq -r '.refreshRate')

# hyprctl reports the previous scale when called from a keybinding (not yet applied)
# so we track state ourselves in /tmp/ — resets to 1 on reboot which is correct
STATE_FILE="/tmp/monitor-scale-state"
CURRENT_SCALE=$(cat "$STATE_FILE" 2>/dev/null || echo "1")

# Cycle: 1 → 1.2 → 1.4 → 1.6 → 2 → 3 → 1
case "$CURRENT_SCALE" in
1)   NEW_SCALE=1.2 ;;
1.2) NEW_SCALE=1.4 ;;
1.4) NEW_SCALE=1.6 ;;
1.6) NEW_SCALE=2 ;;
2)   NEW_SCALE=3 ;;
*)   NEW_SCALE=1 ;;
esac

echo "$NEW_SCALE" > "$STATE_FILE"
hyprctl keyword monitor "$ACTIVE_MONITOR,${WIDTH}x${HEIGHT}@${REFRESH_RATE},auto,$NEW_SCALE"
notify-send -u low "󰍹    Display scaling set to ${NEW_SCALE}x"
