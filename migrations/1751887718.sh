echo "Install Impala as new wifi selection TUI"

if mateos-cmd-missing impala; then
  mateos-pkg-add impala
  mateos-refresh-waybar
fi
