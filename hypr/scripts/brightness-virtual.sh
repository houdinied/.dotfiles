#!/bin/bash

# Adjust display brightness on a 0-130 scale.
# 0-100 uses the hardware backlight.
# 100-130 uses Hyprland's SDR brightness boost (1.0-1.3).
# Usage: brightness-virtual.sh up|down [step]
#        brightness-virtual.sh set <value>

action="${1:-up}"
step="${2:-5}"

# Get focused monitor info
monitor_json=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true)')
name=$(echo "$monitor_json" | jq -r '.name')
width=$(echo "$monitor_json" | jq -r '.width')
height=$(echo "$monitor_json" | jq -r '.height')
refresh=$(echo "$monitor_json" | jq -r '.refreshRate')
x=$(echo "$monitor_json" | jq -r '.x')
y=$(echo "$monitor_json" | jq -r '.y')
scale=$(echo "$monitor_json" | jq -r '.scale')
sdr=$(echo "$monitor_json" | jq -r '.sdrBrightness')

# State file for precise virtual brightness tracking
state_file="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-brightness-virtual"

# Get current hardware brightness
device=$(brightnessctl -m | cut -d',' -f1)
hw_percent=$(brightnessctl -d "$device" -m | cut -d',' -f4 | tr -d '%')

# Determine current virtual brightness (0-130)
if [[ -f "$state_file" ]]; then
  virtual=$(cat "$state_file")
else
  if awk -v s="$sdr" 'BEGIN { exit (s > 1.0 ? 0 : 1) }'; then
    virtual=$(awk -v s="$sdr" 'BEGIN { printf "%d", 100 + (s - 1.0) / 0.3 * 30 }')
  else
    virtual=$hw_percent
  fi
fi

# Adjust
case "$action" in
  up) virtual=$((virtual + step)) ;;
  down) virtual=$((virtual - step)) ;;
  set)
    # For "set", the value is the second argument
    virtual=$step
    ;;
  *)
    echo "Usage: brightness-virtual.sh up|down [step]" >&2
    echo "       brightness-virtual.sh set <value>" >&2
    exit 1
    ;;
esac

# Clamp
(( virtual < 0 )) && virtual=0
(( virtual > 130 )) && virtual=130

# Save precise virtual value for next invocation
mkdir -p "$(dirname "$state_file")"
echo "$virtual" > "$state_file"

# Apply
if (( virtual <= 100 )); then
  brightnessctl -d "$device" set "${virtual}%" >/dev/null
  sdr_new="1.0"
else
  brightnessctl -d "$device" set "100%" >/dev/null
  sdr_new=$(awk -v v="$virtual" 'BEGIN { printf "%.2f", 1.0 + (v - 100) / 30 * 0.3 }')
fi

# Apply SDR brightness while preserving the current monitor config
refresh_int=$(echo "$refresh" | awk '{ printf "%d", $1 }')
hyprctl keyword monitor "$name,${width}x${height}@${refresh_int},${x}x${y},${scale},sdrbrightness,${sdr_new}" >/dev/null

# Show OSD (cap progress bar at 100%, but show the full virtual percent text)
osd_progress=$(awk -v v="$virtual" 'BEGIN { p=v/100; if (p > 1) p=1; printf "%.2f", p }')
swayosd-client \
  --monitor "$(omarchy-hyprland-monitor-focused)" \
  --custom-icon display-brightness \
  --custom-progress "$osd_progress" \
  --custom-progress-text "${virtual}%"
