#!/usr/bin/env bash
# 02-install-base.sh - Instalación del sistema base con Hyprland (mínimo y limpio)
set -e
: "${DISK:?}" "${USERNAME:?}" "${PASSWORD:?}" "${HOSTNAME:?}" "${TIMEZONE:?}" "${KEYMAP:?}"

# Habilitar multilib
sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

echo "[+] Instalando sistema base mínimo..."
pacstrap -K /mnt \
  base base-devel linux linux-headers linux-firmware \
  btrfs-progs networkmanager efibootmgr sudo zsh git curl vim rsync \
  mesa vulkan-icd-loader

echo "[+] Entorno gráfico Hyprland (Wayland puro, sin X11 pesado)..."
pacstrap -K /mnt \
  hyprland waybar wofi alacritty \
  pipewire wireplumber pavucontrol pamixer \
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-utils \
  ttf-jetbrains-mono-nerd starship \
  polkit-gnome brightnessctl grim slurp wl-clipboard \
  thunar file-roller \
  gtk3 gtk4 qt5ct qt6ct kvantum-qt5 kvantum \
  libinput libseat seatd \
  keepassxc

# fstab
genfstab -U /mnt >> /mnt/etc/fstab

echo "[✓] Sistema base instalado sin drivers extra innecesarios."
