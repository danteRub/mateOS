#!/usr/bin/env bash
# 00-preinstall.sh - Preinstallation setup

set -e
: "${DISK:?}" "${USERNAME:?}" "${PASSWORD:?}" "${HOSTNAME:?}" "${TIMEZONE:?}" "${KEYMAP:?}"

if [[ -z "${MIRROR_COUNTRY:-}" ]]; then
    read -rp "[?] Mirror country [Spain]: " MIRROR_COUNTRY
    MIRROR_COUNTRY=${MIRROR_COUNTRY:-Spain}
fi

echo "[+] Configurando teclado..."
loadkeys "$KEYMAP"

echo "[+] Sincronizando hora..."
timedatectl set-ntp true

echo "[+] Configurando mirrors con reflector..."
pacman -Sy --noconfirm reflector
reflector --country "$MIRROR_COUNTRY" --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

echo "[✓] Preinstalación completada."
