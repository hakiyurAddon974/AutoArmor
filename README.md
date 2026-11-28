# AutoArmor 1.0.0 — WoW Forever

Stable release promoted from the owner-approved 1.0.0-rc.1 on 2026-11-28.
Only the AutoArmor folder belongs in Interface/AddOns. Documentation and tests
are supplied alongside it; they are not additional addons.

## What changed

- A bounded, whole-outfit search compares combinations across slots, including
  paired rings, trinkets, weapon hands, unique categories and recognized set bonuses.
- A weaker individual piece can win as part of a better complete combination.
  Related changes are applied together and revalidated before equipment calls.
- Class and intended specialization drive heuristic stat weights. Supported
  committed talent descriptions and client rating conversions refine them.
  Manually selecting another specialization does not reuse incompatible active talents.
- Forever feral weapon DPS is included. Unknown effects still require review;
  recognized on-use effects are explained without assuming their activation uptime.
- Analysis runs in cancellable slices and is invalidated when the character or
  inventory changes. Automatic triggers never apply a partial weapon-disabled plan.
- Three primary tabs: Equipment, History, Settings. Protections, diagnostics and
  Compare / Keep remain accessible from Equipment.
- Compare an item with Ctrl+Alt+click, inspect the entire proposed combination,
  or mark an item to keep for another specialization. Nothing is sold or deleted.
- Quest advice compares rewards against equipment already available in bags.
  It never selects a reward or turns in a quest.

## Controls and existing settings

Left-click an embedded AA button to optimize; right-click for settings.
Advice-only mode makes the AA button show proposals first.
The language dropdown and intended-specialization dropdown remain available.
No saved profile manager or Pawn integration is included.

New characters start with quest and level-up automation disabled. Existing
automation settings are preserved: check them before a strictly manual test.
Locks, protected/reserved items, manual holds, history and undo remain supported.
The validated notification implementation is unchanged from beta.3.

## Limits and validation

Scores are estimates, not simulated DPS, healing or survival gains. The search
prunes large spaces and cannot guarantee a global optimum or best-in-slot gear.
Unrecognized procs, conditional talents, set effects and uncertain roles remain
explicitly limited; no guessed hit/defense caps or encounter model is applied.
Changing between one-hand/off-hand and two-hand setups requires the separate
weapon configuration review. This release targets Forever interface 16001.

23 Lua modules compile and 93 simulated regression scenarios pass, including
40 small inventories checked against exhaustive enumeration and two 200-item
stress cases. These are Lua 5.4 tests with mocked WoW APIs, not an in-game test.
See Documentation/VALIDATION.md and Documentation/TEST_EN_JEU.md.

The approved candidate runtime is unchanged apart from the version label.

Project: https://www.curseforge.com/wow/addons/autoarmor
Source: https://github.com/hakiyurAddon974/AutoArmor
