# HermesCraft

```text
██╗  ██╗███████╗██████╗ ███╗   ███╗███████╗███████╗ ██████╗██████╗  █████╗ ███████╗████████╗
██║  ██║██╔════╝██╔══██╗████╗ ████║██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝
███████║█████╗  ██████╔╝██╔████╔██║█████╗  ███████╗██║     ██████╔╝███████║█████╗     ██║
██╔══██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══╝  ╚════██║██║     ██╔══██╗██╔══██║██╔══╝     ██║
██║  ██║███████╗██║  ██║██║ ╚═╝ ██║███████╗███████║╚██████╗██║  ██║██║  ██║██║        ██║
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝

Embodied Hermes agents for Minecraft.
One agent can feel like a companion.
Many agents can make a world feel alive.
```

HermesCraft lets you play Minecraft with Hermes agents as actual in-world players.

A Hermes agent can join your world, chat with you in Minecraft, follow you, gather resources, build, fight, remember what happened, and adapt over time. The same architecture also scales to multi-agent worlds, where many Hermes agents share the same server, privately message each other, and gradually become characters in the world.

Built for the Nous Hermes hackathon.

## What HermesCraft actually is

HermesCraft is not a fake NPC framework and not a separate custom agent runtime.

Each character is a normal Hermes agent with:
- its own `HERMES_HOME`
- its own memory and session history
- its own SOUL / prompt
- its own Minecraft bot body
- the standard Hermes tool stack
- the `mc` interface for Minecraft-specific action and perception

Core architecture:

```text
Hermes Agent
  -> terminal + tools
  -> mc CLI
  -> bot/server.js HTTP API
  -> Mineflayer bot body
  -> Minecraft world
```

That same stack powers:
- one companion in your personal world
- a small cast of world characters
- larger multi-agent simulations

## Why this matters

Most Minecraft AI projects are one of these:
- benchmark agents
- scripted NPCs
- bots with too much privileged information

HermesCraft is trying to be something more useful and more believable:
- embodied instead of disembodied
- fair instead of x-ray omniscient
- persistent instead of sessionless
- social instead of purely task-oriented
- usable by normal players in a real Minecraft world

Long term, this points toward MiroFish-style agent societies — but in a physical sandbox world with terrain, resources, danger, geography, structures, and human players.

## Main modes

### Companion Mode

Run one Hermes agent as an in-world Minecraft friend.

What it can do today:
- chat with you in Minecraft
- follow you around
- help gather resources
- help build
- scout the area
- fight / flee / survive with you
- remember what happened across sessions
- adapt to your preferences over time

Good use cases:
- "follow me"
- "help me build a house"
- "gather wood while I mine stone"
- "come explore this cave with me"

### Civilization Mode

Run multiple Hermes agents in the same world.

What makes it interesting:
- separate memory and identity per character
- public chat, private DMs, overhearing, and commands
- fair-play perception and local world understanding
- emergent routines, alliances, tension, and division of labor
- the world starts to feel inhabited instead of empty

The current featured civilization cast is the crash-survivor group:
- Marcus
- Sarah
- Jin
- Dave
- Lisa
- Tommy
- Elena

### Landfolk Mode

A 6-character cast (DuckBot + 5 Landfolk) for a player's LAN world.

Current cast:
- DuckBot — the overseer / lead, your main point of contact
- Steve — your normal Minecraft buddy (construction foreman)
- Reed — wants to build a fishing shack on the water
- Moss — makes paths, gardens, and cozy green spaces (farmer)
- Flint — gravitates toward caves, stone, and mining routes
- Ember — builds hearth and forge energy around camp

This mode is meant to make a normal personal world feel more alive without going all the way to a full civilization sim.

## Core features

### Embodied gameplay
- movement and pathfinding
- mining and collection
- crafting and smelting
- chest interaction
- combat and fleeing
- location marking and return
- background tasks so agents can keep checking chat while acting

### Fair-play perception
- line-of-sight filtering for entities
- directional sound hints
- `mc look` for natural-language surroundings
- `mc map` for ASCII spatial understanding
- `mc scene` for current-view fair-play scene summary
- `mc screenshot_meta` for screenshot + synchronized scene/state metadata

### Social systems
- public chat
- direct and group private messages
- overhearing nearby private conversation
- queued in-game commands from human players
- social summary / recent interaction state

### Persistent identity
- per-agent memory
- per-agent sessions
- per-agent prompts / SOUL
- per-agent saved locations

## Stable vs experimental

Most stable path today:
- one companion via `hermescraft.sh`
- direct Hermes-per-agent launches when you want total control
- `civilization.sh` for the crash-survivor cast

More experimental / still being hardened:
- convenience wrappers that spawn lots of terminals automatically
- older experimental arena / battle variants

If you want the most reliable behavior, use the direct or primary launcher flows shown below.

## Prerequisites

- Node.js 18+
- Python 3
- Hermes CLI installed and authenticated
- Minecraft Java Edition
- optional: Java if you want to use the included Paper server flow

Setup:

```bash
cd ~/hermescraft
./setup.sh
```

## Quickstart

### Companion Mode

Fastest way to start one Minecraft buddy (Steve):

```bash
cd ~/hermescraft
./start-steve.sh
```

The script asks for your LAN port, starts Steve's bot body, then opens a terminal running Steve's Hermes brain.

