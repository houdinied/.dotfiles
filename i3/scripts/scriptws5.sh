#!/usr/bin/env bash
set -euo pipefail

i3-msg 'workspace 5; append_layout ~/.config/i3/scripts/ws5.json'
spotify
