# !/bin/bash

if [ ! -f "/mnt/certs/ca.crt" ]; then
  exit 0
fi

cp /mnt/certs/ca.crt /usr/local/share/ca-certificates/ca.crt
update-ca-certificates
