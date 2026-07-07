extends StaticBody3D

@export var interaction_text: String = "E — прочитать записку"
@export var note_title: String = "Записка"
@export_multiline var note_body: String = "Текст записки."
@export var objective_after_read: String = "Проверить дверь в конце коридора."
@export var horror_event_id_after_read: String = "note_read_first_time"

var was_read: bool = false

func get_interaction_text() -> String:
    return interaction_text

func interact(_actor: Node = null) -> void:
    GameState.show_message(note_title, note_body)

    if not was_read:
        was_read = true
        if objective_after_read.strip_edges() != "":
            ObjectiveManager.complete_current_objective(objective_after_read)
        if horror_event_id_after_read.strip_edges() != "":
            HorrorEventManager.play_once(horror_event_id_after_read, _play_note_horror_event)

func _play_note_horror_event() -> void:
    # Минимальный пример scripted event.
    # В реальной игре здесь можно мигнуть светом, включить звук, закрыть дверь или изменить текст на доске.
    print("Horror event triggered: ", horror_event_id_after_read)
