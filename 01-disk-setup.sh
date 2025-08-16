#!/usr/bin/env bash
set -Eeuo pipefail
source ./env.sh

[[ -b "$DISK" ]] || { echo "Disco inválido: $DISK"; exit 1; }

echo "[*] Limpiando firmas y tabla en $DISK"
wipefs -af "$DISK"
sgdisk -Z "$DISK"

# GPT: 1) EFI 512MiB  2) ROOT resto
sgdisk -n1:0:+512M -t1:ef00 -c1:"EFI System" "$DISK"
sgdisk -n2:0:0     -t2:8300 -c2:"ArchRoot"  "$DISK"
partprobe "$DISK"

EFI_PART="${DISK}p1"; ROOT_PART="${DISK}p2"
[[ -b "$EFI_PART" ]] || EFI_PART="${DISK}1"
[[ -b "$ROOT_PART" ]] || ROOT_PART="${DISK}2"

mkfs.fat -F32 "$EFI_PART"
mkfs.btrfs -f "$ROOT_PART"

mount "$ROOT_PART" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@pkg
btrfs subvolume create /mnt/@snapshots
umount /mnt

mount -o subvol=@,compress=${BTRFS_COMPRESSION},noatime "$ROOT_PART" /mnt
mkdir -p /mnt/{boot,home,var/log,var/cache/pacman/pkg,.snapshots}
mount -o subvol=@home,compress=${BTRFS_COMPRESSION},noatime "$ROOT_PART" /mnt/home
mount -o subvol=@log,compress=${BTRFS_COMPRESSION},noatime "$ROOT_PART" /mnt/var/log
mount -o subvol=@pkg,compress=${BTRFS_COMPRESSION},noatime "$ROOT_PART" /mnt/var/cache/pacman/pkg
mount -o subvol=@snapshots,compress=${BTRFS_COMPRESSION},noatime "$ROOT_PART" /mnt/.snapshots
mount "$EFI_PART" /mnt/boot
