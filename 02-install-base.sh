#!/usr/bin/env bash
# 02-install-base.sh - Instalación del sistema base con Hyprland (mínimo y limpio)

set -e
: "${DISK:?}" "${USERNAME:?}" "${PASSWORD:?}" "${HOSTNAME:?}" "${TIMEZONE:?}" "${KEYMAP:?}"

# Habilitar multilib si es necesario
sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

# === IMPORTANTE: redirigir caché y BD de pacman del LIVE al disco destino ===
mkdir -p /mnt/var/cache/pacman/pkg /mnt/var/lib/pacman
mountpoint -q /var/cache/pacman/pkg || mount --bind /mnt/var/cache/pacman/pkg /var/cache/pacman/pkg
mountpoint -q /var/lib/pacman       || mount --bind /mnt/var/lib/pacman       /var/lib/pacman
# Limpia caché del live por si quedó lleno
pacman -Scc --noconfirm || true

echo "[+] Instalando sistema base..."
pacstrap -K /mnt base linux linux-firmware linux-headers \
  btrfs-progs networkmanager grub efibootmgr sudo zsh git curl vim

echo "[+] Instalando entorno Hyprland..."
pacstrap -K /mnt \
  hyprland waybar wofi alacritty \
  pipewire wireplumber pavucontrol pamixer \
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-utils \
  polkit-gnome brightnessctl grim slurp wl-clipboard \
  thunar file-roller \
  gtk3 gtk4 qt5ct qt6ct kvantum-qt5 lxappearance \
  libinput \
  noto-fonts noto-fonts-cjk ttf-jetbrains-mono ttf-nerd-fonts-symbols

# Eliminar huérfanos si los hubiera
if arch-chroot /mnt pacman -Qdtq >/dev/null 2>&1; then
  arch-chroot /mnt pacman -Rns --noconfirm $(arch-chroot /mnt pacman -Qdtq) || true
fi

# fstab
genfstab -U /mnt >> /mnt/etc/fstab

echo "[✓] Base instalada."
