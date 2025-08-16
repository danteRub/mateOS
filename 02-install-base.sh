#!/usr/bin/env bash
# 02-install-base.sh - Instalación del sistema base con Hyprland (mínimo y limpio)

set -e
: "${DISK:?}" "${USERNAME:?}" "${PASSWORD:?}" "${HOSTNAME:?}" "${TIMEZONE:?}" "${KEYMAP:?}"

# Habilitar multilib si es necesario
sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

# Detección de virtualización para instalar guest-additions correctas
VIRT="$(systemd-detect-virt || true)"
VIRT_PKGS=()
case "$VIRT" in
  oracle)   VIRT_PKGS+=(virtualbox-guest-utils) ;;   # VirtualBox
  kvm|qemu) VIRT_PKGS+=(qemu-guest-agent spice-vdagent) ;;
  vmware)   VIRT_PKGS+=(open-vm-tools) ;;
  microsoft) VIRT_PKGS+=(hyperv) ;;
esac

echo "[+] Instalando sistema base mínimo..."
pacstrap -K /mnt base linux linux-firmware linux-headers btrfs-progs \
  networkmanager grub efibootmgr sudo zsh git curl vim ${VIRT_PKGS[@]}

echo "[+] Instalando entorno gráfico Hyprland (Wayland only, sin X11)..."
pacstrap -K /mnt \
  hyprland waybar wofi alacritty \
  pipewire wireplumber pavucontrol pamixer \
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-utils \
  ttf-jetbrains-mono-nerd starship \
  polkit-gnome brightnessctl grim slurp wl-clipboard \
  thunar file-roller \
  gtk3 gtk4 qt5ct qt6ct kvantum-qt5 lxappearance libinput libseat seatd keepassxc

# Eliminar paquetes huérfanos que pacstrap añadió como dependencias opcionales
arch-chroot /mnt pacman -Rns --noconfirm $(arch-chroot /mnt pacman -Qdtq) || true

# Crear fstab
genfstab -U /mnt >> /mnt/etc/fstab

echo "[✓] Sistema base instalado sin paquetes extra innecesarios."