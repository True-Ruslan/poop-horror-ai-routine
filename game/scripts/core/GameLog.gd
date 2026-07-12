class_name GameLogService
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
