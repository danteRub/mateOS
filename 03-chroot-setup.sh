#!/usr/bin/env bash
# 03-chroot-setup.sh — Configuración final dentro del chroot (GRUB universal)

set -euo pipefail
: "${DISK:?}" "${USERNAME:?}" "${PASSWORD:?}" "${HOSTNAME:?}" "${TIMEZONE:?}" "${KEYMAP:?}"

echo "[+] Zona horaria y locales…"
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc

grep -qxF 'en_US.UTF-8 UTF-8' /etc/locale.gen || echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
grep -qxF 'es_ES.UTF-8 UTF-8' /etc/locale.gen || echo 'es_ES.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
echo "LANG=es_ES.UTF-8" > /etc/locale.conf
echo "KEYMAP=$KEYMAP"   > /etc/vconsole.conf

echo "$HOSTNAME" > /etc/hostname
cat >/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF

echo "[+] Usuario y sudo…"
id -u "$USERNAME" >/dev/null 2>&1 || useradd -m -G wheel -s /bin/zsh "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "[+] Microcode…"
if lscpu | grep -qi 'GenuineIntel'; then
  pacman -S --noconfirm --needed intel-ucode
elif lscpu | grep -qi 'AuthenticAMD'; then
  pacman -S --noconfirm --needed amd-ucode
fi

echo "[+] Drivers GPU…"
GPU_PKGS="mesa"
if lspci | grep -Eqi 'VGA.*NVIDIA|3D.*NVIDIA'; then
  GPU_PKGS="$GPU_PKGS nvidia nvidia-utils nvidia-settings"
elif lspci | grep -Eqi 'VGA.*AMD|3D.*AMD'; then
  GPU_PKGS="$GPU_PKGS vulkan-radeon"
elif lspci | grep -Eqi 'VGA.*Intel|3D.*Intel'; then
  GPU_PKGS="$GPU_PKGS vulkan-intel intel-media-driver"
else
  GPU_PKGS="$GPU_PKGS xf86-video-vesa"
fi
# shellcheck disable=SC2086
pacman -S --noconfirm --needed $GPU_PKGS

echo "[+] Entorno virtualizado…"
VIRT="$(systemd-detect-virt || true)"
case "$VIRT" in
  oracle) pacman -S --noconfirm --needed virtualbox-guest-utils && systemctl enable vboxservice ;;
  kvm)    pacman -S --noconfirm --needed qemu-guest-agent       && systemctl enable qemu-guest-agent ;;
  vmware) pacman -S --noconfirm --needed open-vm-tools          && systemctl enable vmtoolsd ;;
  *) : ;;
esac

echo "[+] GRUB (compatibilidad universal)…"
# Herramientas necesarias
pacman -S --noconfirm --needed grub efibootmgr os-prober

# UEFI si existe firmware EFI; si no, BIOS/Legacy
if [ -d /sys/firmware/efi/efivars ]; then
  # Asegúrate de que la EFI (FAT32 ~512MiB) esté montada en /boot
  mountpoint -q /boot || { echo "[-] /boot no está montado (EFI). Monta tu partición EFI en /boot y reintenta."; exit 1; }
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
else
  # Instalación BIOS al disco completo
  grub-install --target=i386-pc "$DISK" --recheck
fi

# Habilitar detección de otros SOs
sed -i 's/^#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' /etc/default/grub
grep -q '^GRUB_DISABLE_OS_PROBER' /etc/default/grub || echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub
# Arranque rápido
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub || echo 'GRUB_TIMEOUT=1' >> /etc/default/grub

os-prober || true
grub-mkconfig -o /boot/grub/grub.cfg

echo "[+] Servicios…"
systemctl enable NetworkManager systemd-timesyncd
# Display manager (SDDM) — puedes cambiar a greetd si prefieres
pacman -S --noconfirm --needed sddm
systemctl enable sddm
systemctl enable bluetooth 2>/dev/null || true

echo "[+] Entorno Wayland recomendado…"
mkdir -p /etc/environment.d
cat >/etc/environment.d/90-wayland.conf <<'EOF'
XDG_SESSION_TYPE=wayland
XDG_CURRENT_DESKTOP=Hyprland
GDK_BACKEND=wayland
QT_QPA_PLATFORM=wayland
QT_QPA_PLATFORMTHEME=qt6ct
MOZ_ENABLE_WAYLAND=1
EOF

echo "[✓] Chroot listo. Puedes salir y reiniciar."
