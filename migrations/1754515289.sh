echo "Update and restart Walker to resolve stuck MateOS menu"

sudo pacman -Syu --noconfirm walker-bin
mateos-restart-walker
