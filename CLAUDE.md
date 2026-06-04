# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Gas Gas Man: Delivery Rush** is a 2D mobile/desktop game built with **Godot Engine 4.5**. The player is a delivery rider who throws packages at houses while the environment auto-scrolls. Mechanics: hold to charge throw power, release to throw. Game ends when the score target is reached or the 60-second timer runs out.

## Running the Game

This project has no build scripts — it must be opened in **Godot Engine 4.5+**:

1. Launch Godot Engine
2. Import project from the repo root (`project.godot`)
3. Press **F5** to run, or use `godot --path . --headless` for headless testing

Export targets (Android + Web) are defined in `export_presets.cfg`. Run exports via Godot's Export dialog or:
```bash
godot --export-release "Android" output.apk
```

## Architecture

### Autoloads (singletons, always loaded)
- `autoload/Constants.gd` — scene paths, group names, gameplay tuning values (scroll speed, spawn interval, score deltas)
- `autoload/GameState.gd` — global state machine (IDLE/PLAYING/PAUSED/GAME_OVER), score, lives, and signals
- `autoload/SceneLoader.gd` — thin wrapper around `get_tree().change_scene_to_file()`
- `autoload/AudioManager.gd` — BGM player; call `AudioManager.play_bgm()` / `stop_bgm()` / `toggle_mute()`

### Scene hierarchy (`scenes/levels/Game.tscn`)
`Game.gd` is the root coordinator. It connects signals from child nodes and drives the main game loop:
- `PlayerMotor` — `CharacterBody2D` running `scripts/player.gd`. Handles charge/throw input (keyboard + touch), instantiates `Package.tscn`, and reacts to `package_hit` signals from the active house
- `PowerBar` — `CanvasLayer` running `scripts/power_bar.gd`. Oscillating progress bar; emits `throw_power_ready(power)` when released
- `HouseSpawner` — `Timer` running `scripts/house_spawner.gd`. Spawns `House.tscn`, injects `PaletTarget` and `AtapTarget` node references into the player
- `Background` — `Node2D` running `scripts/background.gd`. Infinite-scroll via segment recycling; toggled by `is_scrolling`
- `HUD` — `CanvasLayer` running `scripts/hud.gd`. Owns the 60-second countdown timer, score/target counters; emits `game_finished(score, target, time, thrown_count)` when done
- `GameManager` — `scenes/managers/GameManager.gd`. Secondary coordinator that wires `GameState` autoload signals to child nodes (background, spawner, player, HUD)

### Key object scripts (`scripts/`)
| Script | Node type | Role |
|---|---|---|
| `package.gd` | `RigidBody2D` | Physics projectile; simulates fake Z-depth via scale shrink; frees on ground contact |
| `house.gd` | `Node2D` | Scrolls left at runtime speed; connects `PaletTarget` / `AtapCollision` signals |
| `palet_target.gd` | `Area2D` | Detects package landing on the pallet; requires `required_stay_time` seconds of overlap to emit `package_hit(true)` |
| `atap_collision.gd` | `Area2D` | Detects roof hits; emits `package_hit(false)` for misses |
| `segments.gd` | `Node2D` | Camera-relative segment recycler for the ground/road layer |
| `power_bar.gd` | `CanvasLayer` | Oscillating charge bar; emits `throw_power_ready(power)` |
| `hud.gd` | `CanvasLayer` | Score, target, countdown timer |

### Signal flow (throw → score)
```
Player holds input
  → PowerBar.start_charge()
Player releases input
  → PowerBar.stop_charge() → emits throw_power_ready(power)
  → Player._on_throw_power_ready() → Player.throw_package(power)
  → Package instantiated, add_to_group("package"), physics impulse applied
Package overlaps PaletTarget for required_stay_time
  → PaletTarget emits package_hit(true)
  → Player._on_package_hit(true) → HUD.add_score()
  → HUD checks score >= target_score → emits game_finished(...)
  → Game._on_game_finished() → shows ResultScreen
```

## Conventions

- All groups used for cross-tree lookup: `"player"`, `"house"`, `"hud"`, `"package"`, `"ground"`, `"camera"` — defined in `Constants.gd`
- Scene paths are constants in `Constants.gd`; always use `SceneLoader.goto(Constants.SCENE_*)` for transitions
- Gameplay tuning values live in `Constants.gd` (`SCROLL_SPEED`, `HOUSE_SPAWN_INTERVAL`, `SCORE_DELIVERY_SUCCESS`, `SCORE_DELIVERY_FAIL`)
- The project uses Godot's **Mobile** renderer with `canvas_items` stretch and `keep_width` aspect — design at 1280×720
- UI text uses Indonesian (game was developed as a university project in Indonesia)
