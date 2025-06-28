#!/usr/bin/env bash
# bootstrap.sh – instalador remoto de Arch Linux (mateOS)

set -e

REPO="https://github.com/danteRub/mateOS"
BRANCH="main"

echo "[+] Clonando el repositorio de instalación mateOS..."
pacman -Sy --noconfirm git
git clone --depth 1 --branch "$BRANCH" "$REPO" installer
cd installer
chmod +x *.sh
./install.sh
