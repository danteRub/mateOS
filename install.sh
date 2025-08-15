#!/usr/bin/env bash
# install.sh - Instalador principal interactivo de mateOS (Hyprland Edition)

set -euo pipefail
cd "$(dirname "$0")"

# Helper input que usa gum si está, o read si no
_ask() {
  local prompt="$1" def="${2:-}"
  if command -v gum &>/dev/null; then
    if [[ "$prompt" == *"Contraseña"* ]]; then gum input --password --prompt "$prompt"; else gum input --placeholder "$def" --prompt "$prompt"; fi
  else
    read -rp "$prompt " val; echo "${val:-$def}"
  fi
}

# Instalar gum si no existe (en Arch ISO suele estar disponible)
if ! command -v gum &>/dev/null; then
  echo "[+] Instalando 'gum'..."
  pacman -Sy --noconfirm gum || true
fi

# Comprobaciones mínimas
[[ -d /sys/firmware/efi/efivars ]] || { echo "[!] Debes arrancar en modo UEFI."; exit 1; }

# Preguntas
DISK=$(_ask "Disco de destino:" "/dev/nvme0n1")
USERNAME=$(_ask "Nombre de usuario:" "usuario")
PASSWORD=$(_ask "Contraseña para $USERNAME:")
HOSTNAME=$(_ask "Hostname:" "mateos")
TIMEZONE=$(_ask "Zona horaria:" "Europe/Madrid")
KEYMAP=$(_ask "Layout de teclado:" "es")

export DISK USERNAME PASSWORD HOSTNAME TIMEZONE KEYMAP

# Confirmación
if command -v gum &>/dev/null; then
  gum confirm "¿Instalar Arch en $DISK como $USERNAME?" || exit 1
else
  read -rp "¿Instalar Arch en $DISK como $USERNAME? [s/N] " ok; [[ "$ok" =~ ^[sS]$ ]] || exit 1
fi

# Ejecución por fases
./00-preinstall.sh
./01-disk-setup.sh
./02-install-base.sh

# Copiar al chroot
install -Dm755 03-chroot-setup.sh /mnt/tmp/03-chroot-setup.sh
# (opcional) Dotfiles del repo si existen
if [[ -d ./dotfiles ]]; then
  rsync -a ./dotfiles/ /mnt/home/"$USERNAME"/.dotfiles/ || true
fi

# Configuración dentro del sistema
arch-chroot /mnt env -i \
  DISK="$DISK" USERNAME="$USERNAME" PASSWORD="$PASSWORD" \
  HOSTNAME="$HOSTNAME" TIMEZONE="$TIMEZONE" KEYMAP="$KEYMAP" \
  bash /tmp/03-chroot-setup.sh

# Postinstalación final
./04-postinstall.sh

echo "[✓] Instalación completa. Puedes reiniciar."
