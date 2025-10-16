echo "Make new Osaka Jade theme available as new default"

if [[ ! -L ~/.config/mateos/themes/osaka-jade ]]; then
  rm -rf ~/.config/mateos/themes/osaka-jade
  git -C ~/.local/share/mateos checkout -f themes/osaka-jade
  ln -nfs ~/.local/share/mateos/themes/osaka-jade ~/.config/mateos/themes/osaka-jade
fi
