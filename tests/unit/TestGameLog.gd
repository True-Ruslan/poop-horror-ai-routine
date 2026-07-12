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
