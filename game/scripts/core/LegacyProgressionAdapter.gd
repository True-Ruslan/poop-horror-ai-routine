class_name LegacyProgressionAdapterService
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
    if GameLog != null:
        GameLog.info(GameLog.CATEGORY_NARRATIVE, "legacy_event_observed id=%s" % String(event_id))

func has_observed(event_id: StringName) -> bool:
    return _observed_events.has(event_id)

func reset_observed() -> void:
    _observed_events.clear()

func _on_horror_event_started(event_id: String) -> void:
    observe_legacy_event(StringName(event_id))
