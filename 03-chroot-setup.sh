#!/usr/bin/env bash
# 03-chroot-setup.sh - Final system config (inside chroot)

set -euo pipefail

: "${USERNAME:?}" "${PASSWORD:?}" "${HOSTNAME:?}" "${TIMEZONE:?}" "${KEYMAP:?}"

echo "[+] Zona horaria y locales…"
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc

# Locales
grep -qxF 'en_US.UTF-8 UTF-8' /etc/locale.gen || echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
grep -qxF 'es_ES.UTF-8 UTF-8' /etc/locale.gen || echo 'es_ES.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
echo "LANG=es_ES.UTF-8" > /etc/locale.conf
echo "KEYMAP=$KEYMAP"   > /etc/vconsole.conf

# Host
echo "$HOSTNAME" > /etc/hostname
cat >/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF

# Usuario + sudo
useradd -m -G wheel -s /bin/zsh "$USERNAME" || true
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD"       | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Microcode
echo "[+] Microcode…"
if lscpu | grep -qi 'GenuineIntel'; then
  pacman -S --noconfirm --needed intel-ucode
elif lscpu | grep -qi 'AuthenticAMD'; then
  pacman -S --noconfirm --needed amd-ucode
fi

# Drivers GPU (cadena simple, sin arrays)
echo "[+] GPU…"
GPU_PKGS="mesa"
if lspci | grep -Eqi 'VGA.*NVIDIA|3D.*NVIDIA'; then
  echo " -> NVIDIA"
  GPU_PKGS="$GPU_PKGS nvidia nvidia-utils nvidia-settings"
elif lspci | grep -Eqi 'VGA.*AMD|3D.*AMD'; then
  echo " -> AMD"
  GPU_PKGS="$GPU_PKGS vulkan-radeon"
elif lspci | grep -Eqi 'VGA.*Intel|3D.*Intel'; then
  echo " -> Intel"
  GPU_PKGS="$GPU_PKGS vulkan-intel intel-media-driver"
else
  echo " -> Fallback (vesa)"
  GPU_PKGS="$GPU_PKGS xf86-video-vesa"
fi
# ejecuta con expansión normal (no comillas) para no romper la lista
# shellcheck disable=SC2086
pacman -S --noconfirm --needed $GPU_PKGS

# Detección VM
echo "[+] Virtualización…"
VIRT="$(systemd-detect-virt || true)"
case "$VIRT" in
  oracle) pacman -S --noconfirm --needed virtualbox-guest-utils && systemctl enable vboxservice ;;
  kvm)    pacman -S --noconfirm --needed qemu-guest-agent       && systemctl enable qemu-guest-agent ;;
  vmware) pacman -S --noconfirm --needed open-vm-tools          && systemctl enable vmtoolsd ;;
  *)      : ;;
esac

# Bootloader + Secure Boot
echo "[+] GRUB + sbctl…"
pacman -S --noconfirm --needed grub efibootmgr sbctl sbsigntools
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/^#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER=true/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

sbctl create-keys --esp-path /boot || true
sbctl enroll-keys --microsoft-no-prompt || true
sbctl sign -s /boot/vmlinuz-linux      || true
sbctl sign -s /boot/EFI/GRUB/grubx64.efi || true

# Servicios
systemctl enable NetworkManager systemd-timesyncd sddm
systemctl enable bluetooth 2>/dev/null || true

# Entorno Wayland recomendado
mkdir -p /etc/environment.d
cat >/etc/environment.d/90-wayland.conf <<'EOF'
XDG_SESSION_TYPE=wayland
XDG_CURRENT_DESKTOP=Hyprland
GDK_BACKEND=wayland
QT_QPA_PLATFORM=wayland
QT_QPA_PLATFORMTHEME=qt6ct
MOZ_ENABLE_WAYLAND=1
EOF

echo "[✓] Chroot listo."
