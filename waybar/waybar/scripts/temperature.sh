#!/bin/bash
CORETEMP_DIR=$(for f in /sys/class/hwmon/hwmon*/name; do [ "$(cat "$f" 2>/dev/null)" = "coretemp" ] && dirname "$f"; done | head -1)
TEMP=$(( $(cat "$CORETEMP_DIR/temp1_input") / 1000 ))

if [ $TEMP -lt 60 ]; then
    CLASS="cool"
elif [ $TEMP -lt 75 ]; then
    CLASS="normal"
elif [ $TEMP -lt 85 ]; then
    CLASS="warm"
else
    CLASS="hot"
fi

echo "{\"text\": \" ${TEMP}°C\", \"class\": \"$CLASS\", \"tooltip\": \"CPU: ${TEMP}°C\"}"
