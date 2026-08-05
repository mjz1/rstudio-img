#!/usr/bin/env bash
# Image invariants, executed INSIDE the container as uid 1000:
#
#   docker run --rm -i --user 1000:1000 "$IMAGE" bash -s < ci/smoke_invariants.sh
#
# Piped over stdin, not bind-mounted: a mount over /var/lib/rstudio-server
# would mask the very file the first check asserts does not exist, and keeping
# the container unmounted keeps every check honest.
#
# Shared by PR validation and the publish workflow so an image cannot pass
# review under one set of checks and ship under another.

fail=0
ok()  { printf "  ok    %s\n" "$1"; }
bad() { printf "  FAIL  %s\n" "$1"; fail=1; }

# v1.1.1: a baked key signs auth cookies for everyone who pulls the tag.
if [ -e /var/lib/rstudio-server/secure-cookie-key ]; then
  bad "secure-cookie-key is baked into the image"
else ok "no baked secure-cookie-key"; fi

# v1.1.1: RStudio >= 2026.06 treats an unreadable database.conf as fatal.
if [ -r /etc/rstudio/database.conf ]; then ok "database.conf is readable"
else bad "database.conf unreadable by a non-root user"; fi

# v1.1.1: there is no syslog socket in a container; errors vanish.
if grep -q logger-type=stderr /etc/rstudio/logging.conf; then ok "rserver logs to stderr"
else bad "rserver logging is not stderr"; fi

# v1.2.0: TinyTeX used to be unreachable inside a 0700 /root.
if command -v xelatex >/dev/null; then ok "xelatex on PATH"
else bad "xelatex not on PATH (TinyTeX unreachable?)"; fi
if command -v tlmgr >/dev/null; then ok "tlmgr on PATH"
else bad "tlmgr not on PATH"; fi

# v1.2.0: allow-posit-assistant is the option that actually gates it.
if grep -q "^allow-posit-assistant=1" /etc/rstudio/rsession.conf; then ok "posit assistant enabled"
else bad "posit assistant not enabled"; fi
if grep -q "^copilot-enabled=1" /etc/rstudio/rsession.conf; then ok "copilot enabled"
else bad "copilot not enabled"; fi

# v1.3.0: system libcudart (both majors) so R torch GPU works. lantern
# links the plain soname and loads it from ldconfig; without it,
# cuda_is_available() is FALSE even on a GPU node.
if ldconfig -p | grep -q "libcudart.so.12"; then ok "libcudart.so.12 in ldconfig"
else bad "libcudart.so.12 missing (R torch GPU will not load)"; fi
if ldconfig -p | grep -q "libcudart.so.13"; then ok "libcudart.so.13 in ldconfig"
else bad "libcudart.so.13 missing"; fi

# issue #1: headless Chrome for webshot2 / gt::gtsave(png) / pagedown,
# all of which drive Chrome through chromote via CHROMOTE_CHROME.
if command -v google-chrome >/dev/null; then ok "google-chrome on PATH"
else bad "google-chrome missing (gt/webshot2 png output fails)"; fi
if [ -x "${CHROMOTE_CHROME:-/nonexistent}" ]; then ok "CHROMOTE_CHROME shim present"
else bad "CHROMOTE_CHROME shim missing or not set"; fi

exit $fail
