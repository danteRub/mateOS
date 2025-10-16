echo "Add the new ristretto theme as an option"

if [[ ! -L ~/.config/mateos/themes/ristretto ]]; then
  ln -nfs ~/.local/share/mateos/themes/ristretto ~/.config/mateos/themes/
fi
