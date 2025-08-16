#!/usr/bin/env bash
# install.sh - Wrapper principal (no requiere interacción si exportas variables)
set -Eeuo pipefail

# ===== Variables por defecto (puedes sobreescribirlas por entorno) =====
: "${DISK:=}"                         # ej: /dev/nvme0n1
: "${HOSTNAME:=mateos}"
: "${USERNAME:=user}"
: "${PASSWORD:=changeme}"
: "${ROOT_PW:=root}"
: "${TIMEZONE:=Europe/Madrid}"
: "${KEYMAP:=es}"
: "${LOCALE:=en_US.UTF-8}"
: "${LOCALE2:=es_ES.UTF-8}"
: "${BTRFS_COMPRESSION:=zstd}"
: "${SWAPFILE_SIZE:=8G}"

# ===== Soporte opcional de interfaz con 'gum' si no pasas DISK o USERNAME =====
if ! command -v gum >/dev/null 2>&1; then
  pacman -Sy --noconfirm gum || true
fi

detect_single_disk() {
  lsblk -dpno NAME,TYPE,TRAN | awk '$2=="disk" && $3!="usb"{print $1}'
}

if [[ -z "${DISK}" ]]; then
  CANDS=($(detect_single_disk))
  if [[ "${#CANDS[@]}" -eq 1 ]]; then
    DISK="${CANDS[0]}"
  elif command -v gum >/dev/null 2>&1; then
    DISK=$(printf "%s\n" "${CANDS[@]}" | gum choose --limit=1 --selected="${CANDS[0]:-}")
  fi
fi

[[ -n "${DISK}" ]] || { echo "[-] Define DISK=/dev/xxx"; exit 1; }

# Si falta usuario/host/passes y hay gum, pedirlos
if command -v gum >/dev/null 2>&1; then
  USERNAME=${USERNAME:-$(gum input --placeholder "usuario" --prompt "Nombre de usuario:")}
  PASSWORD=${PASSWORD:-$(gum input --password --prompt "Contraseña para ${USERNAME}:")}
  ROOT_PW=${ROOT_PW:-$(gum input --password --prompt "Contraseña para root:")}
  HOSTNAME=${HOSTNAME:-$(gum input --placeholder "mateos" --prompt "Hostname:")}
  TIMEZONE=${TIMEZONE:-$(gum input --placeholder "Europe/Madrid" --prompt "Zona horaria:")}
  KEYMAP=${KEYMAP:-$(gum input --placeholder "es" --prompt "Keymap:")}
fi

# Guardar entorno común para los sub-scripts
cat > env.sh <<EOF
export DISK="${DISK}"
export HOSTNAME="${HOSTNAME}"
export USERNAME="${USERNAME}"
export PASSWORD="${PASSWORD}"
export ROOT_PW="${ROOT_PW}"
export TIMEZONE="${TIMEZONE}"
export KEYMAP="${KEYMAP}"
export LOCALE="${LOCALE}"
export LOCALE2="${LOCALE2}"
export BTRFS_COMPRESSION="${BTRFS_COMPRESSION}"
export SWAPFILE_SIZE="${SWAPFILE_SIZE}"
EOF

chmod +x 00-preinstall.sh 01-disk-setup.sh 02-install-base.sh 03-chroot-setup.sh 04-postinstall.sh bootstrap.sh

# Orquestar
./bootstrap.sh
