#!/usr/bin/env bash
set -Eeuo pipefail
source ./env.sh

need(){ command -v "$1" >/dev/null 2>&1 || { echo "Falta $1"; exit 1; }; }
need lsblk; need awk; need sed; need sfdisk; need mkfs.fat; need btrfs; need pacman

[[ -d /sys/firmware/efi/efivars ]] || { echo "Se requiere UEFI."; exit 1; }

# --- Comprobación de conectividad robusta (sin ICMP) ---
have_net() {
  # 1) ¿Tenemos ruta por defecto?
  ip route show default >/dev/null 2>&1 || return 1
  # 2) ¿Salimos a Internet por TCP?
  command -v curl >/dev/null 2>&1 && \
    curl -s --connect-timeout 5 https://1.1.1.1 >/dev/null && return 0
  # 3) Si no hay curl, probamos con pacman a refrescar solo sincronización (rápido)
  pacman -Sy --noconfirm >/dev/null 2>&1 && return 0
  return 1
}

if ! have_net; then
  echo "[-] No se pudo verificar conectividad por HTTP/TCP (ICMP puede estar bloqueado)."
  echo "    Revisa que haya ruta por defecto y DNS. Continuar puede fallar."
  # No abortamos: deja seguir para casos con mirrors locales/caché.
fi

# Hora y keyring/mirrors
timedatectl set-ntp true || true
pacman -Sy --noconfirm archlinux-keyring
