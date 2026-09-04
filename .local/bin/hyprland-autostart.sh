#!/bin/bash
# ====================================================================
# 🚀 AGILDO HYPRLAND LIGHT AUTOSTART (Managed via Systemd Units)
# ====================================================================

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/1000}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/1000/bus}"

# O fallback "wayland-1" que existia aqui era um chute: o numero do socket
# depende da ordem de inicializacao. Rodando via exec-once do Hyprland, o
# WAYLAND_DISPLAY correto ja' vem herdado do compositor -- se ele nao estiver
# definido, nao ha' compositor e nao ha' nada a iniciar.
if [ -z "$WAYLAND_DISPLAY" ]; then
    echo "hyprland-autostart: WAYLAND_DISPLAY vazio, abortando." >&2
    exit 1
fi

# Publica o ambiente REAL da sessao para o systemd --user e para o D-Bus.
# Sem isto as unidades waybar-agildo/agildodock nao saberiam em qual socket
# Wayland conectar (antes o valor estava chumbado como wayland-1 nos .service).
systemctl --user import-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_SESSION_TYPE 2>/dev/null || true
dbus-update-activation-environment --systemd WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_SESSION_TYPE 2>/dev/null || true

# 🖼️ Wallpaper aleatório a cada inicialização (inicia direto no wallpaper novo, sincronizado com Waypaper)
~/.local/bin/random-wallpaper-boot.sh

# Notification daemon (Mako)
if ! pgrep -x mako >/dev/null; then
    nohup mako >/dev/null 2>&1 &
fi

# Clipboard & NetworkManager
if ! pgrep -x nm-applet >/dev/null; then
    nohup nm-applet --indicator >/dev/null 2>&1 &
fi
if ! pgrep -f "cliphist store" >/dev/null; then
    wl-paste --watch cliphist store >/dev/null 2>&1 &
fi

# Ensure Waybar and AgildoDock systemd services are running.
# O reset-failed limpa qualquer estado de falha herdado de uma tentativa
# anterior; sem ele, se a unidade tivesse estourado o StartLimitBurst, o
# systemd recusaria este start com "start request repeated too quickly".
# Waybar mantida comentada como fallback (migrado para QuickShell)
# systemctl --user reset-failed waybar-agildo.service 2>/dev/null || true
# systemctl --user start waybar-agildo.service 2>/dev/null || true
systemctl --user reset-failed agildodock.service 2>/dev/null || true
systemctl --user start agildodock.service 2>/dev/null || true

(
    for t in 0.5 1.0 1.5 2.0 3.0; do
        sleep 0.5
        hyprctl dismissnotify -1 2>/dev/null
    done
) &
