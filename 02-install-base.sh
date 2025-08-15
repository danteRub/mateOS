#!/usr/bin/env bash
# 02-install-base.sh - Instalación del sistema base con Hyprland (mínimo y limpio)

set -e
: "${DISK:?}" "${USERNAME:?}" "${PASSWORD:?}" "${HOSTNAME:?}" "${TIMEZONE:?}" "${KEYMAP:?}"

# Habilitar multilib si es necesario
sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

echo "[+] Instalando sistema base mínimo..."
pacstrap -K /mnt \
  base linux linux-firmware linux-headers \
  btrfs-progs networkmanager grub efibootmgr sudo zsh git curl vim

echo "[+] Instalando entorno gráfico Hyprland (Wayland only, sin X11)..."
pacstrap -K /mnt \
  hyprland waybar wofi alacritty \
  pipewire wireplumber pavucontrol pamixer \
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-utils \
  ttf-jetbrains-mono-nerd starship \
  polkit-gnome brightnessctl grim slurp wl-clipboard \
  thunar file-roller \
  gtk3 gtk4 qt5ct qt6ct kvantum-qt5 lxappearance \
  libinput seatd \
  keepassxc

# (Opcional) limpiar huérfanos si los hubiera
arch-chroot /mnt pacman -Rns --noconfirm $(arch-chroot /mnt pacman -Qdtq) || true

# Crear fstab
genfstab -U /mnt >> /mnt/etc/fstab

echo "[✓] Sistema base instalado sin paquetes extra innecesarios."
