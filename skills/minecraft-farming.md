---
name: minecraft-farming
description: Food production in Minecraft — crop farming, animal breeding, cooking, food sources
triggers:
  - minecraft farm
  - grow food minecraft
  - minecraft food
  - breed animals
version: 4.0.0
---

# Minecraft Farming

## Commands (full farming + ranching action set)

```
mc till [count=5]                 # hoe dirt/grass -> farmland (needs a hoe equipped)
mc sow SEED [count=10]            # plant on empty farmland (auto-picks a seed if omitted)
mc harvest [radius=8] [cap=16]    # reap mature crops (wheat/carrot/potato/beetroot) + loot drops
mc breed cow|sheep|pig|chicken    # feed 2 adults to produce a baby (need the right food)
mc shear                          # shear a nearby sheep for wool (need shears)
mc milk                           # milk a nearby cow for milk_bucket (need a bucket)
mc fish [timeout=120]             # fish at open water with sky (need a fishing_rod)
mc bg_fish [timeout=180]          # background cast via /task/fish — keeps checking chat
mc collect CROP N                 # hand-harvest crops / break grass for seeds
mc craft ITEM                     # craft tools (stone_hoe, shears, bucket, fishing_rod)
mc smelt RAW_FOOD                 # cook food in furnace
mc inventory                      # check what you have before you act
```

Breeding food map:

```
cow/mooshroom/sheep -> wheat          pig -> carrot potato beetroot
chicken              -> wheat_seeds / melon_seeds / pumpkin_seeds / beetroot_seeds
```

## Quick Food (Early Game)

1. Kill animals: `mc attack cow`, `mc attack pig`, `mc attack chicken` (or
   `mc bg_fight cow`) — or raise them instead: `mc breed`.
2. `mc pickup` — collect raw meat.
3. `mc smelt raw_beef` (or raw_porkchop, raw_chicken).
4. Cooked steak = 8 food points (best common food).

## Crop Farming (the modern flow)

1. Craft a hoe: `mc craft stone_hoe`.
2. `mc till` — the bot hoes the nearest clear dirt/grass within 5 blocks
   (turns coarse/rooted dirt to dirt first, then tills to farmland). Water
   within 4 blocks keeps it hydrated.
3. Get seeds: `mc collect short_grass` (wheat_seeds) or `mc harvest`.
4. `mc sow [seed]` — plants on empty farmland, up to 20.
5. Later: `mc harvest` — reaps mature crops and walks over the drops to
   loot them. Replant with `mc sow` to keep the cycle going.

### Growth notes
- Wheat/carrots/potatoes mature in ~20 minutes of daylight; beetroot ~10.
- Ripe wheat is golden; `mc inspect X Y Z` shows a crop's current age
  (`metadata`/properties).
- Harvest order: wheat age 7, carrots age 7, potatoes age 7, beetroot age 3.

### Animal Products (ranching)
- **Cow**: beef, leather, and `mc milk` for milk_bucket (drinks clear poison).
- **Pig**: porkchop. **Chicken**: meat + feathers + eggs.
- **Sheep**: `mc shear` for wool (regrows after it eats grass).

## Food Rankings (food points + saturation)

```
Golden carrot:     6 food, 14.4 sat  (best overall)
Cooked steak:      8 food, 12.8 sat  (best farmable)
Cooked porkchop:   8 food, 12.8 sat  (tied with steak)
Baked potato:      5 food, 6.0 sat   (easy to mass produce)
Bread:             5 food, 6.0 sat   (easy early game)
Cooked chicken:    6 food, 7.2 sat   (decent)
Apple:             4 food, 2.4 sat   (oak tree drops)
```