echo "6Ghz Wi-Fi + Intel graphics acceleration for existing installations"

bash "$MATEOS_PATH/install/config/hardware/set-wireless-regdom.sh"
bash "$MATEOS_PATH/install/config/hardware/intel.sh"
