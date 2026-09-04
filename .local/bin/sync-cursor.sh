#!/bin/bash
# Syncs KDE Wayland cursor theme and size with X11 / XWayland (Steam, etc.)

THEME=$(kreadconfig6 --file kcminputrc --group Mouse --key cursorTheme 2>/dev/null)
[[ -z "$THEME" ]] && THEME=$(kreadconfig6 --file kdeglobals --group Mouse --key cursorTheme 2>/dev/null)
[[ -z "$THEME" ]] && THEME="catppuccin-mocha-blue-cursors"

SCALE=$(kreadconfig6 --file kwinrc --group Xwayland --key Scale 2>/dev/null)
[[ -z "$SCALE" ]] && SCALE=2.5

BASE_SIZE=$(kreadconfig6 --file kcminputrc --group Mouse --key cursorSize 2>/dev/null)
[[ -z "$BASE_SIZE" ]] && BASE_SIZE=44

# Calculate physical cursor size for X11 / Steam
CALC_SIZE=$(python3 -c "print(int(round($BASE_SIZE * $SCALE)))" 2>/dev/null || echo 120)
DPI=$(python3 -c "print(int(round(96 * $SCALE)))" 2>/dev/null || echo 240)

# 1. Update ~/.icons/default/index.theme
mkdir -p ~/.icons/default
cat << EOT > ~/.icons/default/index.theme
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=${THEME}
EOT

# 2. Update ~/.config/environment.d/cursor.conf
mkdir -p ~/.config/environment.d
cat << EOT > ~/.config/environment.d/cursor.conf
XCURSOR_THEME=${THEME}
XCURSOR_SIZE=${CALC_SIZE}
EOT

# 3. Update ~/.Xresources
cat << EOT > ~/.Xresources
Xcursor.theme: ${THEME}
Xcursor.size: ${CALC_SIZE}
Xft.dpi: ${DPI}
Xft.antialias: true
Xft.hinting: true
Xft.hintstyle: hintslight
Xft.rgba: rgb
EOT
xrdb -merge ~/.Xresources 2>/dev/null || true

# 4. GTK 3 & 4
sed -i "s|gtk-cursor-theme-name=.*|gtk-cursor-theme-name=${THEME}|g" ~/.config/gtk-3.0/settings.ini 2>/dev/null || true
sed -i "s|gtk-cursor-theme-size=.*|gtk-cursor-theme-size=${CALC_SIZE}|g" ~/.config/gtk-3.0/settings.ini 2>/dev/null || true
sed -i "s|gtk-cursor-theme-name=.*|gtk-cursor-theme-name=${THEME}|g" ~/.config/gtk-4.0/settings.ini 2>/dev/null || true
sed -i "s|gtk-cursor-theme-size=.*|gtk-cursor-theme-size=${CALC_SIZE}|g" ~/.config/gtk-4.0/settings.ini 2>/dev/null || true

echo "Cursor successfully synced: Theme=${THEME}, Size=${CALC_SIZE}px, DPI=${DPI}"
