echo "Fix JetBrains font setting"

if [[ $(mateos-font-current) == JetBrains* ]]; then
  mateos-font-set "JetBrainsMono Nerd Font"
fi
