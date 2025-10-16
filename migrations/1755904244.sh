echo "Update fastfetch config with new MateOS logo"

mateos-refresh-config fastfetch/config.jsonc

mkdir -p ~/.config/mateos/branding
cp $MATEOS_PATH/icon.txt ~/.config/mateos/branding/about.txt
