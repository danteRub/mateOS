echo "Allow updating of timezone by right-clicking on the clock (or running mateos-cmd-tzupdate)"

if mateos-cmd-missing tzupdate; then
  bash "$MATEOS_PATH/install/config/timezones.sh"
  mateos-refresh-waybar
fi
