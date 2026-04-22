#!/usr/bin/env bash
# Sendet einen Vexa-Bot zu einem Microsoft Teams Meeting (self-hosted Gateway).
# Konfiguration: Projekt-.env (siehe env.example im Repo-Root) oder Umgebungsvariablen.
#
# Aufruf (Pfad beachten — es gibt kein Unterverzeichnis scripts/ innerhalb von scripts/):
#   cd ~/GoProto && chmod +x scripts/teams-bot-example.sh && ./scripts/teams-bot-example.sh
# oder bereits in scripts/:
#   cd ~/GoProto/scripts && chmod +x teams-bot-example.sh && ./teams-bot-example.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$ROOT/.env" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ROOT/.env"
  set +a
fi

API_BASE="${API_BASE:-http://localhost:8056}"
API_KEY="${API_KEY:?Fehlt API_KEY — in $ROOT/.env setzen oder export API_KEY=...}"
TEAMS_NATIVE_MEETING_ID="${TEAMS_NATIVE_MEETING_ID:?Fehlt TEAMS_NATIVE_MEETING_ID (Zahl aus teams.live.com/meet/...)}"
TEAMS_PASSCODE="${TEAMS_PASSCODE:?Fehlt TEAMS_PASSCODE (Parameter p= aus der Meeting-URL)}"
BOT_NAME="${BOT_NAME:-Vexa Notetaker}"
LANGUAGE="${LANGUAGE:-de}"

payload=$(printf '%s' "{
  \"platform\": \"teams\",
  \"native_meeting_id\": \"${TEAMS_NATIVE_MEETING_ID}\",
  \"passcode\": \"${TEAMS_PASSCODE}\",
  \"bot_name\": \"${BOT_NAME}\",
  \"language\": \"${LANGUAGE}\",
  \"recording_enabled\": true,
  \"transcribe_enabled\": true,
  \"transcription_tier\": \"realtime\",
  \"voice_agent_enabled\": false
}")

curl -sS -X POST "$API_BASE/bots" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d "$payload"
