echo "Add eza themeing"

mkdir -p ~/.config/eza

if [ -f ~/.config/mateos/current/theme/eza.yml ]; then
  ln -snf ~/.config/mateos/current/theme/eza.yml ~/.config/eza/theme.yml
fi

