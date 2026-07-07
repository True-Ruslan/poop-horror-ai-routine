extends SpotLight3D

@export var max_battery: float = 100.0
@export var drain_per_second: float = 4.0
@export var recharge_per_second: float = 0.0
@export var starts_enabled: bool = true
@export var auto_turn_off_when_empty: bool = true

var battery: float = 100.0

func _ready() -> void:
    battery = max_battery
    visible = starts_enabled
    GameState.set_flashlight_battery(_battery_percent())

func _unhandled_input(event: InputEvent) -> void:
    if GameState.is_reading_message or get_tree().paused:
        return

    if event.is_action_pressed("flashlight_toggle"):
        if battery > 0.0:
            visible = not visible

func _process(delta: float) -> void:
    if visible:
        battery = maxf(0.0, battery - drain_per_second * delta)
        if battery <= 0.0 and auto_turn_off_when_empty:
            visible = false
    elif recharge_per_second > 0.0:
        battery = minf(max_battery, battery + recharge_per_second * delta)

    GameState.set_flashlight_battery(_battery_percent())

func recharge(amount: float) -> void:
    battery = minf(max_battery, battery + amount)
    GameState.set_flashlight_battery(_battery_percent())

func _battery_percent() -> float:
    if max_battery <= 0.0:
        return 0.0
    return battery / max_battery * 100.0
