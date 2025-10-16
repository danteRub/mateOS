echo "Fix walker theme loading: copy themes to ~/.config/walker/themes/ where walker actually looks for them"

# Create themes directory
mkdir -p ~/.config/walker/themes/mateos-default

# Copy theme files and rename to expected names (theme.toml and style.css)
cp ~/.local/share/mateos/default/walker/themes/mateos-default.toml ~/.config/walker/themes/mateos-default/theme.toml
cp ~/.local/share/mateos/default/walker/themes/mateos-default.css ~/.config/walker/themes/mateos-default/style.css

# Fix CSS import paths: walker doesn't expand ~ in CSS @import statements
sed -i 's|file://~/|file://'$HOME'/|g' ~/.config/walker/themes/mateos-default/style.css

# Refresh walker configuration and restart
mateos-refresh-walker

