#!/usr/bin/env bash
# Conta atualizacoes pendentes do pacman e devolve JSON para a waybar.
# Substitui o ~/.config/ml4w/scripts/ml4w-check-system-updates do ML4W.
# Somente LEITURA: nao instala nada, so' conta. `checkupdates` usa um banco
# sincronizado a parte, entao nao mexe no /var/lib/pacman/sync do sistema.
set -uo pipefail
command -v checkupdates >/dev/null 2>&1 || { echo '{"text":"","tooltip":"checkupdates ausente (pacman-contrib)"}'; exit 0; }
LIST=$(checkupdates 2>/dev/null || true)
if [ -z "$LIST" ]; then
    echo '{"text":"","tooltip":"Sistema atualizado"}'
    exit 0
fi
N=$(printf '%s\n' "$LIST" | wc -l)
TIP=$(printf '%s\n' "$LIST" | head -30 | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' | paste -sd '\n' -)
[ "$N" -gt 30 ] && TIP="$TIP"$'\n'"... e mais $((N-30))"
python3 -c 'import json,sys; print(json.dumps({"text":sys.argv[1],"tooltip":sys.argv[2]}))' "$N" "$TIP"
