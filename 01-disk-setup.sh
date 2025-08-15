#!/usr/bin/env bash
set -e
: "${DISK:?}"

if [[ "$DISK" =~ nvme.*n[0-9]$ ]]; then
  PART1="${DISK}p1"; PART2="${DISK}p2"
else
  PART1="${DISK}1"; PART2="${DISK}2"
fi

echo "[+] Borrando particiones en $DISK..."
wipefs -af "$DISK"
sgdisk -Zo "$DISK"

echo "[+] Creando nueva tabla GPT y particiones..."
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart ESP fat32 1MiB 513MiB
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart primary btrfs 513MiB 100%

echo "[+] Formateando..."
mkfs.fat -F32 "$PART1"
mkfs.btrfs -f "$PART2"

echo "[+] Subvolúmenes Btrfs..."
mount "$PART2" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
umount /mnt

echo "[+] Montando..."
mount -o noatime,compress=zstd,subvol=@ "$PART2" /mnt
mkdir -p /mnt/{boot,home}
mount -o noatime,compress=zstd,subvol=@home "$PART2" /mnt/home
mount "$PART1" /mnt/boot

echo "[✓] Disco particionado y montado."
