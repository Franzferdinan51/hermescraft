#!/usr/bin/env bash
set -euo pipefail

MC_PORT="${1:?Usage: run-steve-bot.sh MC_PORT [API_PORT]}"
API_PORT="${2:-3001}"
MC_HOST="${MC_HOST:-127.0.0.1}"
MC_AUTH="${MC_AUTH:-offline}"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BOT_DIR="$SCRIPT_DIR/bot"

cd "$BOT_DIR"

echo "[Steve bot] starting Steve on API ${API_PORT} -> ${MC_HOST}:${MC_PORT}"
MC_HOST="$MC_HOST" MC_PORT="$MC_PORT" MC_AUTH="$MC_AUTH" MC_USERNAME="Steve" API_PORT="$API_PORT" node server.js > /tmp/bot-steve.log 2>&1