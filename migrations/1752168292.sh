echo "Enable battery low notifications for laptops"

if ls /sys/class/power_supply/BAT* &>/dev/null && [[ ! -f ~/.local/share/mateos/config/systemd/user/mateos-battery-monitor.service ]]; then
  mkdir -p ~/.config/systemd/user

  cp ~/.local/share/mateos/config/systemd/user/mateos-battery-monitor.* ~/.config/systemd/user/

  systemctl --user daemon-reload
  systemctl --user enable --now mateos-battery-monitor.timer || true
fi