If you already have a world open to LAN and want the generic single-agent flow instead:

```bash
cd ~/hermescraft
MC_PORT=<LAN_PORT> ./hermescraft.sh
```

Examples in chat:
- `hermes follow me`
- `hermes help me build here`
- `hermes gather oak logs`
- `hermes what do you see?`

### Civilization Mode

```bash
cd ~/hermescraft
./civilization.sh --port <PORT>
```

### Landfolk Mode

Most reliable path:
1. start the bot bodies
2. launch each Hermes brain directly in its own terminal

Start the Landfolk bot bodies (modern HermesCraft 26.2, offline auth):

```bash
cd ~/hermescraft
./scripts/run-landfolk-bots.sh 25565    # DuckBot:3001, Steve:3011, Reed:3012, Moss:3013, Flint:3014, Ember:3015
```

Then launch one agent per terminal. Each character is a Hermes **Bot
profile** (`~/.hermes/profiles/minecraft-<name>`) and runs the modern
`--query-file` invocation:

```bash
cd ~/hermescraft
./scripts/run-landfolk-agent.sh Steve 3011 prompts/landfolk/steve.md minecraft-steve
```

Repeat for Reed (3012), Moss (3013), Flint (3014), Ember (3015), and
DuckBot (3001) with their matching profile and prompt. You can also just run
`./landfolk.sh` once, which starts bodies **and** agents for the whole cast.

> **Model note:** each profile pins its own model (e.g. a local LM Studio /
  llama.cpp endpoint via `provider: custom`). Set `MODEL`/`PROVIDER` env on
  the `run-landfolk-agent.sh` or `landfolk.sh` command to override per run.

## Useful `mc` commands

Observation:

```bash
mc status
mc inventory
mc nearby 24
mc look
mc map 24
mc scene 16
mc social
mc read_chat
mc commands
```

Action:

```bash
mc bg_collect oak_log 5
mc bg_goto 100 64 100            # long-distance walk (range default 3)
mc till                           # hoe dirt -> farmland
mc sow wheat_seeds                # plant crops
mc harvest                        # reap ripe crops
mc breed cow                      # breed two cows
mc shear                          # shear sheep
mc milk                           # milk a cow
mc fish                           # cast at open water
mc door                           # open nearest door
mc surface                        # get back to dry ground if submerged
mc inspect 100 63 100            # check a block before acting
mc follow Steve
mc craft stone_pickaxe
mc fight zombie
mc flee 16
mc chat "hello"
mc whisper Reed "meet me by the shore"
```

Vision:

```bash
mc screenshot_meta
```

## Fairness and non-xray design

HermesCraft is intentionally trying to avoid god-mode behavior.

In fair-play mode:
- entities are filtered by line of sight and range
- sounds are directional hints rather than exact coordinates
- `mc scene` reports what is visible in the current view cone plus remembered nearby landmarks
- resource finding is biased toward visible blocks instead of omniscient scans
- agents are encouraged to admit uncertainty and reposition instead of bluffing

This matters for both believability and demo integrity.

## Repository guide

Primary files:
- `hermescraft.sh` — single-agent companion launcher
- `civilization.sh` — multi-agent civilization launcher
- `landfolk.sh` — small-cast LAN launcher (bodies + brains, 6-bot cast)
- `scripts/run-landfolk-bots.sh` — start the 6 Landfolk bot bodies
- `scripts/run-landfolk-agent.sh` — launch one Landfolk Hermes brain (profile + --query-file)
- `bot/server.js` — Mineflayer HTTP bot server
- `bot/lib/` — routing and perception helpers
- `bot/test/` — unit tests
- `bin/mc` — CLI for observation and action
- `SOUL-minecraft.md` — companion behavior
- `SOUL-civilization.md` — civilization behavior
- `SOUL-landfolk.md` — landfolk behavior
- `prompts/` — character prompts (incl. `prompts/landfolk/duckbot.md`)
- `skills/` — minecraft skills taught to the characters
- `docs/` — mode notes, BOT_MODE.md (Bot Mode mapping), and hackathon/demo docs

Archived reference / experimental material:
- `docs/archive/` — old plans, audits, arena notes
- `archive/experimental/` — older battle / arena / side-mode experiments

## Testing

```bash
cd bot
npm test
```

Sanity checks:

```bash
node --check bot/server.js
bash -n civilization.sh
bash -n hermescraft.sh
bash -n landfolk.sh
bash -n setup.sh
bash -n server/start.sh
bash -n scripts/run-landfolk-agent.sh
bash -n scripts/run-landfolk-bots.sh
```

## Known limitations

Current focus is early/mid-game survival, companion play, and small-society behavior — not full endgame autonomy.

Still rough:
- automated batch launchers need more hardening than direct per-agent launches
- building taste still benefits from screenshot + vision loops
- longer-term social simulation needs stronger town-level memory / replay tooling
- public clean-room reproducibility still depends on a reasonably configured local Hermes + Minecraft environment

## Big picture

Minecraft is the proving ground, not the endpoint.

HermesCraft is really about whether the same Hermes architecture can work in two human-legible scales:
- personal companionship
- multi-agent worlds

If one agent can feel like a friend, and many agents can start to make a world feel inhabited, that is a strong foundation for persistent embodied AI systems.

## License

MIT
