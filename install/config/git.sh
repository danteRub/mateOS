# Ensure git settings live under ~/.config
mkdir -p ~/.config/git
touch ~/.config/git/config

# Set common git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true
git config --global init.defaultBranch master

# Set identification from install inputs
if [[ -n "${MATEOS_USER_NAME//[[:space:]]/}" ]]; then
  git config --global user.name "$MATEOS_USER_NAME"
fi

if [[ -n "${MATEOS_USER_EMAIL//[[:space:]]/}" ]]; then
  git config --global user.email "$MATEOS_USER_EMAIL"
fi
