#!/usr/bin/env bash
# Gera ~/.config/waybar-ml4w/colors.css a partir de ~/.config/hypr/scheme/current.conf
#
# O ML4W gera esse arquivo com o Matugen a partir do wallpaper dele. Aqui a
# fonte e' o SEU scheme, que ja' segue a mesma convencao Material You -- so'
# muda o estilo do nome ($surfaceContainerHigh -> surface_container_high).
# Assim a barra do ML4W usa exatamente as cores do resto do seu desktop.
set -euo pipefail
SRC="$HOME/.config/hypr/scheme/current.conf"
DST="$HOME/.config/waybar-ml4w/colors.css"
[ -f "$SRC" ] || { echo "scheme nao encontrado: $SRC" >&2; exit 1; }
python3 - "$SRC" "$DST" <<'PY'
import re, sys, io
src, dst = sys.argv[1], sys.argv[2]
v = {}
for line in io.open(src, encoding='utf-8'):
    m = re.match(r'\s*\$(\w+)\s*=\s*([0-9a-fA-F]{6})\s*$', line)
    if m:
        v[m.group(1)] = m.group(2)
snake = lambda s: re.sub(r'(?<!^)(?=[A-Z])', '_', s).lower()
out = ["/*", " * Cores da barra ML4W", " * GERADO por ~/.local/bin/waybar-ml4w-colors.sh", 
       " * Fonte: ~/.config/hypr/scheme/current.conf -- NAO editar a mao.", " */"]
bg = v.get('background', '0d0f09')
r, g, b = (int(bg[i:i+2], 16) for i in (0, 2, 4))
out.append(f"@define-color blur_background rgba({r}, {g}, {b}, 0.3);")
out.append(f"@define-color blur_background8 rgba({r}, {g}, {b}, 0.8);")
out.append(f"@define-color source_color #{v.get('primary', 'becd96')};")
for k in sorted(v):
    out.append(f"@define-color {snake(k)} #{v[k]};")
io.open(dst, 'w', encoding='utf-8').write("\n".join(out) + "\n")
print(f"{len(v)} cores -> {dst}")
PY
