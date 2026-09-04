#!/bin/bash
# 🎲 Random Wallpaper on Boot (Direct frame-1 display, no mid-session switch)
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/Hyprland"

if [ -d "$WALLPAPER_DIR" ]; then
    python3 -c '
import os, random, re

wall_dir = os.path.expanduser("~/Pictures/Wallpapers/Hyprland")
state_path = os.path.expanduser("~/.local/state/caelestia/wallpaper/path.txt")
cache_path = os.path.expanduser("~/.cache/awww/0.12.1/HDMI-A-1")
waypaper_ini = os.path.expanduser("~/.config/waypaper/config.ini")

current = ""
if os.path.exists(state_path):
    try:
        with open(state_path) as f:
            current = f.read().strip()
    except Exception:
        pass

valid_exts = {".jpg", ".jpeg", ".png", ".webp"}
files = [os.path.join(wall_dir, f) for f in os.listdir(wall_dir) if os.path.splitext(f)[1].lower() in valid_exts]
filtered = [f for f in files if f != current]
if not filtered and files:
    filtered = files

if filtered:
    new_wall = random.choice(filtered)
    # 1. Update swww cache so swww-daemon renders new_wall on frame 1
    os.makedirs(os.path.dirname(cache_path), exist_ok=True)
    with open(cache_path, "wb") as f:
        f.write(b"\x00crop:center\x00Lanczos3\x00" + new_wall.encode("utf-8"))
    
    # 2. Update Caelestia state
    os.makedirs(os.path.dirname(state_path), exist_ok=True)
    with open(state_path, "w") as f:
        f.write(new_wall)
        
    # 3. Synchronize Waypaper config
    if os.path.exists(waypaper_ini):
        try:
            with open(waypaper_ini, "r") as f:
                ini_content = f.read()
            ini_content = re.sub(r"^wallpaper\s*=.*$", f"wallpaper = {new_wall}", ini_content, flags=re.MULTILINE)
            with open(waypaper_ini, "w") as f:
                f.write(ini_content)
        except Exception:
            pass
' 2>/dev/null || true
fi

# Start swww-daemon (it immediately displays the new wallpaper from cache)
if ! pgrep -x awww-daemon >/dev/null && ! pgrep -x swww-daemon >/dev/null; then
    swww-daemon &
fi

# Sync dynamic colors and borders in background
NEW_WALL=$(cat "$HOME/.local/state/caelestia/wallpaper/path.txt" 2>/dev/null)
if [ -n "$NEW_WALL" ]; then
    (
        sleep 0.5
        /home/agildo/.local/bin/sync-wallpaper-theme.sh "$NEW_WALL" >/dev/null 2>&1
    ) &
fi
