#!/bin/bash
set -euo pipefail

i3-msg "workspace 1; append_layout /home/do/.config/i3/scripts/ws1.json"
chromium
