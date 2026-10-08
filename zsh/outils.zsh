# Outils en ligne de commande (chargé automatiquement par oh-my-zsh).
# Chaque bloc ne s'active que si l'outil est installé.

# fzf : Ctrl+R recherche floue dans l'historique, Ctrl+T cherche un fichier,
# Alt+C va dans un sous-dossier
if (( $+commands[fzf] )); then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    # fzf antérieur à 0.48 (Debian 12, Ubuntu 22.04) : scripts fournis par le paquet
    for f in /usr/share/doc/fzf/examples/{key-bindings,completion}.zsh; do
      [[ -r $f ]] && source $f
    done
  fi
fi

# zoxide : « z motif » va dans le dossier le plus fréquenté qui correspond,
# « zi » pour choisir dans une liste
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# eza : ls avec couleurs, icônes et dossiers en premier
if (( $+commands[eza] )); then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -l --icons=auto --group-directories-first --git'
  alias la='eza -la --icons=auto --group-directories-first --git'
  alias lt='eza --tree --level=2 --icons=auto'
fi

# bat (nommé batcat sur Debian et Ubuntu) : cat avec coloration syntaxique
if (( $+commands[batcat] )); then
  alias bat='batcat'
  alias cat='batcat --paging=never --style=plain'
elif (( $+commands[bat] )); then
  alias cat='bat --paging=never --style=plain'
fi

# fd (nommé fdfind sur Debian et Ubuntu) : find plus simple et plus rapide
if (( $+commands[fdfind] )); then
  alias fd='fdfind'
fi
