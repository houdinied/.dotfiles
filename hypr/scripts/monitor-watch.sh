#!/bin/bash
# Restart waybar when monitor/fullscreen/DPMS transitions kill it
ensure_waybar() {
  ~/.config/hypr/scripts/ensure-waybar.sh
}

socat -U - "UNIX-CONNECT:${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" | while read -r line; do
  case "$line" in
    monitoradded*|monitorremoved*)
      sleep 1
      omarchy-restart-waybar
      sleep 1
      ensure_waybar
      ;;
    fullscreen*|monitorresumed*|monitorwenttosleep*)
      sleep 1
      ensure_waybar
      ;;
  esac
done
