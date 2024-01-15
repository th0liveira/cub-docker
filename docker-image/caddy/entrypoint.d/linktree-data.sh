#!/bin/bash

if [ ! -f "/mnt/linktree-data.json" ]; then
  exit 0
fi

rm /opt/linktree/data.json
ln -s /mnt/linktree-data.json /opt/linktree/data.json
