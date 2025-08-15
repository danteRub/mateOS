#!/usr/bin/env bash
# 03-chroot-setup.sh - Configuración final dentro del chroot con auto-detección de drivers

set -e
: "${DISK:?}" "${USERNAME:?}" "${PASSWORD:?}" "${HOSTNAME:?}" "${TIMEZONE:?}" "${KEYMAP:?}"

pkg_add=()

echo "[+] Zona horaria/locale/host..."
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc

# Locales (activar es_ES.UTF-8 y en_US.UTF-8 como fallback)
sed -i 's/^#\(es_ES.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo "LANG=es_ES.UTF-8" > /etc/locale.conf
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF

echo "[+] Usuario y sudo..."
useradd -m -G wheel -s /bin/zsh "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# -------------------------------
# DETECCIÓN DE HARDWARE Y DRIVERS
# -------------------------------
echo "[+] Detectando microcode..."
if grep -qi "GenuineIntel" /proc/cpuinfo; then
  pkg_add+=(intel-ucode)
elif grep -qi "AuthenticAMD" /proc/cpuinfo; then
  pkg_add+=(amd-ucode)
fi

echo "[+] Detectando GPU..."
if lspci -nnk | grep -E "VGA|3D" | grep -qi nvidia; then
  pkg_add+=(nvidia nvidia-utils nvidia-settings)
elif lspci -nnk | grep -E "VGA|3D" | grep -qi "AMD\|ATI\|Radeon"; then
  pkg_add+=(vulkan-radeon libva-mesa-driver mesa-vdpau)
elif lspci -nnk | grep -E "VGA|3D" | grep -qi "Intel"; then
  pkg_add+=(vulkan-intel intel-media-driver)
fi

echo "[+] Detectando Wi‑Fi..."
if lspci -nnk | grep -qi "Network controller.*Wireless\|Wi-Fi\|WLAN"; then
  # Usaremos iwd como backend de NM, sin instalar “atheros/broadcom” genéricos
  pkg_add+=(iwd)
  mkdir -p /etc/NetworkManager/conf.d
  cat > /etc/NetworkManager/conf.d/wifi_backend.conf <<'NM'
[device]
wifi.backend=iwd
NM
fi

echo "[+] Detectando Bluetooth..."
if lsusb | grep -qi bluetooth || dmesg | grep -qi bluetooth; then
  pkg_add+=(bluez bluez-utils)
fi

echo "[+] Detectando virtualización..."
virt=$(systemd-detect-virt || true)
case "$virt" in
  oracle)       pkg_add+=(virtualbox-guest-utils);   systemctl enable vboxservice.service ;;
  kvm|qemu)     pkg_add+=(qemu-guest-agent spice-vdagent); systemctl enable qemu-guest-agent.service ;;
  vmware)       pkg_add+=(open-vm-tools);            systemctl enable vmtoolsd.service ;;
  microsoft)    : ;;  # Hyper-V: módulos en el kernel; no añadimos paquetes pesados
esac

# Instalar lo detectado
if ((${#pkg_add[@]})); then
  echo "[+] Instalando paquetes detectados: ${pkg_add[*]}"
  pacman -S --noconfirm --needed "${pkg_add[@]}"
fi

# -------------------------------
# BOOTLOADER + SECURE BOOT (GRUB)
# -------------------------------
echo "[+] Instalando sbctl y sddm..."
pacman -Sy --noconfirm sbctl sbsigntools sddm

# GRUB EFI (mantengo tu enfoque original)
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/^#GRUB_DISABLE_OS_PROBER.*/GRUB_DISABLE_OS_PROBER=true/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "[+] Secure Boot con sbctl..."
sbctl create-keys --esp-path /boot || true
sbctl enroll-keys --microsoft-no-prompt || true
sbctl sign -s /boot/vmlinuz-linux || true
sbctl sign -s /boot/EFI/GRUB/grubx64.efi || true

# -------------------------------
# Servicios y Wayland
# -------------------------------
systemctl enable NetworkManager
systemctl enable systemd-timesyncd
systemctl enable sddm
systemctl enable bluetooth 2>/dev/null || true
systemctl enable seatd 2>/dev/null || true

# SDDM → Hyprland por defecto (sesión Wayland)
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/10-wayland.conf <<'SDDM'
[General]
DisplayServer=wayland

[Autologin]
#Session=hyprland.desktop

[Wayland]
CompositorCommand=/usr/bin/kwin_wayland # sddm requiere un compositor; omite si no quieres KWin
SessionDir=/usr/share/wayland-sessions
Session=hyprland.desktop
SDDM

# Grupos para Wayland/libseat/hardware
usermod -aG wheel,video,audio,input,seat "$USERNAME" || true

# Directorios de usuario
pacman -S --noconfirm --needed xdg-user-dirs
runuser -l "$USERNAME" -c 'xdg-user-dirs-update' || true

echo "[✓] Chroot completado."
