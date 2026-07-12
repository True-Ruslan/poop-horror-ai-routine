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
