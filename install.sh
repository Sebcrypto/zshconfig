#!/usr/bin/env bash
# Installe l'environnement terminal sur une machine Debian ou Ubuntu :
# zsh, oh-my-zsh, Powerlevel10k, plugins, polices MesloLGS NF, outils
# (fzf, zoxide, eza, bat, fd, ripgrep, tmux) et les fichiers de config.
#
# Usage : ~/dotfiles/install.sh [--sans-paquets] [--sans-shell]
#   --sans-paquets  ne lance pas apt (pas besoin de sudo)
#   --sans-shell    ne fait pas de zsh le shell par défaut
#
# Le script peut être relancé sans risque : il met à jour ce qui existe déjà.
# Les fichiers de config sont des liens vers ce dépôt, donc un « git pull »
# suffit ensuite pour récupérer les changements.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM_DIR="$ZSH_DIR/custom"
STAMP="$(date +%Y%m%d-%H%M%S)"

PAQUETS=1
SHELL_ZSH=1
for arg in "$@"; do
  case "$arg" in
    --sans-paquets) PAQUETS=0 ;;
    --sans-shell) SHELL_ZSH=0 ;;
    -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Option inconnue : $arg" >&2; exit 1 ;;
  esac
done

etape() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
info()  { printf '    %s\n' "$*"; }

# Clone un dépôt, ou le met à jour s'il est déjà là
depot() {
  local url="$1" dest="$2"
  if [[ -d "$dest/.git" ]]; then
    if git -C "$dest" pull --quiet --ff-only; then
      info "à jour : ${dest/#$HOME/\~}"
    else
      info "mise à jour impossible (modifications locales ?), version actuelle gardée : ${dest/#$HOME/\~}"
    fi
  else
    git clone --quiet --depth=1 "$url" "$dest" && info "installé : ${dest/#$HOME/\~}"
  fi
}

# Remplace un fichier par un lien vers le dépôt, en gardant une copie de l'ancien
lien() {
  local src="$DOTFILES/$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    info "déjà lié : ${dest/#$HOME/\~}"
    return
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    mv "$dest" "$dest.avant-dotfiles-$STAMP"
    info "ancien fichier gardé : ${dest/#$HOME/\~}.avant-dotfiles-$STAMP"
  fi
  ln -s "$src" "$dest"
  info "lié : ${dest/#$HOME/\~}"
}

# ---------------------------------------------------------------------------
if (( PAQUETS )); then
  etape "Paquets (apt)"
  if ! command -v apt-get >/dev/null; then
    echo "Ce script est prévu pour Debian ou Ubuntu (apt introuvable)." >&2
    exit 1
  fi

  # Le dépôt debian.griffo.io (Ghostty) propose fzf, zoxide et eza mais refuse
  # les téléchargements : on préfère les versions officielles s'il est présent.
  if grep -rqs griffo /etc/apt/sources.list /etc/apt/sources.list.d/; then
    printf 'Package: fzf zoxide eza\nPin: origin debian.griffo.io\nPin-Priority: 100\n' \
      | sudo tee /etc/apt/preferences.d/outils-debian >/dev/null
    info "priorité aux versions Debian pour fzf, zoxide, eza"
  fi

  sudo apt-get update -qq
  voulus=(zsh git curl fontconfig fzf zoxide eza bat fd-find ripgrep tmux)
  dispo=()
  for p in "${voulus[@]}"; do
    if apt-cache show "$p" >/dev/null 2>&1; then dispo+=("$p"); else info "absent des dépôts, ignoré : $p"; fi
  done
  sudo apt-get install -y -qq "${dispo[@]}"
  info "installés : ${dispo[*]}"
fi

for outil in zsh git; do
  command -v "$outil" >/dev/null || { echo "$outil est requis. Relance sans --sans-paquets." >&2; exit 1; }
done

# ---------------------------------------------------------------------------
etape "oh-my-zsh, Powerlevel10k et plugins"
depot https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR"
depot https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM_DIR/themes/powerlevel10k"
depot https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
depot https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"

# ---------------------------------------------------------------------------
etape "Polices MesloLGS NF (icônes de Powerlevel10k)"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
nouvelles=0
for style in Regular Bold Italic "Bold Italic"; do
  fichier="MesloLGS NF $style.ttf"
  if [[ ! -f "$FONT_DIR/$fichier" ]]; then
    curl -fsSL -o "$FONT_DIR/$fichier" \
      "https://github.com/romkatv/powerlevel10k-media/raw/master/${fichier// /%20}"
    nouvelles=1
  fi
done
if (( nouvelles )) && command -v fc-cache >/dev/null; then fc-cache -f "$FONT_DIR" >/dev/null; fi
info "MesloLGS NF présente dans ${FONT_DIR/#$HOME/\~}"

# ---------------------------------------------------------------------------
etape "Fichiers de configuration"
lien zsh/zshrc        "$HOME/.zshrc"
lien zsh/p10k.zsh     "$HOME/.p10k.zsh"
lien zsh/outils.zsh   "$ZSH_CUSTOM_DIR/outils.zsh"
lien tmux/tmux.conf   "$HOME/.config/tmux/tmux.conf"
if command -v ghostty >/dev/null || [[ -d "$HOME/.config/ghostty" ]]; then
  lien ghostty/config "$HOME/.config/ghostty/config"
else
  info "Ghostty absent : config Ghostty ignorée (relance le script après l'avoir installé)"
fi

# ---------------------------------------------------------------------------
if (( SHELL_ZSH )); then
  etape "Shell par défaut"
  ZSH_BIN="$(command -v zsh)"
  if [[ "$(getent passwd "$USER" | cut -d: -f7)" == "$ZSH_BIN" ]]; then
    info "zsh est déjà le shell par défaut"
  else
    info "changement du shell pour zsh (mot de passe demandé)"
    chsh -s "$ZSH_BIN"
  fi
fi

etape "Terminé"
info "Ouvre un nouveau terminal pour profiter de la config."
info "Dans les terminaux autres que Ghostty, choisis la police « MesloLGS NF »."
