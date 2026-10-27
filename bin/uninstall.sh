#!/usr/bin/env bash
# Stops Infisical and removes its unit and tailnet address. Keeps its data and .env
# (~/.local/share/hisho/infisical and the Docker volumes): deleting those is a separate,
# deliberate step because it destroys every secret stored there.
set -euo pipefail
sudo -n tailscale serve --https="${HISHO_OPT_HTTPS_PORT}" off >/dev/null 2>&1 || true
systemctl --user disable --now hisho-infisical.service || true
rm -f ~/.config/systemd/user/hisho-infisical.service
systemctl --user daemon-reload
