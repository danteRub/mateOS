#!/usr/bin/env bash
set -e
: "${DISK:?}" "${USERNAME:?}" "${PASSWORD:?}" "${HOSTNAME:?}" "${TIMEZONE:?}" "${KEYMAP:?}"

echo "[+] Configurando teclado..."
loadkeys "$KEYMAP" || true

echo "[+] Sincronizando hora..."
timedatectl set-ntp true

echo "[+] Refrescando claves y utilidades base..."
pacman -Sy --noconfirm archlinux-keyring reflector rsync parted btrfs-progs

echo "[+] Configurando mirrors con reflector..."
reflector --country Spain --protocol https --age 12 --sort rate --save /etc/pacman.d/mirrorlist

echo "[✓] Preinstalación completada."
