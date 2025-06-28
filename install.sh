#!/usr/bin/env bash
# install.sh - Main interactive script for mateOS (Hyprland edition)

set -e

# Requiere gum (interfaz interactiva)
if ! command -v gum &> /dev/null; then
  echo "[!] Se necesita instalar 'gum'. Ejecuta: pacman -Sy gum"
  pacman -Sy gum --noconfirm
fi

# Preguntas interactivas con gum
DISK=$(gum input --placeholder "/dev/nvme0n1" --prompt "Disco de destino:")
USERNAME=$(gum input --placeholder "usuario" --prompt "Nombre de usuario:")
PASSWORD=$(gum input --password --prompt "Contraseña para $USERNAME:")
HOSTNAME=$(gum input --placeholder "mateos" --prompt "Hostname:")
TIMEZONE=$(gum input --placeholder "Europe/Madrid" --prompt "Zona horaria:")
KEYMAP=$(gum input --placeholder "es" --prompt "Layout de teclado:")

# Exportar variables para todos los scripts
export DISK USERNAME PASSWORD HOSTNAME TIMEZONE KEYMAP

# Confirmar
gum confirm "¿Instalar Arch en $DISK como $USERNAME?" || exit 1

# Ejecutar pasos
./00-preinstall.sh
./01-disk-setup.sh
./02-install-base.sh

# Pasar variables al entorno chroot
arch-chroot /mnt env -i DISK=$DISK USERNAME=$USERNAME PASSWORD=$PASSWORD HOSTNAME=$HOSTNAME TIMEZONE=$TIMEZONE KEYMAP=$KEYMAP bash /03-chroot-setup.sh

./04-postinstall.sh
