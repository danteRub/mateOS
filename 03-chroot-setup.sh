#!/usr/bin/env bash
# 03-chroot-setup.sh - Final system config (inside chroot)

set -e
: "${DISK:?}" "${USERNAME:?}" "${PASSWORD:?}" "${HOSTNAME:?}" "${TIMEZONE:?}" "${KEYMAP:?}"

echo "[+] Instalando sbctl y sddm..."
pacman -Sy --noconfirm sbctl sbsigntools sddm

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

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/^#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER=true/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "[+] Inicializando sbctl..."
sbctl create-keys --esp-path /boot
sbctl enroll-keys --microsoft-no-prompt
sbctl sign -s /boot/vmlinuz-linux || true
sbctl sign -s /boot/EFI/GRUB/grubx64.efi || true

systemctl enable NetworkManager
systemctl enable systemd-timesyncd
systemctl enable sddm
systemctl enable bluetooth 2>/dev/null || true

# Mover dotfiles a la home si existen en /tmp
if [[ -d /tmp/dotfiles && -n "$USERNAME" ]]; then
  mkdir -p "/home/$USERNAME/.dotfiles"
  rsync -a /tmp/dotfiles/ "/home/$USERNAME/.dotfiles/"
  rsync -a /home/$USERNAME/.dotfiles/ "/home/$USERNAME/"
  chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"
fi

echo "[✓] Chroot completado."
