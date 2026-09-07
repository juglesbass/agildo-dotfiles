#!/usr/bin/env bash
# ==============================================================================
# 🔄 Alternador de shell/barra do Hyprland
#     caelestia <-> waybar <-> wayle <-> ml4w
# ==============================================================================
#
# COMO FUNCIONA
# -------------
# Cada shell tem um fragmento em ~/.config/hypr/shells/<nome>.conf com TUDO que
# e' especifico dele (exec-once, binds, env, rules). O hyprland.conf faz
#   source = ~/.config/hypr/shells/active.conf
# e active.conf e' um symlink. Trocar de shell = repontar o symlink + reload.
#
# O QUE MUDOU EM RELACAO A VERSAO ANTIGA
# --------------------------------------
# A versao antiga rodava `sed -i` no proprio hyprland.conf a cada troca, com 3
# regexes, num arquivo de 428 linhas de config muito customizada. E gerenciava
# apenas as linhas de `exec-once`: os binds especificos de cada shell ficavam
# para tras. Era por isso que o SUPER+L (que chamava o IPC do caelestia) parava
# de travar a tela ao alternar para waybar ou wayle.
#
# Agora o hyprland.conf nunca e' modificado, e o bloqueio de tela nao pertence
# mais a shell nenhum: e' o ~/.local/bin/lock-screen.sh.

set -uo pipefail

SHELLS_DIR="$HOME/.config/hypr/shells"
ACTIVE_LINK="$SHELLS_DIR/active.conf"
SHELLS=(caelestia waybar wayle ml4w)

die()  { printf '\033[31m✖ %s\033[0m\n' "$*" >&2; exit 1; }
info() { printf '\033[36m→ %s\033[0m\n' "$*"; }
ok()   { printf '\033[32m✓ %s\033[0m\n' "$*"; }
warn() { printf '\033[33m⚠ %s\033[0m\n' "$*" >&2; }

usage() {
    cat <<USAGE
Uso: ${0##*/} [<shell>|--status|--list|-h]

  <shell>     um de: ${SHELLS[*]}
  (vazio)     cicla para o proximo da lista
  --status    mostra o shell ativo e o que esta rodando de fato
  --list      lista os fragmentos disponiveis
USAGE
}

# ---------------------------------------------------------------- utilidades

# Shell ativo = alvo do symlink. E' a fonte da verdade (a versao antiga
# adivinhava com pgrep, e o `pgrep -f caelestia` dava falso positivo ao casar
# com a propria linha de comando deste script).
current_shell() {
    [ -L "$ACTIVE_LINK" ] || { echo "nenhum"; return; }
    local t; t=$(readlink -f "$ACTIVE_LINK" 2>/dev/null) || { echo "nenhum"; return; }
    t=${t##*/}; echo "${t%.conf}"
}

next_shell() {
    local cur="$1" i
    for i in "${!SHELLS[@]}"; do
        if [ "${SHELLS[$i]}" = "$cur" ]; then
            echo "${SHELLS[$(( (i + 1) % ${#SHELLS[@]} ))]}"; return
        fi
    done
    echo "${SHELLS[0]}"   # atual desconhecido: comeca do inicio
}

is_valid() {
    local s
    for s in "${SHELLS[@]}"; do [ "$s" = "$1" ] && return 0; done
    return 1
}

stop_all_shells() {
    qs -c caelestia kill >/dev/null 2>&1
    pkill -x wayle  >/dev/null 2>&1
    pkill -x waybar >/dev/null 2>&1
    pkill -x mako   >/dev/null 2>&1
    # Da' um instante para os sockets/layer-surfaces sumirem antes do proximo
    # shell subir; sem isso o novo pode nascer com a layer do anterior ainda
    # registrada e ficar com barra dupla ate' o proximo reload.
    sleep 0.3
}

# O mako so' sobe para os shells que NAO tem daemon de notificacoes proprio
# (caelestia e wayle tem; waybar e ml4w nao).
start_mako() { pgrep -x mako >/dev/null 2>&1 || setsid mako >/dev/null 2>&1 & }

# ------------------------------------------------------------ inicializacao

start_shell() {
    case "$1" in
        caelestia)
            command -v caelestia >/dev/null || die "caelestia nao encontrado no PATH"
            caelestia shell -d >/dev/null 2>&1
            ;;
        wayle)
            command -v wayle >/dev/null || die "wayle nao encontrado no PATH"
            setsid wayle shell >/dev/null 2>&1 &
            # Repassa o wallpaper atual para o wayle puxar a paleta de cores.
            (
                sleep 1
                local w
                w=$(cat "$HOME/.local/state/caelestia/wallpaper/path.txt" 2>/dev/null)
                [ -n "${w:-}" ] && [ -f "$w" ] && wayle wallpaper set "$w" >/dev/null 2>&1
            ) >/dev/null 2>&1 &
            ;;
        waybar)
            command -v waybar >/dev/null || die "waybar nao encontrado no PATH"
            start_mako
            setsid waybar >/dev/null 2>&1 &
            ;;
        ml4w)
            command -v waybar >/dev/null || die "waybar nao encontrado no PATH"
            local cfg="$HOME/.config/waybar-ml4w/config.jsonc"
            local css="$HOME/.config/waybar-ml4w/style.css"
            if [ ! -f "$cfg" ] || [ ! -f "$css" ]; then
                warn "Assets do ML4W ausentes em ~/.config/waybar-ml4w/"
                warn "  faltando: $( [ -f "$cfg" ] || echo -n 'config.jsonc ' )$( [ -f "$css" ] || echo -n 'style.css' )"
                warn "Subindo a waybar com a config padrao (~/.config/waybar) por enquanto."
                start_mako
                setsid waybar >/dev/null 2>&1 &
                return 0
            fi
            # Regenera colors.css a partir do scheme atual, para a barra
            # nascer com as mesmas cores do resto do desktop.
            "$HOME/.local/bin/waybar-ml4w-colors.sh" >/dev/null 2>&1 || true
            start_mako
            setsid waybar -c "$cfg" -s "$css" >/dev/null 2>&1 &
            ;;
    esac
}

