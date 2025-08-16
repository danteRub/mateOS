#!/usr/bin/env bash
# bootstrap.sh - Ejecuta los pasos en orden
set -Eeuo pipefail
source ./env.sh

./00-preinstall.sh
./01-disk-setup.sh
./02-install-base.sh
./03-chroot-setup.sh
./04-postinstall.sh

echo "✅ Instalación finalizada. Reinicia con:  reboot"
echo "Usuario: $USERNAME  |  Pass: $PASSWORD"
echo "Root:    $ROOT_PW"
