#!/usr/bin/env bash
set -Eeuo pipefail
source ./env.sh

need(){ command -v "$1" >/dev/null 2>&1 || { echo "Falta $1"; exit 1; }; }

need lsblk; need awk; need sed; need sfdisk; need mkfs.fat; need btrfs; need pacman

[[ -d /sys/firmware/efi/efivars ]] || { echo "Se requiere UEFI."; exit 1; }
ping -c1 archlinux.org >/dev/null 2>&1 || { echo "Sin internet."; exit 1; }

# Hora
timedatectl set-ntp true || true

# Keyring + mirrors
pacman -Sy --noconfirm archlinux-keyring
