#!/usr/bin/env bash
set -u

RUN_DIR="${VPN_HELPER_RUN_DIR:-/run/vpn-helper}"
PID_FILE="$RUN_DIR/openvpn.pid"
NAME_FILE="$RUN_DIR/name"

json_escape() {
  local value="$1"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/ }
  printf '%s' "$value"
}

hidden() {
  printf '{"text":"","class":"hidden","tooltip":"VPN disconnected"}\n'
  exit 0
}

trim() {
  local value="$1"
  shopt -s extglob
  value="${value##+([[:space:]])}"
  value="${value%%+([[:space:]])}"
  printf '%s' "$value"
}

flag_for_country() {
  case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" in
    austria) printf '🇦🇹' ;;
    belgium) printf '🇧🇪' ;;
    chile) printf '🇨🇱' ;;
    "czech republic"|czechia) printf '🇨🇿' ;;
    denmark) printf '🇩🇰' ;;
    estonia) printf '🇪🇪' ;;
    finland) printf '🇫🇮' ;;
    france) printf '🇫🇷' ;;
    georgia) printf '🇬🇪' ;;
    germany) printf '🇩🇪' ;;
    "hong kong") printf '🇭🇰' ;;
    hungary) printf '🇭🇺' ;;
    israel) printf '🇮🇱' ;;
    kazakhstan) printf '🇰🇿' ;;
    latvia) printf '🇱🇻' ;;
    moldova) printf '🇲🇩' ;;
    netherlands) printf '🇳🇱' ;;
    norway) printf '🇳🇴' ;;
    poland) printf '🇵🇱' ;;
    russia) printf '🇷🇺' ;;
    serbia) printf '🇷🇸' ;;
    slovenia) printf '🇸🇮' ;;
    "south korea"|korea) printf '🇰🇷' ;;
    sweden) printf '🇸🇪' ;;
    switzerland) printf '🇨🇭' ;;
    turkey|turkiye|türkiye) printf '🇹🇷' ;;
    ukraine) printf '🇺🇦' ;;
    "united kingdom"|uk|britain|england) printf '🇬🇧' ;;
    usa|"united states"|"united states of america") printf '🇺🇸' ;;
    *) printf '󰖂' ;;
  esac
}

[[ -r "$NAME_FILE" ]] || hidden
[[ -r "$PID_FILE" ]] || hidden

read -r name < "$NAME_FILE" || hidden
read -r pid < "$PID_FILE" || hidden
[[ -n "$name" && "$pid" =~ ^[0-9]+$ ]] || hidden

comm="$(ps -p "$pid" -o comm= 2>/dev/null | tr -d '[:space:]')"
args="$(ps -p "$pid" -o args= 2>/dev/null)"
[[ "$comm" == "openvpn" || "$comm" == vpn-* || "$args" == *openvpn* || "$args" == vpn-* ]] || hidden

country="$(trim "${name%%,*}")"
flag="$(flag_for_country "$country")"
tooltip="VPN: $(json_escape "$name")"

printf '{"text":"VPN %s","class":"connected","tooltip":"%s"}\n' "$flag" "$tooltip"
