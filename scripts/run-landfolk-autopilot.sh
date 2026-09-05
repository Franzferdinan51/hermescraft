#!/usr/bin/env bash
# Run one independent, bounded Hermes turn per Landfolk, sequentially.
# One shared local model cannot reliably serve six simultaneous interactive TUIs.
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
HERMES="${HERMES_BIN:-/home/duckets/.hermes/hermes-agent/hermes}"
LOG_DIR="${LAND_FOLK_LOG_DIR:-/tmp/hermescraft-autopilot}"
INTERVAL="${LAND_FOLK_INTERVAL:-30}"
ONCE=0
[[ "${1:-}" == "--once" ]] && ONCE=1
mkdir -p "$LOG_DIR"
export PATH="$ROOT/bin:$PATH"

run_turn() {
  local profile="$1" user="$2" port="$3" role="$4"
  local prompt
  prompt="$(mktemp)"
  cat >"$prompt" <<EOF
You are ${user}, a live Minecraft Landfolk companion. This is one real game turn, not a plan or explanation.
You start at the protected village hearth near x=50 y=64 z=87 wearing iron armor and carrying an iron sword, shield, iron pickaxe, and bread.
First execute: mc status; mc inventory.
Safety is absolute: do not break, place, open, enter, or modify any player-owned house, chest, door, path, farm, sign, or placed block. Do not travel beyond 48 blocks from the hearth. If a safe natural target is not visible, patrol/guard the open perimeter instead of guessing.
Your role this turn: ${role}
Use the mc CLI to perform exactly one bounded physical game action, verify it with mc status or mc inventory, then finish with a terse factual receipt. Do not merely tell me what you would do.
EOF
  echo "[$(date -Is)] starting ${user}" >>"$LOG_DIR/supervisor.log"
  if ! env HERMES_HOME="/home/duckets/.hermes/profiles/${profile}" \
      MC_API_URL="http://127.0.0.1:${port}" MC_USERNAME="$user" \
      timeout 75 "$HERMES" chat --cli --yolo --query-file "$prompt" \
      >>"$LOG_DIR/${user}.log" 2>&1; then
    echo "[$(date -Is)] ${user} turn failed or timed out" >>"$LOG_DIR/supervisor.log"
  fi
  rm -f "$prompt"
}

while :; do
  run_turn minecraft-gemma-bot DuckBot 3001 "Coordinate by sending one brief public status message, then safely patrol the open perimeter; engage an immediate hostile only if it threatens a player or Landfolk."
  run_turn minecraft-steve Steve 3011 "Find an exposed natural stone or coal block on open terrain and collect a small amount with your pickaxe; never mine into a structure or cave."
  run_turn minecraft-reed Reed 3012 "Scout the open perimeter and collect a small amount of a clearly natural resource only if it is visibly separate from all player builds."
  run_turn minecraft-moss Moss 3013 "Find wild open terrain and collect a small amount of naturally grown plant material; do not touch cultivated farmland or any placed crop."
  run_turn minecraft-flint Flint 3014 "Collect a small amount of exposed natural stone or coal only from safe open terrain; do not enter caves."
  run_turn minecraft-ember Ember 3015 "Patrol the open perimeter and protect the group; engage only an immediate hostile threat, otherwise gather one clearly natural open-terrain resource."
  (( ONCE )) && break
  sleep "$INTERVAL"
done
