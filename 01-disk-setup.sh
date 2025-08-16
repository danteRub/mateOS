#!/usr/bin/env bash
set -e
: "${DISK:?}"

# Detectar sufijo de particiones (p1 vs 1)
if [[ "$DISK" =~ nvme.*n[0-9]$ ]]; then
  PART1="${DISK}p1"
  PART2="${DISK}p2"
else
  PART1="${DISK}1"
  PART2="${DISK}2"
fi

echo "[+] Borrando particiones en $DISK..."
wipefs -af "$DISK"
sgdisk -Zo "$DISK"

echo "[+] Creando nueva tabla GPT..."
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart ESP fat32 1MiB 513MiB
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart primary btrfs 513MiB 100%

echo "[+] Formateando particiones..."
mkfs.fat -F32 "$PART1"
mkfs.btrfs -f "$PART2"

echo "[+] Creando subvolúmenes Btrfs..."
mount "$PART2" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@snapshots
umount /mnt

echo "[+] Montando particiones..."
mount -o noatime,compress=zstd,subvol=@ "$PART2" /mnt
mkdir -p /mnt/{boot,home,var/log,var/cache/pacman/pkg,.snapshots}
mount -o noatime,compress=zstd,subvol=@home      "$PART2" /mnt/home
mount -o noatime,compress=zstd,subvol=@log       "$PART2" /mnt/var/log
mount -o noatime,compress=zstd,subvol=@pkg       "$PART2" /mnt/var/cache/pacman/pkg
mount -o noatime,compress=zstd,subvol=@snapshots "$PART2" /mnt/.snapshots
mount "$PART1" /mnt/boot

echo "[✓] Disco particionado y montado."
