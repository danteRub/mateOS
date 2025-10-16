# Set links for Nautilius action icons
sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-previous-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-previous-symbolic.svg
sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-next-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-next-symbolic.svg

# Setup theme links
mkdir -p ~/.config/mateos/themes
for f in ~/.local/share/mateos/themes/*; do ln -nfs "$f" ~/.config/mateos/themes/; done

# Set initial theme
mkdir -p ~/.config/mateos/current
ln -snf ~/.config/mateos/themes/tokyo-night ~/.config/mateos/current/theme
ln -snf ~/.config/mateos/current/theme/backgrounds/1-scenery-pink-lakeside-sunset-lake-landscape-scenic-panorama-7680x3215-144.png ~/.config/mateos/current/background

# Set specific app links for current theme
ln -snf ~/.config/mateos/current/theme/neovim.lua ~/.config/nvim/lua/plugins/theme.lua

mkdir -p ~/.config/btop/themes
ln -snf ~/.config/mateos/current/theme/btop.theme ~/.config/btop/themes/current.theme

mkdir -p ~/.config/mako
ln -snf ~/.config/mateos/current/theme/mako.ini ~/.config/mako/config

mkdir -p ~/.config/eza
ln -snf ~/.config/mateos/current/theme/eza.yml ~/.config/eza/theme.yml

# Add managed policy directories for Chromium and Brave for theme changes
sudo mkdir -p /etc/chromium/policies/managed
sudo chmod a+rw /etc/chromium/policies/managed

sudo mkdir -p /etc/brave/policies/managed
sudo chmod a+rw /etc/brave/policies/managed
