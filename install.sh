#!/usr/bin/env bash
# install.sh - Instalador simple de mateOS (Hyprland + Wayland) para Arch Linux
# Funciona en VM (VirtualBox/VMware/QEMU) y hardware real.
# - UEFI -> systemd-boot
# - BIOS -> GRUB
# - Drivers CPU/GPU automáticos (incl. VirtualBox Guest)
# - Hyprland + PipeWire + XDG + Qt6-wayland + GTK integrados
# - greetd + tuigreet para login gráfico
# - Log en /var/log/mateos-install.log (durante chroot también)

set -Eeuo pipefail

### UX: log silencioso, pasos visibles, errores en pantalla
LOG_RUNTIME="/tmp/mateos-install.log"
exec > >(awk '{print strftime("[%H:%M:%S]"), $0; fflush() }' | tee -a "$LOG_RUNTIME") 2> >(tee -a "$LOG_RUNTIME" >&2)

title()  { echo; echo "==> $*"; }
step()   { echo "-- $*"; }
fatal()  { echo "[ERROR] $*" >&2; exit 1; }

require() {
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || fatal "Comando requerido no encontrado: $cmd"
  done
}

### Comprobaciones básicas
[ "$(id -u)" -eq 0 ] || fatal "Ejecuta como root (usa sudo)."
require lsblk pacman sgdisk wipefs partprobe mkfs.fat mkfs.ext4 pacstrap
ping -c1 -W2 archlinux.org >/dev/null 2>&1 || step "Aviso: no pude hacer ping; si tienes red, pacman funcionará igualmente."

### Preguntas mínimas
echo
if [ -z "${DISK:-}" ]; then
  read -rp "Disco destino (ej: /dev/nvme0n1 o /dev/sda): " DISK
fi
[ -b "$DISK" ] || fatal "Disco inexistente: $DISK"

if [ -z "${HOSTNAME:-}" ]; then
  read -rp "Hostname (ej: mateos): " HOSTNAME
fi
if [ -z "${USERNAME:-}" ]; then
  read -rp "Usuario (ej: rubrick): " USERNAME
fi
if [ -z "${PASS:-}" ]; then
  read -rsp "Contraseña para $USERNAME: " PASS; echo
  read -rsp "Confirma contraseña: " PASS2; echo
  [ "$PASS" = "$PASS2" ] || fatal "Las contraseñas no coinciden."
fi

if [ -z "${TIMEZONE:-}" ]; then
  read -rp "Zona horaria [Europe/Madrid]: " TIMEZONE
fi
TIMEZONE=${TIMEZONE:-Europe/Madrid}

### Detección entorno (UEFI/BIOS)
if [ -d /sys/firmware/efi/efivars ]; then
  BOOT_MODE="UEFI"
else
  BOOT_MODE="BIOS"
fi
title "Modo de arranque detectado: $BOOT_MODE"

### Particionado rápido (EFI 512M + raíz ext4; swap con zram)
title "Particionando $DISK (se BORRARÁ)"
wipefs -af "$DISK"
sgdisk -Zo "$DISK"

if [ "$BOOT_MODE" = "UEFI" ]; then
  # 1: EFI 512MiB, 2: root resto
  sgdisk -n1:0:+512MiB -t1:ef00 -c1:"EFI System" "$DISK"
  sgdisk -n2:0:0       -t2:8304 -c2:"Arch Linux" "$DISK"
  PART_EFI="${DISK}p1"; PART_ROOT="${DISK}p2"
  # Compat disko naming for /dev/sdX
  [[ -b "${DISK}p1" ]] || { PART_EFI="${DISK}1"; PART_ROOT="${DISK}2"; }
else
  # BIOS: 1: bios_grub 1MiB, 2: root resto
  sgdisk -n1:0:+1MiB -t1:ef02 -c1:"BIOS Boot" "$DISK"
  sgdisk -n2:0:0     -t2:8304 -c2:"Arch Linux" "$DISK"
  PART_ROOT="${DISK}p2"
  [[ -b "${DISK}p2" ]] || PART_ROOT="${DISK}2"
fi

partprobe "$DISK"
sleep 2

### Formateo
title "Formateando particiones"
if [ "$BOOT_MODE" = "UEFI" ]; then
  mkfs.fat -F32 "$PART_EFI"
fi
mkfs.ext4 -F "$PART_ROOT"

