#!/usr/bin/env bash
set -Eeuo pipefail
source ./env.sh

pacstrap -K /mnt base linux linux-firmware mkinitcpio btrfs-progs \
  vim sudo networkmanager git bash-completion util-linux e2fsprogs openssh

genfstab -U /mnt >> /mnt/etc/fstab
