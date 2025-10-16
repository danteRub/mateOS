echo "Remove fcitx5 input method framework and all related configurations"

# Stop fcitx5 if running
pkill fcitx5 2>/dev/null || true

# Remove fcitx5 packages
mateos-pkg-drop fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool

# Remove fcitx5 configuration directories
rm -rf ~/.config/fcitx5
rm -rf ~/.local/share/fcitx5

# Remove environment configuration
rm -f ~/.config/environment.d/fcitx.conf

echo "fcitx5 has been removed from the system"

