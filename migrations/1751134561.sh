echo "Add MateOS Package Repository"

mateos-refresh-pacman-mirrorlist

if ! grep -q "mateos" /etc/pacman.conf; then
  sudo sed -i '/^\[core\]/i [mateos]\nSigLevel = Optional TrustAll\nServer = https:\/\/pkgs.mateos.org\/$arch\n' /etc/pacman.conf
  sudo systemctl restart systemd-timesyncd
  sudo pacman -Syu --noconfirm
fi
