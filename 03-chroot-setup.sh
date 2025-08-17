#!/usr/bin/env bash
# 03-chroot-setup.sh - Final system config (inside chroot)

set -e
: "${DISK:?}" "${USERNAME:?}" "${PASSWORD:?}" "${HOSTNAME:?}" "${TIMEZONE:?}" "${KEYMAP:?}"

echo "[+] Instalando sddm..."
pacman -Sy --noconfirm sddm

ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc

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

useradd -m -G wheel -s /bin/zsh "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# ---- Guest additions y servicios según virtualización ----
VIRT="$(systemd-detect-virt || true)"
case "$VIRT" in
  oracle)  # VirtualBox
    pacman -S --noconfirm --needed virtualbox-guest-utils
    systemctl enable vboxservice.service
    # Módulos y grupo para carpetas compartidas
    install -Dm644 /dev/stdin /etc/modules-load.d/virtualbox.conf <<'EOM'
vboxguest
vboxsf
vboxvideo
EOM
    gpasswd -a "$USERNAME" vboxsf || true
    ;;
  kvm|qemu)
    pacman -S --noconfirm --needed qemu-guest-agent spice-vdagent
    systemctl enable qemu-guest-agent.service
    ;;
  vmware)
    pacman -S --noconfirm --needed open-vm-tools
    systemctl enable vmtoolsd.service
    ;;
  microsoft)
    pacman -S --noconfirm --needed hyperv
    systemctl enable hv_fcopy_daemon.service hv_kvp_daemon.service hv_vss_daemon.service || true
    ;;
esac
# ---------------------------------------------------------

if [ -d /sys/firmware/efi ]; then
  echo "[+] Entorno UEFI detectado: instalando sbctl..."
  pacman -Sy --noconfirm sbctl sbsigntools
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

  echo "[+] Inicializando sbctl..."
  sbctl create-keys --esp-path /boot
  sbctl enroll-keys --microsoft-no-prompt
  sbctl sign -s /boot/vmlinuz-linux || true
  sbctl sign -s /boot/EFI/GRUB/grubx64.efi || true
else
  echo "[+] Entorno BIOS detectado"
  grub-install --target=i386-pc "$DISK"
fi

sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/^#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER=true/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable systemd-timesyncd
systemctl enable sddm
systemctl enable bluetooth 2>/dev/null || true

echo "[✓] Chroot completado."
