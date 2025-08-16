# mateOS Arch Installer (Hyprland Edition)

## Uso rápido
```bash
pacman -Sy --noconfirm git
git clone https://github.com/danteRub/mateOS
cd mateOS
# Opción A: Sin interacción (define variables)
DISK=/dev/nvme0n1 HOSTNAME=mateos USERNAME=rubrick PASSWORD='tuPass' ROOT_PW='root' \
TIMEZONE=Europe/Madrid KEYMAP=es LOCALE=en_US.UTF-8 LOCALE2=es_ES.UTF-8 \
BTRFS_COMPRESSION=zstd SWAPFILE_SIZE=8G \
./install.sh

# Opción B: Semi-guiado (usa gum si está disponible)
./install.sh
