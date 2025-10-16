echo "Add new matte black theme"

if [[ ! -L "~/.config/mateos/themes/matte-black" ]]; then
  ln -snf ~/.local/share/mateos/themes/matte-black ~/.config/mateos/themes/
fi
