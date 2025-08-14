#!/usr/bin/env bash
# install.sh - Instalador principal interactivo de mateOS (Hyprland Edition)

set -euo pipefail

# Comprobar e instalar gum si es necesario
if ! command -v gum &> /dev/null; then
  echo "[+] Instalando 'gum'..."
  pacman -Sy --noconfirm gum
fi

# Recoger configuración del usuario
DISK=$(gum input --placeholder "/dev/nvme0n1" --prompt "Disco de destino:")
USERNAME=$(gum input --placeholder "usuario" --prompt "Nombre de usuario:")
PASSWORD=$(gum input --password --prompt "Contraseña para $USERNAME:")
HOSTNAME=$(gum input --placeholder "mateos" --prompt "Hostname:")
TIMEZONE=$(gum input --placeholder "Europe/Madrid" --prompt "Zona horaria:")
KEYMAP=$(gum input --placeholder "es" --prompt "Layout de teclado:")

# Exportar para otros scripts
export DISK USERNAME PASSWORD HOSTNAME TIMEZONE KEYMAP

# Confirmación
gum confirm "¿Instalar Arch en $DISK como $USERNAME?" || exit 1

# Ejecutar pasos previos a chroot
./00-preinstall.sh
./01-disk-setup.sh
./02-install-base.sh

# Verificar que el script existe antes de copiar
if [ ! -f 03-chroot-setup.sh ]; then
  echo "[!] Error: el archivo 03-chroot-setup.sh no se encuentra."
  exit 1
fi

# Copiar el script dentro del entorno montado
echo "[+] Copiando 03-chroot-setup.sh al entorno chroot..."
install -Dm755 03-chroot-setup.sh /mnt/tmp/03-chroot-setup.sh
ls -l /mnt/tmp/

# Ejecutar en chroot pasando variables de entorno de forma controlada
echo "[+] Ejecutando configuración dentro del sistema chroot..."
arch-chroot /mnt env -i   DISK="$DISK"   USERNAME="$USERNAME"   PASSWORD="$PASSWORD"   HOSTNAME="$HOSTNAME"   TIMEZONE="$TIMEZONE"   KEYMAP="$KEYMAP"   bash /tmp/03-chroot-setup.sh

# Ejecutar configuración post-chroot
./04-postinstall.sh

echo "[✓] Instalación completa. Puedes reiniciar el sistema."
