#!/bin/bash
# ==============================================================================
# 🔄 Alternador Rápido: Caelestia <-> Waybar
# ==============================================================================
TARGET="$1"

if [ -z "$TARGET" ]; then
    if pgrep -x waybar >/dev/null; then
        TARGET="caelestia"
    else
        TARGET="waybar"
    fi
fi

if [ "$TARGET" = "waybar" ]; then
    echo "Alternando para Waybar..."
    # 1. Parar Caelestia
    qs -c caelestia kill 2>/dev/null || true
    # 2. Iniciar mako para continuar recebendo notificações
    if ! pgrep -x mako >/dev/null; then
        mako &
    fi
    # 3. Iniciar waybar
    pkill -x waybar 2>/dev/null || true
    setsid waybar >/dev/null 2>&1 &
    # 4. Atualizar hyprland.conf para inicializar com waybar
    sed -i -E 's/^[# ]*exec-once\s*=\s*qs -c caelestia/# exec-once = qs -c caelestia/' ~/.config/hypr/hyprland.conf
    sed -i -E 's/^[# ]*exec-once\s*=\s*waybar/exec-once = waybar/' ~/.config/hypr/hyprland.conf
    echo "✅ Waybar ativada!"
elif [ "$TARGET" = "caelestia" ]; then
    echo "Alternando para Caelestia..."
    # 1. Parar waybar e mako
    pkill -x waybar 2>/dev/null || true
    pkill -x mako 2>/dev/null || true
    # 2. Iniciar Caelestia
    caelestia shell -d
    # 3. Atualizar hyprland.conf para inicializar com caelestia
    sed -i -E 's/^[# ]*exec-once\s*=\s*waybar/# exec-once = waybar/' ~/.config/hypr/hyprland.conf
    sed -i -E 's/^[# ]*exec-once\s*=\s*qs -c caelestia/exec-once = qs -c caelestia/' ~/.config/hypr/hyprland.conf
    echo "✅ Caelestia ativado!"
fi
