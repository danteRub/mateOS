echo "Replace wofi with walker as the default launcher"

if mateos-cmd-missing walker; then
  mateos-pkg-add walker-bin libqalculate

  mateos-pkg-drop wofi
  rm -rf ~/.config/wofi

  mkdir -p ~/.config/walker
  cp -r ~/.local/share/mateos/config/walker/* ~/.config/walker/
fi
