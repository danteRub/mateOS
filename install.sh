#!/usr/bin/env bash
# install.sh - Main interactive script for your custom Arch installer (Hyprland edition)

set -e

if ! command -v gum &> /dev/null; then
  echo "[!] Se necesita instalar 'gum'. Ejecuta: pacman -Sy gum"
  exit 1
fi

DISK=$(gum input --placeholder "/dev/nvme0n1" --prompt "Disco de destino:")
USERNAME=$(gum input --placeholder "usuario" --prompt "Nombre de usuario:")
PASSWORD=$(gum input --password --prompt "Contraseña para $USERNAME:")
HOSTNAME=$(gum input --placeholder "archhypr" --prompt "Hostname:")
TIMEZONE=$(gum input --placeholder "Europe/Madrid" --prompt "Zona horaria:")
KEYMAP=$(gum input --placeholder "es" --prompt "Layout de teclado:")

export DISK USERNAME PASSWORD HOSTNAME TIMEZONE KEYMAP

gum confirm "¿Instalar Arch en $DISK como $USERNAME?" || exit 1

./00-preinstall.sh
./01-disk-setup.sh
./02-install-base.sh
arch-chroot /mnt env -i DISK=$DISK USERNAME=$USERNAME PASSWORD=$PASSWORD HOSTNAME=$HOSTNAME TIMEZONE=$TIMEZONE KEYMAP=$KEYMAP bash /03-chroot-setup.sh
./04-postinstall.sh
