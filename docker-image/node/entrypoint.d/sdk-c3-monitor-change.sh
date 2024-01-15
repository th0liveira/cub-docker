# !/bin/bash

SOURCE="/mnt/cub-cash-collection-sdk/lib"
TARGET="/app/node_modules/@cub-com-br/cub-c3-sdk"
LOCK_FILE="/tmp/sdk-syncing"

if [ ! -d "$SOURCE" ]; then
  echo "- Path $SOURCE not exists"
  exit 0;
fi

if [ ! -d "$TARGET" ]; then
  echo "- Path $TARGET not exists"
  exit 0;
fi

sync_directories() {
  rsync -arz --delete $SOURCE/* $TARGET/
}

inotifywait -m -r -e modify,create,delete --format '%T' --timefmt '%Y%m%d%H%M%S' $SOURCE | while read CHANGETIME
do
  if [ ! -f "$LOCK_FILE.$CHANGETIME" ]; then
    echo "Detected SDK changes, start syncing..."
    touch "$LOCK_FILE.$CHANGETIME"
  fi

  sync_directories
done &
