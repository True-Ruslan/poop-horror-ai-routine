# P1 Foundation Rebuild Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add production bootstrap, logging, settings persistence, resilient checkpoint storage, headless validation, CI, version metadata and a Windows development export without changing the current playable route.

**Architecture:** New production services are introduced beside the legacy prototype autoloads. `GameBootstrap` validates startup, `GameLog` centralizes diagnostics, `LegacyProgressionAdapter` mirrors current events, and later PRs add settings and save services. Legacy gameplay remains authoritative throughout P1.

**Tech Stack:** Godot 4.7+, typed GDScript, JSON persistence, Godot headless CLI, GitHub Actions, `barichello/godot-ci:4.7`, Windows Desktop export.

## Global Constraints

- Keep `GameState`, `ObjectiveManager` and `HorrorEventManager` active.
- Preserve the route `стикер → терминал → лампа → дверь → Smart Speaker → терминал → HUD objective glitch`.
- No apartment rebuild, new assets, menu UI, localization content or narrative migration in P1.
- No third-party gameplay framework.
- Use typed public APIs and `StringName` for identifiers.
- Each PR updates `docs/TASKS.md`, `docs/PROJECT_STATE.md`, `docs/CHANGELOG.md`; architecture PRs also update `docs/DECISIONS.md` and `docs/AGENT_HANDOFF.md`.
- Every PR must pass its exact headless checks before being marked complete.

---

# PR P1.1 — Bootstrap and Logging

Branch: `agent/p1-bootstrap-logging`

## Task 1: Add test assertions

**Files**
- Create `tests/TestAssert.gd`

**Produces**
- `TestAssert.is_true(condition: bool, message: String) -> void`
- `TestAssert.are_equal(actual: Variant, expected: Variant, message: String) -> void`

- [ ] Create `tests/TestAssert.gd`:

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
```

- [ ] Parse the project:

```bash
godot --headless --path . --editor --quit
```

Expected: exit `0`.

- [ ] Commit:

```bash
git add tests/TestAssert.gd
git commit -m "test: add dependency-free assertions"
```

## Task 2: Add `GameLog`

**Files**
- Create `game/scripts/core/GameLog.gd`
- Create `tests/unit/TestGameLog.gd`

**Produces**
- `GameLog.Level`
- `set_min_level(level: Level) -> void`
- `should_emit(level: Level) -> bool`
- `debug/info/warning/error(category: StringName, message: String) -> void`

- [ ] Write `tests/unit/TestGameLog.gd`:

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")
const GameLogScript = preload("res://game/scripts/core/GameLog.gd")

func _init() -> void:
    var logger := GameLogScript.new()
    logger.set_min_level(GameLogScript.Level.WARNING)
    TestAssert.is_true(not logger.should_emit(GameLogScript.Level.DEBUG), "debug filtered")
    TestAssert.is_true(not logger.should_emit(GameLogScript.Level.INFO), "info filtered")
    TestAssert.is_true(logger.should_emit(GameLogScript.Level.WARNING), "warning emitted")
    TestAssert.is_true(logger.should_emit(GameLogScript.Level.ERROR), "error emitted")
    quit(0)
```

- [ ] Confirm failure:

```bash
godot --headless --path . --script tests/unit/TestGameLog.gd
```

Expected: missing `GameLog.gd`.

- [ ] Create `game/scripts/core/GameLog.gd`:

```gdscript
class_name GameLog
extends Node

enum Level { DEBUG, INFO, WARNING, ERROR }

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
    if level == Level.ERROR:
        push_error(line)
    elif level == Level.WARNING:
        push_warning(line)
    else:
        print(line)

func _level_name(level: Level) -> String:
    return Level.keys()[level]
```

- [ ] Run test:

```bash
godot --headless --path . --script tests/unit/TestGameLog.gd
```

Expected: exit `0`.

- [ ] Commit:

```bash
git add game/scripts/core/GameLog.gd tests/unit/TestGameLog.gd
git commit -m "feat: add structured game logging"
```

## Task 3: Add `LegacyProgressionAdapter`

