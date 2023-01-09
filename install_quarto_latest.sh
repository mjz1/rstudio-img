# DOWNLOAD LATEST QUARTO RELEASE
QUARTO_DL_URL=$(wget -qO- https://quarto.org/docs/download/_download.json | grep -oP "(?<=\"download_url\":\s\")https.*${ARCH}\.deb")
wget "$QUARTO_DL_URL" -O quarto.deb
dpkg -i quarto.deb
rm quarto.deb
