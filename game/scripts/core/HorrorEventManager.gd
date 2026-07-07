extends Node

signal horror_event_started(event_id: String)
signal horror_event_finished(event_id: String)

var played_events: Dictionary = {}

func play_once(event_id: String, callback: Callable = Callable()) -> void:
    if played_events.has(event_id):
        return

    played_events[event_id] = true
    horror_event_started.emit(event_id)

    if callback.is_valid():
        callback.call()

    horror_event_finished.emit(event_id)

func has_played(event_id: String) -> bool:
    return played_events.has(event_id)

func reset_events() -> void:
    played_events.clear()
