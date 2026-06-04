# Gas Gas Man v2 — Agent Workflows

Four specialized agents operate on this project. Invoke them via Claude Code's Agent tool
or the `/deep-research` skill. Run in order: Research → UX → Asset → Code.

---

## Agent 1: Research Agent

**Purpose:** Web research before starting a new phase.

**Tools:** WebSearch, WebFetch, deep-research skill

**Invoke with:**
```
/deep-research "Gas Gas Man Godot 4.5 Android casual game — [TOPIC]"
```

**Example topics per phase:**
- Phase 2 (Juice): "mobile 2D game feel juice techniques screen shake particles combo feedback"
- Phase 3 (Levels): "endless runner mobile difficulty scaling level progression casual game"
- Phase 4 (UI): "mobile casual game HUD design Android 2024 settings screen tutorial"
- Phase 5 (Assets): "Indonesian cartoon 2D sprite style mobile game asset pack free CC0"

**Output:** Save findings to `docs/research/phase_{N}_{topic}.md`

---

## Agent 2: UX Design Agent

**Purpose:** Design Godot node hierarchies for new screens.

**Viewport:** 1280×720, Android-first, `canvas_items` stretch + `keep_width`

**Prompt template:**
```
You are a UX design agent for Gas Gas Man: Delivery Rush (Godot 4.5, 1280×720, Android).
Font available: LuckiestGuy-Regular.ttf
Existing UI color palette: warm orange (#F4A825), green (#709435), cream (#FFF8E7), dark (#2C1810)

Design: [SCREEN_NAME]
Requirements: [LIST REQUIREMENTS]

Output:
- Godot Control node hierarchy with node types and anchor presets
- Element positions in 1280×720 px space
- Font sizes for each text element
- Tween animation spec (duration, easing, what property)
- No images — pure text spec
```

**Screens to design:**
- `LevelSelect.tscn` — 5 level buttons with star ratings and lock state
- `SettingsScreen.tscn` — music/SFX toggles, close button, blur background
- `TutorialOverlay.tscn` — hand gesture animation, tap-to-dismiss
- `ComboLabel` (HUD node) — position, scale pulse animation spec
- `ResultBoard` v2 — star reveal animation, Next Level / Retry buttons

**Output:** `docs/ux_specs/{screen_name}.md`

---

## Agent 3: Asset Generation Agent

**Purpose:** Write Claude image prompts and OpenGameArt queries for missing assets.

**Style brief:**
```
Bold black outline, Indonesian cartoon style, vibrant flat shading (4–5 colors max per asset),
mobile-readable at 200px, transparent PNG background, no gradients on outlines.
Game setting: Indonesian neighborhood, delivery moped rider, packages, colorful houses.
```

**See:** `docs/asset_prompts/NEEDED.md` for the full priority list.

**Claude image prompt template:**
```
Create a [ASSET] for a 2D Android casual mobile game.
Art style: bold black outlines (3–4px), flat cartoon Indonesian neighborhood aesthetic,
vibrant warm palette (orange #F4A825, green #709435, sky blue #87CEEB, cream #FFF8E7).
Transparent background. Size: [W]×[H]px. High contrast, shapes readable at 64px.
[SPECIFIC DESCRIPTION]
```

---

## Agent 4: Code Agent

**Purpose:** Implement a single GDScript file from spec.

**Prompt template:**
```
You are a Godot 4.5 GDScript implementation agent for Gas Gas Man: Delivery Rush.

Read these files first: [LIST PATHS]

Implement [FILE_PATH] to this spec:
[PASTE SPEC FROM PLAN]

Constraints:
- Godot 4.5 signal API: signal.connect(callable) — NOT connect("name", obj, "method")  
- No print() statements — use push_warning() / push_error() only
- All node lookups via @onready or get_tree().get_first_node_in_group() with Constants group names
- Touch-first: all input paths must work via InputEventScreenTouch, not keyboard-only
- Autoloads available: Constants, GameState, SceneLoader, AudioManager, SaveData, LevelManager

Output: complete file content only.
```

---

## Workflow Order per Phase

```
1. Research Agent  → docs/research/phase_N_topic.md
2. UX Design Agent → docs/ux_specs/screen_name.md  (if new screens involved)
3. Asset Agent     → docs/asset_prompts/phase_N_assets.md (if new sprites/SFX needed)
4. Code Agent(s)   → actual .gd files (can run multiple in parallel per phase)
```
