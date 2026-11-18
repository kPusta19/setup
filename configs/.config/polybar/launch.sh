#!/usr/bin/env bash

set -Eeuo pipefail

CONFIG="$HOME/.config/polybar/config.ini"
LOG="$HOME/.local/state/polybar.log"

mkdir -p "$(dirname "$LOG")"

# Stop previous instances
polybar-msg cmd quit >/dev/null 2>&1 || true

# Wait for previous instances
while pgrep -x polybar >/dev/null; do
    sleep 0.2
done

# Launch one bar per connected monitor
while IFS= read -r monitor; do
    MONITOR="$monitor" polybar --reload main \
        --config="$CONFIG" >>"$LOG" 2>&1 &
done < <(
    xrandr --query |
        awk '/ connected/ {print $1}'
)