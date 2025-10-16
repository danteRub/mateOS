echo "Remove MateOS custom repository - using only official Arch repos"

# Backup current pacman.conf
sudo cp /etc/pacman.conf /etc/pacman.conf.bak

# Remove [mateos] repository section
sudo sed -i '/\[mateos\]/,+2 d' /etc/pacman.conf

# Update package database
sudo pacman -Syu --noconfirm

