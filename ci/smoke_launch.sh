#!/usr/bin/env bash
# OOD-launch-shaped rserver smoke test, run on the host against a loaded image:
#
#   IMAGE=<tag> ci/smoke_launch.sh
#
# Starts rserver the way the downstream Open OnDemand app does -- the same
# flag set and config files as mjz1/rstudio-ood's
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
# --www-address is pinned to 0.0.0.0 rather than left to the default: the
# session must be reachable from another host (the OnDemand web node), and a
# default that ever moved to loopback-only would break that silently. The
# app pins it for the same reason.
#
# The container runs with --network host, as singularity does (no namespace,
# no port mapping) -- docker's -p mapping proved unreliable on CI runners
# (rserver served 200 on loopback AND eth0 inside the container while the
# published port never answered), and production has no mapping to model.
# The poll targets the host's network address, not loopback, because that is
# the address family the web node actually uses.
#
# Rootless throughout (uid 1000), same as the invariants: Singularity runs
# the image as an unprivileged user, so a check that passes as root proves
# nothing.
set -euo pipefail

IMAGE="${IMAGE:?set IMAGE to the tag to test}"
# A random port BELOW the Linux ephemeral range (32768-60999): with
# --network host the container shares the host's ports, and a port inside
# the ephemeral range can be snatched by any outbound connection's source
# port between now and rserver's bind.
PORT="${PORT:-$((RANDOM % 10000 + 21000))}"
NAME="rstudio-smoke-launch-$$"

# $work is chowned to uid 1000 below and becomes unwritable to THIS user --
# anything this script itself writes (like the fetched sign-in page) must
# live elsewhere. Getting that wrong cost four CI cycles: curl received
# HTTP 200, exited 23 on the unwritable -o target, and under -f with stderr
# silenced that is indistinguishable from "connection failed".
work=$(mktemp -d)
page=$(mktemp)
cleanup() {
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  sudo rm -rf "$work" 2>/dev/null || rm -rf "$work" || true
  rm -f "$page"
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

# First IPv4 specifically -- `hostname -I` can list IPv6 too, and a bare v6
# address is malformed in a URL without brackets. Falling back to loopback
# loses the bind-address half of the check, so say so out loud.
ADDR=$(hostname -I 2>/dev/null | tr ' ' '\n' | grep -m1 -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true)
if [ -z "$ADDR" ]; then
  echo "  note  no IPv4 from hostname -I; polling loopback (bind-address coverage lost)"
  ADDR=127.0.0.1
fi

docker run -d --name "$NAME" --user 1000:1000 \
  --network host \
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
    --www-address=0.0.0.0 \
    --www-port="$PORT" \
    --auth-none=0 \
    --auth-pam-require-password-prompt=0 \
    --auth-pam-helper-path=/opt/smoke/auth \
    --auth-encrypt-password=0 \
    --auth-timeout-minutes=10080 \
    --rsession-path=/opt/smoke/rsession.sh >/dev/null

# On failure, "no output" must still leave evidence: what is running, what is
# listening, and whether the page is reachable from INSIDE the container --
# which splits "rserver never bound the port" from "docker port mapping".
diag() {
  echo "        ---- docker logs ----"
  docker logs "$NAME" 2>&1 | sed 's/^/        /' || true
  echo "        ---- processes ----"
  docker exec "$NAME" ps -ef 2>&1 | sed 's/^/        /' || true
  echo "        ---- state dirs ----"
  docker exec "$NAME" ls -la /run/rstudio-server /var/lib/rstudio-server 2>&1 | sed 's/^/        /' || true
  echo "        ---- in-container curl (loopback) ----"
  docker exec "$NAME" bash -c "curl -sS -m 5 -o /dev/null -w '%{http_code}\n' http://127.0.0.1:${PORT}/auth-sign-in" 2>&1 | sed 's/^/        /' || true
  echo "        ---- in-container curl (eth0) ----"
  docker exec "$NAME" bash -c "curl -sS -m 5 -o /dev/null -w '%{http_code}\n' http://\$(hostname -i | awk '{print \$1}'):${PORT}/auth-sign-in" 2>&1 | sed 's/^/        /' || true
  # The exact command the poll runs, un-silenced: if these disagree with the
  # probes above, the problem is THIS side of the socket (curl exit 23 --
  # an unwritable -o target -- reads as "never served" otherwise).
  echo "        ---- host-side poll curl, verbose ----"
  curl -v -m 5 -o "$page" "http://${ADDR}:${PORT}/auth-sign-in" 2>&1 | tail -12 | sed 's/^/        /' || true
}

# Poll the sign-in page. 90 s is generous -- a healthy rserver serves it in
# well under 10 -- but a loaded CI runner should not produce a false failure.
deadline=$((SECONDS + 90))
until curl -fsS -o "$page" "http://${ADDR}:${PORT}/auth-sign-in" 2>/dev/null; do
  if [ "$(docker inspect -f '{{.State.Running}}' "$NAME" 2>/dev/null)" != "true" ]; then
    echo "  FAIL  rserver exited before serving the sign-in page"
    diag
    exit 1
  fi
  if (( SECONDS >= deadline )); then
    echo "  FAIL  rserver is running but never served /auth-sign-in"
    diag
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