### Montaje
title "Montando sistema"
mount "$PART_ROOT" /mnt
mkdir -p /mnt/{boot,efi}
if [ "$BOOT_MODE" = "UEFI" ]; then
  mount "$PART_EFI" /mnt/boot
fi

### Mirrors rápidos (opcional)
step "Actualizando mirrors (opcional)"
pacman -Sy --noconfirm pacman-contrib >/dev/null 2>&1 || true
if command -v rankmirrors >/dev/null 2>&1; then
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak || true
  grep -E '^## Spain|^Server' /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist || true
fi

### Paquetes base
title "Instalando sistema base"
BASE_PKGS=(
  base base-devel linux linux-firmware linux-headers
  mkinitcpio networkmanager sudo vim git curl
  zram-generator
)
# Microcódigo CPU
if lscpu | grep -qi "GenuineIntel"; then BASE_PKGS+=(intel-ucode); fi
if lscpu | grep -qi "AuthenticAMD"; then BASE_PKGS+=(amd-ucode);  fi

pacstrap -K /mnt "${BASE_PKGS[@]}"

### fstab
genfstab -U /mnt >> /mnt/etc/fstab

### Guardar log dentro del nuevo sistema
mkdir -p /mnt/var/log
cp "$LOG_RUNTIME" /mnt/var/log/mateos-install.log || true

### Script de configuración dentro del chroot
cat >/mnt/root/mateos-chroot.sh <<"CHROOT"
#!/usr/bin/env bash
set -Eeuo pipefail

title() { echo; echo "==> $*"; }
step()  { echo "-- $*"; }
fatal() { echo "[ERROR] $*" >&2; exit 1; }

# Cargar variables pasadas por el instalador (escribimos un env file antes de chroot)
source /root/mateos-env.sh

### Zona horaria y reloj
title "Ajustando zona horaria y reloj"
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc || true

### Locale y keymap
title "Configurando locales"
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sed -i 's/^#es_ES.UTF-8/es_ES.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=es_ES.UTF-8" >/etc/locale.conf
echo "KEYMAP=es" >/etc/vconsole.conf

### Hostname y hosts
title "Hostname"
echo "$HOSTNAME" >/etc/hostname
cat >/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

### Red, tiempo
systemctl enable NetworkManager
systemctl enable systemd-timesyncd

### Usuario y sudo
title "Creando usuario"
echo "root:${PASS}" | chpasswd
useradd -m -G wheel,video,audio,input,storage,lp "${USERNAME}"
echo "${USERNAME}:${PASS}" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

### Compresor RAM (zram)
title "Activando zram"
cat >/etc/systemd/zram-generator.conf <<'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF

### Drivers gráficos y utilidades Wayland/Hyprland
title "Detectando GPU e instalando drivers"
GPU_PKGS=(mesa libva-mesa-driver vulkan-icd-loader vulkan-tools)
if lspci | grep -qi "VirtualBox"; then
  GPU_PKGS+=(virtualbox-guest-utils)
  systemctl enable vboxservice.service
fi
if lspci | grep -qi "AMD/ATI"; then
  GPU_PKGS+=(vulkan-radeon)
fi
if lspci | grep -qi "Intel Corporation.*(UHD|Iris|Graphics)"; then
  GPU_PKGS+=(vulkan-intel)
fi
if lspci | grep -qi "NVIDIA"; then
  # Driver propietario (open si disponible)
  GPU_PKGS+=(nvidia nvidia-utils nvidia-settings)
  # Wayland con NVIDIA requiere GBM habilitado en Hyprland, ya viene soportado
fi

PAC_WM=(
  hyprland hypridle hyprlock waybar
  xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-hyprland
  qt6-wayland qt6-ct kde-gtk-config
  gtk3 gtk4 gsettings-desktop-schemas
  pipewire wireplumber pipewire-alsa pipewire-pulse pipewire-jack
  wl-clipboard grim slurp swappy swaybg mako
  wofi kitty nerd-fonts noto-fonts noto-fonts-cjk ttf-jetbrains-mono
  brightnessctl network-manager-applet
  polkit-gnome
  greetd tuigreet
)

pacman -S --noconfirm --needed "${GPU_PKGS[@]}" "${PAC_WM[@]}"

