echo "Add minimal starship prompt to terminal"

if mateos-cmd-missing starship; then
  mateos-pkg-add starship
  cp $MATEOS_PATH/config/starship.toml ~/.config/starship.toml
fi
