#!/bin/bash
# Group all windows on the current workspace into a tab group (like i3 layout tabbed)

WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.id')
WORKSPACE_NAME=$(hyprctl activeworkspace -j | jq -r '.name')
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/hypr-group-layout"
STATE_FILE="$STATE_DIR/workspace-$WORKSPACE.json"
CLIENTS=$(hyprctl clients -j)
mapfile -t WINDOWS < <(echo "$CLIENTS" | jq -r --argjson ws "$WORKSPACE" --arg name "$WORKSPACE_NAME" '.[] | select(.workspace.id == $ws and .workspace.name == $name) | .address')
WINDOW_SET=$(printf '%s\n' "${WINDOWS[@]}" | jq -R . | jq -s .)
ORIGINAL_WORKSPACES=$(echo "$CLIENTS" | jq '[.[] | {address, workspace: .workspace.id}]')

COUNT=${#WINDOWS[@]}
[ "$COUNT" -lt 2 ] && exit 0

GROUPED_COUNT=$(hyprctl clients -j | jq --argjson ws "$WORKSPACE" --arg name "$WORKSPACE_NAME" '[.[] | select(.workspace.id == $ws and .workspace.name == $name and (.grouped | length) > 0)] | length')

if [ "$GROUPED_COUNT" -eq 0 ]; then
    mkdir -p "$STATE_DIR"
    echo "$CLIENTS" | jq \
        --argjson ws "$WORKSPACE" --arg name "$WORKSPACE_NAME" \
        '.[] | select(.workspace.id == $ws and .workspace.name == $name and .floating == false) | {address, at, size}' | \
        jq -s 'sort_by(.at[1], .at[0])' > "$STATE_FILE"
fi

move_direction_to_group() {
    local addr="$1"
    local leader="$2"

    echo "$CLIENTS" | jq -r --arg addr "$addr" --arg leader "$leader" '
        def center: {x: (.at[0] + (.size[0] / 2)), y: (.at[1] + (.size[1] / 2))};
        (.[] | select(.address == $addr) | center) as $a |
        (.[] | select(.address == $leader) | center) as $l |
        ($l.x - $a.x) as $dx |
        ($l.y - $a.y) as $dy |
        (if $dx < 0 then -$dx else $dx end) as $adx |
        (if $dy < 0 then -$dy else $dy end) as $ady |
        if ($adx >= $ady) then
            if $dx < 0 then "l" else "r" end
        else
            if $dy < 0 then "u" else "d" end
        end
    '
}

restore_strays() {
    local current_clients
    current_clients=$(hyprctl clients -j)

    mapfile -t STRAYS < <(echo "$current_clients" | jq -r --argjson ws "$WORKSPACE" --argjson targets "$WINDOW_SET" '
        .[]
        | select(.workspace.id == $ws and (.grouped | length) > 0 and ((.address as $addr | $targets | index($addr)) | not))
        | .address
    ')

    for stray in "${STRAYS[@]}"; do
        original_ws=$(echo "$ORIGINAL_WORKSPACES" | jq -r --arg addr "$stray" '.[] | select(.address == $addr) | .workspace')
        if [ -z "$original_ws" ] || [ "$original_ws" = "null" ]; then
            continue
        fi
        hyprctl dispatch focuswindow "address:$stray"
        hyprctl dispatch moveoutofgroup
        hyprctl dispatch movetoworkspacesilent "$original_ws"
    done
}

# Focus first window; dissolve any existing group then create a fresh one
hyprctl dispatch focuswindow "address:${WINDOWS[0]}"
IN_GROUP=$(hyprctl activewindow -j | jq '.grouped | length')
[ "$IN_GROUP" -gt 0 ] && hyprctl dispatch togglegroup
hyprctl dispatch togglegroup

# Pull each remaining window into the group using only the direction of the
# group leader. Trying all directions can cross monitor/workspace boundaries.
for ((i=1; i<COUNT; i++)); do
    hyprctl dispatch focuswindow "address:${WINDOWS[$i]}"
    hyprctl activewindow -j | jq -e --argjson ws "$WORKSPACE" --arg name "$WORKSPACE_NAME" '.workspace.id == $ws and .workspace.name == $name' >/dev/null || continue
    DIR=$(move_direction_to_group "${WINDOWS[$i]}" "${WINDOWS[0]}")
    hyprctl dispatch moveintogroup "$DIR"
    restore_strays
done
