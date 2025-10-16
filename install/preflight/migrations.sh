MATEOS_MIGRATIONS_STATE_PATH=~/.local/state/mateos/migrations
mkdir -p $MATEOS_MIGRATIONS_STATE_PATH

for file in ~/.local/share/mateos/migrations/*.sh; do
  touch "$MATEOS_MIGRATIONS_STATE_PATH/$(basename "$file")"
done
