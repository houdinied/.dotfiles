#!/usr/bin/env bash
set -euo pipefail

i3-msg 'workspace 9; append_layout ~/.config/i3/scripts/ws9.json'
chromium 
