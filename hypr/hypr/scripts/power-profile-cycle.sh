#!/bin/bash
current=$(powerprofilesctl get)

case "$current" in
  performance) next="balanced" ;;
  balanced)    next="power-saver" ;;
  *)           next="performance" ;;
esac

powerprofilesctl set "$next"
notify-send "Power Profile" "Switched to: $next" --urgency=low
