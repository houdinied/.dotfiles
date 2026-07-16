#!/bin/bash
set -euo pipefail

SETTLE_DELAY=${HYPR_WORKSPACE_MONITOR_CHANGE_DELAY:-0.08}

focused_monitor() {
    hyprctl -j monitors | jq -r 'first(.[] | select(.focused == true) | .name) // empty'
}

monitor_center() {
    local monitor="$1"

    hyprctl -j monitors | jq -r --arg monitor "$monitor" '
        first(.[] | select(.name == $monitor and (.disabled | not))) as $m
        | if $m == null then
            empty
          else
            (($m.x + (($m.width / ($m.scale // 1)) / 2)) | floor | tostring)
            + " "
            + (($m.y + (($m.height / ($m.scale // 1)) / 2)) | floor | tostring)
          end
    '
}

BEFORE_MONITOR=$(focused_monitor)
sleep "$SETTLE_DELAY"
AFTER_MONITOR=$(focused_monitor)

if [ -z "$BEFORE_MONITOR" ] || [ -z "$AFTER_MONITOR" ] || [ "$BEFORE_MONITOR" = "$AFTER_MONITOR" ]; then
    exit 0
fi

read -r X Y < <(monitor_center "$AFTER_MONITOR")
[ -n "${X:-}" ] && [ -n "${Y:-}" ] && hyprctl dispatch movecursor "$X" "$Y" >/dev/null
