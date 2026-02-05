#!/bin/bash
set -euo pipefail

i3-msg "workspace 2; append_layout /home/do/.config/i3/scripts/ws2.json"
ghostty
