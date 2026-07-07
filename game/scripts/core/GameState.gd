extends Node

signal interaction_prompt_changed(text: String)
signal message_requested(title: String, body: String)
signal message_closed
signal flashlight_battery_changed(value: float)
signal game_paused_changed(is_paused: bool)

var is_reading_message: bool = false

func _ready() -> void:
    _ensure_default_input_map()

func set_interaction_prompt(text: String) -> void:
    interaction_prompt_changed.emit(text)

func show_message(title: String, body: String) -> void:
    is_reading_message = true
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    message_requested.emit(title, body)

func close_message() -> void:
    is_reading_message = false
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    message_closed.emit()

func set_flashlight_battery(value: float) -> void:
    flashlight_battery_changed.emit(clampf(value, 0.0, 100.0))

func toggle_pause() -> void:
    var next_state := not get_tree().paused
    get_tree().paused = next_state
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if next_state else Input.MOUSE_MODE_CAPTURED)
    game_paused_changed.emit(next_state)

func _ensure_default_input_map() -> void:
    _add_key_action("move_forward", KEY_W)
    _add_key_action("move_backward", KEY_S)
    _add_key_action("move_left", KEY_A)
    _add_key_action("move_right", KEY_D)
    _add_key_action("sprint", KEY_SHIFT)
    _add_key_action("crouch", KEY_CTRL)
    _add_key_action("interact", KEY_E)
    _add_key_action("flashlight_toggle", KEY_F)
    _add_key_action("close_message", KEY_ESCAPE)

func _add_key_action(action_name: StringName, keycode: Key) -> void:
    if not InputMap.has_action(action_name):
        InputMap.add_action(action_name)

    for event in InputMap.action_get_events(action_name):
        if event is InputEventKey and event.physical_keycode == keycode:
            return

    var key_event := InputEventKey.new()
    key_event.physical_keycode = keycode
    InputMap.action_add_event(action_name, key_event)
