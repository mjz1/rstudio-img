#!/usr/bin/env bash
# OOD-launch-shaped rserver smoke test, run on the host against a loaded image:
#
#   IMAGE=<tag> ci/smoke_launch.sh
#
# Starts rserver the way the downstream Open OnDemand app does -- the same
# flag set and config files as mjz1/openondemandapps' rstudio_dev
# template/script.sh.erb -- then polls the port and asserts the sign-in page
# is served. rserver refuses to start on an unknown option, so an RStudio
# release that removes or renames any flag the app passes becomes a red CI
# run with the error in `docker logs`, instead of an OnDemand session whose
# only symptom is "wait_until_port_used timed out".
#
# THE FLAG LIST BELOW MIRRORS script.sh.erb's rserver invocation. When the
# app changes how it launches rserver, change this to match (and vice versa:
# if a flag has to be dropped here because Posit removed it, the app needs
# the same edit before it can run that RStudio version).
#
# Rootless throughout (uid 1000), same as the invariants: Singularity runs
# the image as an unprivileged user, so a check that passes as root proves
# nothing.
set -euo pipefail

IMAGE="${IMAGE:?set IMAGE to the tag to test}"
PORT="${PORT:-8787}"
NAME="rstudio-smoke-launch-$$"

work=$(mktemp -d)
cleanup() {
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  sudo rm -rf "$work" 2>/dev/null || rm -rf "$work" || true
}
trap cleanup EXIT

mkdir -p "$work/lib" "$work/run" "$work/etc"

# script.sh.erb writes this database.conf itself: the deb ships the file
# 0600 root:root, which RStudio >= 2026.06 treats as fatal under a rootless
# runtime.
cat > "$work/etc/database.conf" <<'EOF'
provider=sqlite
directory=/var/lib/rstudio-server
EOF

# rserver to stderr so a startup failure lands in `docker logs` -- the same
# reason script.sh.erb binds its own logging.conf over the image's.
cat > "$work/etc/logging.conf" <<'EOF'
[*]
log-level=warn
logger-type=stderr
EOF

# Stub of the app's PAM helper (bin/auth): password from stdin against an
# env var. The real helper does exactly this with more ceremony.
cat > "$work/etc/auth" <<'EOF'
#!/usr/bin/env bash
read -rs PASSWORD
[ "$PASSWORD" = "$RSTUDIO_PASSWORD" ]
EOF

# Stub of the app's rsession wrapper: the real one exports per-session
# environment then execs rsession; the flag only needs a valid executable.
cat > "$work/etc/rsession.sh" <<'EOF'
#!/usr/bin/env bash
exec /usr/lib/rstudio-server/bin/rsession "$@"
EOF

chmod 755 "$work/etc/auth" "$work/etc/rsession.sh"
sudo chown -R 1000:1000 "$work" 2>/dev/null || chown -R 1000:1000 "$work"

docker run -d --name "$NAME" --user 1000:1000 \
  -p "127.0.0.1:${PORT}:${PORT}" \
  -v "$work/lib:/var/lib/rstudio-server" \
  -v "$work/run:/run" \
  -v "$work/etc/logging.conf:/etc/rstudio/logging.conf:ro" \
  -v "$work/etc/database.conf:/tmp/database.conf:ro" \
  -v "$work/etc/auth:/opt/smoke/auth:ro" \
  -v "$work/etc/rsession.sh:/opt/smoke/rsession.sh:ro" \
  -e RSTUDIO_PASSWORD=smoke-test-password \
  "$IMAGE" \
  rserver \
    --database-config-file=/tmp/database.conf \
    --server-user=rstudio \
    --www-port="$PORT" \
    --auth-none=0 \
    --auth-pam-require-password-prompt=0 \
    --auth-pam-helper-path=/opt/smoke/auth \
    --auth-encrypt-password=0 \
    --auth-timeout-minutes=10080 \
    --rsession-path=/opt/smoke/rsession.sh >/dev/null

# Poll the sign-in page. 90 s is generous -- a healthy rserver serves it in
# well under 10 -- but a loaded CI runner should not produce a false failure.
page="$work/signin.html"
deadline=$((SECONDS + 90))
until curl -fsS -o "$page" "http://127.0.0.1:${PORT}/auth-sign-in" 2>/dev/null; do
  if [ "$(docker inspect -f '{{.State.Running}}' "$NAME" 2>/dev/null)" != "true" ]; then
    echo "  FAIL  rserver exited before serving the sign-in page; its output:"
    docker logs "$NAME" 2>&1 | sed 's/^/        /'
    exit 1
  fi
  if (( SECONDS >= deadline )); then
    echo "  FAIL  rserver is running but never served /auth-sign-in; its output:"
    docker logs "$NAME" 2>&1 | sed 's/^/        /'
    exit 1
  fi
  sleep 2
done

if ! grep -qi rstudio "$page"; then
  echo "  FAIL  /auth-sign-in answered but does not look like an RStudio sign-in page:"
  head -c 500 "$page" | sed 's/^/        /'
  exit 1
fi

echo "  ok    rserver accepted the OnDemand flag set and served the sign-in page"
