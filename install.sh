#!/usr/bin/env bash
# install.sh - Main interactive script for mateOS (Hyprland edition)

set -e

# Requiere gum (interfaz interactiva)
if ! command -v gum &> /dev/null; then
  echo "[+] Instalando 'gum'..."
  pacman -Sy --noconfirm gum
fi

# Preguntas interactivas
DISK=$(gum input --placeholder "/dev/nvme0n1" --prompt "Disco de destino:")
USERNAME=$(gum input --placeholder "usuario" --prompt "Nombre de usuario:")
PASSWORD=$(gum input --password --prompt "Contraseña para $USERNAME:")
HOSTNAME=$(gum input --placeholder "mateos" --prompt "Hostname:")
TIMEZONE=$(gum input --placeholder "Europe/Madrid" --prompt "Zona horaria:")
KEYMAP=$(gum input --placeholder "es" --prompt "Layout de teclado:")

# Exportar variables globalmente
export DISK USERNAME PASSWORD HOSTNAME TIMEZONE KEYMAP

# Confirmar
gum confirm "¿Instalar Arch en $DISK como $USERNAME?" || exit 1

# Ejecutar fases previas
./00-preinstall.sh
./01-disk-setup.sh
./02-install-base.sh

# Copiar script chroot al sistema montado
install -Dm755 03-chroot-setup.sh /mnt/tmp/03-chroot-setup.sh

# Ejecutar dentro del chroot con entorno limpio y variables
arch-chroot /mnt env -i \
  DISK="$DISK" \
  USERNAME="$USERNAME" \
  PASSWORD="$PASSWORD" \
  HOSTNAME="$HOSTNAME" \
  TIMEZONE="$TIMEZONE" \
  KEYMAP="$KEYMAP" \
  bash /tmp/03-chroot-setup.sh

# Continuar con postinstalación fuera del chroot
./04-postinstall.sh
