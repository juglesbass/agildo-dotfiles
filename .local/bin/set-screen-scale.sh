#!/bin/bash
SCALE="$1"
if [ -z "$SCALE" ]; then
    echo "Usage: $0 <scale (e.g. 1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5)>"
    exit 1
fi

echo "Setting screen scale to: $SCALE"

# 1. Apply dynamically to Hyprland
if command -v jq >/dev/null 2>&1; then
    ACTIVE_MONITORS=$(hyprctl monitors -j | jq -r '.[].name' 2>/dev/null)
    for MON in $ACTIVE_MONITORS; do
        hyprctl keyword monitor "$MON,preferred,auto,$SCALE"
    done
fi
hyprctl keyword monitor "HDMI-A-1,3840x2160@60,0x0,$SCALE"
hyprctl keyword monitor ",preferred,auto,$SCALE"

# 2. Persist in caelestia hypr-user.lua
LUA_CONF="/home/agildo/.config/caelestia/hypr-user.lua"
if [ -f "$LUA_CONF" ]; then
    sed -i -E "s/(scale\s*=\s*)[0-9.]+,/\1$SCALE,/g" "$LUA_CONF"
fi

# 3. Persist in hyprland.conf
HYPR_CONF="/home/agildo/.config/hypr/hyprland.conf"
if [ -f "$HYPR_CONF" ]; then
    sed -i -E "s/(monitor\s*=\s*,preferred,auto,)[0-9.]+/\1$SCALE/g" "$HYPR_CONF"
fi

# 4. Save state file for fast reading
mkdir -p /home/agildo/.local/state/caelestia
echo "$SCALE" > /home/agildo/.local/state/caelestia/screen_scale

echo "Screen scale updated and persisted to $SCALE"
