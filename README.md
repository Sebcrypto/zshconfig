# dotfiles

Environnement terminal commun à toutes les machines Debian et Ubuntu du réseau :
zsh + oh-my-zsh + Powerlevel10k, plugins de suggestion et de coloration,
polices MesloLGS NF, outils (fzf, zoxide, eza, bat, fd, ripgrep, tmux) et
configurations de tmux et Ghostty.

## Installer sur une nouvelle machine

```sh
sudo apt install -y git
git clone ssh://git@ssh.git.studio89.cloud/dev/ConfigTerminal.git ~/dotfiles
~/dotfiles/install.sh
```

Le clone passe par SSH : la machine doit avoir une clé autorisée sur le
serveur git. Pour une nouvelle machine, crée la clé avec
`ssh-keygen -t ed25519`, affiche-la avec `cat ~/.ssh/id_ed25519.pub` et
ajoute-la dans les clés SSH de ton compte sur le serveur.

Le script demande le mot de passe pour apt, puis pour faire de zsh le shell
par défaut. Ouvre ensuite un nouveau terminal.

Options :

- `--sans-paquets` : n'installe aucun paquet (pas de sudo), seulement oh-my-zsh,
  les plugins, les polices et les fichiers de config.
- `--sans-shell` : ne change pas le shell par défaut.

Le script peut être relancé autant de fois que nécessaire : il met à jour
oh-my-zsh et les plugins, et ne touche pas à ce qui est déjà en place.

## Récupérer les changements

Les fichiers de config de chaque machine sont des liens vers ce dépôt :

```sh
cd ~/dotfiles && git pull
```

Après un changement de la liste des paquets ou des plugins, relance aussi
`./install.sh`.

## Modifier la config

Modifie les fichiers du dépôt (ou directement `~/.zshrc`, `~/.p10k.zsh`…,
qui pointent dessus), puis :

```sh
cd ~/dotfiles && git commit -am "Description du changement" && git push
```

| Fichier du dépôt   | Emplacement sur la machine            |
|--------------------|---------------------------------------|
| `zsh/zshrc`        | `~/.zshrc`                            |
| `zsh/p10k.zsh`     | `~/.p10k.zsh` (`p10k configure`)      |
| `zsh/outils.zsh`   | `~/.oh-my-zsh/custom/outils.zsh`      |
| `tmux/tmux.conf`   | `~/.config/tmux/tmux.conf`            |
| `ghostty/config`   | `~/.config/ghostty/config`            |

## Réglages propres à une machine

Ce qui ne concerne qu'une machine va dans `~/.zshrc.local`, qui n'est pas
versionné et que `~/.zshrc` charge en dernier s'il existe.

## Ce que le script ne fait pas

- Il n'installe pas Ghostty. Son dépôt (debian.griffo.io) refuse
  actuellement les téléchargements. La config Ghostty est liée seulement si
  Ghostty est déjà installé : relance le script après l'avoir installé.
- Il ne règle pas la police des autres terminaux : dans GNOME Terminal ou
  autre, choisis « MesloLGS NF ». Ghostty n'en a pas besoin.

Les anciens fichiers remplacés sont gardés à côté, avec le suffixe
`.avant-dotfiles-<date>`.