**Files**
- Create `game/scripts/core/LegacyProgressionAdapter.gd`
- Create `tests/unit/TestLegacyProgressionAdapter.gd`

**Produces**
- signal `legacy_event_observed(event_id: StringName)`
- `observe_legacy_event(event_id: StringName) -> void`
- `has_observed(event_id: StringName) -> bool`
- `reset_observed() -> void`

- [ ] Write failing test:

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")
const AdapterScript = preload("res://game/scripts/core/LegacyProgressionAdapter.gd")

func _init() -> void:
    var adapter := AdapterScript.new()
    adapter.observe_legacy_event(&"terminal_first_ai_reply")
    TestAssert.is_true(adapter.has_observed(&"terminal_first_ai_reply"), "event mirrored")
    adapter.reset_observed()
    TestAssert.is_true(not adapter.has_observed(&"terminal_first_ai_reply"), "reset clears events")
    quit(0)
```

- [ ] Confirm failure:

```bash
godot --headless --path . --script tests/unit/TestLegacyProgressionAdapter.gd
```

- [ ] Create adapter:

```gdscript
class_name LegacyProgressionAdapter
extends Node

signal legacy_event_observed(event_id: StringName)

var _observed_events: Dictionary = {}

func _ready() -> void:
    if not HorrorEventManager.horror_event_started.is_connected(_on_horror_event_started):
        HorrorEventManager.horror_event_started.connect(_on_horror_event_started)

func observe_legacy_event(event_id: StringName) -> void:
    if _observed_events.has(event_id):
        return
    _observed_events[event_id] = true
    legacy_event_observed.emit(event_id)
    var logger := get_node_or_null("/root/GameLog")
    if logger != null:
        logger.info(logger.CATEGORY_NARRATIVE, "legacy_event_observed id=%s" % String(event_id))

func has_observed(event_id: StringName) -> bool:
    return _observed_events.has(event_id)

func reset_observed() -> void:
    _observed_events.clear()

func _on_horror_event_started(event_id: String) -> void:
    observe_legacy_event(StringName(event_id))
```

- [ ] Run test and commit:

```bash
godot --headless --path . --script tests/unit/TestLegacyProgressionAdapter.gd
git add game/scripts/core/LegacyProgressionAdapter.gd tests/unit/TestLegacyProgressionAdapter.gd
git commit -m "feat: mirror legacy progression events"
```

Expected: exit `0`.

## Task 4: Add `GameBootstrap`

**Files**
- Create `game/scripts/core/GameBootstrap.gd`
- Create `tests/smoke/TestBootstrapSmoke.gd`
- Modify `project.godot`

**Produces**
- signal `bootstrap_completed`
- `is_ready() -> bool`
- `get_health_report() -> Dictionary`

- [ ] Create smoke test:

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var bootstrap := root.get_node_or_null("GameBootstrap")
    TestAssert.is_true(bootstrap != null, "bootstrap autoload exists")
    TestAssert.is_true(bootstrap.is_ready(), "bootstrap healthy")
    var report: Dictionary = bootstrap.get_health_report()
    TestAssert.are_equal(report.get("game_state"), true, "GameState healthy")
    TestAssert.are_equal(report.get("objective_manager"), true, "ObjectiveManager healthy")
    TestAssert.are_equal(report.get("horror_event_manager"), true, "HorrorEventManager healthy")
    TestAssert.are_equal(report.get("legacy_progression_adapter"), true, "adapter healthy")
    quit(0)
```

- [ ] Create bootstrap:

```gdscript
class_name GameBootstrap
extends Node

signal bootstrap_completed

var _ready_state: bool = false
var _health_report: Dictionary = {}

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _health_report = {
        "game_state": get_node_or_null("/root/GameState") != null,
        "objective_manager": get_node_or_null("/root/ObjectiveManager") != null,
        "horror_event_manager": get_node_or_null("/root/HorrorEventManager") != null,
        "legacy_progression_adapter": get_node_or_null("/root/LegacyProgressionAdapter") != null,
    }
    _ready_state = not _health_report.values().has(false)
    if _ready_state:
        GameLog.info(GameLog.CATEGORY_GAME, "bootstrap_completed")
        bootstrap_completed.emit()
    else:
        GameLog.error(GameLog.CATEGORY_GAME, "bootstrap_failed report=%s" % str(_health_report))

func is_ready() -> bool:
    return _ready_state

func get_health_report() -> Dictionary:
    return _health_report.duplicate(true)
```

