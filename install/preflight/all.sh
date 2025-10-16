source $MATEOS_INSTALL/preflight/guard.sh
source $MATEOS_INSTALL/preflight/begin.sh
run_logged $MATEOS_INSTALL/preflight/show-env.sh
run_logged $MATEOS_INSTALL/preflight/pacman.sh
run_logged $MATEOS_INSTALL/preflight/migrations.sh
run_logged $MATEOS_INSTALL/preflight/first-run-mode.sh
run_logged $MATEOS_INSTALL/preflight/disable-mkinitcpio.sh
