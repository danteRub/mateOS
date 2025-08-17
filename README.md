# mateOS Arch Installer (Hyprland Edition)

## Uso rápido
Las variables de entorno `DISK`, `HOSTNAME`, `USERNAME`, `PASS` y `TIMEZONE` permiten
ejecutar el instalador sin preguntas.
```bash
pacman -Sy --noconfirm git
git clone https://github.com/danteRub/mateOS
cd mateOS
# Opción A: Sin interacción (define variables)
DISK=/dev/nvme0n1 HOSTNAME=mateos USERNAME=rubrick PASS='tuPass' TIMEZONE=Europe/Madrid \
./install.sh

# Opción B: Interactivo
./install.sh
```
