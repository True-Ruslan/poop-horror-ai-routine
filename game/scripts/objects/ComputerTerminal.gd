extends StaticBody3D

@export var interaction_text: String = "E — открыть терминал"
@export var terminal_title: String = "Терминал"
@export_multiline var terminal_body: String = "Сборка завершилась с ошибкой."
@export var objective_after_first_use: String = "Проверить квартиру."
@export var horror_event_id_after_first_use: String = "terminal_first_use"

var was_used: bool = false

func get_interaction_text() -> String:
    return interaction_text

func interact(_actor: Node = null) -> void:
    GameState.show_message(terminal_title, terminal_body)

    if not was_used:
        was_used = true
        if objective_after_first_use.strip_edges() != "":
            ObjectiveManager.complete_current_objective(objective_after_first_use)
        if horror_event_id_after_first_use.strip_edges() != "":
            HorrorEventManager.play_once(horror_event_id_after_first_use, _play_terminal_horror_event)

func _play_terminal_horror_event() -> void:
    # Первый безопасный scripted event для вертикального среза.
    # На следующей итерации здесь можно мигнуть светом, включить звук, изменить экран или запереть дверь.
    print("Horror event triggered: ", horror_event_id_after_first_use)
