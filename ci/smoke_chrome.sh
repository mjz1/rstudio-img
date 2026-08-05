#!/usr/bin/env bash
# Headless Chrome renders ROOTLESS -- that is the whole point (issue #1).
# gt/webshot2/pagedown drive Chrome through chromote, which under Singularity
# runs as a non-root uid with no usable sandbox. Exercise the shim the way
# chromote will: headless as uid 1000, screenshot a data URI.
#
#   IMAGE=<tag> ci/smoke_chrome.sh
set -euo pipefail
IMAGE="${IMAGE:?set IMAGE to the tag to test}"

docker run --rm --user 1000:1000 \
  -e HOME=/home/rstudio -w /home/rstudio "$IMAGE" bash -euc '
  "$CHROMOTE_CHROME" --headless --screenshot=shot.png \
    --window-size=200,120 --user-data-dir="$PWD/chrome-data" \
    "data:text/html,<h1>ok</h1>"
  test -s shot.png
  echo "  ok    headless Chrome wrote $(stat -c%s shot.png) byte PNG as uid 1000"'
