#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# start-steve.sh — Quick Steve buddy launcher (Companion mode)
#
# Starts Steve's bot body, then opens a terminal running Steve's Hermes
# brain using the modern per-bot profile + --query-file invocation.
#
# Usage:
#   ./start-steve.sh             # prompts for LAN port
#   ./start-steve.sh 25565       # or pass the port directly
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TERMINAL="$(command -v x-terminal-emulator || command -v gnome-terminal || command -v konsole || true)"

MC_PORT="${1:-}"
if [ -z "$MC_PORT" ]; then
  read -rp "Minecraft LAN port: " MC_PORT
fi
if [[ -z "$MC_PORT" ]] || ! [[ "$MC_PORT" =~ ^[0-9]+$ ]]; then
  echo "Port must be numeric."
  exit 1
fi

chmod +x "$SCRIPT_DIR/scripts/run-steve-bot.sh" "$SCRIPT_DIR/scripts/run-landfolk-agent.sh"

# Steve's body rides on 3001 in companion mode (or 3011 for the Landfolk cast).
API_PORT="${API_PORT:-3001}"
PROFILE="minecraft-steve"
PROMPT_FILE="$SCRIPT_DIR/prompts/landfolk/steve.md"

pkill -f "MC_USERNAME=Steve" 2>/dev/null || true
pkill -f '/tmp/bot-steve.log' 2>/dev/null || true
sleep 1

if [ -n "$TERMINAL" ]; then
  echo "Opening Steve terminal..."
  "$TERMINAL" -e bash -lc "cd '$SCRIPT_DIR' && ./scripts/run-steve-bot.sh '$MC_PORT' '$API_PORT' & sleep 3; ./scripts/run-landfolk-agent.sh Steve '$API_PORT' '$PROMPT_FILE' '$PROFILE'; exec bash"
else
  echo "No terminal emulator found. Starting Steve in this terminal."
  cd "$SCRIPT_DIR"
  ./scripts/run-steve-bot.sh "$MC_PORT" "$API_PORT" &
  sleep 3
  ./scripts/run-landfolk-agent.sh Steve "$API_PORT" "$PROMPT_FILE" "$PROFILE"
fi