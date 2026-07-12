# P1 Foundation Rebuild Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the production foundation for `AI Routine: Last Commit` without changing the current playable route, then add settings, checkpoint saves, test infrastructure, CI and release-facing project metadata in separately reviewable PRs.

**Architecture:** P1 introduces production services beside the existing prototype systems. `GameBootstrap` owns service startup, `GameLog` provides structured categories, `LegacyProgressionAdapter` mirrors existing events into the new foundation, and later tasks add `SettingsManager`, `SaveGameManager`, a headless test runner and CI. Existing `GameState`, `ObjectiveManager`, `HorrorEventManager`, scenes and event IDs remain functional until later migration phases.

**Tech Stack:** Godot 4.7+, typed GDScript, Godot `Resource`/JSON APIs, headless Godot CLI, GitHub Actions, Windows Desktop export.

## Global Constraints

- Godot version floor: 4.7+.
- Language: typed GDScript; no C# migration.
- First release platform: Windows.
- Do not add third-party gameplay frameworks in P1.
- Do not change the current regression route: `стикер → терминал → лампа → дверь → Smart Speaker → терминал → HUD objective glitch`.
- Do not replace apartment geometry, materials or audio assets in P1.
- Do not remove `GameState`, `ObjectiveManager` or `HorrorEventManager` in P1.
- Every PR must update `docs/TASKS.md`, `docs/PROJECT_STATE.md` and `docs/CHANGELOG.md`.
- Architecture changes must update `docs/DECISIONS.md` and `docs/AGENT_HANDOFF.md`.
- External assets remain forbidden unless their commercial-use license is recorded in `docs/CREDITS.md`.
- All new public service APIs use explicit return types and `StringName` for identifiers.
- Each subtask below is intended to become one independently reviewable PR.

---

## File Map

### P1.1 — Bootstrap and Logging

- Create `game/scripts/core/GameLog.gd` — structured log categories and level filtering.
- Create `game/scripts/core/LegacyProgressionAdapter.gd` — mirrors existing prototype events into the production foundation without changing gameplay.
- Create `game/scripts/core/GameBootstrap.gd` — service startup and health checks.
- Create `tests/TestAssert.gd` — minimal dependency-free assertions.
- Create `tests/unit/TestGameLog.gd` — headless unit test for log filtering.
- Create `tests/smoke/TestBootstrapSmoke.gd` — loads the production bootstrap and validates required legacy autoloads.
- Modify `project.godot` — register `GameLog`, `LegacyProgressionAdapter` and `GameBootstrap` autoloads after existing prototype autoloads.
- Modify `game/scripts/core/HorrorEventManager.gd` — route event diagnostics through `GameLog` while preserving behavior.

### P1.2 — Settings Foundation

- Create `game/scripts/settings/GameSettings.gd` — typed settings value object.
- Create `game/scripts/settings/SettingsStore.gd` — JSON persistence and schema handling.
- Create `game/scripts/settings/SettingsManager.gd` — runtime API and signal emission.
- Create `tests/unit/TestSettingsStore.gd` — round-trip, defaults and invalid-file tests.
- Modify `project.godot` — register `SettingsManager` autoload.

### P1.3 — Checkpoint Save Foundation

- Create `game/scripts/save/SaveSnapshot.gd` — serializable save DTO.
- Create `game/scripts/save/SaveStore.gd` — primary/backup JSON persistence.
- Create `game/scripts/save/SaveGameManager.gd` — autosave/checkpoint API.
- Create `tests/unit/TestSaveStore.gd` — primary, backup and corruption recovery tests.
- Modify `project.godot` — register `SaveGameManager` autoload.

### P1.4 — Headless Validation and CI

- Create `tests/TestRunner.gd` — discovers and executes test scripts.
- Create `tests/run_all.gd` — command-line entry point.
- Create `.github/workflows/godot-ci.yml` — headless import and tests.
- Create `scripts/validate_project.sh` — local equivalent of CI commands.
- Modify `.gitignore` — ignore local test output and generated reports.

### P1.5 — Versioning and Windows Export Baseline

- Create `game/scripts/core/BuildInfo.gd` — application version and channel constants.
- Create `export_presets.cfg` — Windows development preset.
- Create `scripts/build_windows.sh` — deterministic local build command.
- Modify `project.godot` — set version metadata.
- Modify `.github/workflows/godot-ci.yml` — upload a Windows development build on manual dispatch.

---

## PR P1.1: Bootstrap and Logging

### Task 1: Add the dependency-free test assertions

**Files:**
- Create: `tests/TestAssert.gd`

**Interfaces:**
- Produces: `TestAssert.is_true(condition: bool, message: String) -> void`
- Produces: `TestAssert.are_equal(actual: Variant, expected: Variant, message: String) -> void`
- Produces: `TestAssert.fail(message: String) -> void`

- [ ] **Step 1: Create the assertion helper**

```gdscript
class_name TestAssert
extends RefCounted

static func is_true(condition: bool, message: String) -> void:
    if not condition:
        push_error("TEST FAILED: %s" % message)
        assert(condition, message)

static func are_equal(actual: Variant, expected: Variant, message: String) -> void:
    if actual != expected:
        var details := "%s | expected=%s actual=%s" % [message, str(expected), str(actual)]
        push_error("TEST FAILED: %s" % details)
        assert(actual == expected, details)

static func fail(message: String) -> void:
    push_error("TEST FAILED: %s" % message)
    assert(false, message)
```

- [ ] **Step 2: Verify the script parses**

Run:

```bash
godot --headless --path . --editor --quit
```

Expected: exit code `0`; no parse error mentioning `tests/TestAssert.gd`.

- [ ] **Step 3: Commit**

```bash
git add tests/TestAssert.gd
git commit -m "test: add dependency-free assertions"
```

### Task 2: Add structured logging with category and level filtering

**Files:**
- Create: `game/scripts/core/GameLog.gd`
- Create: `tests/unit/TestGameLog.gd`

**Interfaces:**
- Produces: `GameLog.Level` enum with `DEBUG`, `INFO`, `WARNING`, `ERROR`.
- Produces: `GameLog.set_min_level(level: Level) -> void`.
- Produces: `GameLog.should_emit(level: Level) -> bool`.
- Produces: `GameLog.debug(category: StringName, message: String) -> void`.
- Produces: `GameLog.info(category: StringName, message: String) -> void`.
- Produces: `GameLog.warning(category: StringName, message: String) -> void`.
- Produces: `GameLog.error(category: StringName, message: String) -> void`.

- [ ] **Step 1: Write the failing test**

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")
const GameLogScript = preload("res://game/scripts/core/GameLog.gd")

