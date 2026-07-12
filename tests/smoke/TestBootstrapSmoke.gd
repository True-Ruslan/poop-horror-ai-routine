extends SceneTree

const TestAssert = preload("res://tests/TestAssert.gd")

func _init() -> void:
    await process_frame

    TestAssert.is_true(root.has_node("GameState"), "GameState autoload must exist")
    TestAssert.is_true(root.has_node("ObjectiveManager"), "ObjectiveManager autoload must exist")
    TestAssert.is_true(root.has_node("HorrorEventManager"), "HorrorEventManager autoload must exist")
    TestAssert.is_true(root.has_node("GameLog"), "GameLog autoload must exist")
    TestAssert.is_true(root.has_node("LegacyProgressionAdapter"), "LegacyProgressionAdapter autoload must exist")
    TestAssert.is_true(root.has_node("GameBootstrap"), "GameBootstrap autoload must exist")

    var report: Dictionary = root.get_node("GameBootstrap").get_health_report()
    for service_name in report:
        TestAssert.is_true(bool(report[service_name]), "%s must be healthy" % String(service_name))
    quit(0)
