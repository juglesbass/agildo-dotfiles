#!/usr/bin/env bash
# ==============================================================================
# 🎨 scheme.json (caelestia) -> ~/.config/hypr/scheme/current.conf
# ==============================================================================
# O current.conf e' o ficheiro de cores que TODO o resto le:
#   - ~/.config/hypr/hyprlock.conf        (ecra de bloqueio, via `source =`)
#   - ~/.local/bin/waybar-ml4w-colors.sh  (barra do ML4W)
#   - ~/.config/quickshell/desktop        (relogio e sensores, com watchChanges)
#
# Quem o escrevia era o SHELL caelestia (quickshell). Ao passar para o wayle,
# ninguem mais o reescrevia: ficou parado em 2026-09-02 enquanto o wallpaper
# mudava, e as cores deixaram de acompanhar.
#
# O `caelestia wallpaper -f` (chamado pelo sync-wallpaper-theme.sh) continua a
# actualizar o scheme.json, que tem exactamente as mesmas 120 chaves. Este
# script so' faz a ponte que faltava.
set -euo pipefail
SRC="$HOME/.local/state/caelestia/scheme.json"
DST="$HOME/.config/hypr/scheme/current.conf"
[ -r "$SRC" ] || { echo "scheme.json ausente: $SRC" >&2; exit 1; }
mkdir -p "$(dirname "$DST")"
python3 - "$SRC" "$DST" <<'PY'
import io, json, os, sys, tempfile
src, dst = sys.argv[1], sys.argv[2]
cols = json.load(io.open(src, encoding='utf-8')).get('colours', {})
if not cols:
    sys.exit("scheme.json sem 'colours'")
lines = [f"${k} = {v}" for k, v in cols.items()]
# Escrita atomica: o widget observa este ficheiro e leria um ficheiro
# meio-escrito se fosse gravado no lugar.
d = os.path.dirname(dst)
fd, tmp = tempfile.mkstemp(dir=d, prefix='.current.conf.')
with io.open(fd, 'w', encoding='utf-8') as f:
    f.write("\n".join(lines) + "\n")
os.replace(tmp, dst)
print(f"{len(cols)} cores -> {dst}")
PY
