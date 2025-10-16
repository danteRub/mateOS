echo "Switch to MateOS Chromium for synchronized theme switching"

if mateos-cmd-present chromium; then
  set_theme_colors() {
    if [[ -f ~/.config/mateos/current/theme/chromium.theme ]]; then
      chromium --no-startup-window --set-theme-color="$(<~/.config/mateos/current/theme/chromium.theme)"
    else
      # Use a default, neutral grey if theme doesn't have a color
      chromium --no-startup-window --set-theme-color="28,32,39"
    fi
  }

  mateos-pkg-drop chromium
  mateos-pkg-add mateos-chromium

  if pgrep -x chromium; then
    if gum confirm "Chromium must be restarted. Ready?"; then
      pkill -x chromium
      set_theme_colors
    fi
  else
    set_theme_colors
  fi
fi