func _init() -> void:
    var logger := GameLogScript.new()
    logger.set_min_level(GameLogScript.Level.WARNING)

    TestAssert.is_true(not logger.should_emit(GameLogScript.Level.DEBUG), "debug must be filtered")
    TestAssert.is_true(not logger.should_emit(GameLogScript.Level.INFO), "info must be filtered")
    TestAssert.is_true(logger.should_emit(GameLogScript.Level.WARNING), "warning must be emitted")
    TestAssert.is_true(logger.should_emit(GameLogScript.Level.ERROR), "error must be emitted")
    quit(0)
```

Save as `tests/unit/TestGameLog.gd`.

- [ ] **Step 2: Run the test and confirm failure**

```bash
godot --headless --path . --script tests/unit/TestGameLog.gd
```

Expected: non-zero exit or parse/load failure because `GameLog.gd` does not exist.

- [ ] **Step 3: Implement `GameLog.gd`**

```gdscript
class_name GameLog
extends Node

enum Level {
    DEBUG,
    INFO,
    WARNING,
    ERROR,
}

const CATEGORY_GAME: StringName = &"GAME"
const CATEGORY_NARRATIVE: StringName = &"NARRATIVE"
const CATEGORY_SAVE: StringName = &"SAVE"
const CATEGORY_INTERACTION: StringName = &"INTERACTION"
const CATEGORY_AUDIO: StringName = &"AUDIO"
const CATEGORY_UI: StringName = &"UI"
const CATEGORY_ASSET: StringName = &"ASSET"
const CATEGORY_PERFORMANCE: StringName = &"PERFORMANCE"

var _min_level: Level = Level.DEBUG if OS.is_debug_build() else Level.WARNING

func set_min_level(level: Level) -> void:
    _min_level = level

func should_emit(level: Level) -> bool:
    return level >= _min_level

func debug(category: StringName, message: String) -> void:
    _emit(Level.DEBUG, category, message)

func info(category: StringName, message: String) -> void:
    _emit(Level.INFO, category, message)

func warning(category: StringName, message: String) -> void:
    _emit(Level.WARNING, category, message)

func error(category: StringName, message: String) -> void:
    _emit(Level.ERROR, category, message)

func _emit(level: Level, category: StringName, message: String) -> void:
    if not should_emit(level):
        return

    var line := "[%s][%s] %s" % [_level_name(level), String(category), message]
    match level:
        Level.WARNING:
            push_warning(line)
        Level.ERROR:
            push_error(line)
        _:
            print(line)

func _level_name(level: Level) -> String:
    match level:
        Level.DEBUG:
            return "DEBUG"
        Level.INFO:
            return "INFO"
        Level.WARNING:
            return "WARNING"
        Level.ERROR:
            return "ERROR"
    return "UNKNOWN"
```

- [ ] **Step 4: Run the test and confirm pass**

```bash
godot --headless --path . --script tests/unit/TestGameLog.gd
```

Expected: exit code `0`.

- [ ] **Step 5: Commit**

```bash
git add game/scripts/core/GameLog.gd tests/unit/TestGameLog.gd
git commit -m "feat: add structured game logging"
```

### Task 3: Add `LegacyProgressionAdapter`

**Files:**
- Create: `game/scripts/core/LegacyProgressionAdapter.gd`
- Create: `tests/unit/TestLegacyProgressionAdapter.gd`

**Interfaces:**
- Consumes: `HorrorEventManager.horror_event_started(event_id: String)`.
- Produces: signal `legacy_event_observed(event_id: StringName)`.
- Produces: `has_observed(event_id: StringName) -> bool`.
- Produces: `reset_observed() -> void`.

- [ ] **Step 1: Write the failing test**

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")
const AdapterScript = preload("res://game/scripts/core/LegacyProgressionAdapter.gd")

func _init() -> void:
    var adapter := AdapterScript.new()
    adapter.observe_legacy_event(&"terminal_first_ai_reply")

    TestAssert.is_true(adapter.has_observed(&"terminal_first_ai_reply"), "legacy event must be mirrored")
    TestAssert.is_true(not adapter.has_observed(&"unknown"), "unknown event must remain false")

    adapter.reset_observed()
    TestAssert.is_true(not adapter.has_observed(&"terminal_first_ai_reply"), "reset must clear mirrored events")
    quit(0)
```

Save as `tests/unit/TestLegacyProgressionAdapter.gd`.

- [ ] **Step 2: Run the failing test**

```bash
godot --headless --path . --script tests/unit/TestLegacyProgressionAdapter.gd
```

Expected: failure because the adapter does not exist.

- [ ] **Step 3: Implement the adapter**

```gdscript
class_name LegacyProgressionAdapter
extends Node

signal legacy_event_observed(event_id: StringName)

var _observed_events: Dictionary = {}

func _ready() -> void:
    if HorrorEventManager != null and not HorrorEventManager.horror_event_started.is_connected(_on_horror_event_started):
        HorrorEventManager.horror_event_started.connect(_on_horror_event_started)

func observe_legacy_event(event_id: StringName) -> void:
    if _observed_events.has(event_id):
        return

    _observed_events[event_id] = true
    legacy_event_observed.emit(event_id)

    if Engine.has_singleton("GameLog"):
        GameLog.info(GameLog.CATEGORY_NARRATIVE, "legacy_event_observed id=%s" % String(event_id))

func has_observed(event_id: StringName) -> bool:
    return _observed_events.has(event_id)

func reset_observed() -> void:
    _observed_events.clear()

func _on_horror_event_started(event_id: String) -> void:
    observe_legacy_event(StringName(event_id))
```

Note: when implemented as an autoload, access `GameLog` directly. In the unit test, `observe_legacy_event()` is called without entering the tree, so it remains independent of the autoload environment.

- [ ] **Step 4: Run the test and confirm pass**

```bash
godot --headless --path . --script tests/unit/TestLegacyProgressionAdapter.gd
```

Expected: exit code `0`.

- [ ] **Step 5: Commit**

```bash
git add game/scripts/core/LegacyProgressionAdapter.gd tests/unit/TestLegacyProgressionAdapter.gd
git commit -m "feat: mirror legacy progression events"
```

### Task 4: Add `GameBootstrap` health checks

**Files:**
- Create: `game/scripts/core/GameBootstrap.gd`
- Create: `tests/smoke/TestBootstrapSmoke.gd`

**Interfaces:**
- Produces: signal `bootstrap_completed`.
- Produces: `is_ready() -> bool`.
- Produces: `get_health_report() -> Dictionary`.
- Health keys: `game_state`, `objective_manager`, `horror_event_manager`, `legacy_progression_adapter`.

