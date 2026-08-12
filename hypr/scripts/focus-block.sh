#!/bin/bash
set -euo pipefail

action="${1:-}"
hosts_file="${POMODORO_HOSTS_FILE:-/etc/hosts}"
marker="# POMODORO_FOCUS_BLOCK"
blocked_sites=("youtube.com" "www.youtube.com" "x.com" "www.x.com")
always_allowed_sites=("linkedin.com" "www.linkedin.com" "lnkd.in" "www.lnkd.in")
youtube_sites=("youtube.com" "www.youtube.com")

remove_marked_hosts() {
    local tmp hosts
    hosts="$*"
    tmp="$(mktemp)"

    awk -v marker="$marker" -v hosts="$hosts" '
        BEGIN {
            split(hosts, list, " ")
            for (i in list) {
                remove_host[list[i]] = 1
            }
        }
        index($0, marker) && ($2 in remove_host) { next }
        { print }
    ' "$hosts_file" > "$tmp"

    cat "$tmp" > "$hosts_file"
    rm -f "$tmp"
}

add_blocked_hosts() {
    local site line
    for site in "${blocked_sites[@]}"; do
        # Honor a per-focus-session YouTube allowance so a re-block mid-session
        # (e.g. resuming a paused focus) doesn't undo the user's "Allow YouTube".
        if [[ "${FOCUS_ALLOW_YOUTUBE:-0}" == "1" ]] \
           && printf '%s\n' "${youtube_sites[@]}" | grep -qxF "$site"; then
            continue
        fi
        line="$(printf '127.0.0.1\t%s\t%s' "$site" "$marker")"
        if ! grep -qxF "$line" "$hosts_file" 2>/dev/null; then
            printf '%s\n' "$line" >> "$hosts_file"
        fi
    done
}

case "$action" in
    block)
        remove_marked_hosts "${always_allowed_sites[@]}"
        add_blocked_hosts
        ;;
    unblock)
        sed -i "/$marker/d" "$hosts_file"
        ;;
    unblock-linkedin|allow-linkedin)
        remove_marked_hosts "${always_allowed_sites[@]}"
        ;;
    allow-youtube)
        # Lift ONLY YouTube for the current focus session (e.g. a deliberate
        # informational video). The pomodoro re-blocks it on the next focus
        # session, so this allowance is scoped to the running work timer.
        remove_marked_hosts "${youtube_sites[@]}"
        ;;
    *)
        printf 'usage: %s {block|unblock|unblock-linkedin|allow-youtube}\n' "${0##*/}" >&2
        exit 2
        ;;
esac
