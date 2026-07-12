extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")
const ManagerScript = preload("res://game/scripts/core/HorrorEventManager.gd")

func _init() -> void:
    var manager := ManagerScript.new()
    var callback_count := 0
    var started_count := 0
    var finished_count := 0

    manager.horror_event_started.connect(func(_event_id: String) -> void: started_count += 1)
    manager.horror_event_finished.connect(func(_event_id: String) -> void: finished_count += 1)
    manager.play_once("test_event", func() -> void: callback_count += 1)
    manager.play_once("test_event", func() -> void: callback_count += 1)

    TestAssert.are_equal(callback_count, 1, "callback must run once")
    TestAssert.are_equal(started_count, 1, "started signal must emit once")
    TestAssert.are_equal(finished_count, 1, "finished signal must emit once")
    TestAssert.is_true(manager.has_played("test_event"), "played event must be recorded")
    quit(0)
