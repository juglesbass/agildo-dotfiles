#!/bin/bash
# 🚪 Encerrar a sessão do Hyprland de forma limpa
#
# NÃO use `loginctl terminate-session` / `terminate-user` aqui: eles matam o
# cgroup inteiro da sessão, e dentro dele está o próprio sddm-helper que
# iniciou o Hyprland. O SDDM então registra
#     Auth: sddm-helper (... --start /usr/bin/start-hyprland) crashed (exit code 1)
# trata a sessão como falha e nunca reabre o greeter — sobra a VT vazia com o
# cursor piscando.
#
# Deixando o Hyprland sair por conta própria, a cadeia
# start-hyprland -> wayland-session -> sddm-helper retorna 0, o SDDM registra
# "Auth: sddm-helper exited successfully" e recria o display com a tela de login.

~/.local/bin/prepare-next-wallpaper.sh 2>/dev/null || true

if hyprctl dispatch exit; then
    exit 0
fi

# Último recurso: o hyprctl não respondeu (compositor travado).
pkill -TERM -u "$USER" -x Hyprland
