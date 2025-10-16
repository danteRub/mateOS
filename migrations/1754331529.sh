echo "Update Waybar for new MateOS menu"

if ! grep -q "" ~/.config/waybar/config.jsonc; then
  mateos-refresh-waybar
fi
