echo "Add new MateOS Menu icon to Waybar"

mkdir -p ~/.local/share/fonts
cp ~/.local/share/mateos/config/mateos.ttf ~/.local/share/fonts/
fc-cache
