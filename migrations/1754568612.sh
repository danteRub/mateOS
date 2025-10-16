echo "Update Waybar config to fix path issue with update-available icon click"

if grep -q "alacritty --class MateOS --title MateOS -e mateos-update" ~/.config/waybar/config.jsonc; then
  sed -i 's|\("on-click": "alacritty --class MateOS --title MateOS -e \)mateos-update"|\1mateos-update"|' ~/.config/waybar/config.jsonc
  mateos-restart-waybar
fi
