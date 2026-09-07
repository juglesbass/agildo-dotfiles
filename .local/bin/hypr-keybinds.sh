#!/usr/bin/env bash
# Lista os atalhos ativos do Hyprland no rofi.
# Substitui o ~/.config/hypr/scripts/keybindings.sh do ML4W (que nao existe
# neste setup). Le os binds DE VERDADE via hyprctl, entao reflete sempre o
# shell ativo -- inclusive os binds do fragmento em ~/.config/hypr/shells/.
set -euo pipefail
hyprctl binds -j | python3 -c '
import json, sys
MODS = [(64,"SUPER"),(8,"ALT"),(4,"CTRL"),(1,"SHIFT")]
rows = []
for b in json.load(sys.stdin):
    m = b["modmask"]
    parts = [n for bit, n in MODS if m & bit]
    key = b["key"] or f"code:{b[\"keycode\"]}"
    combo = " + ".join(parts + [key])
    action = f'\''{b["dispatcher"]} {b["arg"]}'\''.strip()
    sub = b.get("submap") or ""
    if sub: combo = f"[{sub}] {combo}"
    rows.append((combo, action))
w = max((len(c) for c, _ in rows), default=0)
for c, a in sorted(rows):
    print(f"{c:<{w}}   {a}")
' | rofi -dmenu -i -p "Atalhos" -theme-str 'window {width: 60%;}' >/dev/null
