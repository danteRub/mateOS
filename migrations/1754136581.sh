echo "Start screensaver automatically after 1 minute and stop before locking"

if ! grep -q "mateos-launch-screensaver" ~/.config/hypr/hypridle.conf; then
  mateos-refresh-hypridle
  mateos-refresh-hyprlock
fi
