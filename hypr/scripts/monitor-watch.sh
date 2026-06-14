#!/bin/bash
# Apply monitor layout and restart waybar when monitor/fullscreen/DPMS transitions kill it
apply_monitor_layout() {
  ~/.config/hypr/scripts/monitor-layout.sh
}

ensure_waybar() {
  ~/.config/hypr/scripts/ensure-waybar.sh
}

apply_monitor_layout

socat -U - "UNIX-CONNECT:${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" | while read -r line; do
  case "$line" in
    monitoradded*|monitorremoved*)
      sleep 1
      apply_monitor_layout
      omarchy-restart-waybar
      ;;
    fullscreen*|monitorresumed*|monitorwenttosleep*)
      sleep 1
      ensure_waybar
      ;;
  esac
done
