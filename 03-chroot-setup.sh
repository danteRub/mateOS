#!/usr/bin/env bash
# 03-chroot-setup.sh - Final system config (inside chroot)

set -e
: "${DISK:?}" "${USERNAME:?}" "${PASSWORD:?}" "${HOSTNAME:?}" "${TIMEZONE:?}" "${KEYMAP:?}"

echo "[+] Configurando zona horaria y locales..."
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=es_ES.UTF-8" > /etc/locale.conf
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

echo "$HOSTNAME" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF

echo "[+] Creando usuario..."
useradd -m -G wheel -s /bin/zsh "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "[+] Instalando microcode..."
if lscpu | grep -qi "GenuineIntel"; then
  pacman -S --noconfirm intel-ucode
elif lscpu | grep -qi "AuthenticAMD"; then
  pacman -S --noconfirm amd-ucode
fi

echo "[+] Detectando GPU..."
GPU_PKGS=(mesa)
if lspci | grep -Eqi "VGA.*NVIDIA|3D.*NVIDIA"; then
  echo " -> NVIDIA detectada"
  GPU_PKGS+=(nvidia nvidia-utils nvidia-settings)
elif lspci | grep -Eqi "VGA.*AMD|3D.*AMD"; then
  echo " -> AMD detectada"
  GPU_PKGS+=(vulkan-radeon)
elif lspci | grep -Eqi "VGA.*Intel|3D.*Intel"; then
  echo " -> Intel detectada"
  GPU_PKGS+=(vulkan-intel intel-media-driver)
else
  echo " -> No se detectó GPU conocida, instalando fallback (vesa + mesa)"
  GPU_PKGS+=(xf86-video-vesa)
fi
pacman -S --noconfirm --needed "${GPU_PKGS[@]}"

echo "[+] Detectando entorno de virtualización..."
VIRT=$(systemd-detect-virt || true)
case "$VIRT" in
  oracle)  echo "[*] VirtualBox detectado"; pacman -S --noconfirm virtualbox-guest-utils && systemctl enable vboxservice ;;
  kvm)     echo "[*] KVM/QEMU detectado";   pacman -S --noconfirm qemu-guest-agent && systemctl enable qemu-guest-agent ;;
  vmware)  echo "[*] VMware detectado";     pacman -S --noconfirm open-vm-tools && systemctl enable vmtoolsd ;;
  none)    echo "[*] Instalación en hardware físico" ;;
  *)       echo "[*] Virtualización desconocida: $VIRT" ;;
esac

echo "[+] Instalando bootloader (GRUB + sbctl Secure Boot)..."
pacman -S --noconfirm sbctl sbsigntools grub efibootmgr

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/^#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER=true/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "[+] Inicializando sbctl..."
sbctl create-keys --esp-path /boot
sbctl enroll-keys --microsoft-no-prompt
sbctl sign -s /boot/vmlinuz-linux || true
sbctl sign -s /boot/EFI/GRUB/grubx64.efi || true

echo "[+] Habilitando servicios..."
systemctl enable NetworkManager
systemctl enable systemd-timesyncd
systemctl enable sddm
systemctl enable bluetooth 2>/dev/null || true

echo "[✓] Configuración en chroot completada."
