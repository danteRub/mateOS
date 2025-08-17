# mateOS Arch Installer (Hyprland Edition)

## Uso rápido

```bash
pacman -Sy --noconfirm git
git clone https://github.com/danteRub/mateOS
cd mateOS
# Opción A: Sin interacción (define variables)
DISK=/dev/nvme0n1 HOSTNAME=mateos USERNAME=rubrick PASSWORD='tuPass' \
ROOT_PW='root' TIMEZONE=Europe/Madrid KEYMAP=es \
LOCALE=en_US.UTF-8 LOCALE2=es_ES.UTF-8 \
./install.sh

# Opción B: Semi-guiado (usa gum si está disponible)
./install.sh
```

Este instalador usa una partición ext4 para la raíz y habilita
swap mediante zram.
El soporte para Btrfs y swapfile aún no está implementado.
