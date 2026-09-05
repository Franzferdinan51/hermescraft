# HermesCraft + Hermes Bot Mode

HermesCraft rides on the modern Hermes Bot architecture. Every character is a
real **Hermes profile** (`~/.hermes/profiles/minecraft-<name>`), which is
exactly the primitive Hermes **Bot Mode** manages — meaning the whole cast
shows up in the Hermes desktop app's *Bots* tab, each with its own role,
model, memory, skills, avatar, and a canonical bot chat.

## Character = profile = bot

| Character | Profile | Bot body port | Role |
|---|---|---|---|
| DuckBot | `minecraft-duckbot` | 3001 | Overseer / lead, talks to the player |
| Steve | `minecraft-steve` | 3011 | Construction foreman (your buddy) |
| Reed | `minecraft-reed` | 3012 | Builder — dock, paths, interiors |
| Moss | `minecraft-moss` | 3013 | Farmer — paths, gardens, crops |
| Flint | `minecraft-flint` | 3014 | Miner — stone, ore, coal |
| Ember | `minecraft-ember` | 3015 | Guardian — light, fire, beds, smelting |

Each profile pins its own inference provider (commonly a local LM Studio /
llama.cpp endpoint via `model.provider: custom`), so different characters can
run on different models side by side.

## What the launchers do

- `run-landfolk-bots.sh MC_PORT` — starts the six Mineflayer **bodies**,
  one per API port (DuckBot 3001, Landfolk 3011–3015).
- `run-landfolk-agent.sh NAME API_PORT PROMPT_FILE [PROFILE]` — starts one
  character's Hermes **brain** with:
  - `HERMES_HOME=$HOME/.hermes/profiles/$PROFILE` (Bot profile)
  - `hermes chat --cli --yolo --query-file <prompt>` (modern, shell-safe
    prompt delivery — nothing is shell-interpreted)
  - `MC_API_URL` + `MC_USERNAME` bound to that character's body
- `landfolk.sh` — convenience wrapper that boots bodies **and** brains for
  the whole cast in one command.

If a profile doesn't exist yet, `run-landfolk-agent.sh` tries
`hermes profile create <name> --clone` to scaffold it from your default
profile before running.

## Interacting from the desktop Bots tab

Because each character is a real profile, you can open the **Bots** tab in
the Hermes desktop app and talk to DuckBot, Steve, Reed, Moss, Flint, or
Ember outside the game. Their memories, skills, and chat history are the
same ones their in-game brains use — so guidance you give in the app carries
into the world.

Bot routines (recurring jobs like "every morning, check torches around the
village") are ordinary Hermes cron jobs namespaced `[bot:minecraft-<name>]`
and show up in `hermes cron list`. You can schedule them from the CLI (run
the command under the character's profile via `-p <profile>`):

```bash
hermes -p minecraft-ember cron create "0 9 * * *" \
  --name "torch-check" \
  "Run mc status; if it is night, mc sleep. Keep it to one safe action."
```

`--deliver bot-chat[:minecraft-ember]` injects the run's output into that
character's canonical Bot Chat as a message it can respond to.

## CLI parity cheat sheet

| Bot Mode action | CLI equivalent |
|---|---|
| Chat with a character | `hermes -p minecraft-steve chat` |
| A character's files | `~/.hermes/profiles/minecraft-steve/` |
| Its routines | `hermes cron list` (look for `[bot:minecraft-*]`) |
| Create / inspect profiles | `hermes profile create/list` |

## Why this is better than the old model

The original HermesCraft copied `~/.hermes/config.yaml` into per-agent home
directories (`~/.hermes-landfolk-<name>`), swapped SOUL files by rewrite, and
passed prompts inline via `hermes chat -q "<prompt>"`. Modern HermesCraft:

- uses first-class **profiles** for isolation and Bot Mode visibility
- delivers prompts via **`--query-file`** so quotes/backticks are preserved
  and nothing is shell-interpreted
- pins a **model per character** instead of one shared model
- preloads **skills** (minecraft-survival, farming, building, combat,
  navigation) when the profile has them installed