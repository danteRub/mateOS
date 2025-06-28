#!/usr/bin/env bash
# 01-disk-setup.sh - Disk partitioning and formatting with Btrfs

set -e
: "${DISK:?}"

echo "[+] Borrando particiones en $DISK..."
wipefs -af "$DISK"
sgdisk -Zo "$DISK"

echo "[+] Creando nueva tabla GPT..."
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart ESP fat32 1MiB 513MiB
parted -s "$DISK" set 1 esp on
parted -s "$DISK" mkpart primary btrfs 513MiB 100%

mkfs.fat -F32 "${DISK}p1"
mkfs.btrfs -f "${DISK}p2"

mount "${DISK}p2" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
umount /mnt

mount -o noatime,compress=zstd,subvol=@ "${DISK}p2" /mnt
mkdir -p /mnt/{boot,home}
mount -o noatime,compress=zstd,subvol=@home "${DISK}p2" /mnt/home
mount "${DISK}p1" /mnt/boot

echo "[✓] Disco particionado y montado."
