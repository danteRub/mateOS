#!/usr/bin/env bash
set -Eeuo pipefail
source ./env.sh

arch-chroot /mnt bash -e <<'CHROOT'
set -Eeuo pipefail

# ⚠️ Vuelve a definir aquí (no hereda variables del host en heredoc sin export)
HOSTNAME="${HOSTNAME:-mateos}"
TIMEZONE="${TIMEZONE:-Europe/Madrid}"
LOCALE="${LOCALE:-en_US.UTF-8}"
LOCALE2="${LOCALE2:-es_ES.UTF-8}"
KEYMAP="${KEYMAP:-es}"
USERNAME="${USERNAME:-user}"
PASSWORD="${PASSWORD:-changeme}"
ROOT_PW="${ROOT_PW:-root}"
SWAPFILE_SIZE="${SWAPFILE_SIZE:-8G}"

# Locales/zonas
{ echo "en_US.UTF-8 UTF-8"; echo "${LOCALE} UTF-8"; echo "${LOCALE2} UTF-8"; } | sort -u > /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}" > /etc/locale.conf
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf
ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
hwclock --systohc

# Host
echo "${HOSTNAME}" > /etc/hostname
cat >/etc/hosts <<EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

# Servicios base
systemctl enable NetworkManager sshd

# Microcode
if lscpu | grep -qi "GenuineIntel"; then
  pacman -S --noconfirm --needed intel-ucode
elif lscpu | grep -qi "AuthenticAMD"; then
  pacman -S --noconfirm --needed amd-ucode
fi

# GPU
GPU_PKGS=(mesa libva-mesa-driver vulkan-icd-loader)
if lspci | grep -Eqi "VGA.*NVIDIA|3D.*NVIDIA"; then
  GPU_PKGS+=(nvidia nvidia-utils nvidia-settings)
elif lspci | grep -Eqi "VGA.*AMD|3D.*AMD|Display.*AMD"; then
  GPU_PKGS+=(vulkan-radeon)
elif lspci | grep -Eqi "VGA.*Intel|3D.*Intel|Display.*Intel"; then
  GPU_PKGS+=(vulkan-intel intel-media-driver)
fi
pacman -S --noconfirm --needed "\${GPU_PKGS[@]}"

# VM
VIRT="\$(systemd-detect-virt || true)"
case "\$VIRT" in
  oracle) pacman -S --noconfirm --needed virtualbox-guest-utils && systemctl enable vboxservice ;;
  kvm)    pacman -S --noconfirm --needed qemu-guest-agent         && systemctl enable qemu-guest-agent ;;
  vmware) pacman -S --noconfirm --needed open-vm-tools            && systemctl enable vmtoolsd ;;
esac

# Audio/Bluetooth/Avahi
pacman -S --noconfirm --needed pipewire wireplumber pipewire-alsa pipewire-pulse pipewire-jack \
                            bluez bluez-utils avahi nss-mdns
systemctl enable bluetooth avahi-daemon

# Hyprland stack + XDG portals + Qt/GTK
pacman -S --noconfirm --needed \
  hyprland hypridle hyprlock waybar wofi kitty \
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
  qt6-wayland qt6ct kvantum-qt6 qt5ct nwg-look \
  grim slurp wl-clipboard swappy cliphist brightnessctl playerctl pavucontrol \
  network-manager-applet \
  noto-fonts noto-fonts-cjk ttf-jetbrains-mono ttf-noto-nerd

# Login (greetd + tuigreet)
pacman -S --noconfirm --needed greetd tuigreet
systemctl enable greetd
install -d -m755 /etc/greetd
cat >/etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1
[default_session]
command = "tuigreet --time --remember --cmd Hyprland"
user = "greeter"
EOF

# Usuario
useradd -m -G wheel,video,audio,input "\${USERNAME}"
echo "\${USERNAME}:\${PASSWORD}" | chpasswd
echo "root:\${ROOT_PW}" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# Config mínima
install -d -m755 "/home/\${USERNAME}/.config/hypr" "/home/\${USERNAME}/.config/waybar" "/home/\${USERNAME}/.config/wofi"
cat >"/home/\${USERNAME}/.config/hypr/hyprland.conf" <<'EOF'
monitor=,preferred,auto,1
exec-once = wl-paste --watch cliphist store
exec-once = waybar
exec-once = nm-applet
env = XDG_CURRENT_DESKTOP,Hyprland
env = QT_QPA_PLATFORM,wayland
env = QT_QPA_PLATFORMTHEME,qt6ct
env = GDK_BACKEND,wayland
env = XDG_SESSION_TYPE,wayland
env = MOZ_ENABLE_WAYLAND,1
bind = SUPER, Return, exec, kitty
bind = SUPER, D, exec, wofi --show drun
bind = SUPER, Q, killactive,
bind = SUPER, F, fullscreen,
bind = SUPER, V, togglefloating,
EOF

cat >"/home/\${USERNAME}/.config/waybar/config.jsonc" <<'EOF'
{
  "layer": "top",
  "position": "top",
  "modules-left": ["workspaces", "window"],
  "modules-center": ["clock"],
  "modules-right": ["pulseaudio", "network", "battery", "tray"],
  "clock": { "format": "{:%Y-%m-%d %H:%M}" }
}
EOF

cat >"/home/\${USERNAME}/.config/waybar/style.css" <<'EOF'
* { font-family: "JetBrainsMono Nerd Font", "Noto Sans"; font-size: 12pt; }
window { background: transparent; }
#workspaces button.focused { border-bottom: 2px solid #89b4fa; }
EOF

# XDG env centralizado
mkdir -p /etc/environment.d
cat >/etc/environment.d/90-wayland.conf <<'EOF'
XDG_CURRENT_DESKTOP=Hyprland
XDG_SESSION_TYPE=wayland
GDK_BACKEND=wayland
QT_QPA_PLATFORM=wayland
QT_QPA_PLATFORMTHEME=qt6ct
MOZ_ENABLE_WAYLAND=1
EOF

# Swapfile en BTRFS
btrfs filesystem mkswapfile --size "\${SWAPFILE_SIZE}" /swapfile
chmod 600 /swapfile
mkswap /swapfile
echo '/swapfile none swap defaults 0 0' >> /etc/fstab

# mkinitcpio
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect microcode modconf kms keyboard keymap block filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

# systemd-boot
bootctl install
ROOT_UUID="\$(blkid -s UUID -o value "\$(findmnt -no SOURCE /)")"
MICROCODE_IMG=""
if pacman -Q intel-ucode >/dev/null 2>&1; then MICROCODE_IMG="/intel-ucode.img"; fi
if pacman -Q amd-ucode   >/dev/null 2>&1; then MICROCODE_IMG="/amd-ucode.img"; fi

cat >/boot/loader/loader.conf <<'EOF'
default arch
timeout 3
console-mode max
editor no
EOF

cat >/boot/loader/entries/arch.conf <<EOF
title   Arch Linux (mateOS)
linux   /vmlinuz-linux
initrd  ${MICROCODE_IMG}
initrd  /initramfs-linux.img
options root=UUID=${ROOT_UUID} rootflags=subvol=@ rw quiet splash loglevel=3 nowatchdog
EOF

# mDNS
sed -i 's/^hosts:.*/hosts: files mdns_minimal [NOTFOUND=return] resolve myhostname dns/' /etc/nsswitch.conf

# Permisos de HOME
chown -R "\${USERNAME}:\${USERNAME}" "/home/\${USERNAME}"
CHROOT
