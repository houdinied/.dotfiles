#!/bin/bash
set -euo pipefail

hypr_json() {
    local command="$1"
    local output

    for _ in {1..8}; do
        output=$(hyprctl "$command" -j 2>/dev/null || true)
        if echo "$output" | jq -e 'type == "array"' >/dev/null 2>&1; then
            echo "$output"
            return 0
        fi
        sleep 0.25
    done

    return 1
}

MONITORS=$(hypr_json monitors) || exit 0
LAPTOP=$(echo "$MONITORS" | jq -r 'first(.[] | select((.disabled | not) and (.name | startswith("eDP-"))) | .name) // empty')

[ -z "$LAPTOP" ] && exit 0

move_workspace() {
    local workspace="$1"
    local monitor="$2"

    hyprctl dispatch moveworkspacetomonitor "$workspace" "$monitor" >/dev/null 2>&1 || true
}

normal_workspaces() {
    local workspaces
    workspaces=$(hypr_json workspaces) || return 0
    echo "$workspaces" | jq -r '.[] | select(.id > 0) | .id' | sort -n -u
}

arrange_workspaces() {
    local laptop="$1"
    local external="${2:-}"

    if [ -n "$external" ]; then
        normal_workspaces | while read -r workspace; do
            case "$workspace" in
                1|2|3|4) move_workspace "$workspace" "$external" ;;
                *) move_workspace "$workspace" "$laptop" ;;
            esac
        done
    else
        normal_workspaces | while read -r workspace; do
            move_workspace "$workspace" "$laptop"
        done
    fi
}

LAPTOP_WIDTH=$(echo "$MONITORS" | jq -r --arg name "$LAPTOP" '.[] | select(.name == $name) | .width')
LAPTOP_HEIGHT=$(echo "$MONITORS" | jq -r --arg name "$LAPTOP" '.[] | select(.name == $name) | .height')
LAPTOP_REFRESH=$(echo "$MONITORS" | jq -r --arg name "$LAPTOP" '.[] | select(.name == $name) | (.refreshRate // 60 | round)')

hyprctl keyword monitor "$LAPTOP,${LAPTOP_WIDTH}x${LAPTOP_HEIGHT}@${LAPTOP_REFRESH},0x0,1" >/dev/null 2>&1 || true

NEXT_X=$LAPTOP_WIDTH

echo "$MONITORS" | jq -r --arg laptop "$LAPTOP" '
    [.[] | select((.disabled | not) and .name != $laptop and .width > 0 and .height > 0)]
    | sort_by(.id, .name)
    | .[].name
' | while read -r EXTERNAL; do
    [ -z "$EXTERNAL" ] && continue

    WIDTH=$(echo "$MONITORS" | jq -r --arg name "$EXTERNAL" '.[] | select(.name == $name) | .width')
    HEIGHT=$(echo "$MONITORS" | jq -r --arg name "$EXTERNAL" '.[] | select(.name == $name) | .height')
    REFRESH=$(echo "$MONITORS" | jq -r --arg name "$EXTERNAL" '.[] | select(.name == $name) | (.refreshRate // 60 | round)')

    hyprctl keyword monitor "$EXTERNAL,${WIDTH}x${HEIGHT}@${REFRESH},${NEXT_X}x0,1" >/dev/null 2>&1 || true
    NEXT_X=$((NEXT_X + WIDTH))
done

PRIMARY_EXTERNAL=$(echo "$MONITORS" | jq -r --arg laptop "$LAPTOP" '
    first([.[] | select((.disabled | not) and .name != $laptop and .width > 0 and .height > 0)] | sort_by(.id, .name) | .[].name) // empty
')
arrange_workspaces "$LAPTOP" "$PRIMARY_EXTERNAL"
