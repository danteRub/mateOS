echo "Update Waybar CSS to dim unused workspaces"

if ! grep -q "#workspaces button\.empty" ~/.config/waybar/style.css; then
  mateos-refresh-config waybar/style.css
  mateos-restart-waybar
fi
