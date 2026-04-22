#!/usr/bin/env bash
# Installiert und aktiviert eine Nginx-Reverse-Proxy-Config fuer Vexa.
# Standard-Setup:
#   Domain      -> API Gateway  (localhost:8056)
#   /dashboard/ -> Vexa Dashboard (localhost:3001)
set -euo pipefail

if [[ "${EUID:-0}" -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

DOMAIN="${DOMAIN:-goproto.goecloud.eu}"
API_UPSTREAM="${API_UPSTREAM:-127.0.0.1:8056}"
DASHBOARD_UPSTREAM="${DASHBOARD_UPSTREAM:-127.0.0.1:3001}"

TEMPLATE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/nginx-vexa.conf.template"
TARGET_PATH="/etc/nginx/sites-available/vexa.conf"
ENABLED_PATH="/etc/nginx/sites-enabled/vexa.conf"

install_nginx_if_missing() {
  if command -v nginx >/dev/null 2>&1; then
    return 0
  fi

  if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update
    $SUDO apt-get install -y nginx
    return 0
  fi

  echo "nginx nicht gefunden und apt-get nicht verfuegbar. Bitte nginx manuell installieren." >&2
  exit 1
}

install_envsubst_if_missing() {
  if command -v envsubst >/dev/null 2>&1; then
    return 0
  fi

  if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update
    $SUDO apt-get install -y gettext-base
    return 0
  fi

  echo "envsubst nicht gefunden. Bitte gettext-base manuell installieren." >&2
  exit 1
}

render_template() {
  DOMAIN="$DOMAIN" API_UPSTREAM="$API_UPSTREAM" DASHBOARD_UPSTREAM="$DASHBOARD_UPSTREAM" \
    envsubst '${DOMAIN} ${API_UPSTREAM} ${DASHBOARD_UPSTREAM}' < "$TEMPLATE_PATH"
}

install_nginx_if_missing
install_envsubst_if_missing

if [[ ! -f "$TEMPLATE_PATH" ]]; then
  echo "Template nicht gefunden: $TEMPLATE_PATH" >&2
  exit 1
fi

render_template | $SUDO tee "$TARGET_PATH" >/dev/null

if [[ ! -L "$ENABLED_PATH" ]]; then
  $SUDO ln -s "$TARGET_PATH" "$ENABLED_PATH"
fi

if [[ -L /etc/nginx/sites-enabled/default ]]; then
  $SUDO rm /etc/nginx/sites-enabled/default
fi

$SUDO nginx -t
$SUDO systemctl reload nginx

echo "Nginx-Integration aktiv."
echo "Domain: $DOMAIN"
echo "API Gateway Upstream: $API_UPSTREAM"
echo "Dashboard Upstream: $DASHBOARD_UPSTREAM"
echo "Test: curl -I http://$DOMAIN/docs"
