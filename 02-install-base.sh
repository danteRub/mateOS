#!/usr/bin/env bash
# 02-install-base.sh - Install base system and Hyprland

set -e
: "${DISK:?}" "${USERNAME:?}" "${PASSWORD:?}" "${HOSTNAME:?}" "${TIMEZONE:?}" "${KEYMAP:?}"

sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
pacman -Sy

echo "[+] Instalando base del sistema..."
pacstrap -K /mnt base linux linux-firmware linux-headers btrfs-progs networkmanager grub efibootmgr sudo zsh git curl vim

echo "[+] Instalando entorno gráfico Hyprland (Wayland-only)..."
pacstrap -K /mnt \
  hyprland waybar wofi alacritty \
  xdg-desktop-portal-hyprland xdg-utils \
  ttf-jetbrains-mono-nerd starship \
  pipewire wireplumber pavucontrol

genfstab -U /mnt >> /mnt/etc/fstab
echo "[✓] Sistema base instalado."
