#!/usr/bin/env bash
set -e
: "${USERNAME:?}"

echo '[+] Post-instalación para el usuario...'
HOME_DIR="/mnt/home/$USERNAME"

# Starship en zsh
echo 'eval "$(starship init zsh)"' >> "$HOME_DIR/.zshrc" || true

# Dotfiles si se copiaron antes
if [[ -d "$HOME_DIR/.dotfiles" ]]; then
  rsync -a "$HOME_DIR/.dotfiles/." "$HOME_DIR/"
fi

chown -R "$USERNAME:$USERNAME" "$HOME_DIR"

echo '[✓] Post-instalación completada. Puedes reiniciar.'
