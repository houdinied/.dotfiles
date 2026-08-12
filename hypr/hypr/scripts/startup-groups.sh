#!/bin/bash

wait_for_class() {
    local pattern="$1"
    local max="${2:-30}"
    for _ in $(seq 1 "$max"); do
        hyprctl clients -j 2>/dev/null | python3 -c "
import json, sys
exit(0 if any('$pattern' in c.get('class','') for c in json.load(sys.stdin)) else 1)
" && return 0
        sleep 1
    done
    return 1
}

get_addr() {
    local pattern="$1"
    local ws="$2"
    hyprctl clients -j 2>/dev/null | python3 -c "
import json, sys
for c in json.load(sys.stdin):
    if '$pattern' in c.get('class','') and c.get('workspace',{}).get('id')==$ws:
        print(c['address']); break
"
}

is_grouped() {
    local addr="$1"
    hyprctl clients -j 2>/dev/null | python3 -c "
import json, sys
for c in json.load(sys.stdin):
    if c['address'] == '$addr':
        print(len(c.get('grouped', [])))
        break
" | grep -qv '^[01]$'
}

moveintogroup_any() {
    local addr="$1"
    for dir in l r u d; do
        hyprctl dispatch moveintogroup "$dir"
        sleep 0.2
        is_grouped "$addr" && return 0
    done
    return 1
}

group_windows() {
    local ws="$1"; shift
    local patterns=("$@")
    local first_addr=""

    for pattern in "${patterns[@]}"; do
        local addr
        addr=$(get_addr "$pattern" "$ws")
        [ -z "$addr" ] && continue

        if [ -z "$first_addr" ]; then
            first_addr="$addr"
            hyprctl dispatch focuswindow "address:$addr"
            hyprctl dispatch togglegroup
            sleep 0.3
        else
            hyprctl dispatch focuswindow "address:$addr"
            sleep 0.2
            moveintogroup_any "$addr"
            sleep 0.3
        fi
    done
}

# Workspace 4: Discord + Telegram
wait_for_class "discord"
wait_for_class "telegram"
sleep 1
group_windows 4 "discord" "telegram"
