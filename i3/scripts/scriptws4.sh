#!/bin/bash
set -euo pipefail

i3-msg "workspace 4; append_layout /home/do/.config/i3/scripts/ws4.json"
telegram-desktop &
flatpak run com.discordapp.Discord