- [ ] **Step 1: Write the failing smoke test**

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var bootstrap := root.get_node_or_null("GameBootstrap")
    TestAssert.is_true(bootstrap != null, "GameBootstrap autoload must exist")
    TestAssert.is_true(bootstrap.is_ready(), "GameBootstrap must finish startup")

    var report: Dictionary = bootstrap.get_health_report()
    TestAssert.are_equal(report.get("game_state"), true, "GameState must be healthy")
    TestAssert.are_equal(report.get("objective_manager"), true, "ObjectiveManager must be healthy")
    TestAssert.are_equal(report.get("horror_event_manager"), true, "HorrorEventManager must be healthy")
    TestAssert.are_equal(report.get("legacy_progression_adapter"), true, "legacy adapter must be healthy")
    quit(0)
```

Save as `tests/smoke/TestBootstrapSmoke.gd`.

- [ ] **Step 2: Run and confirm failure**

```bash
godot --headless --path . --script tests/smoke/TestBootstrapSmoke.gd
```

Expected: failure because the autoload is not registered.

- [ ] **Step 3: Implement `GameBootstrap.gd`**

```gdscript
class_name GameBootstrap
extends Node

signal bootstrap_completed

var _is_ready: bool = false
var _health_report: Dictionary = {}

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _health_report = {
        "game_state": get_node_or_null("/root/GameState") != null,
        "objective_manager": get_node_or_null("/root/ObjectiveManager") != null,
        "horror_event_manager": get_node_or_null("/root/HorrorEventManager") != null,
        "legacy_progression_adapter": get_node_or_null("/root/LegacyProgressionAdapter") != null,
    }

    _is_ready = not _health_report.values().has(false)

    if _is_ready:
        GameLog.info(GameLog.CATEGORY_GAME, "bootstrap_completed")
        bootstrap_completed.emit()
    else:
        GameLog.error(GameLog.CATEGORY_GAME, "bootstrap_failed report=%s" % str(_health_report))

func is_ready() -> bool:
    return _is_ready

func get_health_report() -> Dictionary:
    return _health_report.duplicate(true)
```

- [ ] **Step 4: Register autoload order in `project.godot`**

Replace the `[autoload]` section with:

```ini
[autoload]

GameState="*res://game/scripts/core/GameState.gd"
ObjectiveManager="*res://game/scripts/core/ObjectiveManager.gd"
HorrorEventManager="*res://game/scripts/core/HorrorEventManager.gd"
GameLog="*res://game/scripts/core/GameLog.gd"
LegacyProgressionAdapter="*res://game/scripts/core/LegacyProgressionAdapter.gd"
GameBootstrap="*res://game/scripts/core/GameBootstrap.gd"
```

- [ ] **Step 5: Run the smoke test**

```bash
godot --headless --path . --script tests/smoke/TestBootstrapSmoke.gd
```

Expected: exit code `0`; output contains `[INFO][GAME] bootstrap_completed` in debug builds.

- [ ] **Step 6: Run the existing main scene headlessly**

```bash
godot --headless --path . --path . --editor --quit
```

Expected: exit code `0`; no autoload parse errors.

- [ ] **Step 7: Commit**

```bash
git add game/scripts/core/GameBootstrap.gd tests/smoke/TestBootstrapSmoke.gd project.godot
git commit -m "feat: add production bootstrap health checks"
```

### Task 5: Route legacy event diagnostics through `GameLog`

**Files:**
- Modify: `game/scripts/core/HorrorEventManager.gd`
- Create: `tests/unit/TestHorrorEventManager.gd`

**Interfaces:**
- Existing API remains unchanged: `play_once(event_id: String, callback: Callable = Callable()) -> void`.
- Adds diagnostics only; callback timing remains unchanged in P1.1.

- [ ] **Step 1: Write regression test**

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")
const ManagerScript = preload("res://game/scripts/core/HorrorEventManager.gd")

func _init() -> void:
    var manager := ManagerScript.new()
    var callback_count := 0
    var callback := func() -> void:
        callback_count += 1

    manager.play_once("event_a", callback)
    manager.play_once("event_a", callback)

    TestAssert.are_equal(callback_count, 1, "play_once must preserve one-shot behavior")
    TestAssert.is_true(manager.has_played("event_a"), "event must remain marked as played")
    quit(0)
```

- [ ] **Step 2: Run the regression test before modification**

```bash
godot --headless --path . --script tests/unit/TestHorrorEventManager.gd
```

Expected: exit code `0`.

- [ ] **Step 3: Add diagnostics without changing control flow**

Use this complete implementation:

```gdscript
extends Node

signal horror_event_started(event_id: String)
signal horror_event_finished(event_id: String)

var played_events: Dictionary = {}

func play_once(event_id: String, callback: Callable = Callable()) -> void:
    if played_events.has(event_id):
        GameLog.debug(GameLog.CATEGORY_NARRATIVE, "legacy_event_skipped id=%s reason=already_played" % event_id)
        return

    played_events[event_id] = true
    GameLog.info(GameLog.CATEGORY_NARRATIVE, "legacy_event_started id=%s" % event_id)
    horror_event_started.emit(event_id)

    if callback.is_valid():
        callback.call()

    horror_event_finished.emit(event_id)
    GameLog.info(GameLog.CATEGORY_NARRATIVE, "legacy_event_finished id=%s" % event_id)

func has_played(event_id: String) -> bool:
    return played_events.has(event_id)

func reset_events() -> void:
    played_events.clear()
    GameLog.debug(GameLog.CATEGORY_NARRATIVE, "legacy_events_reset")
```

- [ ] **Step 4: Re-run regression and bootstrap tests**

```bash
godot --headless --path . --script tests/unit/TestHorrorEventManager.gd
godot --headless --path . --script tests/smoke/TestBootstrapSmoke.gd
```

Expected: both exit `0`.

- [ ] **Step 5: Commit**

```bash
git add game/scripts/core/HorrorEventManager.gd tests/unit/TestHorrorEventManager.gd
git commit -m "refactor: add structured legacy event diagnostics"
```

### Task 6: Update P1.1 documentation and open PR

**Files:**
- Modify: `docs/TASKS.md`
- Modify: `docs/PROJECT_STATE.md`
- Modify: `docs/CHANGELOG.md`
- Modify: `docs/DECISIONS.md`
- Modify: `docs/AGENT_HANDOFF.md`

**Interfaces:**
- No runtime API.
- Documents must state that P1.1 does not include settings, saves, new assets or narrative migration.

- [ ] **Step 1: Update task state**

Mark `P1.1 — Bootstrap and Logging` complete only after all commands above pass. Set `P1.2 — Settings Foundation` as the next task.

- [ ] **Step 2: Add changelog entry**

Add:

```markdown
## [0.4.0] — 2026-07-12

### Added

- Production `GameBootstrap` with startup health checks.
- Structured `GameLog` categories and level filtering.
- `LegacyProgressionAdapter` for mirroring prototype events.
- Dependency-free headless unit and smoke tests for the new foundation.

### Changed

- Legacy horror events now emit structured diagnostics without changing gameplay behavior.
```

