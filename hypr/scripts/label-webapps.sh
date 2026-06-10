#!/bin/bash
app_dir="$HOME/.local/share/applications"
find "$app_dir" -name "*.desktop" 2>/dev/null | while read -r f; do
    exec_line=$(grep -m1 "^Exec=" "$f" 2>/dev/null)
    [[ -z "$exec_line" ]] && continue
    [[ "$exec_line" != *"--app="* ]] && continue
    name_line=$(grep -m1 "^Name=" "$f" 2>/dev/null)
    [[ -z "$name_line" ]] && continue
    name="${name_line#Name=}"
    [[ "$name" == *"(Web)" ]] && continue
    sed -i "s/^Name=$name$/Name=$name (Web)/" "$f"
done
