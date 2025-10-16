#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

# Define MateOS locations
export MATEOS_PATH="$HOME/.local/share/mateos"
export MATEOS_INSTALL="$MATEOS_PATH/install"
export MATEOS_INSTALL_LOG_FILE="/var/log/mateos-install.log"
export PATH="$MATEOS_PATH/bin:$PATH"

# Install
source "$MATEOS_INSTALL/helpers/all.sh"
source "$MATEOS_INSTALL/preflight/all.sh"
source "$MATEOS_INSTALL/packaging/all.sh"
source "$MATEOS_INSTALL/config/all.sh"
source "$MATEOS_INSTALL/login/all.sh"
source "$MATEOS_INSTALL/post-install/all.sh"
