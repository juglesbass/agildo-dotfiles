#!/bin/bash
# ==============================================================================
# 🔒 Bloqueio de tela INDEPENDENTE DE SHELL
# ==============================================================================
# Antes, SUPER+L chamava `qs -c caelestia ipc call lock lock` direto no
# hyprland.conf. Isso so' funcionava enquanto o caelestia estivesse rodando --
# ao alternar para waybar/wayle/ml4w com o switch-shell.sh, o bind continuava
# apontando para um IPC morto e a tela simplesmente nao travava
# ("No running instances").
#
# Este script escolhe o melhor locker DISPONIVEL, na ordem:
#   1. hyprlock  -- preferido (nativo do Hyprland, GPU-acelerado)
#   2. swaylock  -- fallback, ja' instalado
#
# Assim o bind no hyprland.conf nunca mais precisa mudar ao trocar de shell.
# Instale o hyprlock (`sudo pacman -S hyprlock`) e este script passa a usa-lo
# automaticamente, sem editar nada.

# Evita duas instancias sobrepostas se o atalho for apertado duas vezes.
if pgrep -x hyprlock >/dev/null || pgrep -x swaylock >/dev/null; then
    exit 0
fi

if command -v hyprlock >/dev/null 2>&1; then
    exec hyprlock
fi

if command -v swaylock >/dev/null 2>&1; then
    # Cores retiradas de ~/.config/hypr/scheme/current.conf para bater com o
    # resto do desktop. --screenshots + --effect-blur exigem swaylock-effects,
    # que e' o pacote instalado aqui; se algum dia virar o swaylock puro, essas
    # duas flags sao ignoradas com erro -- por isso o fallback logo abaixo.
    swaylock \
        --screenshots \
        --effect-blur 7x5 \
        --clock \
        --indicator \
        --indicator-radius 110 \
        --indicator-thickness 8 \
        --ring-color becd96 \
        --key-hl-color dbeab1 \
        --line-color 00000000 \
        --inside-color 0d0f09cc \
        --separator-color 00000000 \
        --text-color e5e7d6 \
        --font "SF Pro Display" \
        --fade-in 0.2 \
    || swaylock -f -c 0d0f09
    exit 0
fi

# Nenhum locker instalado: avisa em vez de falhar em silencio.
notify-send -u critical "Bloqueio indisponivel" \
    "Nem hyprlock nem swaylock encontrados. Instale: sudo pacman -S hyprlock" \
    2>/dev/null
exit 1
