extends StaticBody3D

@export var interaction_text: String = "E — щёлкнуть выключатель"
@export var target_light_path: NodePath
@export var objective_after_use: String = "Свет работает. Теперь нужно найти выход."

var was_used: bool = false

func get_interaction_text() -> String:
    return interaction_text

func interact(_actor: Node = null) -> void:
    var target := get_node_or_null(target_light_path)
    if target is Light3D:
        target.visible = not target.visible
        GameState.show_message("Выключатель", "Лампы коротко гудят. Свет изменился.")
    else:
        GameState.show_message("Выключатель", "Где-то щёлкнуло, но ничего не произошло.")

    if not was_used:
        was_used = true
        if objective_after_use.strip_edges() != "":
            ObjectiveManager.complete_current_objective(objective_after_use)
