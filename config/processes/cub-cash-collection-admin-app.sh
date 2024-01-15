#!/bin/sh

concurrently \
  "npm run --workspace=current start:${ENV}" \
  "npm run --workspace=admin-partner start:${ENV}"
