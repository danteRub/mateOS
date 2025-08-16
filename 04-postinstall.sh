#!/usr/bin/env bash
set -Eeuo pipefail
source ./env.sh

# Si existe carpeta ./dotfiles en el repo, copiala al HOME del usuario
if [[ -d "./dotfiles" ]]; then
  echo "[i] Copiando dotfiles al nuevo sistema..."
  rsync -a --chown=1000:1000 ./dotfiles/ /mnt/home/${USERNAME}/
fi

echo "[i] Sincronizando y desmontando..."
sync
umount -R /mnt || true
