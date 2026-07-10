#!/bin/bash
set -euo pipefail

# Detect system architecture
ARCH=$(dpkg --print-architecture)

# Extract the download URL for this architecture.
#
# `[^"]*` rather than `.*`: _download.json is currently pretty-printed, so a
# greedy match happens to stay within one line and picks the right URL. It would
# silently select the wrong one the moment Quarto minifies that JSON, and there
# is already more than one *_amd64.deb in the file.
#
# `|| true` because `set -e` aborts on a failed command substitution: without it
# grep finding no match kills the script here, and the error message below is
# never reached.
QUARTO_DL_URL=$(wget -qO- https://quarto.org/docs/download/_download.json \
  | grep -oP "(?<=\"download_url\":\s\")[^\"]*${ARCH}\.deb" || true)

if [ -z "${QUARTO_DL_URL}" ]; then
  echo "Error: Failed to determine Quarto download URL for architecture '${ARCH}'." >&2
  echo "Please check https://quarto.org/docs/download/ for available downloads." >&2
  exit 1
fi

echo "Installing Quarto from ${QUARTO_DL_URL}"
wget -q "$QUARTO_DL_URL" -O quarto.deb

# `apt-get install ./quarto.deb` rather than `dpkg -i`, so dependencies are
# resolved rather than leaving the package half-configured.
apt-get update -qq
apt-get install -y --no-install-recommends ./quarto.deb
rm -f quarto.deb
rm -rf /var/lib/apt/lists/*

quarto --version
