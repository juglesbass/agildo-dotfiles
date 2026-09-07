#!/usr/bin/env bash
# ==============================================================================
# 📋 Historico da area de transferencia (cliphist + rofi)
# ==============================================================================
# O daemon que grava e' o `wl-paste --watch cliphist store`, iniciado pelo
# ~/.local/bin/hyprland-autostart.sh. Este script e' so' a interface de escolha.
#
# Existe como ficheiro, e nao como comando inline, porque e' usado em dois
# sitios -- o atalho global do hyprland.conf e o botao da barra do ML4W. Ter a
# mesma logica escrita duas vezes so' garante que uma das copias fica para tras.
#
#   clipboard-history.sh            escolher e copiar
#   clipboard-history.sh delete     escolher e apagar essa entrada
#   clipboard-history.sh wipe       limpar tudo (pede confirmacao)
set -uo pipefail

mode=${1:-copy}

have() { command -v "$1" >/dev/null 2>&1; }
have cliphist || { notify-send "Clipboard" "cliphist nao encontrado" 2>/dev/null; exit 1; }
have rofi     || { notify-send "Clipboard" "rofi nao encontrado" 2>/dev/null; exit 1; }

case "$mode" in
    wipe)
        # Destrutivo e irreversivel: nunca sem confirmar.
        if [ "$(printf 'Nao\nSim' | rofi -dmenu -i -p 'Apagar TODO o historico?' -lines 2)" = "Sim" ]; then
            cliphist wipe && notify-send "Clipboard" "Historico apagado" 2>/dev/null
        fi
        ;;
    delete)
        sel=$(cliphist list | rofi -dmenu -i -p "Apagar entrada" -theme-str 'window {width: 55%;}')
        [ -n "$sel" ] && printf '%s' "$sel" | cliphist delete
        ;;
    copy|*)
        sel=$(cliphist list | rofi -dmenu -i -p "Clipboard" -theme-str 'window {width: 55%;}')
        # decode devolve o conteudo original, inclusive imagens; sem ele
        # copiava-se o texto truncado que o rofi mostra.
        [ -n "$sel" ] && printf '%s' "$sel" | cliphist decode | wl-copy
        ;;
esac