- [ ] Replace `[autoload]` in `project.godot` with:

```ini
[autoload]

GameState="*res://game/scripts/core/GameState.gd"
ObjectiveManager="*res://game/scripts/core/ObjectiveManager.gd"
HorrorEventManager="*res://game/scripts/core/HorrorEventManager.gd"
GameLog="*res://game/scripts/core/GameLog.gd"
LegacyProgressionAdapter="*res://game/scripts/core/LegacyProgressionAdapter.gd"
GameBootstrap="*res://game/scripts/core/GameBootstrap.gd"
```

- [ ] Run smoke test:

```bash
godot --headless --path . --script tests/smoke/TestBootstrapSmoke.gd
```

Expected: exit `0`.

- [ ] Commit:

```bash
git add game/scripts/core/GameBootstrap.gd tests/smoke/TestBootstrapSmoke.gd project.godot
git commit -m "feat: add production bootstrap"
```

## Task 5: Add structured diagnostics to legacy events

**Files**
- Modify `game/scripts/core/HorrorEventManager.gd`
- Create `tests/unit/TestHorrorEventManager.gd`

- [ ] Create regression test:

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")
const ManagerScript = preload("res://game/scripts/core/HorrorEventManager.gd")

func _init() -> void:
    var manager := ManagerScript.new()
    var count := 0
    var callback := func() -> void: count += 1
    manager.play_once("event_a", callback)
    manager.play_once("event_a", callback)
    TestAssert.are_equal(count, 1, "one-shot behavior preserved")
    quit(0)
```

- [ ] Run before changing code:

```bash
godot --headless --path . --script tests/unit/TestHorrorEventManager.gd
```

Expected: exit `0`.

- [ ] Add these calls without changing control flow:

```gdscript
GameLog.debug(GameLog.CATEGORY_NARRATIVE, "legacy_event_skipped id=%s" % event_id)
GameLog.info(GameLog.CATEGORY_NARRATIVE, "legacy_event_started id=%s" % event_id)
GameLog.info(GameLog.CATEGORY_NARRATIVE, "legacy_event_finished id=%s" % event_id)
GameLog.debug(GameLog.CATEGORY_NARRATIVE, "legacy_events_reset")
```

Placement:
- skipped log immediately before the early return;
- started log after `played_events[event_id] = true`;
- finished log after `horror_event_finished.emit(event_id)`;
- reset log after `played_events.clear()`.

- [ ] Run regression tests:

```bash
godot --headless --path . --script tests/unit/TestHorrorEventManager.gd
godot --headless --path . --script tests/smoke/TestBootstrapSmoke.gd
```

Expected: both exit `0`.

- [ ] Commit:

```bash
git add game/scripts/core/HorrorEventManager.gd tests/unit/TestHorrorEventManager.gd
git commit -m "refactor: log legacy horror events"
```

## Task 6: Close P1.1

- [ ] Update required documentation.
- [ ] Add changelog version `0.4.0`.
- [ ] Run:

```bash
godot --headless --path . --script tests/unit/TestGameLog.gd
godot --headless --path . --script tests/unit/TestLegacyProgressionAdapter.gd
godot --headless --path . --script tests/unit/TestHorrorEventManager.gd
godot --headless --path . --script tests/smoke/TestBootstrapSmoke.gd
godot --headless --path . --editor --quit
```

Expected: all exit `0`.

- [ ] Manually run the existing route in Godot 4.7+.
- [ ] Open draft PR titled `Add production bootstrap and structured logging`.

---

# PR P1.2 — Settings Foundation

Branch: `agent/p1-settings-foundation`

## Task 7: Add typed settings data

**Files**
- Create `game/scripts/settings/GameSettings.gd`
- Create `tests/unit/TestGameSettings.gd`

- [ ] Create test:

```gdscript
extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")
const SettingsScript = preload("res://game/scripts/settings/GameSettings.gd")

