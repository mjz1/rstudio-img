#!/usr/bin/env bash
# End-to-end PDF render: this is what a user means by "PDF output works".
# It failed in every image published before v1.2.0.
#
# `docker run --user` does not set HOME, so it defaults to `/`, which is not
# writable. Quarto's cache and TinyTeX's TEXMFVAR both resolve under $HOME.
#
#   IMAGE=<tag> ci/smoke_quarto.sh
set -euo pipefail
IMAGE="${IMAGE:?set IMAGE to the tag to test}"

docker run --rm --user 1000:1000 \
  -e HOME=/home/rstudio -e XDG_CACHE_HOME=/home/rstudio/.cache \
  -w /home/rstudio "$IMAGE" bash -euc '
  printf -- "---\ntitle: smoke\nformat: pdf\n---\n\nHello.\n" > t.qmd
  quarto render t.qmd --to pdf
  test -s t.pdf
  echo "  ok    rendered $(stat -c%s t.pdf) byte PDF"'
