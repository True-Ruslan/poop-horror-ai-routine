class_name GameBootstrapService
extends Node

const REQUIRED_SERVICES := PackedStringArray([
    "GameState",
    "ObjectiveManager",
    "HorrorEventManager",
    "GameLog",
    "LegacyProgressionAdapter",
])

var _health_report: Dictionary = {}

func _ready() -> void:
    _refresh_health_report()
    if is_healthy():
        GameLog.info(GameLog.CATEGORY_GAME, "bootstrap_ready services=%d" % _health_report.size())
    else:
        GameLog.error(GameLog.CATEGORY_GAME, "bootstrap_failed report=%s" % str(_health_report))

func get_health_report() -> Dictionary:
    _refresh_health_report()
    return _health_report.duplicate(true)

func is_healthy() -> bool:
    _refresh_health_report()
    for service_name in _health_report:
        if not bool(_health_report[service_name]):
            return false
    return true

func _refresh_health_report() -> void:
    _health_report.clear()
    var scene_tree := get_tree()
    if scene_tree == null:
        for service_name in REQUIRED_SERVICES:
            _health_report[StringName(service_name)] = false
        return

    var root := scene_tree.root
    for service_name in REQUIRED_SERVICES:
        _health_report[StringName(service_name)] = root.has_node(service_name)