func _init() -> void:
    var original := SettingsScript.new()
    original.mouse_sensitivity = 0.004
    original.subtitles_enabled = false
    var copy := SettingsScript.new()
    copy.apply_dictionary(original.to_dictionary())
    TestAssert.are_equal(copy.mouse_sensitivity, 0.004, "sensitivity round-trip")
    TestAssert.are_equal(copy.subtitles_enabled, false, "subtitles round-trip")
    quit(0)
```

- [ ] Create `GameSettings.gd` with fields and defaults:

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

- [ ] Run and commit:

```bash
godot --headless --path . --script tests/unit/TestGameSettings.gd
git add game/scripts/settings/GameSettings.gd tests/unit/TestGameSettings.gd
git commit -m "feat: define typed game settings"
```

## Task 8: Add settings persistence and manager

**Files**
- Create `game/scripts/settings/SettingsStore.gd`
- Create `game/scripts/settings/SettingsManager.gd`
- Create `tests/unit/TestSettingsStore.gd`
- Create `tests/smoke/TestSettingsManagerSmoke.gd`
- Modify `project.godot`

**Produces**
- `SettingsStore.save(path: String, settings: GameSettings) -> Error`
- `SettingsStore.load(path: String) -> GameSettings`
- `SettingsManager.get_settings() -> GameSettings`
- `SettingsManager.update_settings(next_settings: GameSettings) -> Error`

- [ ] Implement `SettingsStore.gd`:

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
    var parsed := JSON.parse_string(file.get_as_text())
    file.close()
    if parsed is Dictionary:
        settings.apply_dictionary(parsed)
    return settings
```

- [ ] Implement `SettingsManager.gd`:

```gdscript
class_name SettingsManager
extends Node

signal settings_changed(settings: GameSettings)

const SETTINGS_PATH := "user://settings.json"
const StoreScript = preload("res://game/scripts/settings/SettingsStore.gd")

var _store: SettingsStore
var _settings: GameSettings

func _ready() -> void:
    _store = StoreScript.new()
    reload()

func get_settings() -> GameSettings:
    return _settings

func update_settings(next_settings: GameSettings) -> Error:
    var result := _store.save(SETTINGS_PATH, next_settings)
    if result != OK:
        GameLog.error(GameLog.CATEGORY_GAME, "settings_save_failed error=%s" % error_string(result))
        return result
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
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if _settings.vsync else DisplayServer.VSYNC_DISABLED)
```

- [ ] Register:

```ini
SettingsManager="*res://game/scripts/settings/SettingsManager.gd"
```

- [ ] Tests must cover missing file, round-trip and invalid JSON returning defaults.
- [ ] Run all P1.1 tests plus settings tests.
- [ ] Update docs, add version `0.4.1`, and open draft PR `Add persistent game settings foundation`.

---

# PR P1.3 — Checkpoint Save Foundation

Branch: `agent/p1-checkpoint-save-foundation`

## Task 9: Add `SaveSnapshot`

**Files**
- Create `game/scripts/save/SaveSnapshot.gd`
- Create `tests/unit/TestSaveSnapshot.gd`

- [ ] Implement:

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
    var serialized_events: Array[String] = []
    for event_id in completed_events:
        serialized_events.append(String(event_id))
    return {
        "schema_version": schema_version,
        "game_version": game_version,
        "checkpoint_id": String(checkpoint_id),
        "chapter_id": String(chapter_id),
        "beat_id": String(beat_id),
        "narrative_flags": narrative_flags.duplicate(true),
        "completed_events": serialized_events,
        "object_states": object_states.duplicate(true),
        "ending_conditions": ending_conditions.duplicate(true),
    }