- [ ] **Step 3: Add ADR**

Record that P1 uses parallel migration: new production services coexist with legacy managers until regression coverage is complete.

- [ ] **Step 4: Run all P1.1 checks**

```bash
godot --headless --path . --script tests/unit/TestGameLog.gd
godot --headless --path . --script tests/unit/TestLegacyProgressionAdapter.gd
godot --headless --path . --script tests/unit/TestHorrorEventManager.gd
godot --headless --path . --script tests/smoke/TestBootstrapSmoke.gd
godot --headless --path . --editor --quit
```

Expected: all commands exit `0`.

- [ ] **Step 5: Commit documentation**

```bash
git add docs/TASKS.md docs/PROJECT_STATE.md docs/CHANGELOG.md docs/DECISIONS.md docs/AGENT_HANDOFF.md
git commit -m "docs: complete P1.1 bootstrap foundation"
```

- [ ] **Step 6: Open draft PR**

Branch:

```text
agent/p1-bootstrap-logging
```

Title:

```text
Add production bootstrap and structured logging
```

PR body must include the regression route and explicitly state that settings, saves, apartment rebuild, assets and narrative migration are out of scope.

---

## PR P1.2: Settings Foundation

### Task 7: Define typed settings data

**Files:**
- Create: `game/scripts/settings/GameSettings.gd`
- Create: `tests/unit/TestGameSettings.gd`

**Interfaces:**
- Produces: `GameSettings.SCHEMA_VERSION: int = 1`.
- Produces fields: `mouse_sensitivity`, `invert_y`, `master_volume`, `effects_volume`, `ambience_volume`, `voice_volume`, `ui_volume`, `fullscreen`, `vsync`, `max_fps`, `film_grain_enabled`, `chromatic_aberration_enabled`, `head_bob_enabled`, `reduced_flashes`, `subtitles_enabled`, `sound_captions_enabled`, `text_scale`.
- Produces: `to_dictionary() -> Dictionary`.
- Produces: `apply_dictionary(data: Dictionary) -> void`.

- [ ] **Step 1: Write the failing test**

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")
const SettingsScript = preload("res://game/scripts/settings/GameSettings.gd")

func _init() -> void:
    var settings := SettingsScript.new()
    settings.mouse_sensitivity = 0.004
    settings.subtitles_enabled = false

    var copy := SettingsScript.new()
    copy.apply_dictionary(settings.to_dictionary())

    TestAssert.are_equal(copy.mouse_sensitivity, 0.004, "mouse sensitivity must round-trip")
    TestAssert.are_equal(copy.subtitles_enabled, false, "subtitle setting must round-trip")
    TestAssert.are_equal(copy.schema_version, SettingsScript.SCHEMA_VERSION, "schema version must be stored")
    quit(0)
```

- [ ] **Step 2: Run and confirm failure**

```bash
godot --headless --path . --script tests/unit/TestGameSettings.gd
```

Expected: missing script failure.

- [ ] **Step 3: Implement `GameSettings.gd`**

```gdscript
class_name GameSettings
extends RefCounted

const SCHEMA_VERSION: int = 1

var schema_version: int = SCHEMA_VERSION
var mouse_sensitivity: float = 0.0025
var invert_y: bool = false
var master_volume: float = 1.0
var effects_volume: float = 1.0
var ambience_volume: float = 1.0
var voice_volume: float = 1.0
var ui_volume: float = 1.0
var fullscreen: bool = true
var vsync: bool = true
var max_fps: int = 120
var film_grain_enabled: bool = true
var chromatic_aberration_enabled: bool = true
var head_bob_enabled: bool = true
var reduced_flashes: bool = false
var subtitles_enabled: bool = true
var sound_captions_enabled: bool = false
var text_scale: float = 1.0

func to_dictionary() -> Dictionary:
    return {
        "schema_version": schema_version,
        "mouse_sensitivity": mouse_sensitivity,
        "invert_y": invert_y,
        "master_volume": master_volume,
        "effects_volume": effects_volume,
        "ambience_volume": ambience_volume,
        "voice_volume": voice_volume,
        "ui_volume": ui_volume,
        "fullscreen": fullscreen,
        "vsync": vsync,
        "max_fps": max_fps,
        "film_grain_enabled": film_grain_enabled,
        "chromatic_aberration_enabled": chromatic_aberration_enabled,
        "head_bob_enabled": head_bob_enabled,
        "reduced_flashes": reduced_flashes,
        "subtitles_enabled": subtitles_enabled,
        "sound_captions_enabled": sound_captions_enabled,
        "text_scale": text_scale,
    }

func apply_dictionary(data: Dictionary) -> void:
    schema_version = int(data.get("schema_version", SCHEMA_VERSION))
    mouse_sensitivity = clampf(float(data.get("mouse_sensitivity", mouse_sensitivity)), 0.0005, 0.02)
    invert_y = bool(data.get("invert_y", invert_y))
    master_volume = clampf(float(data.get("master_volume", master_volume)), 0.0, 1.0)
    effects_volume = clampf(float(data.get("effects_volume", effects_volume)), 0.0, 1.0)
    ambience_volume = clampf(float(data.get("ambience_volume", ambience_volume)), 0.0, 1.0)
    voice_volume = clampf(float(data.get("voice_volume", voice_volume)), 0.0, 1.0)
    ui_volume = clampf(float(data.get("ui_volume", ui_volume)), 0.0, 1.0)
    fullscreen = bool(data.get("fullscreen", fullscreen))
    vsync = bool(data.get("vsync", vsync))
    max_fps = clampi(int(data.get("max_fps", max_fps)), 30, 240)
    film_grain_enabled = bool(data.get("film_grain_enabled", film_grain_enabled))
    chromatic_aberration_enabled = bool(data.get("chromatic_aberration_enabled", chromatic_aberration_enabled))
    head_bob_enabled = bool(data.get("head_bob_enabled", head_bob_enabled))
    reduced_flashes = bool(data.get("reduced_flashes", reduced_flashes))
    subtitles_enabled = bool(data.get("subtitles_enabled", subtitles_enabled))
    sound_captions_enabled = bool(data.get("sound_captions_enabled", sound_captions_enabled))
    text_scale = clampf(float(data.get("text_scale", text_scale)), 0.8, 1.5)
