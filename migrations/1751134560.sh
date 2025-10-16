echo "Add UWSM env"

export MATEOS_PATH="$HOME/.local/share/mateos"
export PATH="$MATEOS_PATH/bin:$PATH"

mkdir -p "$HOME/.config/uwsm/"
mateos-refresh-config uwsm/env

echo -e "\n\e[31mMateOS bins have been added to PATH (and MATEOS_PATH is now system-wide).\nYou must immediately relaunch Hyprland or most MateOS cmds won't work.\nPlease run MateOS > Update again after the quick relaunch is complete.\e[0m"
echo

mkdir -p ~/.local/state/mateos/migrations
gum confirm "Ready to relaunch Hyprland? (All applications will be closed)" &&
  touch ~/.local/state/mateos/migrations/1751134560.sh &&
  uwsm stop
