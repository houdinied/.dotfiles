#!/bin/bash
# Smart window move:
# - Inside group at edge → leaves group but stays on the current workspace
# - Inside group not at edge → reorders tab
# - Outside group → moves window within the current workspace only
# Usage: move-window.sh <l|r|u|d>

DIR=$1
ACTIVE=$(hyprctl activewindow -j)
ADDR=$(echo "$ACTIVE" | jq -r '.address')
WORKSPACE=$(echo "$ACTIVE" | jq -r '.workspace.id')
WORKSPACE_NAME=$(echo "$ACTIVE" | jq -r '.workspace.name')
GROUPED_LEN=$(echo "$ACTIVE" | jq '.grouped | length')
refocus_active() {
    hyprctl dispatch focuswindow "address:$ADDR"
}

move_active_out_of_group() {
    hyprctl dispatch moveoutofgroup
    hyprctl dispatch movewindow "$DIR"
    keep_on_workspace
    refocus_active
}

keep_on_workspace() {
    local current_ws
    current_ws=$(hyprctl clients -j | jq -r --arg addr "$ADDR" '.[] | select(.address == $addr) | .workspace.id')

    if [ "$current_ws" != "$WORKSPACE" ]; then
        hyprctl dispatch focuswindow "address:$ADDR"
        hyprctl dispatch movetoworkspacesilent "$WORKSPACE"
    fi
}

if [ "$GROUPED_LEN" -gt 1 ]; then
    IDX=$(echo "$ACTIVE" | jq -r ".grouped | to_entries[] | select(.value == \"$ADDR\") | .key")
    LAST=$((GROUPED_LEN - 1))

    case $DIR in
        l|u)
            if [ "$IDX" -eq 0 ]; then
                move_active_out_of_group
            else
                hyprctl dispatch movegroupwindow b
            fi
            ;;
        r|d)
            if [ "$IDX" -eq "$LAST" ]; then
                move_active_out_of_group
            else
                hyprctl dispatch movegroupwindow f
            fi
            ;;
    esac
else
    hyprctl dispatch movewindow "$DIR"
    keep_on_workspace
    refocus_active
fi
