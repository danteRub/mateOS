# Install all base packages
mapfile -t all_packages < <(grep -v '^#' "$MATEOS_INSTALL/mateos-base.packages" | grep -v '^$')

# Separate official repo packages from AUR packages
official_packages=()
aur_packages=()

for pkg in "${all_packages[@]}"; do
  if pacman -Si "$pkg" &>/dev/null; then
    official_packages+=("$pkg")
  else
    aur_packages+=("$pkg")
  fi
done

# Install official repo packages with pacman
if [ ${#official_packages[@]} -gt 0 ]; then
  echo "Installing ${#official_packages[@]} packages from official repos..."
  sudo pacman -S --noconfirm --needed "${official_packages[@]}"
fi

# Install AUR packages with yay if available
if [ ${#aur_packages[@]} -gt 0 ]; then
  if command -v yay &>/dev/null; then
    echo "Installing ${#aur_packages[@]} packages from AUR..."
    yay -S --noconfirm --needed "${aur_packages[@]}"
  else
    echo "Warning: ${#aur_packages[@]} AUR packages skipped (yay not found):"
    printf '  - %s\n' "${aur_packages[@]}"
  fi
fi
