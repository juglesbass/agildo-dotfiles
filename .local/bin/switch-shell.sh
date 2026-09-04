#!/bin/bash
# ==============================================================================
# 🔄 Alternador Rápido: Caelestia <-> Waybar <-> Wayle
# ==============================================================================
TARGET="$1"

# Identificar o shell atual em execução
CURRENT="caelestia"
if pgrep -x wayle >/dev/null; then
    CURRENT="wayle"
elif pgrep -x waybar >/dev/null; then
    CURRENT="waybar"
elif pgrep -f "caelestia" >/dev/null; then
    CURRENT="caelestia"
fi

# Se nenhum alvo foi passado, ciclar: caelestia -> waybar -> wayle -> caelestia
if [ -z "$TARGET" ]; then
    case "$CURRENT" in
        caelestia) TARGET="waybar" ;;
        waybar)    TARGET="wayle" ;;
        wayle)     TARGET="caelestia" ;;
        *)         TARGET="caelestia" ;;
    esac
fi

case "$TARGET" in
    waybar)
        echo "Alternando para Waybar..."
        # 1. Parar outros shells
        qs -c caelestia kill 2>/dev/null || true
        pkill -x wayle 2>/dev/null || true
        # 2. Iniciar mako para notificações se não estiver rodando
        if ! pgrep -x mako >/dev/null; then
            mako &
        fi
        # 3. Iniciar waybar
        pkill -x waybar 2>/dev/null || true
        setsid waybar >/dev/null 2>&1 &
        # 4. Atualizar hyprland.conf
        sed -i -E 's/^[# ]*exec-once\s*=\s*qs -c caelestia/# exec-once = qs -c caelestia/' ~/.config/hypr/hyprland.conf
        sed -i -E 's/^[# ]*exec-once\s*=\s*wayle shell/# exec-once = wayle shell/' ~/.config/hypr/hyprland.conf
        sed -i -E 's/^[# ]*exec-once\s*=\s*waybar/exec-once = waybar/' ~/.config/hypr/hyprland.conf
        echo "✅ Waybar ativada!"
        ;;

    wayle)
        echo "Alternando para Wayle..."
        # 1. Parar outros shells e mako (Wayle tem daemon de notificações próprio)
        qs -c caelestia kill 2>/dev/null || true
        pkill -x waybar 2>/dev/null || true
        pkill -x mako 2>/dev/null || true
        # 2. Iniciar Wayle
        pkill -x wayle 2>/dev/null || true
        setsid wayle shell >/dev/null 2>&1 &
        # 3. Atualizar hyprland.conf
        sed -i -E 's/^[# ]*exec-once\s*=\s*qs -c caelestia/# exec-once = qs -c caelestia/' ~/.config/hypr/hyprland.conf
        sed -i -E 's/^[# ]*exec-once\s*=\s*waybar/# exec-once = waybar/' ~/.config/hypr/hyprland.conf
        sed -i -E 's/^[# ]*exec-once\s*=\s*wayle shell/exec-once = wayle shell/' ~/.config/hypr/hyprland.conf
        echo "✅ Wayle ativado!"
        ;;

    caelestia)
        echo "Alternando para Caelestia..."
        # 1. Parar outros shells e mako
        pkill -x waybar 2>/dev/null || true
        pkill -x wayle 2>/dev/null || true
        pkill -x mako 2>/dev/null || true
        # 2. Iniciar Caelestia
        caelestia shell -d
        # 3. Atualizar hyprland.conf
        sed -i -E 's/^[# ]*exec-once\s*=\s*waybar/# exec-once = waybar/' ~/.config/hypr/hyprland.conf
        sed -i -E 's/^[# ]*exec-once\s*=\s*wayle shell/# exec-once = wayle shell/' ~/.config/hypr/hyprland.conf
        sed -i -E 's/^[# ]*exec-once\s*=\s*qs -c caelestia/exec-once = qs -c caelestia/' ~/.config/hypr/hyprland.conf
        echo "✅ Caelestia ativado!"
        ;;

    *)
        echo "Uso: $0 [caelestia|waybar|wayle]"
        exit 1
        ;;
esac
