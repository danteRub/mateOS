#!/usr/bin/env bash
# 04-postinstall.sh - Post-install config

set -e
: "${USERNAME:?}"

echo '[+] Configurando entorno para el usuario...'
echo 'eval "$(starship init zsh)"' >> /mnt/home/$USERNAME/.zshrc
chown -R $USERNAME:$USERNAME /mnt/home/$USERNAME

echo '[✓] Post-instalación completada. Reinicia el sistema.'
