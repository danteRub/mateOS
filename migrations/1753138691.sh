echo "Install swayOSD to show volume status"

if mateos-cmd-missing swayosd-server; then
  mateos-pkg-add swayosd
  setsid uwsm app -- swayosd-server &>/dev/null &
fi
