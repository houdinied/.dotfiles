#!/bin/bash
set -euo pipefail

i3-msg "workspace 3; append_layout /home/do/.config/i3/scripts/ws3.json"
obsidian
