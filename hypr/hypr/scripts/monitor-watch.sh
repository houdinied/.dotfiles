#!/bin/bash
# Poll monitor state so hotplug gets the right layout without pinning workspaces.
apply_monitor_layout() {
  ~/.config/hypr/scripts/monitor-layout.sh
}

ensure_waybar() {
  ~/.config/hypr/scripts/ensure-waybar.sh
}

# Re-declaring monitors in monitor-layout.sh drops sdrbrightness back to 1.0,
# so restore the saved virtual brightness level after every layout change.
reapply_brightness() {
  local state_file="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-brightness-virtual"
  [ -f "$state_file" ] || return 0
  local value
  value=$(cat "$state_file" 2>/dev/null) || return 0
  [ -n "$value" ] || return 0
  ~/.config/hypr/scripts/brightness-virtual.sh set "$value" >/dev/null 2>&1 || true
}

monitor_signature() {
  local output

  output=$(hyprctl monitors -j 2>/dev/null || true)
  echo "$output" | jq -e 'type == "array"' >/dev/null 2>&1 || return 1

  echo "$output" | jq -cr '
    [.[] | select(.disabled | not) | {name, width, height, refreshRate, x, y}]
    | sort_by(.name)
  '
}

apply_monitor_layout
reapply_brightness

LAST_MONITORS=""
while [ -z "$LAST_MONITORS" ]; do
  LAST_MONITORS=$(monitor_signature || true)
  [ -n "$LAST_MONITORS" ] || sleep 1
done

TICKS=0

while sleep 2; do
  CURRENT_MONITORS=$(monitor_signature || true)

  if [ -z "$CURRENT_MONITORS" ]; then
    continue
  fi

  if [ "$CURRENT_MONITORS" != "$LAST_MONITORS" ]; then
    sleep 1
    apply_monitor_layout
    reapply_brightness
    omarchy-restart-waybar >/dev/null 2>&1 || true
    LAST_MONITORS=$(monitor_signature || echo "$CURRENT_MONITORS")
  fi

  TICKS=$((TICKS + 1))
  if [ "$TICKS" -ge 5 ]; then
    ensure_waybar
    TICKS=0
  fi
done