# ------------------------------------------------------------------ acoes

show_status() {
    printf 'Shell ativo (symlink): \033[1m%s\033[0m\n' "$(current_shell)"
    echo "Processos rodando agora:"
    local found=0 p
    for p in caelestia wayle waybar mako; do
        if pgrep -x "$p" >/dev/null 2>&1; then printf '  ✓ %s\n' "$p"; found=1; fi
    done
    pgrep -f 'qs -c caelestia' >/dev/null 2>&1 && { printf '  ✓ quickshell (caelestia)\n'; found=1; }
    [ "$found" = 0 ] && echo "  (nenhum)"
    echo
    echo -n "Bloqueio de tela: "
    if   command -v hyprlock >/dev/null 2>&1; then echo "hyprlock (SUPER+L)"
    elif command -v swaylock >/dev/null 2>&1; then echo "swaylock (SUPER+L) — instale hyprlock para o modo preferido"
    else echo "❌ NENHUM locker instalado"; fi
}

case "${1:-}" in
    -h|--help) usage; exit 0 ;;
    --status)  show_status; exit 0 ;;
    --list)
        for s in "${SHELLS[@]}"; do
            [ -f "$SHELLS_DIR/$s.conf" ] && printf '  %-12s %s\n' "$s" "$SHELLS_DIR/$s.conf" \
                                         || printf '  %-12s \033[31m(fragmento ausente)\033[0m\n' "$s"
        done
        exit 0 ;;
esac

[ -d "$SHELLS_DIR" ] || die "$SHELLS_DIR nao existe"

CURRENT=$(current_shell)
TARGET="${1:-$(next_shell "$CURRENT")}"

is_valid "$TARGET" || { usage >&2; die "shell desconhecido: '$TARGET'"; }
[ -f "$SHELLS_DIR/$TARGET.conf" ] || die "fragmento nao encontrado: $SHELLS_DIR/$TARGET.conf"

if [ "$TARGET" = "$CURRENT" ]; then
    info "'$TARGET' ja' e' o shell ativo — reiniciando os processos dele."
fi

info "Alternando: $CURRENT -> $TARGET"

stop_all_shells

# Repontar o symlink e recarregar. O reload aplica binds/rules/windowrules do
# novo fragmento imediatamente; `exec-once` NAO e' reexecutado pelo reload,
# por isso os processos sobem via start_shell logo abaixo.
ln -sfn "$SHELLS_DIR/$TARGET.conf" "$ACTIVE_LINK" || die "falhou ao repontar o symlink"

if ! hyprctl reload >/dev/null 2>&1; then
    warn "hyprctl reload falhou (Hyprland nao esta rodando?). O symlink foi trocado assim mesmo."
fi

start_shell "$TARGET"

ok "$TARGET ativo."
echo "  (config: $SHELLS_DIR/$TARGET.conf)"
