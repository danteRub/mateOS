echo "Replace volume control GUI with a TUI"

if mateos-cmd-missing wiremix; then
  mateos-pkg-add wiremix
  mateos-pkg-drop pavucontrol
  mateos-refresh-applications
  mateos-refresh-waybar
fi