### Configurar greetd + Hyprland (login gráfico)
title "Configurando greetd + Hyprland"
mkdir -p /etc/greetd
cat >/etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --cmd Hyprland"
user = "greeter"
EOF
systemctl enable greetd

### Config base de Hyprland para el usuario
title "Configurando dotfiles mínimos para Hyprland"
USER_HOME="/home/${USERNAME}"
mkdir -p "${USER_HOME}/.config/hypr" "${USER_HOME}/.config/waybar" "${USER_HOME}/.config/wofi" "${USER_HOME}/.config/environment.d"
cat >"${USER_HOME}/.config/hypr/hyprland.conf" <<'EOF'
monitor=,preferred,auto,1
exec-once = dbus-update-activation-environment --systemd --all
exec-once = systemctl --user import-environment
exec-once = waybar
exec-once = nm-applet --indicator
exec-once = mako
input {
  kb_layout = es
}
general {
  gaps_in = 6
  gaps_out = 10
  border_size = 2
}
decoration {
  rounding = 8
  blur = yes
}
EOF

cat >"${USER_HOME}/.config/waybar/config.jsonc" <<'EOF'
{
  "layer": "top",
  "position": "top",
  "modules-left": ["wlr/workspaces"],
  "modules-center": ["clock"],
  "modules-right": ["pulseaudio", "network", "battery", "tray"]
}
EOF

cat >"${USER_HOME}/.config/wofi/config" <<'EOF'
allow_images=true
term=kitty
EOF

# Integración XDG + Qt/Gtk
cat >"${USER_HOME}/.config/environment.d/10-xdg.conf" <<'EOF'
XDG_CURRENT_DESKTOP=Hyprland
XDG_SESSION_TYPE=wayland
GTK_THEME=Adwaita:dark
QT_QPA_PLATFORM=wayland
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
EOF

chown -R "${USERNAME}:${USERNAME}" "${USER_HOME}/.config"

### Bootloader
if [ -d /sys/firmware/efi/efivars ]; then
  title "Instalando systemd-boot (UEFI)"
  bootctl install
  ROOT_UUID=$(blkid -s UUID -o value "$PART_ROOT")
  KERNEL_OPTS="rw root=UUID=${ROOT_UUID} quiet loglevel=3 nowatchdog rd.udev.log_level=3"
  # Microcode:
  MICROCODE=""
  if pacman -Q intel-ucode >/dev/null 2>&1; then MICROCODE="intel-ucode.img"; fi
  if pacman -Q amd-ucode   >/dev/null 2>&1; then MICROCODE="amd-ucode.img";   fi

  mkdir -p /boot/loader/entries
  cat >/boot/loader/loader.conf <<EOF
default arch
timeout 3
editor no
EOF

  cat >/boot/loader/entries/arch.conf <<EOF
title   Arch Linux (mateOS)
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
EOF

  if [ -n "$MICROCODE" ]; then
    sed -i "/initrd  \\/initramfs-linux.img/i initrd  /${MICROCODE}" /boot/loader/entries/arch.conf
  fi
  echo "options ${KERNEL_OPTS}" >> /boot/loader/entries/arch.conf
else
  title "Instalando GRUB (BIOS)"
  pacman -S --noconfirm --needed grub
  grub-install --target=i386-pc "$DISK"
  grub-mkconfig -o /boot/grub/grub.cfg
fi

### mkinitcpio (por si zram requiere compresión)
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect microcode modconf block filesystems keyboard fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

### Fin
title "Configuración en chroot completada"
CHROOT

chmod +x /mnt/root/mateos-chroot.sh

### Pasar variables necesarias al chroot
cat >/mnt/root/mateos-env.sh <<EOF
DISK="$DISK"
PART_ROOT="$PART_ROOT"
TIMEZONE="$TIMEZONE"
HOSTNAME="$HOSTNAME"
USERNAME="$USERNAME"
PASS="$PASS"
EOF

### Ejecutar configuración en chroot
title "Entrando en chroot para configurar el sistema"
arch-chroot /mnt bash /root/mateos-chroot.sh | tee -a "$LOG_RUNTIME"

### Copiar log final dentro del sistema
cp "$LOG_RUNTIME" /mnt/var/log/mateos-install.log || true

### Desmontar y reiniciar
title "Instalación completada. Desmontando y reiniciando..."
umount -R /mnt || true
echo "Puedes reiniciar ahora: 'reboot'"
reboot