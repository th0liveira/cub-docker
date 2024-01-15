# !/bin/bash

if [ ! -f "/app/package.json" ]; then
  exit 0;
fi

cd /app
npm i