```

- [ ] **Step 4: Run and confirm pass**

```bash
godot --headless --path . --script tests/unit/TestGameSettings.gd
```

Expected: exit `0`.

- [ ] **Step 5: Commit**

```bash
git add game/scripts/settings/GameSettings.gd tests/unit/TestGameSettings.gd
git commit -m "feat: define typed game settings"
```

### Task 8: Persist settings safely

**Files:**
- Create: `game/scripts/settings/SettingsStore.gd`
- Create: `tests/unit/TestSettingsStore.gd`

**Interfaces:**
- Produces: `SettingsStore.save(path: String, settings: GameSettings) -> Error`.
- Produces: `SettingsStore.load(path: String) -> GameSettings`.
- Invalid or missing files return default settings and do not throw.

- [ ] **Step 1: Write failing round-trip and corruption tests**

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")
const GameSettingsScript = preload("res://game/scripts/settings/GameSettings.gd")
const StoreScript = preload("res://game/scripts/settings/SettingsStore.gd")

func _init() -> void:
    var path := "user://test_settings.json"
    var settings := GameSettingsScript.new()
    settings.master_volume = 0.35

    var store := StoreScript.new()
    TestAssert.are_equal(store.save(path, settings), OK, "settings save must succeed")
    var loaded = store.load(path)
    TestAssert.are_equal(loaded.master_volume, 0.35, "saved volume must load")

    var file := FileAccess.open(path, FileAccess.WRITE)
    file.store_string("not-json")
    file.close()

    var recovered = store.load(path)
    TestAssert.are_equal(recovered.master_volume, 1.0, "corrupt file must return defaults")
    DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    quit(0)
```

- [ ] **Step 2: Run and confirm failure**

```bash
godot --headless --path . --script tests/unit/TestSettingsStore.gd
```

Expected: missing store failure.

- [ ] **Step 3: Implement `SettingsStore.gd`**

```gdscript
class_name SettingsStore
extends RefCounted

const GameSettingsScript = preload("res://game/scripts/settings/GameSettings.gd")

func save(path: String, settings: GameSettings) -> Error:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return FileAccess.get_open_error()

    file.store_string(JSON.stringify(settings.to_dictionary(), "  "))
    file.close()
    return OK

func load(path: String) -> GameSettings:
    var settings := GameSettingsScript.new()
    if not FileAccess.file_exists(path):
        return settings

    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return settings

    var text := file.get_as_text()
    file.close()
    var parsed: Variant = JSON.parse_string(text)
    if not (parsed is Dictionary):
        return settings

    settings.apply_dictionary(parsed as Dictionary)
    return settings
```

- [ ] **Step 4: Run and confirm pass**

```bash
godot --headless --path . --script tests/unit/TestSettingsStore.gd
```

Expected: exit `0`.

- [ ] **Step 5: Commit**

```bash
git add game/scripts/settings/SettingsStore.gd tests/unit/TestSettingsStore.gd
git commit -m "feat: persist game settings"
```

### Task 9: Add `SettingsManager` autoload

**Files:**
- Create: `game/scripts/settings/SettingsManager.gd`
- Modify: `project.godot`
- Create: `tests/smoke/TestSettingsManagerSmoke.gd`

**Interfaces:**
- Produces signal `settings_changed(settings: GameSettings)`.
- Produces: `get_settings() -> GameSettings`.
- Produces: `update_settings(next_settings: GameSettings) -> Error`.
- Produces: `reload() -> void`.
- Uses path `user://settings.json`.

- [ ] **Step 1: Write failing smoke test**

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var manager := root.get_node_or_null("SettingsManager")
    TestAssert.is_true(manager != null, "SettingsManager autoload must exist")
    TestAssert.is_true(manager.get_settings() != null, "SettingsManager must expose settings")
    quit(0)
```

- [ ] **Step 2: Implement manager**

```gdscript
class_name SettingsManager
extends Node

signal settings_changed(settings: GameSettings)

const SETTINGS_PATH: String = "user://settings.json"
const GameSettingsScript = preload("res://game/scripts/settings/GameSettings.gd")
const SettingsStoreScript = preload("res://game/scripts/settings/SettingsStore.gd")

var _settings: GameSettings
var _store: SettingsStore

func _ready() -> void:
    _store = SettingsStoreScript.new()
    reload()

func get_settings() -> GameSettings:
    return _settings

func update_settings(next_settings: GameSettings) -> Error:
    var error := _store.save(SETTINGS_PATH, next_settings)
    if error != OK:
        GameLog.error(GameLog.CATEGORY_GAME, "settings_save_failed error=%s" % error_string(error))
        return error

    _settings = next_settings
    _apply_runtime_settings()
    settings_changed.emit(_settings)
    return OK

func reload() -> void:
    _settings = _store.load(SETTINGS_PATH)
    _apply_runtime_settings()
    settings_changed.emit(_settings)

func _apply_runtime_settings() -> void:
    Engine.max_fps = _settings.max_fps
    DisplayServer.window_set_vsync_mode(
        DisplayServer.VSYNC_ENABLED if _settings.vsync else DisplayServer.VSYNC_DISABLED
    )
```

- [ ] **Step 3: Register autoload**

Add after `GameBootstrap`:

```ini
SettingsManager="*res://game/scripts/settings/SettingsManager.gd"
```

- [ ] **Step 4: Run tests**

```bash
godot --headless --path . --script tests/unit/TestGameSettings.gd
godot --headless --path . --script tests/unit/TestSettingsStore.gd
godot --headless --path . --script tests/smoke/TestSettingsManagerSmoke.gd
```

Expected: all exit `0`.

- [ ] **Step 5: Commit**

```bash
git add game/scripts/settings/SettingsManager.gd project.godot tests/smoke/TestSettingsManagerSmoke.gd
git commit -m "feat: add settings manager autoload"
```

### Task 10: Complete P1.2 documentation and PR

Follow the same documentation minimum as P1.1. Add changelog version `0.4.1`. State explicitly that P1.2 stores settings but does not yet add a user-facing settings menu.

Validation:

```bash
godot --headless --path . --script tests/unit/TestGameSettings.gd
godot --headless --path . --script tests/unit/TestSettingsStore.gd
godot --headless --path . --script tests/smoke/TestSettingsManagerSmoke.gd
godot --headless --path . --script tests/smoke/TestBootstrapSmoke.gd
```

Branch: `agent/p1-settings-foundation`.

---

## PR P1.3: Checkpoint Save Foundation

### Task 11: Define serializable `SaveSnapshot`

**Files:**
- Create: `game/scripts/save/SaveSnapshot.gd`
- Create: `tests/unit/TestSaveSnapshot.gd`

**Interfaces:**
- Produces schema version `1`.
- Fields: `game_version`, `checkpoint_id`, `chapter_id`, `beat_id`, `narrative_flags`, `completed_events`, `object_states`, `ending_conditions`.
- Produces: `to_dictionary() -> Dictionary`.
- Produces: `apply_dictionary(data: Dictionary) -> void`.

- [ ] **Step 1: Write failing round-trip test**

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")
const SnapshotScript = preload("res://game/scripts/save/SaveSnapshot.gd")

func _init() -> void:
    var snapshot := SnapshotScript.new()
    snapshot.checkpoint_id = &"act1_after_terminal"
    snapshot.narrative_flags[&"lamp_seen"] = true

    var copy := SnapshotScript.new()
    copy.apply_dictionary(snapshot.to_dictionary())

    TestAssert.are_equal(copy.checkpoint_id, &"act1_after_terminal", "checkpoint must round-trip")
    TestAssert.are_equal(copy.narrative_flags.get(&"lamp_seen"), true, "flags must round-trip")
    quit(0)
```

