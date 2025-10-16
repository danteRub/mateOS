echo "Adding MateOS version info to fastfetch"
if ! grep -q "mateos" ~/.config/fastfetch/config.jsonc; then
  cp ~/.local/share/mateos/config/fastfetch/config.jsonc ~/.config/fastfetch/
fi

