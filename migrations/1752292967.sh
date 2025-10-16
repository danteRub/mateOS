echo "Update to use UWSM and seamless login"

if mateos-cmd-missing uwsm; then
  sudo rm -f /etc/systemd/system/getty@tty1.service.d/override.conf
  sudo rmdir /etc/systemd/system/getty@tty1.service.d/ 2>/dev/null || true

  if [ -f "$HOME/.bash_profile" ]; then
    # Remove the specific line
    sed -i '/^\[\[ -z \$DISPLAY && \$(tty) == \/dev\/tty1 \]\] && exec Hyprland$/d' "$HOME/.bash_profile"
    echo "Cleaned up .bash_profile"
  fi

  source $MATEOS_PATH/install/login/plymouth.sh
fi
