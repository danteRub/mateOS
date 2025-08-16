#!/usr/bin/env bash
# install.sh - Instalador principal de mateOS (Hyprland Edition)
# - Pregunta datos con gum
# - Genera env.sh con las variables
# - Exporta variables al entorno actual
# - Orquesta 00 → 04 y el chroot

set -euo pipefail

need() { command -v "$1" >/dev/null 2>&1 || { echo "[-] Falta $1"; exit 1; }; }

# --- Dependencias mínimas en la Live ISO ---
pacman -Sy --noconfirm --needed git curl >/dev/null
if ! command -v gum >/dev/null 2>&1; then
  echo "[+] Instalando 'gum'..."
  pacman -Sy --noconfirm gum
fi

# --- Recoger datos ---
DISK=$(gum input --placeholder "/dev/nvme0n1" --prompt "Disco de destino:")
USERNAME=$(gum input --placeholder "usuario" --prompt "Nombre de usuario:")
PASSWORD=$(gum input --password --prompt "Contraseña para $USERNAME:")
HOSTNAME=$(gum input --placeholder "mateos" --prompt "Hostname:")
TIMEZONE=$(gum input --placeholder "Europe/Madrid" --prompt "Zona horaria:")
KEYMAP=$(gum input --placeholder "es" --prompt "Layout de teclado:")

[ -n "$DISK" ] || { echo "[-] Debes indicar DISK"; exit 1; }

gum confirm "¿Instalar Arch en $DISK para el usuario $USERNAME?" || exit 1

# --- Guardar variables para el resto de scripts (env.sh) ---
cat > env.sh <<EOF
export DISK="$DISK"
export USERNAME="$USERNAME"
export PASSWORD="$PASSWORD"
export HOSTNAME="$HOSTNAME"
export TIMEZONE="$TIMEZONE"
export KEYMAP="$KEYMAP"
EOF

# --- Exportar también a la sesión actual ---
# (los 00–02 se ejecutan fuera del chroot y leen del entorno)
# shellcheck source=/dev/null
source ./env.sh

chmod +x 00-preinstall.sh 01-disk-setup.sh 02-install-base.sh 03-chroot-setup.sh 04-postinstall.sh

# --- Pipeline fuera del chroot ---
./00-preinstall.sh
./01-disk-setup.sh
./02-install-base.sh   # este script ya hace bind del caché si lo añadiste

# --- Copiar y ejecutar la fase de chroot con variables limpias ---
echo "[+] Copiando 03-chroot-setup.sh al chroot…"
install -Dm755 03-chroot-setup.sh /mnt/tmp/03-chroot-setup.sh

echo "[+] Ejecutando 03 dentro del chroot…"
arch-chroot /mnt env -i \
  DISK="$DISK" USERNAME="$USERNAME" PASSWORD="$PASSWORD" \
  HOSTNAME="$HOSTNAME" TIMEZONE="$TIMEZONE" KEYMAP="$KEYMAP" \
  bash /tmp/03-chroot-setup.sh

# --- Post ---
./04-postinstall.sh

echo
echo "✅ Instalación completa. Puedes reiniciar con:  reboot"
echo "   Usuario: $USERNAME"
echo "   Hostname: $HOSTNAME"
echo "   Variables guardadas en ./env.sh"
