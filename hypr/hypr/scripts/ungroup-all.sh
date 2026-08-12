#!/bin/bash
# Dissolve all groups on the current workspace (like i3 layout toggle split)

WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.id')
WORKSPACE_NAME=$(hyprctl activeworkspace -j | jq -r '.name')
ACTIVE=$(hyprctl activewindow -j | jq -r '.address')
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/hypr-group-layout"
STATE_FILE="$STATE_DIR/workspace-$WORKSPACE.json"
mapfile -t WINDOWS < <(hyprctl clients -j | jq -r --argjson ws "$WORKSPACE" --arg name "$WORKSPACE_NAME" '.[] | select(.workspace.id == $ws and .workspace.name == $name) | .address')

for addr in "${WINDOWS[@]}"; do
    IN_GROUP=$(hyprctl clients -j | jq -r --arg addr "$addr" --argjson ws "$WORKSPACE" --arg name "$WORKSPACE_NAME" '.[] | select(.address == $addr and .workspace.id == $ws and .workspace.name == $name) | .grouped | length')
    if [ "$IN_GROUP" -gt 0 ]; then
        hyprctl dispatch focuswindow "address:$addr"
        hyprctl dispatch moveoutofgroup
    fi
done

if [ -s "$STATE_FILE" ]; then
    sleep 0.15
    mapfile -t RESTORE_WINDOWS < <(jq -r '.[] | [.address, .size[0], .size[1]] | @tsv' "$STATE_FILE")

    for row in "${RESTORE_WINDOWS[@]}"; do
        IFS=$'\t' read -r addr width height <<< "$row"

        if hyprctl clients -j | jq -e --arg addr "$addr" --argjson ws "$WORKSPACE" --arg name "$WORKSPACE_NAME" '.[] | select(.address == $addr and .workspace.id == $ws and .workspace.name == $name and .floating == false)' >/dev/null; then
            hyprctl dispatch resizewindowpixel "exact $width $height,address:$addr"
        fi
    done
fi

rm -f "$STATE_FILE"

if [ -n "$ACTIVE" ]; then
    hyprctl dispatch focuswindow "address:$ACTIVE"
fi
