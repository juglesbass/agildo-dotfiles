# ~/.config/hypr/shells/

Cada arquivo aqui contem TUDO que e' especifico de um shell: exec-once, binds,
env, windowrules e layerrules. O `hyprland.conf` faz `source = active.conf`, e
`active.conf` e' um symlink para o shell em uso.

Trocar de shell = repontar o symlink + `hyprctl reload`. Use o switch-shell.sh:

    switch-shell.sh wayle        # alterna para um shell especifico
    switch-shell.sh              # cicla para o proximo
    switch-shell.sh --status     # mostra qual esta ativo

## Por que isto existe

O switch-shell.sh antigo reescrevia o proprio hyprland.conf com `sed -i` a cada
troca -- 3 regexes rodando in-place num arquivo de 428 linhas de config muito
customizada. E gerenciava apenas as 3 linhas de `exec-once`: os binds, rules e
env especificos de cada shell ficavam para tras, apontando para processos que
nao estavam mais rodando. Era por isso que o SUPER+L parava de travar a tela ao
sair do caelestia.

## Adicionar um shell novo

1. Crie `<nome>.conf` aqui com o que aquele shell precisa.
2. Acrescente o nome ao array SHELLS no ~/.local/bin/switch-shell.sh.
3. Se ele precisar iniciar/parar processos, adicione o case correspondente la'.

## Cuidados

- `env =` so' vale no LOGIN. Trocar de shell em runtime nao muda variavel de
  ambiente; e' preciso relogar para valer.
- `exec-once =` tambem so' roda no login -- `hyprctl reload` NAO o re-executa.
  Isso e' proposital: quem sobe/derruba processo em runtime e' o switch-shell.sh.
- NAO redefina o SUPER+L aqui. O bloqueio de tela e' universal, mora no
  hyprland.conf e chama ~/.local/bin/lock-screen.sh (que escolhe hyprlock ou
  swaylock sozinho). Redefinir geraria bind duplicado.
