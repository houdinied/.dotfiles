#!/bin/bash
set -euo pipefail

WORKSPACE=${1:?Usage: move-active-to-workspace.sh <workspace> [--follow]}
FOLLOW=${2:-}

ACTIVE=$(hyprctl activewindow -j)
ADDR=$(echo "$ACTIVE" | jq -r '.address')
[ -z "$ADDR" ] || [ "$ADDR" = "null" ] && exit 0

GROUPED_LEN=$(echo "$ACTIVE" | jq '.grouped | length')
if [ "$GROUPED_LEN" -gt 0 ]; then
    hyprctl dispatch moveoutofgroup
    hyprctl dispatch focuswindow "address:$ADDR"
fi

if [ "$FOLLOW" = "--follow" ]; then
    hyprctl dispatch movetoworkspace "$WORKSPACE,address:$ADDR"
else
    hyprctl dispatch movetoworkspacesilent "$WORKSPACE,address:$ADDR"
fi
