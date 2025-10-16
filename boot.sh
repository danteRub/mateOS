#!/bin/bash

# Set install mode to online since boot.sh is used for curl installations
export MATEOS_ONLINE_INSTALL=true

ansi_art='                             ███                 ███████     █████████ 
                           ░░███               ███░░░░░███  ███░░░░░███
 █████████████    ██████   ███████    ██████  ███     ░░███░███    ░░░ 
░░███░░███░░███  ░░░░░███ ░░░███░    ███░░███░███      ░███░░█████████ 
 ░███ ░███ ░███   ███████   ░███    ░███████ ░███      ░███ ░░░░░░░░███
 ░███ ░███ ░███  ███░░███   ░███ ███░███░░░  ░░███     ███  ███    ░███
 █████░███ █████░░████████  ░░█████ ░░██████  ░░░███████░  ░░█████████ 
░░░░░ ░░░ ░░░░░  ░░░░░░░░    ░░░░░   ░░░░░░     ░░░░░░░     ░░░░░░░░░  '

clear
echo -e "\n$ansi_art\n"

sudo pacman -Syu --noconfirm --needed git

# Use custom repo if specified, otherwise default to danteRub/mateOS
MATEOS_REPO="${MATEOS_REPO:-danteRub/mateOS}"

echo -e "\nCloning MateOS from: https://github.com/${MATEOS_REPO}.git"
rm -rf ~/.local/share/mateos/
git clone "https://github.com/${MATEOS_REPO}.git" ~/.local/share/mateos >/dev/null

# Use custom branch if instructed, otherwise default to master
MATEOS_REF="${MATEOS_REF:-master}"
if [[ $MATEOS_REF != "master" ]]; then
  echo -e "\e[32mUsing branch: $MATEOS_REF\e[0m"
  cd ~/.local/share/mateos
  git fetch origin "${MATEOS_REF}" && git checkout "${MATEOS_REF}"
  cd -
fi

echo -e "\nInstallation starting..."
source ~/.local/share/mateos/install.sh
