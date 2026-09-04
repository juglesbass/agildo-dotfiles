#!/usr/bin/env bash
# ==============================================================================
# 🚀 Agildo Dotfiles - Script de Instalação e Sincronização
# ==============================================================================
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "============================================="
echo "  🚀 Instalando Agildo Dotfiles"
echo "============================================="

# 1. Garantir diretórios de destino
mkdir -p "$HOME/.config/quickshell"
mkdir -p "$HOME/.config/caelestia"
mkdir -p "$HOME/.config/hypr"
mkdir -p "$HOME/.local/bin"

# 2. Criar backup dos arquivos existentes
if [ "$1" != "--no-backup" ]; then
    echo "📦 Criando backup em $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    [ -d "$HOME/.config/quickshell/caelestia" ] && cp -r "$HOME/.config/quickshell/caelestia" "$BACKUP_DIR/" 2>/dev/null || true
    [ -d "$HOME/.config/caelestia" ] && cp -r "$HOME/.config/caelestia" "$BACKUP_DIR/" 2>/dev/null || true
    [ -d "$HOME/.config/hypr" ] && cp -r "$HOME/.config/hypr" "$BACKUP_DIR/" 2>/dev/null || true
fi

# 3. Sincronizar arquivos de configuração
echo "🔗 Sincronizando configurações..."
rsync -av --exclude="*.bak*" --exclude="*.so" "$DOTFILES_DIR/.config/" "$HOME/.config/"
rsync -av "$DOTFILES_DIR/.local/bin/" "$HOME/.local/bin/"

# 4. Ajustar permissões de execução nos scripts
chmod +x "$HOME/.local/bin/"*.sh 2>/dev/null || true

echo "============================================="
echo "✅ Instalação concluída com sucesso!"
echo "🔄 Para recarregar o shell execute: qs -c caelestia kill && caelestia shell -d"
echo "============================================="
