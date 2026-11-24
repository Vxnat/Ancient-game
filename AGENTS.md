# AGENTS.md — Technical Rules & Architecture Guide

## 1. Engine & Environment
- **Engine:** Godot `4.3-stable`
- **Godot CLI (Headless Verification & Tests):** `C:\Users\pc\Downloads\Godot_v4.3-stable_win64.exe\Godot_v4.3-stable_win64_console.exe`
  - Import & verify scripts/scenes: `"C:\Users\pc\Downloads\Godot_v4.3-stable_win64.exe\Godot_v4.3-stable_win64_console.exe" --headless --import --path "c:\Hoc_Tap\Game-new"` followed by `--headless --quit --path "c:\Hoc_Tap\Game-new"`
- **Language:** `GDScript` (static typing preferred: `var hp: float = 100.0`, `func take_damage(amount: float) -> void:`)
- **Target Style:** 2D Pixel Art (`default_texture_filter = Nearest`, viewport `960x540`, stretch `viewport`).

## 2. Core Architecture Principles
1. **Composition over Inheritance:**
   - Shared entity mechanics live in `core/components/` (`HealthComponent`, `KiComponent`, `StatsComponent`, `WeaponComponent`, `HitboxComponent`, `HurtboxComponent`).
   - Player, Allies (Đệ tử), Enemies, and Bosses share these components instead of duplicating health/damage code.
2. **Node-based State Machine:**
   - Movement, combat, and AI states use `StateMachine` and `State` (`core/state_machine/`).
   - Keep `player.gd` slim; put behavior inside dedicated State nodes (`Idle`, `Move`, `Jump`, `Dash`, `Attack`, `Overdrive`, `Fusion`).
3. **Data-Driven Design (`data/`):**
   - Static definitions are Custom `Resource` scripts + `.tres` files under `data/` (`forms/`, `weapons/`, `skills/`, `items/`, `quests/`, `dialogues/`).
   - **CRITICAL:** Never mutate `.tres` Resource files at runtime!
     - Use `WeaponInstance` (`core/components/weapon_instance.gd`) for runtime `current_durability` and `upgrade_level`.
4. **Decoupling via `EventBus`:**
   - Cross-system communication (e.g., enemy killed -> `QuestManager`, HP changed -> `HUD`) goes through `EventBus` signals instead of direct node references.
5. **Scene Persistence (`current_run_data`):**
   - Because `SceneManager` replaces map scenes when transitioning between areas, persistent runtime player state (HP, Ki, Essence, unlocked skills, weapons, current form) is stored in `GameManager.current_run_data` and restored when the new `Player` enters the tree.

## 3. Directory Map
- `autoloads/`: Global singletons (`EventBus`, `AudioManager`, `GameManager`, `SceneManager`, `QuestManager`, `SaveManager`).
- `core/`: Reusable `state_machine/` and `components/`.
- `combat/`: Decoupled `projectiles/` (Ki blasts) and `vfx/` (auras, hit sparks).
- `entities/`: `player/`, `allies/` (disciple), `enemies/`, `npcs/`.
- `data/`: Custom Resource scripts and `.tres` data files.
- `world/`: `peaceful_planet/`, `ruins/`, `shared/` (portals, checkpoints, lore tablets).
- `ui/`: `hud/`, `quest_log/`, `awakening_menu/`, `dialogue_box/`, `menus/`.
- `assets/`: Raw assets (`sprites/`, `tilesets/`, `audio/bgm/`, `audio/sfx/`, `fonts/`, `shaders/`).

## 4. Naming & Coding Conventions
- **Files & folders:** `snake_case` (e.g., `health_component.gd`, `peaceful_village.tscn`).
- **Classes (`class_name`) & Nodes:** `PascalCase` (e.g., `HealthComponent`, `StateMachine`).
- **Variables, functions, signals:** `snake_case`.
- **Constants & Enums:** `UPPER_SNAKE_CASE`.
- **Physics Layers (2D):**
  1. `world` | 2. `player` | 3. `allies` | 4. `enemies` | 5. `player_hitbox` | 6. `enemy_hitbox` | 7. `interactable`
  - **Hitbox / Hurtbox Rules:** `HurtboxComponent` lives on its entity's layer (`player` 2, `allies` 3, `enemies` 4). `player_hitbox` (5) masks `enemies` (4) and is shared by both Player and Allies (Đệ tử) to prevent friendly fire; `enemy_hitbox` (6) masks `player` (2) and `allies` (3).

## 5. Workflow & Documentation Sync
- **Start of Session:** Read `GDD.md` and `ROADMAP.md` first to understand the current design specs and next milestone.
- **Keep Docs Synced:** Whenever gameplay mechanics/numbers change or a milestone completes, update `GDD.md` (Section 5 Gameplay Specs) and check off items in `ROADMAP.md`.