func apply_dictionary(data: Dictionary) -> void:
    schema_version = int(data.get("schema_version", SCHEMA_VERSION))
    game_version = String(data.get("game_version", game_version))
    checkpoint_id = StringName(data.get("checkpoint_id", ""))
    chapter_id = StringName(data.get("chapter_id", ""))
    beat_id = StringName(data.get("beat_id", ""))
    narrative_flags = data.get("narrative_flags", {}).duplicate(true)
    object_states = data.get("object_states", {}).duplicate(true)
    ending_conditions = data.get("ending_conditions", {}).duplicate(true)
    completed_events.clear()
    for value in data.get("completed_events", []):
        completed_events.append(StringName(value))
```

- [ ] Test all fields round-trip and commit.

## Task 10: Add resilient `SaveStore` and manager

**Files**
- Create `game/scripts/save/SaveStore.gd`
- Create `game/scripts/save/SaveGameManager.gd`
- Create `tests/unit/TestSaveStore.gd`
- Create `tests/smoke/TestSaveGameManagerSmoke.gd`
- Modify `project.godot`

**Produces**
- primary `user://autosave.json`
- backup `user://autosave.json.bak`
- `save_checkpoint(snapshot: SaveSnapshot) -> Error`
- `load_latest() -> SaveSnapshot`

- [ ] Implement `SaveStore.gd` with these exact behaviors:
  - before replacing an existing primary, copy it byte-for-byte to `.bak`;
  - parse primary first;
  - on missing/invalid primary, parse backup;
  - return `null` when neither is valid;
  - never overwrite a corrupt file during load.

- [ ] Implement manager:

```gdscript
class_name SaveGameManager
extends Node

signal checkpoint_saved(checkpoint_id: StringName)
signal checkpoint_loaded(checkpoint_id: StringName)

const SAVE_PATH := "user://autosave.json"
const StoreScript = preload("res://game/scripts/save/SaveStore.gd")

var _store: SaveStore

func _ready() -> void:
    _store = StoreScript.new()

func save_checkpoint(snapshot: SaveSnapshot) -> Error:
    var result := _store.save(SAVE_PATH, snapshot)
    if result == OK:
        GameLog.info(GameLog.CATEGORY_SAVE, "checkpoint_saved id=%s" % String(snapshot.checkpoint_id))
        checkpoint_saved.emit(snapshot.checkpoint_id)
    else:
        GameLog.error(GameLog.CATEGORY_SAVE, "checkpoint_save_failed error=%s" % error_string(result))
    return result

func load_latest() -> SaveSnapshot:
    var snapshot := _store.load(SAVE_PATH)
    if snapshot != null:
        GameLog.info(GameLog.CATEGORY_SAVE, "checkpoint_loaded id=%s" % String(snapshot.checkpoint_id))
        checkpoint_loaded.emit(snapshot.checkpoint_id)
    return snapshot
```

- [ ] Register:

```ini
SaveGameManager="*res://game/scripts/save/SaveGameManager.gd"
```

- [ ] Tests must verify first save, second save creates backup, corrupt primary recovers previous snapshot, both invalid returns `null`.
- [ ] Run all prior tests.
- [ ] Update docs, add version `0.4.2`, and open draft PR `Add resilient checkpoint save foundation`.

---

# PR P1.4 — Headless Validation and CI

Branch: `agent/p1-headless-ci`

## Task 11: Add unified runner and local validation

**Files**
- Create `tests/TestRunner.gd`
- Create `tests/run_all.gd`
- Create `scripts/validate_project.sh`

- [ ] `tests/run_all.gd` must execute every unit and smoke script in a child Godot process and return non-zero if any child fails.
- [ ] Create local script:

```bash
#!/usr/bin/env bash
set -euo pipefail
GODOT_BIN="${GODOT_BIN:-godot}"
"$GODOT_BIN" --headless --path . --editor --quit
"$GODOT_BIN" --headless --path . --script tests/run_all.gd
echo "Project validation passed."
```

- [ ] Run:

```bash
chmod +x scripts/validate_project.sh
./scripts/validate_project.sh
```

Expected: `Project validation passed.`.

## Task 12: Add CI

**Files**
- Create `.github/workflows/godot-ci.yml`
- Modify `.gitignore`

