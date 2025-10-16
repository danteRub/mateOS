# Copy over MateOS configs
mkdir -p ~/.config
cp -R ~/.local/share/mateos/config/* ~/.config/

# Use default zshrc from MateOS
cp ~/.local/share/mateos/default/zshrc ~/.zshrc

# Set zsh as default shell
sudo chsh -s /usr/bin/zsh $USER
