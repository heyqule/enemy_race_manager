# Enemy Race Manager — Agent Guide

This is a **Factorio mod** (v2.0.69, target factorio 2.0). It adds multi-race enemies, custom attack groups, boss fights, interplanetary raids, quality-tiered enemies, RTS-style army controls, and GUI overlays.

## Architecture

- **Entrypoints** (standard Factorio mod lifecycle):
  - `data.lua` — data stage (prototype registration, autoplace config)
  - `data-updates.lua` — data-updates stage
  - `data-final-fixes.lua` — data-final-fixes stage
  - `control.lua` — runtime stage; wires up all `event_handler` libs + remote APIs
- **`global.lua`** — constants, debug/test flags, force names, trigger/event name strings
- **`lib/`** — pure logic processors (no event handlers), e.g. `attack_group_processor`, `quality_processor`, `boss_processor`. The `lib/rig/` helpers are data-stage only.
- **`controllers/`** — event-handler libs registered via `handler.add_lib(...)` in `control.lua`. These react to Factorio events.
- **`gui/`** — GUI code (main window, boss detail, army control, etc.)
- **`prototypes/`** — data-stage prototype extensions (units, spawners, recipes, quality, etc.)
- **`migrations/`** — save migration scripts, named by version (e.g. `enemyracemanager-2.0.68.lua`)
- **`scenarios/`** — debug scenarios (boss-debug, unit-debug, unit-detail-debug) with scenario control.lua files
- **`lib/remote_api.lua`** — exposed via `remote.add_interface("enemyracemanager", ...)`
- **`lib/debug_remote_api.lua`** — exposed via `remote.add_interface("enemyracemanager_debug", ...)`

## Hard Dependencies (from `info.json`)

- `enemyracemanager_assets >= 2.0.4`
- `erm_unit_control >= 1.1.0`
- `erm_libs >= 2.0.8`
- `advanced_target_priorities >= 1.0.3`

## Testing

Tests require the [`factorio-test`](https://mods.factorio.com/mod/factorio-test) mod and run inside a live Factorio instance.

- **Test registration**: `testcase.lua` — conditionally requires test files when `TEST_MODE = true` and `factorio-test` is active.
- **Test files**: in `tests/` directory (e.g. `tests/attack_beacon`, `tests/attack_pathing`, `tests/boss_spawns`).
- **Test prerequisites** (from `tests/README.md` + `testcase.lua`):
  - Set `DEBUG_MODE = true` and `TEST_MODE = true` in `global.lua`
  - Test suite designed for **Space Age** — some tests crash in base game
  - Some tests require `erm_zerg`, `erm_toss`, and `erm_terran` mods
  - `ENABLE_BOSS_TESTS` flag for boss test modes
  - `ENABLE_LENGTHY_TESTS = true` to run slow tests (e.g. `tests/psi_radar`)
- **Test fixture**: `tests/shared.lua` — `TestShared` module provides `prepare_the_factory()`, `reset_the_factory()`, river/defense builders, etc.

## Key Gotchas

- **`global.lua` DEBUG_MODE and TEST_MODE** must be `false` before release (line 18-21).
- **Data-stage vs runtime**: `lib/rig/*` helpers are for data stage only (per `lib/rig/README.md`). Do not require them from runtime code.
- **Module paths**: Always use full `__enemyracemanager__/` prefix in requires (e.g. `require("__enemyracemanager__/lib/global_config")`).
- **Custom events**: Generated in `control.lua` via `script.generate_event_name()`, stored in `GlobalConfig.custom_event_handlers`. The event names are defined in `lib/global_config.lua` (e.g. `"erm_flush_global"`, `"erm_adjust_attack_meter"`).
- **Settings**: All settings prefixed `enemyracemanager-` in `settings.lua`. Startup settings (e.g. Nauvis enemy, max hitpoints, damage multipliers) are fixed at game start. Runtime-global settings (attack meter, difficulty, build style) can change mid-game.
- **Migrations**: Named as `enemyracemanager-<version>.lua` (or `.json`). Always check `migrations/` when changing `storage` keys.