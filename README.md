# AutoArmor

Smart gear selection for **World of Warcraft: Forever**. Use the **AA** buttons on
the character window or bags: left-click to optimize, right-click for options.
Bagnon is supported. English and French are available from the language dropdown.

## Version 0.8.0-beta.3

- Compare gear using built-in class and specialization stat weights, or item level.
- Choose the specialization you intend to play, or use automatic detection from
  recognized specialization/talent data. Your choice does not change your talents.
- Compare weapon combinations, rings and trinkets while respecting unique items,
  protected gear, reserved items and manual equipment choices.
- Review uncertain effects, set changes and ambiguous roles before equipping.
- Confirm actual equipment changes before reporting success; inspect history or
  undo the last optimization.
- Use optional quest and level-up automation, discreet animated notifications,
  reduced motion and equipment diagnostics.

No saved profile system or Pawn integration is required or included. Scores are
heuristic estimates, not combat simulations or a guarantee of best-in-slot gear.

## Install

Install the `AutoArmor` folder in `Interface/AddOns`, with `AutoArmor.toc` directly
inside it. When updating manually, replace the old addon folder while the game is
closed; keep SavedVariables to preserve character settings and protections.

See [LISEZ-MOI.md](LISEZ-MOI.md) for French instructions and
[CHANGELOG.md](CHANGELOG.md) for this release's changes.

## Validation

The project owner tested and approved this build for publication. Its 23 runtime
files match the approved local beta.3 package. Automated checks compile 19 Lua
modules and run 52 regression scenarios with simulated WoW APIs.

Run `python3 tests/run.py` with Python 3 and the system Lua 5.4 library installed
(`liblua5.4-0` on Ubuntu). These checks do not reproduce the live game renderer.
