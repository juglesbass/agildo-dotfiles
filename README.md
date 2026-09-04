# 🚀 Agildo Dotfiles

Configurações personalizadas para **Hyprland** e **Caelestia Shell (Quickshell)** com foco em produtividade, estética Material You e suporte nativo a monitores 4K em escala variável.

---

## ✨ Recursos Personalizados

- **Caelestia Shell em Português (PT-BR)**:
  - Todo o aplicativo de configurações (Nexus) traduzido.
  - Seções intuitivas de rede, áudio, bluetooth, aparência e estilo.
- **Controles Gráficos de Aparência no Nexus**:
  - **Escala da tela (100% a 300%)**: Seletor rápido em grade com predefinições visíveis (`100% Nativo`, `125%`, `150%`, `175%`, `200% TV 4K`, `225%`, `250%`, `300%`) e ajuste manual fino (`StepperRow`).
  - **Largura da Dock**: Ajuste dinâmico da espessura da barra inferior de tarefas.
  - **Contorno de tela e cantos**: Opção de remover bordas (`0px`) ou ajustar curvatura da moldura.
  - **Tipografia e arredondamento**: Escala de fonte e curvatura dos elementos visuais.
  - **Cores**: Gerenciador de paletas dinâmicas Material You e temas pré-definidos.
- **Scripts de Integração e Automação (`~/.local/bin`)**:
  - `set-screen-scale.sh`: Aplica resolução e escala dinamicamente no Hyprland e persiste no sistema.
  - `set-bar-width.sh`: Ajusta a espessura da barra e recarrega os tokens.
  - `hyprland-autostart.sh`: Inicialização automática de serviços essenciais.
  - `window-minimize.sh`: Gerenciador intuitivo de minimização e restauração de janelas.
  - `sync-wallpaper-theme.sh`: Sincronização automática entre papéis de parede e paleta Material You.

---

## 📦 Estrutura do Repositório

```
agildo-dotfiles/
├── .config/
│   ├── quickshell/caelestia/  # Shell em QML (Quickshell) com traduções e novos controles
│   ├── caelestia/             # Configurações do usuário, tokens e hypr-user.lua
│   └── hypr/                  # Configurações, atalhos e regras de janela do Hyprland
├── .local/
│   └── bin/                   # Scripts auxiliares e ferramentas de automação
├── install.sh                 # Script de instalação com backup automático
└── README.md
```

---

## 🛠️ Como Instalar e Usar

1. **Clonar o repositório**:
   ```bash
   git clone https://github.com/juglesbass/agildo-dotfiles.git
   cd agildo-dotfiles
   ```

2. **Executar o instalador**:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. **Recarregar o Caelestia Shell**:
   ```bash
   qs -c caelestia kill && caelestia shell -d
   ```