- [ ] **Step 2: Implement**

```gdscript
class_name SaveSnapshot
extends RefCounted

const SCHEMA_VERSION: int = 1

var schema_version: int = SCHEMA_VERSION
var game_version: String = "0.4.2"
var checkpoint_id: StringName = &""
var chapter_id: StringName = &""
var beat_id: StringName = &""
var narrative_flags: Dictionary = {}
var completed_events: Array[StringName] = []
var object_states: Dictionary = {}
var ending_conditions: Dictionary = {}

func to_dictionary() -> Dictionary:
    return {
        "schema_version": schema_version,
        "game_version": game_version,
        "checkpoint_id": String(checkpoint_id),
        "chapter_id": String(chapter_id),
        "beat_id": String(beat_id),
        "narrative_flags": narrative_flags.duplicate(true),
        "completed_events": completed_events.map(func(value: StringName) -> String: return String(value)),
        "object_states": object_states.duplicate(true),
        "ending_conditions": ending_conditions.duplicate(true),
    }

func apply_dictionary(data: Dictionary) -> void:
    schema_version = int(data.get("schema_version", SCHEMA_VERSION))
    game_version = String(data.get("game_version", game_version))
    checkpoint_id = StringName(data.get("checkpoint_id", ""))
    chapter_id = StringName(data.get("chapter_id", ""))
    beat_id = StringName(data.get("beat_id", ""))
    narrative_flags = Dictionary(data.get("narrative_flags", {})).duplicate(true)
    object_states = Dictionary(data.get("object_states", {})).duplicate(true)
    ending_conditions = Dictionary(data.get("ending_conditions", {})).duplicate(true)
    completed_events.clear()
    for value in Array(data.get("completed_events", [])):
        completed_events.append(StringName(value))
```

- [ ] **Step 3: Run and commit**

```bash
godot --headless --path . --script tests/unit/TestSaveSnapshot.gd
git add game/scripts/save/SaveSnapshot.gd tests/unit/TestSaveSnapshot.gd
git commit -m "feat: define checkpoint save snapshot"
```

Expected: test exits `0`.

### Task 12: Add primary and backup save persistence

**Files:**
- Create: `game/scripts/save/SaveStore.gd`
- Create: `tests/unit/TestSaveStore.gd`

**Interfaces:**
- Produces: `save(path: String, snapshot: SaveSnapshot) -> Error`.
- Produces: `load(path: String) -> SaveSnapshot` or `null`.
- Uses backup suffix `.bak`.
- A successful save copies the current primary to backup before replacement.

- [ ] **Step 1: Write failing test**

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")
const SnapshotScript = preload("res://game/scripts/save/SaveSnapshot.gd")
const StoreScript = preload("res://game/scripts/save/SaveStore.gd")

func _init() -> void:
    var path := "user://test_save.json"
    var store := StoreScript.new()

    var first := SnapshotScript.new()
    first.checkpoint_id = &"first"
    TestAssert.are_equal(store.save(path, first), OK, "first save must succeed")

    var second := SnapshotScript.new()
    second.checkpoint_id = &"second"
    TestAssert.are_equal(store.save(path, second), OK, "second save must succeed")

    var file := FileAccess.open(path, FileAccess.WRITE)
    file.store_string("corrupt")
    file.close()

    var recovered = store.load(path)
    TestAssert.is_true(recovered != null, "backup must recover corrupt primary")
    TestAssert.are_equal(recovered.checkpoint_id, &"first", "backup must contain previous snapshot")

    DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(path + ".bak"))
    quit(0)
```

- [ ] **Step 2: Implement `SaveStore.gd`**

```gdscript
class_name SaveStore
extends RefCounted

const SaveSnapshotScript = preload("res://game/scripts/save/SaveSnapshot.gd")

func save(path: String, snapshot: SaveSnapshot) -> Error:
    var backup_path := path + ".bak"
    if FileAccess.file_exists(path):
        var copy_error := _copy_file(path, backup_path)
        if copy_error != OK:
            return copy_error

    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return FileAccess.get_open_error()

    file.store_string(JSON.stringify(snapshot.to_dictionary(), "  "))
    file.close()
    return OK

func load(path: String) -> SaveSnapshot:
    var primary := _load_single(path)
    if primary != null:
        return primary
    return _load_single(path + ".bak")

func _load_single(path: String) -> SaveSnapshot:
    if not FileAccess.file_exists(path):
        return null

    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return null

    var parsed: Variant = JSON.parse_string(file.get_as_text())
    file.close()
    if not (parsed is Dictionary):
        return null

    var snapshot := SaveSnapshotScript.new()
    snapshot.apply_dictionary(parsed as Dictionary)
    return snapshot

func _copy_file(source_path: String, target_path: String) -> Error:
    var source := FileAccess.open(source_path, FileAccess.READ)
    if source == null:
        return FileAccess.get_open_error()

    var target := FileAccess.open(target_path, FileAccess.WRITE)
    if target == null:
        source.close()
        return FileAccess.get_open_error()

    target.store_buffer(source.get_buffer(source.get_length()))
    source.close()
    target.close()
    return OK
```

- [ ] **Step 3: Run and commit**

```bash
godot --headless --path . --script tests/unit/TestSaveStore.gd
git add game/scripts/save/SaveStore.gd tests/unit/TestSaveStore.gd
git commit -m "feat: add resilient checkpoint persistence"
```

Expected: test exits `0`.

### Task 13: Add `SaveGameManager` autoload

**Files:**
- Create: `game/scripts/save/SaveGameManager.gd`
- Modify: `project.godot`
- Create: `tests/smoke/TestSaveGameManagerSmoke.gd`

**Interfaces:**
- Produces signals `checkpoint_saved(checkpoint_id: StringName)` and `checkpoint_loaded(checkpoint_id: StringName)`.
- Produces: `save_checkpoint(snapshot: SaveSnapshot) -> Error`.
- Produces: `load_latest() -> SaveSnapshot`.
- Uses `user://autosave.json`.

- [ ] **Step 1: Implement manager**

