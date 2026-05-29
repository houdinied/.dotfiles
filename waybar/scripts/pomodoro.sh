#!/usr/bin/env bash
set -u

CONFIG_FILE="${POMODORO_CONFIG:-$HOME/.config/waybar/pomodoro.conf}"

FOCUS_MIN=25
BREAK_MIN=5
LONG_BREAK_MIN=15
AUTO_START_BREAKS=0
AUTO_START_POMODOROS=0
LONG_BREAK_EVERY=4

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/waybar-pomodoro"
STATE_FILE="$STATE_DIR/state"
LOCK_FILE="$STATE_DIR/lock"

if ! mkdir -p "$STATE_DIR" 2>/dev/null || ! { : > "$STATE_DIR/.probe"; } 2>/dev/null; then
  STATE_DIR="/tmp/waybar-pomodoro-${UID:-$(id -u)}"
  STATE_FILE="$STATE_DIR/state"
  LOCK_FILE="$STATE_DIR/lock"
  mkdir -p "$STATE_DIR"
else
  rm -f "$STATE_DIR/.probe"
fi

json_escape() {
  local value="$1"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/ }
  printf '%s' "$value"
}

write_default_config() {
  [[ -r "$CONFIG_FILE" ]] && return 0
  mkdir -p "$(dirname "$CONFIG_FILE")"
  {
    printf 'FOCUS_MIN=25\n'
    printf 'BREAK_MIN=5\n'
    printf 'LONG_BREAK_MIN=15\n'
    printf 'AUTO_START_BREAKS=0\n'
    printf 'AUTO_START_POMODOROS=0\n'
    printf 'LONG_BREAK_EVERY=4\n'
  } > "$CONFIG_FILE"
}

clamp_int() {
  local value="$1"
  local fallback="$2"
  local min="$3"
  local max="$4"

  [[ "$value" =~ ^[0-9]+$ ]] || value="$fallback"
  ((value < min)) && value="$min"
  ((value > max)) && value="$max"
  printf '%d' "$value"
}

clamp_bool() {
  case "${1:-0}" in
    1|true|TRUE|yes|YES|on|ON) printf '1' ;;
    *) printf '0' ;;
  esac
}

load_config() {
  write_default_config
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"

  FOCUS_MIN="$(clamp_int "${POMODORO_FOCUS_MIN:-$FOCUS_MIN}" 25 1 240)"
  BREAK_MIN="$(clamp_int "${POMODORO_BREAK_MIN:-$BREAK_MIN}" 5 1 120)"
  LONG_BREAK_MIN="$(clamp_int "${POMODORO_LONG_BREAK_MIN:-$LONG_BREAK_MIN}" 15 1 180)"
  AUTO_START_BREAKS="$(clamp_bool "${POMODORO_AUTO_START_BREAKS:-$AUTO_START_BREAKS}")"
  AUTO_START_POMODOROS="$(clamp_bool "${POMODORO_AUTO_START_POMODOROS:-$AUTO_START_POMODOROS}")"
  LONG_BREAK_EVERY="$(clamp_int "${POMODORO_LONG_BREAK_EVERY:-$LONG_BREAK_EVERY}" 4 1 20)"
}

save_config_values() {
  mkdir -p "$(dirname "$CONFIG_FILE")"
  {
    printf 'FOCUS_MIN=%q\n' "$FOCUS_MIN"
    printf 'BREAK_MIN=%q\n' "$BREAK_MIN"
    printf 'LONG_BREAK_MIN=%q\n' "$LONG_BREAK_MIN"
    printf 'AUTO_START_BREAKS=%q\n' "$AUTO_START_BREAKS"
    printf 'AUTO_START_POMODOROS=%q\n' "$AUTO_START_POMODOROS"
    printf 'LONG_BREAK_EVERY=%q\n' "$LONG_BREAK_EVERY"
  } > "$CONFIG_FILE"
}

notify() {
  local title="$1"
  local body="$2"
  command -v notify-send >/dev/null 2>&1 || return 0
  notify-send -a "Pomodoro" -u normal -i appointment-soon "$title" "$body" >/dev/null 2>&1 || true
}

