#!/bin/bash
set -u

lock_dir="${XDG_RUNTIME_DIR:-/tmp}/ensure-waybar.lock"
if ! mkdir "$lock_dir" 2>/dev/null; then
    exit 0
fi
trap 'rmdir "$lock_dir" 2>/dev/null || true' EXIT

waybar_pids() {
    mapfile -t pids < <(pgrep -x waybar 2>/dev/null || true)
}

stop_duplicate_waybars() {
    pkill -x waybar 2>/dev/null || true
    sleep 0.3
}

for _ in {1..5}; do
    waybar_pids
    if (( ${#pids[@]} == 1 )); then
        exit 0
    elif (( ${#pids[@]} > 1 )); then
        stop_duplicate_waybars
        break
    fi

    sleep 0.1
done

waybar_pids
if (( ${#pids[@]} == 1 )); then
    exit 0
elif (( ${#pids[@]} > 1 )); then
    stop_duplicate_waybars
fi

live_hyprland_signature() {
    local runtime="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    local socket

    for socket in "$runtime"/hypr/*/.socket.sock; do
        [[ -S "$socket" ]] || continue
        basename "$(dirname "$socket")"
        return 0
    done
}

if command -v hyprctl >/dev/null 2>&1 && signature="$(live_hyprland_signature)" && [[ -n "$signature" ]]; then
    HYPRLAND_INSTANCE_SIGNATURE="$signature" hyprctl dispatch exec waybar >/dev/null 2>&1 && exit 0
fi

setsid waybar >/dev/null 2>&1 &