- [ ] Create workflow:

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
      image: barichello/godot-ci:4.7
    steps:
      - uses: actions/checkout@v4
      - name: Import project
        run: godot --headless --path . --editor --quit
      - name: Run tests
        run: godot --headless --path . --script tests/run_all.gd
```

- [ ] Add to `.gitignore`:

```gitignore
reports/
.junit/
```

- [ ] Push branch and verify GitHub Actions actually starts with the pinned image.
- [ ] If `barichello/godot-ci:4.7` cannot be pulled, stop P1.4, record the failure, select a verified exact 4.7-compatible image in a new ADR, and update both jobs before continuing. Do not use `latest`.
- [ ] Update docs, add version `0.4.3`, and open draft PR `Add headless validation and Godot CI`.

---

# PR P1.5 — Versioning and Windows Export Baseline

Branch: `agent/p1-windows-export-baseline`

## Task 13: Add build metadata

**Files**
- Create `game/scripts/core/BuildInfo.gd`
- Create `tests/unit/TestBuildInfo.gd`
- Modify `project.godot`

- [ ] Create:

```gdscript
class_name BuildInfo
extends RefCounted

const VERSION: String = "0.4.4"
const CHANNEL: String = "development"
const DISPLAY_VERSION: String = VERSION + "-" + CHANNEL
```

- [ ] Add under `[application]`:

```ini
config/version="0.4.4"
config/channel="development"
```

- [ ] Test constants against project metadata and commit.

## Task 14: Add Windows export

**Files**
- Create `export_presets.cfg`
- Create `scripts/build_windows.sh`

- [ ] Create preset:

```ini
[preset.0]

name="Windows Development"
platform="Windows Desktop"
runnable=true
advanced_options=false
custom_features="development"
export_filter="all_resources"
export_path="builds/windows/AI-Routine-Last-Commit.exe"
script_export_mode=2

[preset.0.options]

binary_format/embed_pck=true
texture_format/s3tc_bptc=true
texture_format/etc2_astc=false
codesign/enable=false
```

- [ ] Create script:

```bash
#!/usr/bin/env bash
set -euo pipefail
GODOT_BIN="${GODOT_BIN:-godot}"
mkdir -p builds/windows
"$GODOT_BIN" --headless --path . --export-debug "Windows Development" builds/windows/AI-Routine-Last-Commit.exe
echo "Windows development build created."
```

- [ ] Run with export templates installed and confirm the `.exe` exists.

## Task 15: Add manual CI artifact build

**Files**
- Modify `.github/workflows/godot-ci.yml`

- [ ] Add:

```yaml
  windows-development-build:
    if: github.event_name == 'workflow_dispatch'
    runs-on: ubuntu-latest
    timeout-minutes: 20
    container:
      image: barichello/godot-ci:4.7
    steps:
      - uses: actions/checkout@v4
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

- [ ] Trigger `workflow_dispatch`, download artifact and launch it outside Godot Editor.
- [ ] Update `docs/EXPORT_GUIDE.md`, required project docs and changelog `0.4.4`.
- [ ] Open draft PR `Add Windows development export baseline`.

---

# Final P1 Verification

- [ ] `./scripts/validate_project.sh` exits `0`.
- [ ] Current prototype route completes without a progression blocker.
- [ ] `LegacyProgressionAdapter` observes existing event IDs.
- [ ] Settings survive restart and invalid JSON falls back to defaults.
- [ ] Primary checkpoint loads.
- [ ] Corrupt primary checkpoint recovers from backup.
- [ ] GitHub CI passes on a pull request.
- [ ] Manual workflow produces a Windows artifact.
- [ ] Exported executable launches outside Godot Editor.
- [ ] No placeholder models, menus or narrative changes are claimed as part of P1.

## Self-Review

- P1 is split into five independently reviewable PRs.
- API names and paths are consistent across tasks.
- CI uses one explicit pinned image string in both jobs.
- No `TBD`, angle-bracket placeholder or unpinned image remains.
- P2+ systems are explicitly excluded.