play_alert() {
  local sound="${POMODORO_ALERT_SOUND:-/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga}"

  if command -v paplay >/dev/null 2>&1 && [[ -r "$sound" ]]; then
    paplay --device="@DEFAULT_SINK@" "$sound" >/dev/null 2>&1 && return 0
  fi

  if command -v canberra-gtk-play >/dev/null 2>&1; then
    canberra-gtk-play --id="alarm-clock-elapsed" --description="Pomodoro alert" >/dev/null 2>&1 && return 0
  fi

  if command -v pw-play >/dev/null 2>&1 && [[ -r "$sound" ]]; then
    pw-play --target="@DEFAULT_SINK@" "$sound" >/dev/null 2>&1 && return 0
  fi

  printf '\a'
}

alert() {
  local title="$1"
  local body="$2"
  notify "$title" "$body"
  play_alert &
}

duration_for() {
  case "$1" in
    focus) printf '%d' "$((FOCUS_MIN * 60))" ;;
    long_break) printf '%d' "$((LONG_BREAK_MIN * 60))" ;;
    *) printf '%d' "$((BREAK_MIN * 60))" ;;
  esac
}

label_for() {
  case "$1" in
    focus) printf 'Focus' ;;
    long_break) printf 'Long break' ;;
    *) printf 'Break' ;;
  esac
}

icon_for() {
  case "$1" in
    focus) printf '󰔛' ;;
    long_break) printf '󰒲' ;;
    *) printf '󰅶' ;;
  esac
}

load_state() {
  running=0
  mode="focus"
  started_at=0
  remaining="$(duration_for focus)"
  cycle=0
  visible=1

  [[ -r "$STATE_FILE" ]] || return 0
  # shellcheck disable=SC1090
  source "$STATE_FILE"

  [[ "$running" =~ ^[0-1]$ ]] || running=0
  [[ "$mode" == "focus" || "$mode" == "break" || "$mode" == "long_break" ]] || mode="focus"
  [[ "$started_at" =~ ^[0-9]+$ ]] || started_at=0
  [[ "$remaining" =~ ^[0-9]+$ ]] || remaining="$(duration_for "$mode")"
  [[ "$cycle" =~ ^[0-9]+$ ]] || cycle=0
  [[ "$visible" =~ ^[0-1]$ ]] || visible=1
}

save_state() {
  {
    printf 'running=%q\n' "$running"
    printf 'mode=%q\n' "$mode"
    printf 'started_at=%q\n' "$started_at"
    printf 'remaining=%q\n' "$remaining"
    printf 'cycle=%q\n' "$cycle"
    printf 'visible=%q\n' "$visible"
  } > "$STATE_FILE"
}

current_remaining() {
  local now="$1"
  if [[ "$running" -eq 1 ]]; then
    local elapsed=$((now - started_at))
    local left=$((remaining - elapsed))
    ((left > 0)) && printf '%d' "$left" || printf '0'
  else
    printf '%d' "$remaining"
  fi
}

start_mode() {
  mode="$1"
  running="${3:-1}"
  started_at="$2"
  remaining="$(duration_for "$mode")"
}

advance_phase() {
  local now="$1"

  if [[ "$mode" == "focus" ]]; then
    cycle=$((cycle + 1))
    if ((cycle % LONG_BREAK_EVERY == 0)); then
      start_mode "long_break" "$now" "$AUTO_START_BREAKS"
      alert "Pomodoro complete" "Take a long break."
    else
      start_mode "break" "$now" "$AUTO_START_BREAKS"
      alert "Pomodoro complete" "Take a short break."
    fi
  else
    start_mode "focus" "$now" "$AUTO_START_POMODOROS"
    alert "Break finished" "Time to focus."
  fi
}

