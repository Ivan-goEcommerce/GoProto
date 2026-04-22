#!/usr/bin/env bash
# Docker Engine + Docker Compose Plugin installieren (offizielles Skript inkl. Repo-GPG-Setup).
# Voraussetzung: Debian/Ubuntu oder ein von https://get.docker.com unterstütztes System.
#
# Aufruf: als normaler Benutzer (nutzt sudo) oder als root auf dem Server.
#   ./scripts/install-docker.sh   |   bash scripts/install-docker.sh
set -euo pipefail

if [[ "${EUID:-0}" -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

if command -v apt-get >/dev/null 2>&1; then
  $SUDO apt-get update
  $SUDO apt-get install -y ca-certificates curl
else
  exit 1
fi

curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
$SUDO sh /tmp/get-docker.sh
rm -f /tmp/get-docker.sh

if [[ "${EUID:-0}" -ne 0 ]]; then
  $SUDO usermod -aG docker "${USER}"
fi

docker --version
docker compose version
