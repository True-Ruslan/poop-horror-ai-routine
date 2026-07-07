extends RayCast3D

@export var prompt_when_empty: String = ""

var current_target: Object = null

func _physics_process(_delta: float) -> void:
    if GameState.is_reading_message or get_tree().paused:
        GameState.set_interaction_prompt("")
        return

    force_raycast_update()

    if not is_colliding():
        current_target = null
        GameState.set_interaction_prompt(prompt_when_empty)
        return

    var collider := get_collider()
    current_target = collider

    if collider != null and collider.has_method("get_interaction_text"):
        GameState.set_interaction_prompt(collider.get_interaction_text())
    elif collider != null and collider.has_method("interact"):
        GameState.set_interaction_prompt("E — взаимодействовать")
    else:
        GameState.set_interaction_prompt(prompt_when_empty)

func _unhandled_input(event: InputEvent) -> void:
    if GameState.is_reading_message or get_tree().paused:
        return

    if event.is_action_pressed("interact") and current_target != null:
        if current_target.has_method("interact"):
            current_target.interact(owner)