```gdscript
class_name SaveGameManager
extends Node

signal checkpoint_saved(checkpoint_id: StringName)
signal checkpoint_loaded(checkpoint_id: StringName)

const SAVE_PATH: String = "user://autosave.json"
const SaveStoreScript = preload("res://game/scripts/save/SaveStore.gd")

var _store: SaveStore

func _ready() -> void:
    _store = SaveStoreScript.new()

func save_checkpoint(snapshot: SaveSnapshot) -> Error:
    var error := _store.save(SAVE_PATH, snapshot)
    if error == OK:
        GameLog.info(GameLog.CATEGORY_SAVE, "checkpoint_saved id=%s" % String(snapshot.checkpoint_id))
        checkpoint_saved.emit(snapshot.checkpoint_id)
    else:
        GameLog.error(GameLog.CATEGORY_SAVE, "checkpoint_save_failed error=%s" % error_string(error))
    return error

func load_latest() -> SaveSnapshot:
    var snapshot := _store.load(SAVE_PATH)
    if snapshot != null:
        GameLog.info(GameLog.CATEGORY_SAVE, "checkpoint_loaded id=%s" % String(snapshot.checkpoint_id))
        checkpoint_loaded.emit(snapshot.checkpoint_id)
    return snapshot
```

- [ ] **Step 2: Register autoload**

```ini
SaveGameManager="*res://game/scripts/save/SaveGameManager.gd"
```

