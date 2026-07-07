extends Node3D

@export var desk_lamp_path: NodePath = NodePath("DeskLamp")
@export var lamp_blink_event_id: String = "terminal_first_ai_reply"
@export var objective_after_lamp_event: String = "Проверить, почему лампа щёлкнула сама."
@export var blink_count: int = 3
@export var blink_interval_seconds: float = 0.18
@export var delay_before_blink_seconds: float = 0.7

var _lamp_event_started: bool = false

func _ready() -> void:
    HorrorEventManager.horror_event_started.connect(_on_horror_event_started)

func _on_horror_event_started(event_id: String) -> void:
    if event_id != lamp_blink_event_id or _lamp_event_started:
        return

    _lamp_event_started = true
    _blink_desk_lamp.call_deferred()

func _blink_desk_lamp() -> void:
    await get_tree().create_timer(delay_before_blink_seconds).timeout

    var lamp := get_node_or_null(desk_lamp_path)
    if not lamp is Light3D:
        return

    var light := lamp as Light3D
    var original_visible := light.visible
    var original_energy := light.light_energy

    for _i in range(maxi(1, blink_count)):
        light.visible = false
        await get_tree().create_timer(blink_interval_seconds).timeout
        light.visible = true
        light.light_energy = original_energy * 1.35
        await get_tree().create_timer(blink_interval_seconds).timeout
        light.light_energy = original_energy

    light.visible = original_visible
    light.light_energy = original_energy

    if objective_after_lamp_event.strip_edges() != "":
        ObjectiveManager.complete_current_objective(objective_after_lamp_event)
