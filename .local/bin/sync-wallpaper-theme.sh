#!/bin/bash
# 🎨 Sync dynamic Material You colors with current wallpaper
WALL="$1"
[ -z "$WALL" ] && [ -f "$HOME/.local/state/caelestia/wallpaper/path.txt" ] && WALL=$(cat "$HOME/.local/state/caelestia/wallpaper/path.txt")
[ -z "$WALL" ] && exit 0

# 1. Update Caelestia wallpaper state
mkdir -p "$HOME/.local/state/caelestia/wallpaper"
echo "$WALL" > "$HOME/.local/state/caelestia/wallpaper/path.txt"

# 2. Extract Material You dynamic colors via Caelestia CLI (updates scheme.json)
caelestia wallpaper -f "$WALL" >/dev/null 2>&1

# 3. Update Hyprland window border colors to match the wallpaper palette on the fly
if [ -f "$HOME/.local/state/caelestia/scheme.json" ]; then
    PRIMARY=$(python3 -c "import json; data=json.load(open('$HOME/.local/state/caelestia/scheme.json')); print(data['colours'].get('primary', '89b4fa'))" 2>/dev/null)
    SECONDARY=$(python3 -c "import json; data=json.load(open('$HOME/.local/state/caelestia/scheme.json')); print(data['colours'].get('secondary', 'cba6f7'))" 2>/dev/null)
    if [ -n "$PRIMARY" ] && [ -n "$SECONDARY" ]; then
        hyprctl keyword general:col.active_border "rgba(${PRIMARY}ee) rgba(${SECONDARY}ee) 45deg" >/dev/null 2>&1
    fi
fi

# 4. Sincronizar cores dinâmicas no Wayle (se estiver rodando)
if pgrep -x wayle >/dev/null; then
    wayle wallpaper set "$WALL" >/dev/null 2>&1 || true
fi