- [ ] **Step 3: Write smoke test**

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")
const SnapshotScript = preload("res://game/scripts/save/SaveSnapshot.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var manager := root.get_node_or_null("SaveGameManager")
    TestAssert.is_true(manager != null, "SaveGameManager autoload must exist")

    var snapshot := SnapshotScript.new()
    snapshot.checkpoint_id = &"smoke"
    TestAssert.are_equal(manager.save_checkpoint(snapshot), OK, "autosave must succeed")
    TestAssert.are_equal(manager.load_latest().checkpoint_id, &"smoke", "latest checkpoint must load")

    DirAccess.remove_absolute(ProjectSettings.globalize_path("user://autosave.json"))
    DirAccess.remove_absolute(ProjectSettings.globalize_path("user://autosave.json.bak"))
    quit(0)
```

- [ ] **Step 4: Run and commit**

```bash
godot --headless --path . --script tests/unit/TestSaveSnapshot.gd
godot --headless --path . --script tests/unit/TestSaveStore.gd
godot --headless --path . --script tests/smoke/TestSaveGameManagerSmoke.gd
git add game/scripts/save/SaveGameManager.gd project.godot tests/smoke/TestSaveGameManagerSmoke.gd
git commit -m "feat: add checkpoint save manager"
```

Expected: all tests exit `0`.

### Task 14: Complete P1.3 documentation and PR

Use version `0.4.2`. State that the manager is foundational only: no chapter integration and no user-facing continue button are included yet.

Branch: `agent/p1-checkpoint-save-foundation`.

---

## PR P1.4: Headless Validation and CI

### Task 15: Add a unified test runner

**Files:**
- Create: `tests/TestRunner.gd`
- Create: `tests/run_all.gd`

**Interfaces:**
- Produces: `TestRunner.run(test_paths: PackedStringArray) -> int`.
- Returns `0` when all subprocess tests pass; non-zero otherwise.

- [ ] **Step 1: Implement runner**

```gdscript
class_name TestRunner
extends RefCounted

func run(test_paths: PackedStringArray) -> int:
    var failures: int = 0
    var executable := OS.get_executable_path()

    for test_path in test_paths:
        var output: Array = []
        var exit_code := OS.execute(
            executable,
            PackedStringArray(["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", test_path]),
            output,
            true
        )
        for line in output:
            print(line)
        if exit_code != 0:
            failures += 1
            push_error("Test failed: %s" % test_path)

    return failures
```

- [ ] **Step 2: Implement entry point**

```gdscript
extends SceneTree

const RunnerScript = preload("res://tests/TestRunner.gd")

const TESTS := PackedStringArray([
    "tests/unit/TestGameLog.gd",
    "tests/unit/TestLegacyProgressionAdapter.gd",
    "tests/unit/TestHorrorEventManager.gd",
    "tests/unit/TestGameSettings.gd",
    "tests/unit/TestSettingsStore.gd",
    "tests/unit/TestSaveSnapshot.gd",
    "tests/unit/TestSaveStore.gd",
    "tests/smoke/TestBootstrapSmoke.gd",
    "tests/smoke/TestSettingsManagerSmoke.gd",
    "tests/smoke/TestSaveGameManagerSmoke.gd",
])

func _init() -> void:
    var failures := RunnerScript.new().run(TESTS)
    quit(0 if failures == 0 else 1)
```

- [ ] **Step 3: Run all tests**

```bash
godot --headless --path . --script tests/run_all.gd
```

Expected: exit `0` and each listed test runs once.

- [ ] **Step 4: Commit**

```bash
git add tests/TestRunner.gd tests/run_all.gd
git commit -m "test: add unified headless test runner"
```

### Task 16: Add local validation script

**Files:**
- Create: `scripts/validate_project.sh`

- [ ] **Step 1: Create script**

```bash
#!/usr/bin/env bash
set -euo pipefail

GODOT_BIN="${GODOT_BIN:-godot}"

"$GODOT_BIN" --headless --path . --editor --quit
"$GODOT_BIN" --headless --path . --script tests/run_all.gd

echo "Project validation passed."
```

- [ ] **Step 2: Make executable and run**

```bash
chmod +x scripts/validate_project.sh
./scripts/validate_project.sh
```

Expected: final line `Project validation passed.`.

- [ ] **Step 3: Commit**

```bash
git add scripts/validate_project.sh
git commit -m "chore: add local project validation"
```

### Task 17: Add GitHub Actions import and test workflow

**Files:**
- Create: `.github/workflows/godot-ci.yml`
- Modify: `.gitignore`

- [ ] **Step 1: Create workflow**

```yaml
name: Godot CI

on:
  pull_request:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  validate:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    container:
      image: barichello/godot-ci:4.4
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Import project
        run: godot --headless --path . --editor --quit

      - name: Run tests
        run: godot --headless --path . --script tests/run_all.gd
```

Before merge, update the container tag to an available image matching Godot 4.7. If no 4.7 image exists, pin the latest compatible 4.x image and record the temporary mismatch in the PR. Do not leave an unpinned `latest` tag.

- [ ] **Step 2: Extend `.gitignore`**

```gitignore
# Test output
reports/
.junit/
```

- [ ] **Step 3: Validate YAML locally**

```bash
python - <<'PY'
from pathlib import Path
import yaml
with Path('.github/workflows/godot-ci.yml').open() as f:
    yaml.safe_load(f)
print('workflow yaml parsed')
PY
```

Expected: `workflow yaml parsed`.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/godot-ci.yml .gitignore
git commit -m "ci: validate Godot project and tests"
```

### Task 18: Complete P1.4 documentation and PR

Use version `0.4.3`. Record the exact pinned Godot CI image and any version mismatch. Branch: `agent/p1-headless-ci`.

---

## PR P1.5: Versioning and Windows Export Baseline

### Task 19: Add build metadata

**Files:**
- Create: `game/scripts/core/BuildInfo.gd`
- Create: `tests/unit/TestBuildInfo.gd`
- Modify: `project.godot`

**Interfaces:**
- Produces constants `VERSION`, `CHANNEL`, `DISPLAY_VERSION`.

- [ ] **Step 1: Write test**

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")
const BuildInfo = preload("res://game/scripts/core/BuildInfo.gd")

func _init() -> void:
    TestAssert.are_equal(BuildInfo.VERSION, "0.4.4", "version must match project metadata")
    TestAssert.are_equal(BuildInfo.CHANNEL, "development", "P1.5 channel must be development")
    TestAssert.are_equal(BuildInfo.DISPLAY_VERSION, "0.4.4-development", "display version must be stable")
    quit(0)
```

- [ ] **Step 2: Implement**

```gdscript
class_name BuildInfo
extends RefCounted

const VERSION: String = "0.4.4"
const CHANNEL: String = "development"
const DISPLAY_VERSION: String = VERSION + "-" + CHANNEL
```

- [ ] **Step 3: Add project metadata**

Under `[application]` add:

```ini
config/version="0.4.4"
config/channel="development"
```

- [ ] **Step 4: Run and commit**

```bash
godot --headless --path . --script tests/unit/TestBuildInfo.gd
git add game/scripts/core/BuildInfo.gd tests/unit/TestBuildInfo.gd project.godot
git commit -m "feat: add build version metadata"
```

### Task 20: Add Windows development export preset

**Files:**
- Create: `export_presets.cfg`
- Create: `scripts/build_windows.sh`

- [ ] **Step 1: Create export preset**

```ini
[preset.0]

name="Windows Development"
platform="Windows Desktop"
runnable=true
advanced_options=false
dedicated_server=false
custom_features="development"
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="builds/windows/AI-Routine-Last-Commit.exe"
script_export_mode=2

[preset.0.options]

binary_format/embed_pck=true
texture_format/s3tc_bptc=true
texture_format/etc2_astc=false
texture_format/no_bptc_fallbacks=true
codesign/enable=false
```

- [ ] **Step 2: Create build script**

```bash
#!/usr/bin/env bash
set -euo pipefail

GODOT_BIN="${GODOT_BIN:-godot}"
mkdir -p builds/windows
"$GODOT_BIN" --headless --path . --export-debug "Windows Development" builds/windows/AI-Routine-Last-Commit.exe

echo "Windows development build created."
```

- [ ] **Step 3: Make executable**

```bash
chmod +x scripts/build_windows.sh
```

- [ ] **Step 4: Validate preset parsing**

```bash
godot --headless --path . --editor --quit
```

Expected: exit `0`; no export preset parse errors.

- [ ] **Step 5: Build when export templates are installed**

```bash
./scripts/build_windows.sh
```

Expected: `builds/windows/AI-Routine-Last-Commit.exe` exists. If export templates are unavailable locally, record that exact blocker and verify the build in CI before marking the task complete.

- [ ] **Step 6: Commit**

```bash
git add export_presets.cfg scripts/build_windows.sh
git commit -m "build: add Windows development export"
```

### Task 21: Add manual Windows artifact build to CI

**Files:**
- Modify: `.github/workflows/godot-ci.yml`

- [ ] **Step 1: Add build job**

Append:

```yaml
  windows-development-build:
    if: github.event_name == 'workflow_dispatch'
    runs-on: ubuntu-latest
    timeout-minutes: 20
    container:
      image: <same-pinned-godot-ci-image-as-validate-job>
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Build Windows development executable
        run: |
          mkdir -p builds/windows
          godot --headless --path . --export-debug "Windows Development" builds/windows/AI-Routine-Last-Commit.exe

      - name: Upload Windows build
        uses: actions/upload-artifact@v4
        with:
          name: ai-routine-windows-development
          path: builds/windows/
```

Replace the placeholder with the exact pinned image already selected in P1.4 before committing.

- [ ] **Step 2: Validate workflow YAML and tests**

```bash
python - <<'PY'
from pathlib import Path
import yaml
with Path('.github/workflows/godot-ci.yml').open() as f:
    yaml.safe_load(f)
print('workflow yaml parsed')
PY
./scripts/validate_project.sh
```

Expected: YAML parses and project validation passes.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/godot-ci.yml
git commit -m "ci: build Windows development artifact"
```

### Task 22: Complete P1.5 documentation and PR

Use version `0.4.4`. Update `docs/EXPORT_GUIDE.md` with the exact local and CI commands. State that signing, Steam SDK, installer creation and release publishing remain outside P1.

Branch: `agent/p1-windows-export-baseline`.

---

## Final P1 Verification

- [ ] Run the complete validation script:

```bash
./scripts/validate_project.sh
```

Expected: exit `0` and final line `Project validation passed.`.

- [ ] Run the current prototype manually in Godot 4.7+ and verify this exact regression route:

```text
стикер → терминал → лампа → дверь → Smart Speaker → терминал → HUD objective glitch
```

Expected:

- no progression blocker;
- no duplicate one-shot event;
- no errors in Godot Output;
- `LegacyProgressionAdapter` observes existing event IDs;
- bootstrap health report remains fully true.

- [ ] Verify settings persistence across restart.
- [ ] Verify a checkpoint save loads from primary.
- [ ] Corrupt primary autosave and verify backup recovery.
- [ ] Trigger GitHub Actions `workflow_dispatch` and download the Windows development artifact.
- [ ] Launch the exported executable outside Godot Editor.
- [ ] Confirm all P1 documentation reflects actual implementation.

## Self-Review Results

- Spec coverage: P1 bootstrap, logging, legacy coexistence, settings, checkpoint saves, tests, CI, versioning and Windows export are each mapped to a dedicated PR.
- Deliberate exclusions: UI menus, apartment art rebuild, narrative Resources, `NarrativeDirector`, async `EventSequenceRunner`, localization content and gameplay migration remain P2+.
- Placeholder scan: no `TBD` or generic “implement later” steps remain. The CI image selection is an explicit execution-time compatibility check because a Godot 4.7 container tag must be verified when the task is executed.
- Type consistency: `GameSettings`, `SaveSnapshot`, `SettingsStore`, `SaveStore`, `SettingsManager` and `SaveGameManager` signatures are consistent across tasks.
- Regression safety: every new service is additive; legacy managers remain registered and gameplay behavior is preserved.
