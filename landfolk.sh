#!/usr/bin/env bash
# HermesCraft Landfolk — 5 in-world characters for a player's LAN world
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BOT_DIR="$SCRIPT_DIR/bot"
BIN_DIR="$SCRIPT_DIR/bin"
PROMPT_DIR="$SCRIPT_DIR/prompts/landfolk"
SOUL_FILE="$SCRIPT_DIR/SOUL-landfolk.md"

# Preserve the currently working Anthropic env from the calling shell.
# Do not override it with stale on-disk values.
MC_HOST="${MC_HOST:-127.0.0.1}"
MC_PORT="${MC_PORT:-25565}"
MC_AUTH="${MC_AUTH:-offline}"
MODEL=""
PROVIDER=""
# Modern Hermes: each character is a Bot profile under ~/.hermes/profiles/.
PROFILE_PREFIX="minecraft"
BOTS_ONLY=false
AGENTS_ONLY=false

# Cast (name:role). DuckBot is the overseer; the rest are the Landfolk cast.
# Ports match the live HermesCraft deployment (DuckBot 3001, Landfolk 3011-3015).
CAST=(
  "DuckBot:overseer:3001"
  "Steve:friend:3011"
  "Reed:water:3012"
  "Moss:garden:3013"
  "Flint:stone:3014"
  "Ember:fire:3015"
)

PIDS=()
BOT_PIDS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bots-only) BOTS_ONLY=true; shift ;;
    --agents-only) AGENTS_ONLY=true; shift ;;
    --port) MC_PORT="$2"; shift 2 ;;
    --profile-prefix) PROFILE_PREFIX="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    --provider) PROVIDER="$2"; shift 2 ;;
    --help|-h)
      echo "Landfolk launcher"
      echo "Usage: ./landfolk.sh [--port LAN_PORT] [--agents-only] [--bots-only]"
      echo ""
      echo "Options:"
      echo "  --port PORT         Minecraft server port (default: 25565)"
      echo "  --profile-prefix P  Hermes profile prefix (default: minecraft)"
      echo "  --model M / --provider P   overrides for the brains"
      exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

cleanup() {
  echo ""
  echo "  Stopping landfolk..."
  for pid in "${PIDS[@]}"; do kill "$pid" 2>/dev/null || true; done
  if [ "$AGENTS_ONLY" = false ]; then
    for pid in "${BOT_PIDS[@]}"; do kill "$pid" 2>/dev/null || true; done
  fi
  wait 2>/dev/null || true
}
trap cleanup EXIT INT TERM

export PATH="$BIN_DIR:$PATH"
HERMES=""
for c in hermes "$HOME/.local/bin/hermes" /usr/local/bin/hermes; do
  if command -v "$c" &>/dev/null || [ -x "$c" ]; then HERMES="$c"; break; fi
done
[ -z "$HERMES" ] && { echo "hermes CLI not found"; exit 1; }

[ -d "$BOT_DIR/node_modules" ] || { echo "Installing bot deps..."; cd "$BOT_DIR" && npm install --no-audit --no-fund; cd "$SCRIPT_DIR"; }

if [ "$AGENTS_ONLY" = false ]; then
  echo "Starting landfolk bot bodies on $MC_HOST:$MC_PORT"
  for entry in "${CAST[@]}"; do
    IFS=':' read -r name role port <<< "$entry"
    cd "$BOT_DIR"
    MC_HOST="$MC_HOST" MC_PORT="$MC_PORT" MC_AUTH="$MC_AUTH" MC_USERNAME="$name" API_PORT="$port" node server.js > "/tmp/bot-${name,,}.log" 2>&1 &
    BOT_PIDS+=($!)
    cd "$SCRIPT_DIR"
    sleep 2
  done
  sleep 5
fi

FAILED=()
for entry in "${CAST[@]}"; do
  IFS=':' read -r name role port <<< "$entry"
  CONN=$(curl -sf "http://127.0.0.1:$port/health" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('connected',False))" 2>/dev/null || echo "False")
  if [ "$CONN" != "True" ]; then
    FAILED+=("$name")
  fi
done
if [ ${#FAILED[@]} -gt 0 ]; then
  echo "These bot bodies are not connected: ${FAILED[*]}"
  exit 1
fi

[ "$BOTS_ONLY" = true ] && { echo "Bots ready."; wait; exit 0; }

# Modern Hermes: every character is its own Bot profile; brains use the
# proven `hermes chat --cli --yolo --query-file <prompt>` invocation.
for entry in "${CAST[@]}"; do
  IFS=':' read -r name role port <<< "$entry"
  name_lower="${name,,}"
  PROFILE="${PROFILE_PREFIX}-${name_lower}"
  PROMPT_FILE="$PROMPT_DIR/${name_lower}.md"
  [ -f "$PROMPT_FILE" ] || PROMPT_FILE="$SOUL_FILE"

  echo "  🧠 $name ($role) on port $port · profile=$PROFILE"

  HERMES_ARGS=(chat --cli --yolo --query-file "$PROMPT_FILE")
  [ -n "${SKILLS:-}" ] && HERMES_ARGS+=(-s "$SKILLS")
  [ -n "$MODEL" ] && HERMES_ARGS+=(-m "$MODEL")
  [ -n "$PROVIDER" ] && HERMES_ARGS+=(--provider "$PROVIDER")

  HERMES_HOME="$HOME/.hermes/profiles/$PROFILE" MC_API_URL="http://127.0.0.1:$port" MC_USERNAME="$name" "$HERMES" "${HERMES_ARGS[@]}" > "/tmp/agent-${name_lower}.log" 2>&1 &
  PIDS+=($!)
  sleep 4
done

echo ""
echo "Landfolk launched."
echo "Use: ./landfolk.sh --port <LAN_PORT>"
wait
