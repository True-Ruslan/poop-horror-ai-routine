extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")
const ManagerScript = preload("res://game/scripts/core/HorrorEventManager.gd")

func _init() -> void:
    var manager := ManagerScript.new()
    var counters := {
        "callback": 0,
        "started": 0,
        "finished": 0,
    }

    manager.horror_event_started.connect(func(_event_id: String) -> void: counters["started"] += 1)
    manager.horror_event_finished.connect(func(_event_id: String) -> void: counters["finished"] += 1)
    manager.play_once("test_event", func() -> void: counters["callback"] += 1)
    manager.play_once("test_event", func() -> void: counters["callback"] += 1)

    TestAssert.are_equal(counters["callback"], 1, "callback must run once")
    TestAssert.are_equal(counters["started"], 1, "started signal must emit once")
    TestAssert.are_equal(counters["finished"], 1, "finished signal must emit once")
    TestAssert.is_true(manager.has_played("test_event"), "played event must be recorded")
    quit(0)
