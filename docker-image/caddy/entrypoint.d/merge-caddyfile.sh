# !/bin/bash

cp /etc/caddy/Caddyfile.original /etc/caddy/Caddyfile

if [ ! -d "/mnt/caddy.d" ]; then
  echo "Path /mnt/caddy.d not exists"
  exit 0
fi

cd /mnt/caddy.d

for FILE in *; do
  if [ -f "$FILE" ]; then
    echo "Append $FILE into /etc/caddy/Caddyfile"
    echo ""
    echo "-----------------------------------------------------------------------------"

    echo "" >> /etc/caddy/Caddyfile
    echo "" >> /etc/caddy/Caddyfile
    echo "# $FILE --------------------" >> /etc/caddy/Caddyfile
    echo "" >> /etc/caddy/Caddyfile
    cat $FILE >> /etc/caddy/Caddyfile
    echo "" >> /etc/caddy/Caddyfile
    echo "# End $FILE ----------------" >> /etc/caddy/Caddyfile
  fi
done
