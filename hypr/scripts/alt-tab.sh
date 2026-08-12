#!/bin/bash

# Cycle tabs inside a Hyprland group, or windows when the active window is not
# grouped. This keeps Alt+Tab useful both in the i3-style tabbed layout and in
# the regular tiled layout.

DIRECTION="${1:-next}"

if hyprctl activewindow -j | jq -e '(.grouped // []) | length > 0' >/dev/null; then
    if [ "$DIRECTION" = "prev" ]; then
        hyprctl dispatch changegroupactive b
    else
        hyprctl dispatch changegroupactive f
    fi
else
    if [ "$DIRECTION" = "prev" ]; then
        hyprctl dispatch cyclenext prev
    else
        hyprctl dispatch cyclenext
    fi
    hyprctl dispatch bringactivetotop
fi
