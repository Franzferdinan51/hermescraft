#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# run-landfolk-agent.sh — Launch ONE Hermes brain for a Landfolk bot
#
# Modern Hermes pattern: per-bot Hermes profile (Bot Mode), a prompt file
# delivered via --query-file (nothing shell-interpreted), --cli for a
# headless non-interactive loop, and -s to preload the minecraft skills.
#
# Usage:
#   ./scripts/run-landfolk-agent.sh NAME API_PORT PROMPT_FILE [PROFILE]
#
#   NAME          character / bot username (e.g. Steve, DuckBot)
#   API_PORT      bot body API port (e.g. 3011)
#   PROMPT_FILE   prompt that seeds this character's first turn
#   PROFILE       optional Hermes profile name (default: minecraft-<NAME>)
#
# Environment:
#   MODEL, PROVIDER, SKILLS  optional overrides (defaults: inherits profile
#                            model; skills = minecraft-survival,farming,...)
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

NAME="${1:?Usage: run-landfolk-agent.sh NAME API_PORT PROMPT_FILE [PROFILE]}"
API_PORT="${2:?Usage: run-landfolk-agent.sh NAME API_PORT PROMPT_FILE [PROFILE]}"
PROMPT_FILE="${3:?Usage: run-landfolk-agent.sh NAME API_PORT PROMPT_FILE [PROFILE]}"
NAME_LOWER="$(printf '%s' "$NAME" | tr '[:upper:]' '[:lower:]')"
PROFILE="${4:-minecraft-${NAME_LOWER}}"

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SCRIPT_DIR"

# Modern default: preload the minecraft skills so the brain can act competently.
# Leave empty (or set SKILLS="") to skip skill preloading and run exactly like
# the live deployment. Only set this if the named skills are installed in the
# target Hermes profile's skills/ store.
SKILLS="${SKILLS:-}"

# Resolve hermes CLI.
HERMES=""
for c in hermes "$HOME/.local/bin/hermes" /usr/local/bin/hermes; do
  if command -v "$c" &>/dev/null || [ -x "$c" ]; then HERMES="$c"; break; fi
done
[ -z "$HERMES" ] && { echo "[$NAME] ✗ hermes CLI not found"; exit 1; }

# Resolve the Hermes profile HOME (Bot Mode primitive) — create from the
# base profile if the specialist doesn't exist yet.
PROFILE_HOME="$HOME/.hermes/profiles/$PROFILE"
if [ ! -d "$PROFILE_HOME" ]; then
  echo "[$NAME] creating Bot-profile $PROFILE (no existing profile)..."
  "$HERMES" profile create "$PROFILE" --clone >/dev/null 2>&1 \
    && echo "    ✓ profile $PROFILE created" \
    || echo "    ⚠ could not auto-create profile $PROFILE (will try to run anyway)"
fi

echo "[$NAME] waiting for bot body on port ${API_PORT}..."
until curl -sf "http://127.0.0.1:${API_PORT}/health" >/dev/null 2>&1; do
  sleep 1
done

echo "[$NAME] starting Hermes brain: --cli --yolo --query-file ${PROMPT_FILE}"
echo "[$NAME] profile=${PROFILE}  MC_API_URL=http://127.0.0.1:${API_PORT}"
[ -n "$SKILLS" ] && echo "[$NAME] skills=${SKILLS}"

export PATH="$SCRIPT_DIR/bin:$PATH"
export HERMES_HOME="$PROFILE_HOME"
export MC_API_URL="http://127.0.0.1:${API_PORT}"
export MC_USERNAME="$NAME"

_ARGS=(chat --cli --yolo --query-file "$PROMPT_FILE")
[ -n "$SKILLS" ] && _ARGS+=(-s "$SKILLS")
exec "$HERMES" "${_ARGS[@]}" "$@"