# Show installation environment variables
gum log --level info "Installation Environment:"

env | grep -E "^(MATEOS_CHROOT_INSTALL|MATEOS_ONLINE_INSTALL|MATEOS_USER_NAME|MATEOS_USER_EMAIL|USER|HOME|MATEOS_REPO|MATEOS_REF|MATEOS_PATH)=" | sort | while IFS= read -r var; do
  gum log --level info "  $var"
done
