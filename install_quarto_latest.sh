#!/bin/bash
set -euo pipefail

# Detect system architecture
ARCH=$(dpkg --print-architecture)

# Download latest Quarto release
QUARTO_DL_URL=$(wget -qO- https://quarto.org/docs/download/_download.json | grep -oP "(?<=\"download_url\":\s\")https.*${ARCH}\.deb")

if [ -z "${QUARTO_DL_URL:-}" ]; then
  echo "Error: Failed to determine Quarto download URL for architecture '${ARCH}'." >&2
  echo "Please check https://quarto.org/docs/download/ for available downloads." >&2
  exit 1
fi
wget "$QUARTO_DL_URL" -O quarto.deb
dpkg -i quarto.deb
rm quarto.deb
