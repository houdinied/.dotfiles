#!/bin/bash
action="${1:-}"
hosts_file="/etc/hosts"
marker="# POMODORO_FOCUS_BLOCK"
sites=("youtube.com" "www.youtube.com" "x.com" "www.x.com" "linkedin.com" "www.linkedin.com")

case "$action" in
    block)
        for site in "${sites[@]}"; do
            if ! grep -q "$site $marker" "$hosts_file" 2>/dev/null; then
                printf '127.0.0.1\t%s\t%s\n' "$site" "$marker" >> "$hosts_file"
            fi
        done
        ;;
    unblock)
        sed -i "/$marker/d" "$hosts_file"
        ;;
esac
