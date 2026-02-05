#!/usr/bin/env bash
set -euo pipefail

# 1. Go to workspace 6 and apply layout
i3-msg 'workspace 6; append_layout ~/.config/i3/test.json'

# 2. Small delay
sleep 0.3

# 3. Start Chromium with clean flags
chromium \
    --user-data-dir=/tmp/chromium-ws6 \
    --no-default-browser-check \
    --new-window \
    --disable-extensions \
    --disable-gpu \
    https://github.com \
    https://news.ycombinator.com \
    https://duckduckgo.com &

# 4. Move any extra Chromium windows to scratchpad
sleep 0.5
i3-msg '[class="^Chromium$" window_role="^browser$" title=~"^(Untitled|New Tab|about:blank)$"] move to scratchpad'