open_settings() {
  local helper="$HOME/.config/waybar/scripts/pomodoro-settings.py"
  if [[ -x "$helper" ]]; then
    "$helper" "$CONFIG_FILE"
    return 0
  fi

  command -v zenity >/dev/null 2>&1 || {
    notify "Pomodoro settings" "Install zenity to use the settings dialog."
    exit 1
  }

  local output
  output="$(
    zenity --forms \
      --title="Pomodoro Settings" \
      --text="Timer. Blank fields keep the current value." \
      --separator=$'\n' \
      --add-entry="Pomodoro time (minutes, current ${FOCUS_MIN})" \
      --add-entry="Short break (minutes, current ${BREAK_MIN})" \
      --add-entry="Long break (minutes, current ${LONG_BREAK_MIN})" \
      --add-combo="Auto start breaks" \
      --combo-values="No|Yes" \
      --add-combo="Auto start pomodoros" \
      --combo-values="No|Yes" \
      --add-entry="Long break interval (current ${LONG_BREAK_EVERY})"
  )" || exit 0

  mapfile -t fields <<< "$output"
  FOCUS_MIN="$(clamp_int "${fields[0]:-$FOCUS_MIN}" "$FOCUS_MIN" 1 240)"
  BREAK_MIN="$(clamp_int "${fields[1]:-$BREAK_MIN}" "$BREAK_MIN" 1 120)"
  LONG_BREAK_MIN="$(clamp_int "${fields[2]:-$LONG_BREAK_MIN}" "$LONG_BREAK_MIN" 1 180)"
  AUTO_START_BREAKS="$(clamp_bool "${fields[3]:-No}")"
  AUTO_START_POMODOROS="$(clamp_bool "${fields[4]:-No}")"
  LONG_BREAK_EVERY="$(clamp_int "${fields[5]:-$LONG_BREAK_EVERY}" "$LONG_BREAK_EVERY" 1 20)"
  save_config_values
}

render() {
  local now left mins secs text state tooltip label icon

  if [[ "$visible" -eq 0 ]]; then
    printf '{"text":"","class":["hidden"],"tooltip":"Pomodoro hidden. Press Super+Shift+W to show."}\n'
    return 0
  fi

  now="$(date +%s)"
  left="$(current_remaining "$now")"

  if [[ "$running" -eq 1 && "$left" -le 0 ]]; then
    advance_phase "$now"
    left="$(current_remaining "$now")"
    save_state
  fi

  mins=$((left / 60))
  secs=$((left % 60))
  label="$(label_for "$mode")"
  icon="$(icon_for "$mode")"

  if [[ "$running" -eq 1 ]]; then
    state="running"
    text="$(printf '%s %02d:%02d' "$icon" "$mins" "$secs")"
  else
    state="paused"
    text="$(printf '%s %02d:%02d' "$icon" "$mins" "$secs")"
  fi

  tooltip="$label $(printf '%02d:%02d' "$mins" "$secs")"
  if [[ "$running" -eq 1 ]]; then
    tooltip="$tooltip\nLeft: pause  Right: settings  Middle: skip"
  else
    tooltip="$tooltip\nLeft: start/resume  Right: settings  Middle: skip"
  fi

  printf '{"text":"%s","class":["%s","%s"],"tooltip":"%s"}\n' \
    "$(json_escape "$text")" \
    "$(json_escape "$mode")" \
    "$(json_escape "$state")" \
    "$(json_escape "$tooltip")"
}

with_lock() {
  local action="$1"
  exec 9>"$LOCK_FILE"
  flock -x 9

  load_state
  now="$(date +%s)"
  left="$(current_remaining "$now")"

  if [[ "$running" -eq 1 && "$left" -le 0 ]]; then
    advance_phase "$now"
    left="$(current_remaining "$now")"
  fi

  case "$action" in
    toggle)
      if [[ "$running" -eq 1 ]]; then
        remaining="$left"
        running=0
        started_at=0
      else
        running=1
        started_at="$now"
        [[ "$remaining" -gt 0 ]] || remaining="$(duration_for "$mode")"
      fi
      ;;
    reset)
      running=0
      mode="focus"
      started_at=0
      remaining="$(duration_for focus)"
      cycle=0
      notify "Pomodoro reset" "Ready for a fresh focus block."
      ;;
    init)
      visible=1
      running=1
      mode="focus"
      started_at="$now"
      remaining="$(duration_for focus)"
      cycle=0
      notify "Pomodoro started" "Focus for ${FOCUS_MIN} minutes."
      ;;
    toggle-visible)
      if [[ "$visible" -eq 1 ]]; then
        visible=0
      else
        visible=1
      fi
      ;;
    reconfigure)
      if [[ "$running" -eq 0 ]]; then
        started_at=0
        remaining="$(duration_for "$mode")"
      fi
      notify "Pomodoro settings saved" "Timer defaults updated."
      ;;
    skip)
      advance_phase "$now"
      ;;
    status) ;;
    *)
      printf 'Usage: %s [status|toggle|reset|init|skip|settings|toggle-visible]\n' "$0" >&2
      exit 2
      ;;
  esac

  save_state
  render
}

load_config

case "${1:-status}" in
  settings|config)
    open_settings
    load_config
    with_lock reconfigure
    ;;
  *)
    with_lock "${1:-status}"
    ;;
esac
