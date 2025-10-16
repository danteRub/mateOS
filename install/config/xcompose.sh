# Set default XCompose that is triggered with CapsLock
tee ~/.XCompose >/dev/null <<EOF
include "%H/.local/share/mateos/default/xcompose"

# Identification
<Multi_key> <space> <n> : "$MATEOS_USER_NAME"
<Multi_key> <space> <e> : "$MATEOS_USER_EMAIL"
EOF
