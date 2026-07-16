#!/usr/bin/env bash
set -euo pipefail

bluez_power() {
  local power="$1"

  command -v busctl >/dev/null 2>&1 || return 0
  busctl set-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered b "$power" >/dev/null 2>&1 || true
}

bluetooth_is_on() {
  rfkill --json list bluetooth 2>/dev/null |
    jq -e '[.rfkilldevices[]? | select(.device | test("^hci[0-9]+$")) | select(.hard == "unblocked" and .soft == "unblocked")] | length > 0' >/dev/null
}

rfkill_each_bluetooth_id() {
  local action="$1"
  local id

  while IFS= read -r id; do
    rfkill "$action" "$id" || true
  done < <(rfkill --json list bluetooth 2>/dev/null | jq -r '.rfkilldevices[]?.id')
}

turn_on() {
  rfkill unblock bluetooth
  rfkill_each_bluetooth_id unblock
  bluez_power true
  rfkill unblock bluetooth
  rfkill_each_bluetooth_id unblock
}

turn_off() {
  bluez_power false
  rfkill block bluetooth
  rfkill_each_bluetooth_id block
  bluez_power false
}

case "${1:-toggle}" in
  on|enable)
    turn_on
    ;;
  off|disable)
    turn_off
    ;;
  toggle)
    if bluetooth_is_on; then
      turn_off
    else
      turn_on
    fi
    ;;
  *)
    printf 'Usage: %s [on|off|toggle]\n' "$0" >&2
    exit 2
    ;;
esac
