# Copy over MateOS configs
mkdir -p ~/.config
cp -R ~/.local/share/mateos/config/* ~/.config/

# Use default bashrc from MateOS
cp ~/.local/share/mateos/default/bashrc ~/.bashrc
