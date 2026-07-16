#!/usr/bin/env bash
set -euo pipefail

adapter="/org/bluez/hci0"

json() {
  jq -cn --arg text "$1" --arg tooltip "$2" --arg class "$3" \
    '{text: $text, tooltip: $tooltip, class: $class}'
}

property_value() {
  local path="$1"
  local iface="$2"
  local prop="$3"

  busctl get-property org.bluez "$path" "$iface" "$prop" 2>/dev/null
}

if ! powered_raw=$(property_value "$adapter" org.bluez.Adapter1 Powered); then
  json "" "No Bluetooth controller" "no-controller"
  exit 0
fi

if [[ "$(awk '{print $2}' <<<"$powered_raw")" != "true" ]]; then
  json "󰂲" "Bluetooth off" "off"
  exit 0
fi

mapfile -t devices < <(
  busctl tree org.bluez 2>/dev/null |
    awk '$NF ~ /^\/org\/bluez\/hci[0-9]+\/dev_[0-9A-F_]+$/ {print $NF}' |
    sort -u
)

connected=0
names=()

for device in "${devices[@]}"; do
  connected_raw=$(property_value "$device" org.bluez.Device1 Connected || true)
  [[ "$(awk '{print $2}' <<<"$connected_raw")" == "true" ]] || continue

  connected=$((connected + 1))
  alias_raw=$(property_value "$device" org.bluez.Device1 Alias || true)
  name=$(sed -E 's/^s "(.*)"$/\1/' <<<"$alias_raw")
  [[ -n "$name" && "$name" != "$alias_raw" ]] || name="${device##*/}"
  names+=("$name")
done

if (( connected > 0 )); then
  tooltip="Connected: $(IFS=', '; printf '%s' "${names[*]}")"
  json "󰂱 ${connected}" "$tooltip" "connected"
else
  json "" "Bluetooth on, no devices connected" "on"
fi
