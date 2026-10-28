#!/usr/bin/env bash
# Runs on the Core machine (in this folder) during `hisho addon install infisical`.
# Writes the server's own secrets once (never overwritten: losing ENCRYPTION_KEY loses every
# secret), installs the compose file and a user unit, starts it, and publishes it on the tailnet.
set -euo pipefail
data=~/.local/share/hisho/infisical
mkdir -p "$data" ~/.config/systemd/user
umask 077
if [ ! -f "$data/.env" ]; then
  {
    echo "ENCRYPTION_KEY=$(openssl rand -hex 16)"
    echo "AUTH_SECRET=$(openssl rand -base64 32)"
    pw=$(openssl rand -hex 24)
    echo "POSTGRES_USER=infisical"
    echo "POSTGRES_PASSWORD=$pw"
    echo "POSTGRES_DB=infisical"
    echo "DB_CONNECTION_URI=postgres://infisical:$pw@db:5432/infisical"
    echo "REDIS_URL=redis://redis:6379"
    echo "TELEMETRY_ENABLED=false"
    echo "OTEL_TELEMETRY_COLLECTION_ENABLED=false"
  } > "$data/.env"
  echo "wrote $data/.env (back up ENCRYPTION_KEY: without it the stored secrets can't be read)"
fi
# Its address: the setting, or this machine's tailnet name (a fresh Souko has nothing to type here).
site="${HISHO_OPT_SITE_URL:-}"
if [ -z "$site" ]; then
  dns=$(tailscale status --json 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin)["Self"]["DNSName"].rstrip("."))' 2>/dev/null || true)
  [ -n "$dns" ] || { echo "connect this machine to Tailscale first (Set up your Hisho > Tailscale)" >&2; exit 1; }
  site="https://${dns}:${HISHO_OPT_HTTPS_PORT}"
fi
# settings that may change go in on every install
grep -v -E '^(SITE_URL|INFISICAL_IMAGE|INFISICAL_PORT)=' "$data/.env" > "$data/.env.new" || true
{
  echo "SITE_URL=${site}"
  echo "INFISICAL_IMAGE=${HISHO_OPT_IMAGE}"
  echo "INFISICAL_PORT=${HISHO_OPT_PORT}"
} >> "$data/.env.new"
mv "$data/.env.new" "$data/.env"
chmod 600 "$data/.env"
install -m 644 docker-compose.yml "$data/docker-compose.yml"
install -m 644 units/hisho-infisical.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable hisho-infisical.service >/dev/null
systemctl --user restart hisho-infisical.service
for i in $(seq 1 60); do
  curl -s -m 3 -o /dev/null "http://127.0.0.1:${HISHO_OPT_PORT}/api/status" && break
  sleep 5
done
curl -s -m 5 -o /dev/null -w "infisical local: %{http_code}\n" "http://127.0.0.1:${HISHO_OPT_PORT}/api/status"
# The owner is Tailscale's operator on a Souko (no sudo); elsewhere it publishes with sudo.
tailscale serve --bg --https="${HISHO_OPT_HTTPS_PORT}" "http://127.0.0.1:${HISHO_OPT_PORT}" >/dev/null 2>&1 \
  || sudo -n tailscale serve --bg --https="${HISHO_OPT_HTTPS_PORT}" "http://127.0.0.1:${HISHO_OPT_PORT}" >/dev/null
echo "published: ${site} (tailnet only)"
