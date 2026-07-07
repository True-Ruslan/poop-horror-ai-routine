extends Node

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    ObjectiveManager.set_objective("Запустить вечернюю сборку.")

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("close_message"):
        if GameState.is_reading_message:
            GameState.close_message()
        else:
            GameState.toggle_pause()
