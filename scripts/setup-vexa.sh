#!/usr/bin/env bash
# Offizielles Vexa-Stack klonen und starten (PostgreSQL, Redis, MinIO, API-Gateway, Bots, …).
# Voraussetzung: Docker + Compose (siehe scripts/install-docker.sh). git/make/curl werden
# unter Ubuntu/Debian per apt nachinstalliert, falls sie fehlen.
set -euo pipefail

if [[ "${EUID:-0}" -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

VEXA_REPO="${VEXA_REPO:-https://github.com/Vexa-ai/vexa.git}"
VEXA_DIR="${VEXA_DIR:-$HOME/vexa}"

ensure_git_make_curl() {
  local missing=()
  for c in git make curl; do
    command -v "$c" >/dev/null 2>&1 || missing+=("$c")
  done
  [[ ${#missing[@]} -eq 0 ]] && return 0
  if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update
    $SUDO apt-get install -y git make curl
  else
    exit 1
  fi
}

ensure_git_make_curl

if ! command -v docker >/dev/null 2>&1; then
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  exit 1
fi

if [[ ! -d "$VEXA_DIR/.git" ]]; then
  git clone "$VEXA_REPO" "$VEXA_DIR"
fi

cd "$VEXA_DIR"

if [[ ! -f .env ]]; then
  cp deploy/env-example .env
fi

cd deploy/compose
make all
