#!/bin/bash
set -euo pipefail

# Detect system architecture
ARCH=$(dpkg --print-architecture)

# Download latest Quarto release
QUARTO_DL_URL=$(wget -qO- https://quarto.org/docs/download/_download.json | grep -oP "(?<=\"download_url\":\s\")https.*${ARCH}\.deb")
wget "$QUARTO_DL_URL" -O quarto.deb
dpkg -i quarto.deb
rm quarto.deb
