echo "Add Catppuccin Latte light theme"

if [[ ! -L "~/.config/mateos/themes/catppuccin-latte" ]]; then
  ln -snf ~/.local/share/mateos/themes/catppuccin-latte ~/.config/mateos/themes/
fi
