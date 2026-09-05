#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# run-landfolk-bots.sh — Start the bot BODIES for the Landfolk cast
#
# Cast (matches the live HermesCraft deployment):
#   DuckBot  -> 3001   (overseer / lead, bridge-driven)
#   Steve    -> 3011
#   Reed     -> 3012
#   Moss     -> 3013
#   Flint    -> 3014
#   Ember    -> 3015
#
# Usage:
#   ./scripts/run-landfolk-bots.sh MC_PORT        (default MC_PORT=25565)
#
# Environment:
#   MC_HOST    Minecraft server host (default: 127.0.0.1)
#   MC_PORT    Minecraft server port (default: 25565)
#   MC_AUTH    offline|microsoft (default: offline)
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

MC_HOST="${MC_HOST:-127.0.0.1}"
MC_PORT="${MC_PORT:-25565}"
MC_AUTH="${MC_AUTH:-offline}"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BOT_DIR="$SCRIPT_DIR/bot"

cd "$BOT_DIR"

# name:api_port
CAST=(
  "duckbot:3001"
  "steve:3011"
  "reed:3012"
  "moss:3013"
  "flint:3014"
  "ember:3015"
)

run_bot() {
  local name="$1" api_port="$2"
  echo "[bot] starting $name on API $api_port -> $MC_HOST:$MC_PORT"
  MC_HOST="$MC_HOST" MC_PORT="$MC_PORT" MC_AUTH="$MC_AUTH" MC_USERNAME="$name" API_PORT="$api_port" node server.js > "/tmp/bot-${name}.log" 2>&1 &
}

for entry in "${CAST[@]}"; do
  IFS=':' read -r name port <<< "$entry"
  run_bot "$name" "$port"
  sleep 1
done

echo
printf '[bot] started %d bodies on MC %s:%s\n' "${#CAST[@]}" "$MC_HOST" "$MC_PORT"
echo '[bot] logs: /tmp/bot-{duckbot,steve,reed,moss,flint,ember}.log'
wait